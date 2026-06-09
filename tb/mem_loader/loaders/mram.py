
from ip.mram_axi_bridge.verification.erbium_et.et_bch import (
    et_bch_decode_79_to_64,
    et_bch_encode_64_to_79,
)
from mem_loader.loaders.loader import Loader
from cocotb.triggers import Timer

class MRAMLoader(Loader):

    # Bit index
    # 24                            8 7             6 5             4 3       3 2             0
    # ↓                             ↓ ↓             ↓ ↓             ↓ ↓       ↓ ↓             ↓
    # ┌──────────────────────────────┬───────────────┬───────────────┬─────────┬──────────────┐
    # │            MEM_ROW           │   INST[2:1]   │   BANK[1:0]   │ INST[0] │   ROW_OFFSET │
    # │           (17 bits)          │    (2 bits)   │    (2 bits)   │ (1 bit) │    (3 bits)  │
    # └──────────────────────────────┴───────────────┴───────────────┴─────────┴──────────────┘

    # Field ranges:
    #     MEM_ROW     = address[24:8]
    #     INST[2:1]   = address[7:6]
    #     BANK[1:0]   = address[5:4]
    #     INST[0]     = address[3]
    #     ROW_OFFSET  = address[2:0]

    # Instance index reconstruction:
    #     INST = (INST[2:1] << 1) | INST[0]

    NUM_BANKS = 4
    NUM_INSTANCES = 8

    def __init__(self, dut, base_addr, size):
        self.BASE_ADDR = base_addr
        self.MAX_SIZE = size
        self.dut = dut
        assert size == 16*1024*1024, "Current implementation only supports 16MB, found size {size}"

        self.mram = {
            bank_idx: {
                instance_idx: self._get_mram_instance(bank_idx, instance_idx)
                for instance_idx in range(self.NUM_INSTANCES)
            }
            for bank_idx in range(self.NUM_BANKS)
        }

        # ---- Address field widths ----
        col_w     = int(self.mram[0][0].COL_ADDR_WIDTH.value)
        plane_w   = int(self.mram[0][0].PLANE_ADDR_WIDTH.value)
        reserve_w = int(self.mram[0][0].RESERVE_ADDR_WIDTH.value)
        row_w     = int(self.mram[0][0].ADDR_WIDTH.value) - reserve_w - plane_w - col_w

        # ---- Bit positions ----
        self._plane_shift   = row_w + col_w
        self._reserve_shift = self._plane_shift + plane_w

        # ---- Masks for each field ----
        self._plane_mask   = (1 << plane_w) - 1
        self._reserve_mask = (1 << reserve_w) - 1
        self._normal_mask  = (1 << (row_w + col_w)) - 1

        # ---- Instance Data Fields ----
        IDENTITY = lambda x: x
        codec = {
            bank_idx: {
                instance_idx: (
                    (et_bch_encode_64_to_79, et_bch_decode_79_to_64)
                    if len(self.mram[bank_idx][instance_idx].din_i) == 79
                    else (IDENTITY, IDENTITY)
                )
                for instance_idx in range(self.NUM_INSTANCES)
            }
            for bank_idx in range(self.NUM_BANKS)
        }

        self._encode_data = {
            bank_index: {
                instance_index: encode_fn
                for instance_index, (encode_fn, _) in instance_map.items()
            }
            for bank_index, instance_map in codec.items()
        }

        self._decode_data = {
            bank_index: {
                instance_index: lambda x: decode_fn(x).corrected_data_64
                for instance_index, (_, decode_fn) in instance_map.items()
            }
            for bank_index, instance_map in codec.items()
        }

    def map_address(self, bus_addr):
        row_offset = bus_addr & 0b111
        bus_addr >>= 3
        instance = bus_addr & 0b1
        bus_addr >>= 1
        bank = bus_addr & 0b11
        bus_addr >>= 2
        instance |= (bus_addr & 0b11) << 1
        bus_addr >>= 2

        rr_sel    = (bus_addr >> self._reserve_shift) & self._reserve_mask
        plane_idx = (bus_addr >> self._plane_shift)   & self._plane_mask
        plane_row = (rr_sel   << self._plane_shift)   | (bus_addr & self._normal_mask)

        return bank, instance, plane_idx, plane_row, row_offset

    def _get_mram_instance(self, bank_idx, instance_idx):
        bank_wrapper_u = getattr(self.dut, f"mram_bank[{bank_idx}].bank_wrapper_u")
        bank_u = getattr(bank_wrapper_u, "bank_u")
        return getattr(bank_u, f"mram_inst[{instance_idx}].mram_inst")

    async def write_row(self, addr: int, row_data: bytes):
        chunk_addr = addr
        for i in range(8):
            chunk = int.from_bytes(row_data[i*8:(i+1)*8], byteorder="little")
            bank, instance, plane_idx, plane_row, row_offset = self.map_address(chunk_addr)
            self.mram[bank][instance].memory_q[plane_idx][plane_row].value = self._encode_data[bank][instance](chunk)
            chunk_addr = chunk_addr + 8
        await Timer(1, units="step")

    async def write_byte(self, addr: int, row_data: bytes):
        assert len(row_data) == 1, f"Row data must be less than 1 Byte. Found {hex(row_data)}."
        bank, instance, plane_idx, plane_row, row_offset = self.map_address(addr)

        # Get DUT signal
        sig = self.mram[bank][instance].memory_q[plane_idx][plane_row]

        # Decode the current payload, patch the target byte, then re-encode
        # the full word so partial ELF writes keep BCH parity valid.
        val = self._decode_data[bank][instance](sig.value.to_unsigned())

        # Modify slice
        msb = (row_offset*8) + 7
        lsb = row_offset*8
        width = msb - lsb + 1
        mask = ((1 << width) - 1) << lsb
        val = (val & ~mask) | ((row_data[0] << lsb) & mask)

        # Write back
        sig.value = self._encode_data[bank][instance](val)
        await Timer(1, units="step")

    async def read_byte(self, addr: int):
        bank, instance, plane_idx, plane_row, row_offset = self.map_address(addr)
        raw_val = self.mram[bank][instance].memory_q[plane_idx][plane_row].value
        val = self._decode_data[bank][instance](raw_val.to_unsigned())
        lsb = row_offset*8
        return (val >> lsb) & 0xFF
