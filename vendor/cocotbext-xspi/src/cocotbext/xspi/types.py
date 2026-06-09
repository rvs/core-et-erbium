"""Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.

Author: Vijayvithal <jvs@nekko.ai>
Created on: 2026-02-09
Description: Collection of Emumes, Dicts etc.
"""

from enum import Enum, IntEnum


class Mode(Enum):
    """Enum of supported rates."""

    S1 = 0
    D1 = 1
    S2 = 2
    D2 = 3
    S4 = 4
    D4 = 5
    S8 = 6
    D8 = 7
    HB = 8


class Format(Enum):
    """Enum of Formats defines in xspi spec."""

    # 1S
    A0 = 0  # Comand only
    B0 = 1  # Comand + Read Data
    C0 = 2  # Command + 3byte Address + Read Data
    D0 = 3  # Command + 4 byte address + Read Data
    E0 = 4  # Command + 3 byte address + latency + Read Data
    F0 = 5  # Command + 4 byte address + latency + Read data
    G0 = 6  # Command + write data
    H0 = 7  # Command + 3 byte address
    I0 = 8  # Command + 4 byte address
    J0 = 9  # Command + 3 byte address + Write data
    K0 = 10  # Command + 4 byte address + Write data
    # 4D TBD
    # 8D Profile 1
    A1 = 11  # Command and Extension
    B1 = 12  # Command +Extension +4B address + N Latency + R Data
    C1 = 13  # C + E +4B address
    D1 = 14  # C +E +4B address + W Data.
    G1 = 17  # C +E +4B address + W Data.

    # 8D Profile 2
    A2 = 15  # C + 5B address + Latency + Read
    B2 = 16  # C + 5B address + Latency + Write
    # 4s-4D-4D Profile 1
    A3 = 17  # Command Only
    B3 = 18  # Command and Read Data
    C3 = 19  # Command 3B Address +Latency + R Data
    D3 = 20  # Command 1B Address +Latency + R Data
    E3 = 21  # Command 4B Address +Latency + R Data
    F3 = 22  # Command + W Data
    G3 = 23  # Command + 4B Address
    H3 = 24  # Command + 1B Address, W Data
    I3 = 25  # Command + 4B Address, W Data


class Cmd(IntEnum):
    """Enum of supported commands."""

    ReadSFDP = 0x5A
    ReadSR = 0x5
    ReadFSR = 0x70
    ReadCR = 0x85
    ReadGPR = 0x96

    ReadMEM = 0x0B
    WriteMEM = 0x02  # Program

    ReadReg = 0x65
    WriteReg = 0x71

    WriteSR = 1
    WriteCR = 0x81
    ClearFR = 0x50
    ResetDevice = 0x99
    ResetEnable = 0x66
    EnterDeepSleep = 0xB9
    ExitDeepSleep = 0xAB
    SetRate = 0x52
    OTPRead = 0x4B
    OTPWrite = 0x42


command_table = {
    Cmd.ReadSFDP: {"fmt_1s": Format.C0, "fmt_8s": Format.B1},
    Cmd.ReadSR: {"fmt_1s": Format.C0, "fmt_8s": Format.B1},
    Cmd.ReadFSR: {"fmt_1s": Format.C0, "fmt_8s": Format.B1},
    Cmd.ReadCR: {"fmt_1s": Format.C0, "fmt_8s": Format.B1},
    Cmd.ReadGPR: {"fmt_1s": Format.C0, "fmt_8s": Format.B1},
    Cmd.ReadMEM: {"fmt_1s": Format.F0, "fmt_8s": Format.B1},
    Cmd.WriteMEM: {"fmt_1s": Format.K0, "fmt_8s": Format.D1},
    Cmd.ReadReg: {"fmt_1s": Format.E0, "fmt_8s": Format.B1},
    Cmd.WriteReg: {"fmt_1s": Format.J0, "fmt_8s": Format.D1},
    Cmd.WriteSR: {"fmt_1s": Format.G0, "fmt_8s": Format.D1},
    Cmd.WriteCR: {"fmt_1s": Format.G0, "fmt_8s": Format.D1},
    Cmd.ClearFR: {"fmt_1s": Format.A0, "fmt_8s": Format.A1},
    Cmd.ResetDevice: {"fmt_1s": Format.A0, "fmt_8s": Format.A1},
    Cmd.ResetEnable: {"fmt_1s": Format.A0, "fmt_8s": Format.A1},
    Cmd.EnterDeepSleep: {"fmt_1s": Format.A0, "fmt_8s": Format.A1},
    Cmd.ExitDeepSleep: {"fmt_1s": Format.A0, "fmt_8s": Format.A1},
    Cmd.SetRate: {"fmt_1s": Format.G0, "fmt_8s": Format.G1},
    Cmd.OTPRead: {"fmt_1s": Format.F0, "fmt_8s": Format.B1},
    Cmd.OTPWrite: {"fmt_1s": Format.F0, "fmt_8s": Format.D1},
}
format_table = {
    # 0E (1B?)
    Format.A0: {
        "extension": False,
        "address": 0,
        "latency": False,
        "isread": False,
        "iswrite": False,
    },
    Format.D0: {
        "extension": False,
        "address": 4,
        "latency": False,
        "isread": True,
        "iswrite": False,
    },
    # 0E (1B?)
    Format.E0: {
        "extension": False,
        "address": 3,
        "latency": True,
        "isread": True,
        "iswrite": False,
    },
    # 0F                    , 1B
    Format.F0: {
        "extension": False,
        "address": 4,
        "latency": True,
        "isread": True,
        "iswrite": False,
    },
    # 0F                    , 1B
    Format.G0: {
        "extension": False,
        "address": 0,
        "latency": False,
        "isread": False,
        "iswrite": True,
    },
    # 0F                    , 1B
    Format.J0: {
        "extension": False,
        "address": 3,
        "latency": False,
        "isread": False,
        "iswrite": True,
    },
    Format.K0: {
        "extension": False,
        "address": 4,
        "latency": False,
        "isread": False,
        "iswrite": True,
    },
    Format.B1: {
        "extension": True,
        "address": 4,
        "latency": True,
        "isread": True,
        "iswrite": False,
    },  # 1.B
    # 1.A (Seems incorrect)
    Format.A1: {
        "extension": True,
        "address": 0,
        "latency": False,
        "isread": False,
        "iswrite": False,
    },
    Format.D1: {
        "extension": True,
        "address": 4,
        "latency": False,
        "isread": False,
        "iswrite": True,
    },  # 1D
    Format.G1: {  # This is a dummy mode
        "extension": True,
        "address": 0,
        "latency": False,
        "isread": False,
        "iswrite": True,
    },  # 1D
    Format.A2: {  # This is a dummy mode
        "extension": False,
        "address": 4,
        "latency": True,
        "isread": True,
        "iswrite": False,
    },  # 1D
    Format.B2: {  # This is a dummy mode
        "extension": False,
        "address": 4,
        "latency": True,
        "isread": False,
        "iswrite": True,
    },  # 1D
}
