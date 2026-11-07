#!/usr/bin/env sh
# Autossuficiente: o instalador Python completo esta embutido abaixo.
# Execute com: bash install-vesper.sh --dry-run
# Requer Python 3.9+ do Windows. Nao usa PowerShell nem instala bibliotecas.
set -eu

run_vesper_python() {
    if command -v py >/dev/null 2>&1 && py -3 -c 'import os,sys; sys.exit(0 if os.name == "nt" and sys.version_info >= (3,9) else 1)' >/dev/null 2>&1; then
        py -3 - "$@"
    elif command -v python >/dev/null 2>&1 && python -c 'import os,sys; sys.exit(0 if os.name == "nt" and sys.version_info >= (3,9) else 1)' >/dev/null 2>&1; then
        python - "$@"
    elif command -v python3 >/dev/null 2>&1 && python3 -c 'import os,sys; sys.exit(0 if os.name == "nt" and sys.version_info >= (3,9) else 1)' >/dev/null 2>&1; then
        python3 - "$@"
    else
        printf '%s\n' 'ERRO: Python 3.9+ do Windows nao encontrado. Teste py -3 --version ou python --version.' >&2
        printf '%s\n' 'O launcher .sh tambem precisa de Python. Nenhuma configuracao foi alterada.' >&2
        return 1
    fi
}

run_vesper_python "$@" <<'VESPER_PYTHON_EMBEDDED'
#!/usr/bin/env python3
"""Apply the self-contained Vesper preset. Python 3.9+, standard library only.

Windows VS Code Stable, default profile. Custom settings files require
--skip-extensions so extension installation cannot target a different profile.
No font binaries, downloaded scripts, administrator privileges or policy changes.
"""

import argparse
import copy
import datetime
import json
import os
from pathlib import Path
import re
import shutil
import stat
import subprocess
import sys
import tempfile
import uuid
from dataclasses import dataclass, field


PRESET = json.loads(r'''{
  "workbench.colorTheme": "Vesper",
  "window.autoDetectColorScheme": false,
  "workbench.iconTheme": "symbols",
  "editor.fontFamily": "'Cascadia Code NF', Consolas, monospace",
  "editor.fontLigatures": true,
  "editor.fontSize": 14,
  "editor.lineHeight": 22,
  "editor.fontWeight": "400",
  "editor.letterSpacing": 0,
  "terminal.integrated.fontFamily": "'Cascadia Code NF', Consolas, monospace",
  "editor.minimap.enabled": false,
  "breadcrumbs.enabled": false,
  "editor.renderWhitespace": "selection",
  "editor.guides.indentation": true,
  "editor.guides.highlightActiveIndentation": true,
  "workbench.activityBar.location": "default",
  "editor.stickyScroll.enabled": true,
  "workbench.editor.showTabs": "multiple",
  "workbench.colorCustomizations": {
    "[Vesper]": {
      "editor.background": "#101010",
      "sideBar.background": "#101010",
      "sideBarSectionHeader.background": "#101010",
      "activityBar.background": "#101010",
      "editorGroupHeader.tabsBackground": "#101010",
      "tab.inactiveBackground": "#101010",
      "titleBar.activeBackground": "#101010",
      "titleBar.inactiveBackground": "#101010",
      "statusBar.background": "#101010",
      "statusBar.noFolderBackground": "#101010",
      "tab.border": "#00000000",
      "sideBar.border": "#00000000",
      "editorGroup.border": "#00000000",
      "titleBar.border": "#00000000",
      "statusBar.border": "#00000000",
      "editor.findMatchBackground": "#FFC79926",
      "editor.findMatchBorder": "#FFC79980",
      "editor.findMatchHighlightBackground": "#FFC79914",
      "editor.selectionBackground": "#FFFFFF25",
      "editor.selectionHighlightBackground": "#FFFFFF14",
      "editor.wordHighlightBackground": "#FFFFFF0F",
      "editor.wordHighlightStrongBackground": "#FFC79918",
      "statusBar.debuggingBackground": "#241C17",
      "statusBar.debuggingForeground": "#FFC799",
      "statusBarItem.remoteBackground": "#1C1C1C",
      "statusBarItem.remoteForeground": "#FFC799",
      "editor.foreground": "#D0D0D0",
      "editorLineNumber.foreground": "#707070",
      "editorLineNumber.activeForeground": "#B0B0B0",
      "tab.activeBackground": "#161616",
      "input.background": "#1C1C1C",
      "editorWidget.background": "#101010",
      "editorHoverWidget.background": "#161616",
      "editorHoverWidget.border": "#282828",
      "editorGroupHeader.tabsBorder": "#00000000",
      "diffEditor.insertedLineBackground": "#99FFE422",
      "diffEditor.insertedTextBackground": "#99FFE422",
      "diffEditor.removedLineBackground": "#FF808022",
      "diffEditor.removedTextBackground": "#FF808022"
    }
  },
  "symbols.hidesExplorerArrows": false,
  "symbols.folders.associations": {
    "src": "folder",
    "tests": "folder",
    "data": "folder",
    "notebooks": "folder",
    ".venv": "folder"
  },
  "editor.tokenColorCustomizations": {
    "[Vesper]": {
      "comments": "#858585",
      "textMateRules": [
        {
          "name": "Vesper variáveis no tom escolhido",
          "scope": [
            "variable",
            "meta.block variable.other",
            "support.other.variable",
            "string constant.other.placeholder"
          ],
          "settings": {
            "foreground": "#D0D0D0"
          }
        },
        {
          "name": "Vesper delimitadores de comentário legíveis",
          "scope": "punctuation.definition.comment",
          "settings": {
            "foreground": "#858585"
          }
        }
      ]
    }
  },
  "[python]": {
    "editor.semanticHighlighting.enabled": true
  },
  "editor.semanticTokenColorCustomizations": {
    "[Vesper]": {
      "rules": {
        "variable:python": "#D0D0D0",
        "parameter:python": "#D0D0D0",
        "property:python": "#D0D0D0",
        "variable.readonly:python": "#FFC799",
        "function:python": "#FFC799",
        "method:python": "#FFC799",
        "decorator:python": "#FFC799",
        "class:python": "#E0E0E0",
        "type:python": "#E0E0E0"
      }
    }
  }
}''')
APPEARANCE_EXTENSIONS = ("raunofreiberg.vesper", "miguelsolorio.symbols")
PYTHON_EXTENSIONS = (
    "ms-python.python", "ms-python.vscode-pylance", "ms-python.debugpy"
)


