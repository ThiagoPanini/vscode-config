"""Maintainers only: refresh the Python payload in the standalone shell launcher."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
shell_path = root / "scripts/install-vesper.sh"
marker = "<<'VESPER_PYTHON_EMBEDDED'\n"
shell = shell_path.read_text(encoding="utf-8")
header, _ = shell.split(marker, 1)
python = (root / "scripts/install_vesper.py").read_text(encoding="utf-8").rstrip("\n")
shell_path.write_bytes((header + marker + python + "\nVESPER_PYTHON_EMBEDDED\n").encode("utf-8"))
print("Launcher atualizado a partir do instalador Python.")
