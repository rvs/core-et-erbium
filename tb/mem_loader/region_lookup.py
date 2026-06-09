import bisect
from enum import Enum, auto

class MemMap(Enum):
    ROM  = auto()
    SRAM = auto()
    MRAM = auto()

class RegionLookup:
    # Built‑in custom map
    erbium_map = [
        # Start          Size             Region
        # -------------  ---------------  ---------------------
        (    0x02008000,          8*1024,            MemMap.ROM),
        (    0x0200C000,          4*1024,           MemMap.SRAM),
        (    0x40000000,    16*1024*1024,           MemMap.MRAM),
    ]

    # Class‑level lookup tables
    _regions = None
    _starts = None

    @classmethod
    def initialize(cls):
        if cls._regions is None:
            name_map = {}
            processed = []

            for start, size, region in cls.erbium_map:
                end = start + size
                processed.append((start, end, region))
                name_map[region.name] = (start, size)

            cls._regions = sorted(processed, key=lambda r: r[0])
            cls._starts = [r[0] for r in cls._regions]
            cls._name_map = name_map

    def __init__(self):
        self.initialize()

    def find(self, addr):
        i = bisect.bisect_right(self._starts, addr) - 1
        if i >= 0:
            start, end, region = self._regions[i]
            if start <= addr < end:
                return (start, end, region)
        return None

    def by_name(self, name):
        # Return (base, size) for a region name, or None if not found
        return self._name_map.get(name)