@dataclass
class Node:
    kind: str
    start: int
    end: int
    value: object
    members: dict = field(default_factory=dict)
    close: int = 0
    trailing: bool = False


class JSONC:
    """Parse comments/trailing commas and retain spans for surgical edits."""

    def __init__(self, source):
        self.source = source
        self.index = 0
        self.decoder = json.JSONDecoder(parse_constant=self.invalid_constant)

    @staticmethod
    def invalid_constant(value):
        raise ValueError("Constante JSON invalida: " + value)

    def peek(self):
        return self.source[self.index:self.index + 1]

    def whitespace(self):
        while self.index < len(self.source):
            if self.source[self.index].isspace():
                self.index += 1
            elif self.source.startswith("//", self.index):
                end = self.source.find("\n", self.index)
                self.index = len(self.source) if end < 0 else end + 1
            elif self.source.startswith("/*", self.index):
                end = self.source.find("*/", self.index + 2)
                if end < 0:
                    raise ValueError("Comentario JSONC sem fechamento")
                self.index = end + 2
            else:
                break

    def value(self):
        self.whitespace()
        start = self.index
        if self.peek() == "{":
            self.index += 1
            members, values = {}, {}
            trailing = False
            while True:
                self.whitespace()
                if self.peek() == "}":
                    close = self.index
                    self.index += 1
                    return Node("object", start, self.index, values,
                                members, close, trailing)
                if self.peek() != '"':
                    raise ValueError("Chave JSONC ausente ou invalida")
                key, end = self.decoder.raw_decode(self.source, self.index)
                if key in members:
                    raise ValueError("Chave JSONC duplicada; corrija antes de aplicar")
                self.index = end
                self.whitespace()
                if self.peek() != ":":
                    raise ValueError("Falta ':' no objeto JSONC")
                self.index += 1
                node = self.value()
                members[key], values[key] = node, node.value
                self.whitespace()
                if self.peek() == ",":
                    self.index += 1
                    self.whitespace()
                    trailing = self.peek() == "}"
                    continue
                if self.peek() != "}":
                    raise ValueError("Falta virgula ou '}' no objeto JSONC")
        if self.peek() == "[":
            self.index += 1
            values = []
            while True:
                self.whitespace()
                if self.peek() == "]":
                    self.index += 1
                    return Node("array", start, self.index, values)
                values.append(self.value().value)
                self.whitespace()
                if self.peek() == ",":
                    self.index += 1
                    continue
                if self.peek() != "]":
                    raise ValueError("Falta virgula ou ']' na lista JSONC")
        value, end = self.decoder.raw_decode(self.source, self.index)
        self.index = end
        return Node("scalar", start, end, value)

    def parse(self):
        node = self.value()
        self.whitespace()
        if self.index != len(self.source):
            raise ValueError("Conteudo extra depois do JSONC")
        return node


