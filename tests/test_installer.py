"""Run: python -m unittest discover -s tests -v. Never touches real user settings."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest import mock

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("vesper_installer", ROOT / "scripts/install_vesper.py")
installer = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = installer
spec.loader.exec_module(installer)


class JSONCTests(unittest.TestCase):
    def test_preset_is_exact_complete_reference(self):
        reference = installer.JSONC((ROOT / "settings/replica-completa.jsonc").read_text(encoding="utf-8")).parse().value
        self.assertEqual(installer.PRESET, reference)

    def test_shell_contains_exact_python_installer(self):
        shell = (ROOT / "scripts/install-vesper.sh").read_text(encoding="utf-8")
        embedded = shell.split("<<'VESPER_PYTHON_EMBEDDED'\n", 1)[1].rsplit("\nVESPER_PYTHON_EMBEDDED", 1)[0]
        self.assertEqual(embedded, (ROOT / "scripts/install_vesper.py").read_text(encoding="utf-8").rstrip("\n"))

    def test_preserves_work_settings_comments_and_crlf(self):
        source = ('{\r\n  // corporativo\r\n  "[python]": {"editor.formatOnType": true},\r\n'
                  '  "editor.defaultFormatter": "corp.formatter", // preserve\r\n'
                  '  "example": "literal // and ,}",\r\n}\r\n')
        result, before, after = installer.edit_settings(source, installer.PRESET)
        self.assertIn('// corporativo\r\n', result)
        self.assertIn('"editor.defaultFormatter": "corp.formatter", // preserve\r\n', result)
        self.assertIn('"example": "literal // and ,}",\r\n', result)
        self.assertTrue(after['[python]']['editor.formatOnType'])
        self.assertEqual(after['editor.defaultFormatter'], before['editor.defaultFormatter'])
        self.assertNotIn('\n', result.replace('\r\n', ''))

    def test_inserts_comma_before_trailing_comment(self):
        source = '{\n  "old": 1 // keep\n}\n'
        result, _, after = installer.edit_settings(source, {'new': True})
        self.assertIn('"old": 1, // keep', result)
        self.assertEqual(after, {'old': 1, 'new': True})

    def test_inline_and_trailing_comma_fixtures(self):
        for source in ['{}', '{ /* keep */ }', '{"a":1}', '{"a":1,}', '{"a":{"x":true},"s":"// ,}"}']:
            with self.subTest(source=source):
                result, _, after = installer.edit_settings(source, {'a': {'other': 4}, 'new': {'nested': True}})
                self.assertEqual(installer.JSONC(result).parse().value, after)
                if '/* keep */' in source:
                    self.assertIn('/* keep */', result)

    def test_personal_rules_and_other_theme_customizations_preserved(self):
        personal = {'name': 'Personal', 'scope': 'keyword', 'settings': {'fontStyle': 'italic'}}
        previous = {'editor.tokenColorCustomizations': {'[Other]': {'comments': '#999999'},
                    '[Vesper]': {'textMateRules': [personal]}}}
        result, _, after = installer.edit_settings(json.dumps(previous), installer.PRESET)
        rules = after['editor.tokenColorCustomizations']['[Vesper]']['textMateRules']
        self.assertEqual(rules[0], personal)
        self.assertEqual(after['editor.tokenColorCustomizations']['[Other]'], {'comments': '#999999'})
        second, _, _ = installer.edit_settings(result, installer.PRESET)
        self.assertEqual(second, result)

    def test_named_setup_rules_updated_instead_of_duplicated(self):
        name = installer.PRESET['editor.tokenColorCustomizations']['[Vesper]']['textMateRules'][0]['name']
        previous = {'editor.tokenColorCustomizations': {'[Vesper]': {'textMateRules': [{'name': name, 'settings': {'foreground': '#FFFFFF'}}]}}}
        result, _, after = installer.edit_settings(json.dumps(previous), installer.PRESET)
        rules = after['editor.tokenColorCustomizations']['[Vesper]']['textMateRules']
        self.assertEqual(sum(rule.get('name') == name for rule in rules), 1)
        self.assertEqual(rules[0]['settings']['foreground'], '#D0D0D0')
        self.assertEqual(installer.edit_settings(result, installer.PRESET)[0], result)

    def test_malformed_duplicate_and_nonobject_rejected(self):
        for source in ['{"x":1,"x":2}', '{"a":', '{"a":NaN}', '{"a":1', '[]', 'null', '{/*unfinished', '{}{}', '{"a":[1,,2]}']:
            with self.subTest(source=source), self.assertRaises(ValueError):
                installer.edit_settings(source, installer.PRESET)


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='vesper-test-')
        self.path = Path(self.temporary.name) / 'settings.json'
        self.original = b'\xef\xbb\xbf{\r\n  // untouched\r\n  "[python]":{"editor.formatOnType":true},\r\n  "corp":"keep"\r\n}\r\n'
        self.path.write_bytes(self.original)

    def tearDown(self):
        self.temporary.cleanup()

    def invoke(self, *arguments):
        with contextlib.redirect_stdout(io.StringIO()):
            return installer.main(list(arguments))

    def test_dry_run_has_no_writes_backups_or_cli_calls(self):
        with mock.patch.object(installer, 'run_code') as cli:
            self.invoke('--settings-path', str(self.path), '--skip-extensions', '--dry-run')
        cli.assert_not_called()
        self.assertEqual(self.path.read_bytes(), self.original)
        self.assertEqual(len(list(self.path.parent.iterdir())), 1)

    def test_apply_keeps_bom_exact_backup_and_is_idempotent(self):
        self.invoke('--settings-path', str(self.path), '--skip-extensions')
        after = self.path.read_bytes()
        self.assertTrue(after.startswith(b'\xef\xbb\xbf'))
        backups = list(self.path.parent.glob('settings.before-vesper-*.jsonc'))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_bytes(), self.original)
        data = installer.JSONC(after.decode('utf-8-sig')).parse().value
        self.assertEqual(data['corp'], 'keep')
        self.assertTrue(data['[python]']['editor.formatOnType'])
        self.invoke('--settings-path', str(self.path), '--skip-extensions')
        self.assertEqual(self.path.read_bytes(), after)
        self.assertEqual(list(self.path.parent.glob('settings.before-vesper-*.jsonc')), backups)

    def test_concurrent_change_not_overwritten(self):
        original, candidate, _ = installer.prepare_settings(self.path, installer.PRESET)
        self.path.write_text('{"updated":true}', encoding='utf-8')
        with self.assertRaises(ValueError):
            installer.write_settings(self.path, original, candidate)
        self.assertEqual(self.path.read_text(encoding='utf-8'), '{"updated":true}')

    def test_atomic_replace_failure_keeps_original_and_backup(self):
        original, candidate, _ = installer.prepare_settings(self.path, installer.PRESET)
        with contextlib.redirect_stdout(io.StringIO()), mock.patch.object(installer.os, 'replace', side_effect=PermissionError('locked')):
            with self.assertRaises(PermissionError):
                installer.write_settings(self.path, original, candidate)
        self.assertEqual(self.path.read_bytes(), self.original)
        self.assertEqual(len(list(self.path.parent.glob('settings.before-vesper-*.jsonc'))), 1)
        self.assertFalse(list(self.path.parent.glob('.vesper-*.tmp')))

    def test_invalid_settings_no_backup_or_write(self):
        self.path.write_text('{"x":1,"x":2}', encoding='utf-8')
        with self.assertRaises(ValueError):
            self.invoke('--settings-path', str(self.path), '--skip-extensions')
        self.assertEqual(len(list(self.path.parent.iterdir())), 1)

    def test_custom_path_requires_skip_extensions(self):
        with self.assertRaises(ValueError):
            self.invoke('--settings-path', str(self.path))

    def test_consolas_and_preserved_terminal_font(self):
        self.path.write_text('{"terminal.integrated.fontFamily":"Corporate Mono"}', encoding='utf-8')
        self.invoke('--settings-path', str(self.path), '--skip-extensions', '--consolas', '--keep-terminal-font')
        data = installer.JSONC(self.path.read_text(encoding='utf-8')).parse().value
        self.assertEqual(data['terminal.integrated.fontFamily'], 'Corporate Mono')
        self.assertEqual(data['editor.fontFamily'], 'Consolas, monospace')
        self.assertFalse(data['editor.fontLigatures'])

    def test_new_settings_file(self):
        target = self.path.parent / 'new-user' / 'settings.json'
        original, candidate, _ = installer.prepare_settings(target, installer.PRESET)
        self.assertIsNone(original)
        self.assertIsNone(installer.write_settings(target, original, candidate))
        self.assertEqual(installer.JSONC(target.read_text(encoding='utf-8')).parse().value, installer.PRESET)

    def test_extension_failure_keeps_settings_original(self):
        with mock.patch.object(installer, 'settings_target', return_value=self.path), \
             mock.patch.object(installer, 'find_code', return_value=Path('fake-code.cmd')), \
             mock.patch.object(installer, 'ensure_extensions', side_effect=ValueError('offline')):
            with self.assertRaises(ValueError):
                self.invoke()
        self.assertEqual(self.path.read_bytes(), self.original)
        self.assertEqual(len(list(self.path.parent.iterdir())), 1)

    def test_existing_extensions_are_not_reinstalled(self):
        output = '\n'.join(installer.APPEARANCE_EXTENSIONS)
        with mock.patch.object(installer, 'run_code', return_value=output) as cli, contextlib.redirect_stdout(io.StringIO()):
            installer.ensure_extensions(Path('fake-code.cmd'), installer.APPEARANCE_EXTENSIONS)
        self.assertEqual(cli.call_count, 2)
        for call in cli.call_args_list:
            self.assertEqual(call.args[1:], ('--list-extensions',))

    def test_missing_extension_install_and_verification(self):
        outputs = ['raunofreiberg.vesper', 'installed', '\n'.join(installer.APPEARANCE_EXTENSIONS)]
        with mock.patch.object(installer, 'run_code', side_effect=outputs) as cli, contextlib.redirect_stdout(io.StringIO()):
            installer.ensure_extensions(Path('fake-code.cmd'), installer.APPEARANCE_EXTENSIONS)
        self.assertEqual(cli.call_args_list[1].args[1:], ('--install-extension', 'miguelsolorio.symbols'))

    def test_unverified_install_aborts(self):
        with mock.patch.object(installer, 'run_code', return_value=''), contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaises(ValueError):
                installer.ensure_extensions(Path('fake-code.cmd'), installer.APPEARANCE_EXTENSIONS)

    def test_cli_rejects_arbitrary_arguments(self):
        with mock.patch.object(installer.subprocess, 'run') as process:
            with self.assertRaises(ValueError):
                installer.run_code(Path('fake-code.cmd'), '--install-extension', 'x&whoami')
        process.assert_not_called()


if __name__ == '__main__':
    unittest.main()
