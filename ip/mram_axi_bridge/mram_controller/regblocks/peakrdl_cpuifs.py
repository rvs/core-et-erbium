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

from peakrdl_regblock.cpuif.axi4lite import AXI4Lite_Cpuif_flattened


class AXI4Lite_Cpuif_flattened_resp1(AXI4Lite_Cpuif_flattened):
    @property
    def max_outstanding(self) -> int:
        return 1

    @property
    def resp_buffer_size(self) -> int:
        return 1