def merge(previous, patch):
    if isinstance(previous, dict) and isinstance(patch, dict):
        result = dict(previous)
        for key, value in patch.items():
            result[key] = merge(result[key], value) if key in result else value
        return result
    if isinstance(previous, list) and isinstance(patch, list):
        # Keep personal TextMate rules; update the setup's named rules in place.
        result = list(previous)
        for value in patch:
            match = next((i for i, old in enumerate(result)
                          if isinstance(old, dict) and isinstance(value, dict)
                          and value.get("name") and old.get("name") == value["name"]), None)
            if match is not None:
                result[match] = value
            elif value not in result:
                result.append(value)
        return result
    return patch


def edit_settings(source, preset):
    tree = JSONC(source).parse()
    if tree.kind != "object":
        raise ValueError("settings.json precisa conter um objeto JSONC")
    expected = merge(tree.value, preset)
    newline = "\r\n" if "\r\n" in source else "\n"
    indents = re.findall(r'(?m)^([ \t]+)"', source)
    unit = min(indents, key=len) if indents else "    "
    edits = []

    def line_indent(position):
        before = source[source.rfind("\n", 0, position) + 1:position]
        return re.match(r"[ \t]*", before)[0]

    def encoded(value, indent):
        return json.dumps(value, ensure_ascii=False, indent=unit).replace(
            "\n", newline + indent)

    def walk(node, patch):
        new = []
        for key, value in patch.items():
            old = node.members.get(key)
            if old is None:
                new.append((key, value))
            elif old.kind == "object" and isinstance(value, dict):
                walk(old, value)
            else:
                target = merge(old.value, value)
                if old.value != target:
                    edits.append((old.start, old.end,
                                  encoded(target, line_indent(old.start))))
        if new:
            if node.members and not node.trailing:
                last = list(node.members.values())[-1]
                edits.append((last.end, last.end, ","))
            start = source.rfind("\n", 0, node.close) + 1
            prefix = source[start:node.close]
            if not prefix.strip():
                position, base, lead = start, prefix, ""
            else:
                position, base, lead = node.close, line_indent(node.start), newline
            indent = base + unit
            content = lead + ("," + newline).join(
                indent + json.dumps(key, ensure_ascii=False) + ": " + encoded(value, indent)
                for key, value in new) + newline
            edits.append((position, position, content))

    walk(tree, preset)
    grouped = {}
    for start, end, replacement in edits:
        key = start, end
        if key in grouped and start != end:
            raise ValueError("Edicoes de JSONC sobrepostas")
        grouped[key] = grouped.get(key, "") + replacement
    result = source
    for (start, end), replacement in sorted(grouped.items(), reverse=True):
        result = result[:start] + replacement + result[end:]
    if JSONC(result).parse().value != expected:
        raise ValueError("A validacao do JSONC mesclado falhou; nada foi gravado")
    return result, tree.value, expected


def read_snapshot(path):
    try:
        return path.read_bytes()
    except FileNotFoundError:
        return None


def prepare_settings(path, preset):
    original = read_snapshot(path)
    source = original.decode("utf-8-sig") if original is not None else "{}\n"
    if not source.strip():
        source = "{}\n"
    updated, before, after = edit_settings(source, preset)
    bom = b"\xef\xbb\xbf" if original and original.startswith(b"\xef\xbb\xbf") else b""
    candidate = bom + updated.encode("utf-8")
    changed = [key for key in preset if key not in before or before[key] != after[key]]
    return original, candidate, changed


