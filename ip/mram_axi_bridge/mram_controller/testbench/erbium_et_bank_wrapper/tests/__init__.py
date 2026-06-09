from pathlib import Path
import importlib

# Auto-import every .py module in this package and pull all public names
# into this namespace so cocotb discovers all @cocotb.test() functions
# when tb.py does "from tests import *".
_pkg_dir = Path(__file__).parent
for _f in sorted(_pkg_dir.glob("*.py")):
    if _f.name.startswith("_"):
        continue
    _mod = importlib.import_module(f".{_f.stem}", __package__)
    # Pull all public names (or everything if no __all__) into this namespace
    _names = getattr(_mod, "__all__", [n for n in dir(_mod) if not n.startswith("_")])
    globals().update({n: getattr(_mod, n) for n in _names})
