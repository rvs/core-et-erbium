import random

mram_address = 0
def total_beats_calculation(total_bytes, axi_size):
    # total_bytes = (axi_len + 1) << axi_size
    shift_offset = 4 if axi_size <= 4 else axi_size
    msb_beat_mask = 0x1ff << shift_offset
    # lsb_beat_mask = msb_beat_mask ^ ((0x100 << shift_offset) - 1)
    lsb_beat_mask = msb_beat_mask ^ (msb_beat_mask |  (0x7fff & (0x7f00 << shift_offset) ^ 0x7fff))

    bytes_per_beat = 1 << shift_offset
    msb_beats = (msb_beat_mask & total_bytes) >> shift_offset
    lsb_beats = 0 if lsb_beat_mask & total_bytes == 0 else 1
    return msb_beats + lsb_beats

def calculate_banks_needed(
    axi_addr,  # Base address for axi
    axi_size,  # Size of each beat
    axi_len,   # Number of beats
    beat_count # Current beat
):
    """
    axi_size, Bytes per beat:
    0 -> 1 byte
    1 -> 2 bytes
    2 -> 4 bytes
    3 -> 8 bytes
    4 -> 16 bytes
    5 -> 32 bytes
    6 -> 64 bytes
    7 -> 128 bytes
    """
    global mram_address
    selected_banks = 0b000_0000
    # Each bank is 128 bits, which is 16 bytes
    # So, that means for each 16 bytes in a beat, we select that bank.
    # Also, we are always transfer aligned based on the axi_size. So, if it's 4 bytes, then the
    # lowest 2 bits of the address are always 0.

    # Starting with the easiest case, 64Bytes per beat.
    starting_bank = ((((axi_addr >> 4) & 0b11 ) + 2 * beat_count) & 0b11) if axi_size == 5 else \
                    ((((axi_addr >> 4) & 0b11 ) + 1 * beat_count) & 0b11) if axi_size <= 4 else \
                    ((axi_addr >> 4) & 0b11 )
    if beat_count == 0:
        mram_address = (axi_addr >> 4)
    # Lets calculate the total bytes in the read request
    total_bytes = (axi_len + 1) << axi_size
    required_beats = total_beats_calculation(total_bytes, axi_size)
    banks_each_beat = 0b000_1111 if axi_size == 6 else \
                      0b000_0011 if axi_size == 5 else \
                      0b000_0001
    selected_banks = (banks_each_beat << starting_bank) & 0b111_1111
    bank_addresses = [
        mram_address if selected_banks & (1 << 0) else mram_address + 1 if selected_banks & (1 << 4) else None,
        mram_address if selected_banks & (1 << 1) else mram_address + 1 if selected_banks & (1 << 5) else None,
        mram_address if selected_banks & (1 << 2) else mram_address + 1 if selected_banks & (1 << 6) else None,
        mram_address if selected_banks & (1 << 3) else None,
    ]
    if selected_banks & 0b111_1000 != 0:
        mram_address += 1
    string_printout = []
    for _ in range(beat_count):
        if _ == 1:
            break
        string_printout.append(f"  ")
    string_printout.append(f"Starting bank: {starting_bank} @ address {axi_addr:08x} (axi_size={axi_size}, axi_len={axi_len}), ")
    string_printout.append(f"total bytes: {total_bytes}, ")
    string_printout.append(f"beat count: {beat_count+1} / {required_beats}, ")
    string_printout.append(f" Selected banks: {selected_banks:07b},")
    string_printout.append(f" bank addresses: {[hex(bank_addr) if bank_addr is not None else None for bank_addr in bank_addresses]}")
    print("".join(string_printout))

    return (beat_count + 1) != required_beats
num_of_iterations = 100
rand_address_list = []
axi_arg_list = []

# Add in specific corner cases
axi_arg_list.append((5, 255))
axi_arg_list.append((4, 255))
axi_arg_list.append((0, 255))
axi_arg_list.append((1, 255))
axi_arg_list.append((2, 255))
axi_arg_list.append((3, 255))
axi_arg_list.append((6, 255))

for i in range(num_of_iterations):
    rand_address = random.randrange(0, 2**16, 4)
    rand_address_list.append(rand_address)
    if len(axi_arg_list) < num_of_iterations:
        axi_arg_list.append((random.randrange(0, 7, 1), random.randrange(0, 256, 1)))

for iter in range(num_of_iterations):
    i = 0
    while calculate_banks_needed(
            axi_addr=rand_address_list[iter],
            axi_size=axi_arg_list[iter][0],
            axi_len=axi_arg_list[iter][1],
            beat_count=i
    ):
        i += 1


