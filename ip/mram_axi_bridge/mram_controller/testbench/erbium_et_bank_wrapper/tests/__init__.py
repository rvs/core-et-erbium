# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright (c) 2026 Ainekko, Co.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
