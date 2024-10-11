﻿namespace ComputerEmulator.V2;

internal static class Game
{
    public static IReadOnlyList<MyByte> Bytes()
    {
        return _bytes.Select(x => new MyByte(x)).ToList();
    }

    private static readonly IReadOnlyList<string> _bytes = [
        
        // 0000 (main)
        "00", // 00
        "00", // 01
        "00", // 02
        "00", // 03
        "00", // 04
        "00", // 05
        "00", // 06
        "00", // 07
        "00", // 08
        "00", // 09
        "00", // 0A
        "00", // 0B
        "00", // 0C
        "00", // 0D
        "00", // 0E
        "00", // 0F
        "00", // 10
        "00", // 11
        "00", // 12
        "00", // 13
        "00", // 14
        "00", // 15
        "00", // 16
        "00", // 17
        "00", // 18
        "00", // 19
        "00", // 1A
        "00", // 1B
        "00", // 1C
        "00", // 1D
        "00", // 1E
        "00", // 1F
        
        // 0020
        "00", // 20
        "00", // 21
        "00", // 22
        "00", // 23
        "00", // 24
        "00", // 25
        "00", // 26
        "00", // 27
        "00", // 28
        "00", // 29
        "00", // 2A
        "00", // 2B
        "00", // 2C
        "00", // 2D
        "00", // 2E
        "00", // 2F
        "00", // 30
        "00", // 31
        "00", // 32
        "00", // 33
        "00", // 34
        "00", // 35
        "00", // 36
        "00", // 37
        "00", // 38
        "00", // 39
        "00", // 3A
        "00", // 3B
        "00", // 3C
        "00", // 3D (bank): 0
        "00", // 3E (in): 0
        "00", // 3F (out): 0
        
        // 0040 (screen)
        "00", // 40
        "00", // 41
        "00", // 42
        "00", // 43
        "00", // 44
        "00", // 45
        "00", // 46
        "00", // 47
        "00", // 48
        "00", // 49
        "00", // 4A
        "00", // 4B
        "00", // 4C
        "00", // 4D
        "00", // 4E
        "00", // 4F
        "00", // 50
        "00", // 51
        "00", // 52
        "00", // 53
        "00", // 54
        "00", // 55
        "00", // 56
        "00", // 57
        "00", // 58
        "00", // 59
        "00", // 5A
        "00", // 5B
        "00", // 5C
        "00", // 5D
        "00", // 5E
        "00", // 5F
        
        // 0060
        "00", // 60
        "00", // 61
        "00", // 62
        "00", // 63
        "00", // 64
        "00", // 65
        "00", // 66
        "00", // 67
        "00", // 68
        "00", // 69
        "00", // 6A
        "00", // 6B
        "00", // 6C
        "00", // 6D
        "00", // 6E
        "00", // 6F
        "00", // 70
        "00", // 71
        "00", // 72
        "00", // 73
        "00", // 74
        "00", // 75
        "00", // 76
        "00", // 77
        "00", // 78
        "00", // 79
        "00", // 7A
        "00", // 7B
        "00", // 7C
        "00", // 7D
        "00", // 7E
        "00", // 7F
        
        // 0080 (bank 1)
        "00", // 80
        "00", // 81
        "00", // 82
        "00", // 83
        "00", // 84
        "00", // 85
        "00", // 86
        "00", // 87
        "00", // 88
        "00", // 89
        "00", // 8A
        "00", // 8B
        "00", // 8C
        "00", // 8D
        "00", // 8E
        "00", // 8F
        "00", // 90
        "00", // 91
        "00", // 92
        "00", // 93
        "00", // 94
        "00", // 95
        "00", // 96
        "00", // 97
        "00", // 98
        "00", // 99
        "00", // 9A
        "00", // 9B
        "00", // 9C
        "00", // 9D
        "00", // 9E
        "00", // 9F
        
        // 00A0
        "00", // A0
        "00", // A1
        "00", // A2
        "00", // A3
        "00", // A4
        "00", // A5
        "00", // A6
        "00", // A7
        "00", // A8
        "00", // A9
        "00", // AA
        "00", // AB
        "00", // AC
        "00", // AD
        "00", // AE
        "00", // AF
        "00", // B0
        "00", // B1
        "00", // B2
        "00", // B3
        "00", // B4
        "00", // B5
        "00", // B6
        "00", // B7
        "00", // B8
        "00", // B9
        "00", // BA
        "00", // BB
        "00", // BC
        "00", // BD
        "00", // BE
        "00", // BF
        
        // 00C0
        "00", // C0
        "00", // C1
        "00", // C2
        "00", // C3
        "00", // C4
        "00", // C5
        "00", // C6
        "00", // C7
        "00", // C8
        "00", // C9
        "00", // CA
        "00", // CB
        "00", // CC
        "00", // CD
        "00", // CE
        "00", // CF
        "00", // D0
        "00", // D1
        "00", // D2
        "00", // D3
        "00", // D4
        "00", // D5
        "00", // D6
        "00", // D7
        "00", // D8
        "00", // D9
        "00", // DA
        "00", // DB
        "00", // DC
        "00", // DD
        "00", // DE
        "00", // DF
        
        // 00E0
        "00", // E0
        "00", // E1
        "00", // E2
        "00", // E3
        "00", // E4
        "00", // E5
        "00", // E6
        "00", // E7
        "00", // E8
        "00", // E9
        "00", // EA
        "00", // EB
        "00", // EC
        "00", // ED
        "00", // EE
        "00", // EF
        "00", // F0
        "00", // F1
        "00", // F2
        "00", // F3
        "00", // F4
        "00", // F5
        "00", // F6
        "00", // F7
        "00", // F8
        "00", // F9
        "00", // FA
        "00", // FB
        "00", // FC
        "00", // FD
        "00", // FE
        "00", // FF
        
        // 0100 (bank 2)
        "00", // 80
        "00", // 81
        "00", // 82
        "00", // 83
        "00", // 84
        "00", // 85
        "00", // 86
        "00", // 87
        "00", // 88
        "00", // 89
        "00", // 8A
        "00", // 8B
        "00", // 8C
        "00", // 8D
        "00", // 8E
        "00", // 8F
        "00", // 90
        "00", // 91
        "00", // 92
        "00", // 93
        "00", // 94
        "00", // 95
        "00", // 96
        "00", // 97
        "00", // 98
        "00", // 99
        "00", // 9A
        "00", // 9B
        "00", // 9C
        "00", // 9D
        "00", // 9E
        "00", // 9F
        
        // 0120
        "00", // A0
        "00", // A1
        "00", // A2
        "00", // A3
        "00", // A4
        "00", // A5
        "00", // A6
        "00", // A7
        "00", // A8
        "00", // A9
        "00", // AA
        "00", // AB
        "00", // AC
        "00", // AD
        "00", // AE
        "00", // AF
        "00", // B0
        "00", // B1
        "00", // B2
        "00", // B3
        "00", // B4
        "00", // B5
        "00", // B6
        "00", // B7
        "00", // B8
        "00", // B9
        "00", // BA
        "00", // BB
        "00", // BC
        "00", // BD
        "00", // BE
        "00", // BF
        
        // 0140
        "00", // C0
        "00", // C1
        "00", // C2
        "00", // C3
        "00", // C4
        "00", // C5
        "00", // C6
        "00", // C7
        "00", // C8
        "00", // C9
        "00", // CA
        "00", // CB
        "00", // CC
        "00", // CD
        "00", // CE
        "00", // CF
        "00", // D0
        "00", // D1
        "00", // D2
        "00", // D3
        "00", // D4
        "00", // D5
        "00", // D6
        "00", // D7
        "00", // D8
        "00", // D9
        "00", // DA
        "00", // DB
        "00", // DC
        "00", // DD
        "00", // DE
        "00", // DF

        // 0160
        "00", // E0
        "00", // E1
        "00", // E2
        "00", // E3
        "00", // E4
        "00", // E5
        "00", // E6
        "00", // E7
        "00", // E8
        "00", // E9
        "00", // EA
        "00", // EB
        "00", // EC
        "00", // ED
        "00", // EE
        "00", // EF
        "00", // F0
        "00", // F1
        "00", // F2
        "00", // F3
        "00", // F4
        "00", // F5
        "00", // F6
        "00", // F7
        "00", // F8
        "00", // F9
        "00", // FA
        "00", // FB
        "00", // FC
        "00", // FD
        "00", // FE
        "00", // FF
        
        // 0180 (bank 3)
        "00", // 80
        "00", // 81
        "00", // 82
        "00", // 83
        "00", // 84
        "00", // 85
        "00", // 86
        "00", // 87
        "00", // 88
        "00", // 89
        "00", // 8A
        "00", // 8B
        "00", // 8C
        "00", // 8D
        "00", // 8E
        "00", // 8F
        "00", // 90
        "00", // 91
        "00", // 92
        "00", // 93
        "00", // 94
        "00", // 95
        "00", // 96
        "00", // 97
        "00", // 98
        "00", // 99
        "00", // 9A
        "00", // 9B
        "00", // 9C
        "00", // 9D
        "00", // 9E
        "00", // 9F
        
        // 01A0
        "00", // A0
        "00", // A1
        "00", // A2
        "00", // A3
        "00", // A4
        "00", // A5
        "00", // A6
        "00", // A7
        "00", // A8
        "00", // A9
        "00", // AA
        "00", // AB
        "00", // AC
        "00", // AD
        "00", // AE
        "00", // AF
        "00", // B0
        "00", // B1
        "00", // B2
        "00", // B3
        "00", // B4
        "00", // B5
        "00", // B6
        "00", // B7
        "00", // B8
        "00", // B9
        "00", // BA
        "00", // BB
        "00", // BC
        "00", // BD
        "00", // BE
        "00", // BF
        
        // 01C0
        "00", // C0
        "00", // C1
        "00", // C2
        "00", // C3
        "00", // C4
        "00", // C5
        "00", // C6
        "00", // C7
        "00", // C8
        "00", // C9
        "00", // CA
        "00", // CB
        "00", // CC
        "00", // CD
        "00", // CE
        "00", // CF
        "00", // D0
        "00", // D1
        "00", // D2
        "00", // D3
        "00", // D4
        "00", // D5
        "00", // D6
        "00", // D7
        "00", // D8
        "00", // D9
        "00", // DA
        "00", // DB
        "00", // DC
        "00", // DD
        "00", // DE
        "00", // DF
        
        // 01E0
        "00", // E0
        "00", // E1
        "00", // E2
        "00", // E3
        "00", // E4
        "00", // E5
        "00", // E6
        "00", // E7
        "00", // E8
        "00", // E9
        "00", // EA
        "00", // EB
        "00", // EC
        "00", // ED
        "00", // EE
        "00", // EF
        "00", // F0
        "00", // F1
        "00", // F2
        "00", // F3
        "00", // F4
        "00", // F5
        "00", // F6
        "00", // F7
        "00", // F8
        "00", // F9
        "00", // FA
        "00", // FB
        "00", // FC
        "00", // FD
        "00", // FE
        "00", // FF
    ];
}