def write_settings(path, original, candidate):
    """Backup exact original bytes, recheck snapshot, then replace atomically."""
    if read_snapshot(path) != original:
        raise ValueError("settings.json mudou durante a execucao; execute novamente")
    if original == candidate:
        return None
    path.parent.mkdir(parents=True, exist_ok=True)
    backup = None
    mode = stat.S_IMODE(path.stat().st_mode) if original is not None else None
    if original is not None:
        stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
        backup = path.with_name("settings.before-vesper-" + stamp + "-" +
                                uuid.uuid4().hex[:8] + ".jsonc")
        with backup.open("xb") as stream:
            stream.write(original)
            stream.flush()
            os.fsync(stream.fileno())
        if mode is not None:
            os.chmod(backup, mode)
        print("Backup local: " + str(backup))
    temporary = None
    try:
        fd, temporary = tempfile.mkstemp(prefix=".vesper-", suffix=".tmp", dir=str(path.parent))
        with os.fdopen(fd, "wb") as stream:
            stream.write(candidate)
            stream.flush()
            os.fsync(stream.fileno())
        if mode is not None:
            os.chmod(temporary, mode)
        if path.is_symlink() or read_snapshot(path) != original:
            raise ValueError("settings.json mudou durante a execucao; nada foi substituido")
        os.replace(temporary, path)
        temporary = None
    finally:
        if temporary is not None:
            Path(temporary).unlink(missing_ok=True)
    return backup


def settings_target(args):
    if args.settings_path:
        if not args.skip_extensions:
            raise ValueError("--settings-path exige --skip-extensions; instale as extensoes no perfil correto pela interface")
        path = Path(os.path.expandvars(args.settings_path)).expanduser()
        if not path.is_absolute() or not path.is_file():
            raise ValueError("--settings-path deve apontar para um arquivo existente com caminho absoluto")
    else:
        if os.name != "nt":
            raise ValueError("O alvo automatico e VS Code Stable no Windows. Use o Python do Windows, nao WSL")
        if os.environ.get("VSCODE_PORTABLE"):
            raise ValueError("VS Code portatil: use --settings-path com --skip-extensions")
        appdata = os.environ.get("APPDATA")
        if not appdata or not Path(appdata).is_absolute():
            raise ValueError("APPDATA nao esta disponivel como caminho absoluto do Windows")
        path = Path(appdata) / "Code" / "User" / "settings.json"
    if path.is_symlink():
        raise ValueError("O arquivo de configuracao e um link; informe diretamente o arquivo real")
    return path.resolve()


def find_code(explicit=None):
    if os.name != "nt":
        raise ValueError("A instalacao automatica de extensoes usa code.cmd no Windows")
    candidates = [Path(explicit)] if explicit else []
    if not explicit:
        found = shutil.which("code.cmd")
        if found:
            candidates.append(Path(found))
        for variable in ("LOCALAPPDATA", "ProgramFiles", "ProgramFiles(x86)"):
            base = os.environ.get(variable)
            if base:
                prefix = Path(base) / "Programs" if variable == "LOCALAPPDATA" else Path(base)
                candidates.append(prefix / "Microsoft VS Code" / "bin" / "code.cmd")
    for path in candidates:
        if path.name.lower() != "code.cmd" or not path.is_file():
            continue
        path = path.resolve()
        # Batch files are parsed by cmd.exe; args below are fixed extension IDs.
        # Reject expansion characters in the executable path as well.
        if any(char in str(path) for char in '%!^"\r\n'):
            raise ValueError("Caminho do code.cmd contem caracteres nao suportados; instale extensoes pela interface e use --skip-extensions")
        if (path.parent.parent / "data").is_dir():
            raise ValueError("VS Code portatil detectado: use --settings-path com --skip-extensions")
        return path
    raise ValueError("code.cmd nao encontrado. Use --code-command com seu caminho ou instale as extensoes na interface e use --skip-extensions")


def run_code(code, *arguments):
    # Only this module's fixed flags and known extension IDs reach the .cmd.
    allowed = {"--list-extensions", "--install-extension", *APPEARANCE_EXTENSIONS, *PYTHON_EXTENSIONS}
    if any(argument not in allowed for argument in arguments):
        raise ValueError("Argumento inesperado para a CLI do VS Code")
    result = subprocess.run(
        [str(code), *arguments], stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        text=True, encoding="utf-8", errors="replace", timeout=240, shell=False)
    if result.returncode:
        raise ValueError("A CLI do VS Code falhou (codigo " + str(result.returncode) +
                         "). Confira acesso ao Marketplace ou instale pela interface. "
                         "As configuracoes nao foram gravadas; extensoes ja instaladas podem permanecer.")
    return result.stdout


