from peakrdl_regblock.cpuif.axi4lite import AXI4Lite_Cpuif_flattened


class AXI4Lite_Cpuif_flattened_resp1(AXI4Lite_Cpuif_flattened):
    @property
    def max_outstanding(self) -> int:
        return 1

    @property
    def resp_buffer_size(self) -> int:
        return 1