def ensure_extensions(code, extensions):
    installed = {line.strip().lower() for line in run_code(code, "--list-extensions").splitlines()}
    for extension in extensions:
        if extension in installed:
            print("Extensao ja instalada: " + extension)
        else:
            print("Instalando pelo Marketplace: " + extension, flush=True)
            run_code(code, "--install-extension", extension)
    installed = {line.strip().lower() for line in run_code(code, "--list-extensions").splitlines()}
    if not set(extensions).issubset(installed):
        raise ValueError("Nem todas as extensoes foram confirmadas; settings.json nao sera alterado. Confira o Marketplace")


def argument_parser():
    parser = argparse.ArgumentParser(description="Aplica Vesper + Symbols, com backup e mesclagem de JSONC. Python 3.9+.")
    parser.add_argument("--dry-run", action="store_true", help="somente simular; sem gravar arquivos ou chamar a CLI")
    parser.add_argument("--skip-extensions", action="store_true", help="mesclar somente configuracoes; instale Vesper e Symbols pela interface")
    parser.add_argument("--with-python-extensions", action="store_true", help="instalar tambem Python, Pylance e Python Debugger se ausentes")
    parser.add_argument("--settings-path", help="caminho absoluto existente do settings.json de outro perfil; exige --skip-extensions")
    parser.add_argument("--code-command", help="caminho do bin/code.cmd de VS Code Stable")
    parser.add_argument("--consolas", action="store_true", help="usar Consolas e desligar ligaduras, sem instalar fontes")
    parser.add_argument("--keep-terminal-font", action="store_true", help="preservar a fonte atual do terminal integrado")
    return parser


def main(argv=None):
    args = argument_parser().parse_args(argv)
    if sys.version_info < (3, 9):
        raise ValueError("Este instalador requer Python 3.9 ou mais recente")
    if args.skip_extensions and args.with_python_extensions:
        raise ValueError("--skip-extensions e --with-python-extensions nao podem ser usados juntos")
    if args.skip_extensions and args.code_command:
        raise ValueError("--code-command nao e usado com --skip-extensions")
    path = settings_target(args)
    preset = copy.deepcopy(PRESET)
    if args.consolas:
        preset["editor.fontFamily"] = "Consolas, monospace"
        preset["editor.fontLigatures"] = False
        preset["terminal.integrated.fontFamily"] = "Consolas, monospace"
    if args.keep_terminal_font:
        preset.pop("terminal.integrated.fontFamily", None)
    original, candidate, changed = prepare_settings(path, preset)
    extensions = APPEARANCE_EXTENSIONS + (PYTHON_EXTENSIONS if args.with_python_extensions else ())
    print("Alvo: " + str(path))
    print("Perfil automatico: Default do VS Code Stable" if not args.settings_path else "Arquivo de configuracao informado explicitamente")
    print("Chaves principais com mudanca: " + (", ".join(changed) if changed else "nenhuma"))
    if args.dry_run:
        if not args.skip_extensions:
            code = find_code(args.code_command)
            print("CLI encontrada (nao executada): " + str(code))
            print("Conferiria/instalaria se ausentes: " + ", ".join(extensions))
        print("SIMULACAO: nenhum arquivo gravado, nenhuma extensao instalada.")
        return 0
    if not args.skip_extensions:
        ensure_extensions(find_code(args.code_command), extensions)
    else:
        print("Extensoes nao conferidas: Vesper e Symbols devem estar instalados e habilitados no perfil alvo.")
    if changed:
        write_settings(path, original, candidate)
        print("Preset completo aplicado: Vesper + Symbols + ajustes de Python e tipografia.")
    else:
        print("As configuracoes ja correspondem ao preset; nenhum backup ou regravacao necessarios.")
    print("Fonte: " + preset["editor.fontFamily"] + ". Nenhuma fonte foi instalada no Windows.")
    print("Se necessario, salve seu trabalho e use Developer: Reload Window quando for conveniente.")
    return 0


def entrypoint():
    try:
        return main()
    except (OSError, ValueError, subprocess.SubprocessError, RecursionError) as error:
        print("ERRO: " + str(error), file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print("Interrompido. Confira as extensoes instaladas e o backup local, se criado.", file=sys.stderr)
        return 130


if __name__ == "__main__":
    sys.exit(entrypoint())
VESPER_PYTHON_EMBEDDED
