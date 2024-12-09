namespace ComputerEmulator.V2;

internal static class SpaceFight
{
    public static IReadOnlyList<MyByte> Bytes()
    {
        return _bytes.Select(x => new MyByte(x)).ToList();
    }

    // WIN_LEFT     equ 30
    // STEP_CNT     equ 14
    // KEY_LEFT     equ 0x11
    // KEY_RIGHT    equ 0x13
    // KEY_FIRE     equ 0x20

    private static readonly IReadOnlyList<string> _bytes = [

        // 00
        "55", // 00 clear:          ldi b, clear_loop
        "06", // 01
        "56", // 02                 ldi c, 4
        "04", // 03
        "57", // 04                 ldi d, 0x5B
        "5B", // 05
        "3C", // 06 clear_loop:     st a, d
        "7F", // 07                 dec d
        "7A", // 08                 dec c
        "24", // 09                 jnz b
        "56", // 0A                 ldi c, 12
        "0C", // 0B
        "EC", // 0C random:         rnd a
        "ED", // 0D                 rnd b
        "B4", // 0E                 and a, b
        "E0", // 0F                 shl a
        "3C", // 10                 st a, d
        "7F", // 11                 dec d
        "EC", // 12                 rnd a
        "ED", // 13                 rnd b
        "B4", // 14                 and a, b
        "E4", // 15                 shr a
        "3C", // 16                 st a, d
        "7F", // 17                 dec d
        "7A", // 18                 dec c
        "0C", // 19                 jnz random
        "0C", // 1A
        "03", // 1B random_jmp:     jmp score
        "1D", // 1C
        "50", // 1D score:          ld a, win_left
        "3A", // 1E
        "30", // 1F                 st a, win_left
        
        // 20
        "3A", // 20
        "54", // 21                 ldi a, step
        "25", // 22
        "30", // 23                 st a, random_jmp +1
        "1C", // 24
        "55", // 25 step:           ldi b, KEY_LEFT
        "11", // 26
        "56", // 27                 ldi c, KEY_RIGHT
        "13", // 28
        "57", // 29                 ldi d, KEY_FIRE
        "20", // 2A
        "50", // 2B step_loop:      ld a, step_left
        "3D", // 2C
        "70", // 2D                 dec a
        "09", // 2E                 js level
        "B6", // 2F
        "30", // 30                 st a, step_left
        "3D", // 31
        "50", // 32                 ld a, in_out
        "3E", // 33
        "D3", // 34                 xor d, a
        "08", // 35                 jz fire
        "8B", // 36
        "D2", // 37                 xor c, a
        "03", // 38                 jmp step_end
        "60", // 39
        "1E", // 3A win_left    db  WIN_LEFT            ; bcd
        "00", // 3B ---                                 ; bcd (reserved)
        "0E", // 3C step_cnt    db  STEP_CNT
        "0E", // 3D step_left   db  STEP_CNT
        "06", // 3E in_out:     db  0b_00000110         ; b/w display + bcd
        "00", // 3F bank        db  0
        
        // 40 (display)
        "28", // 40 00101000 00000000
        "00", // 41
        "20", // 42 00100000 00101000
        "28", // 43
        "00", // 44 00000000 00001000
        "08", // 45
        "09", // 46 00001001 00000000
        "00", // 47
        "21", // 48 00100001 00100000
        "20", // 49
        "23", // 4A 00100011 10001000
        "88", // 4B
        "03", // 4C 00000011 10001000
        "88", // 4D
        "0B", // 4E 00001011 10100000
        "A0", // 4F
        "0A", // 50 00001010 10100000
        "A0", // 51
        "2E", // 52 00101110 11101000
        "E8", // 53
        "2F", // 54 00101111 11101000
        "E8", // 55
        "3B", // 56 00111011 10111000
        "B8", // 57
        "35", // 58 00110101 01011000
        "58", // 59
        "20", // 5A 00100000 00001000
        "08", // 5B
        "01", // 5C 00000001 00000000
        "00", // 5D
        "03", // 5E 00000011 10000000
        "80", // 5F

        // 60
        "08", // 60 step_end:       jz right
        "78", // 61
        "D1", // 62                 xor b, a
        "0C", // 63                 jnz step_loop
        "2B", // 64
        "51", // 65 left:           ld b, 0x5E
        "5E", // 66
        "E1", // 67                 shl b
        "0A", // 68                 jc step
        "25", // 69
        "55", // 6A                 ldi b, 0x5F
        "5F", // 6B
        "56", // 6C                 ldi c, 4
        "04", // 6D
        "57", // 6E                 ldi d, left_loop
        "70", // 6F
        "44", // 70 left_loop:      ld a, b
        "C0", // 71                 rcl a
        "34", // 72                 st a, b
        "75", // 73                 dec b
        "7A", // 74                 dec c
        "2C", // 75                 jnz d
        "03", // 76                 jmp step
        "25", // 77
        "51", // 78 right:          ld b, 0x5F
        "5F", // 79
        "E5", // 7A                 shr b
        "0A", // 7B                 jc step
        "25", // 7C
        "55", // 7D                 ldi b, 0x5C
        "5C", // 7E
        "56", // 7F                 ldi c, 4

        // 80
        "04", // 80
        "57", // 81                 ldi d, right_loop
        "83", // 82
        "44", // 83 right_loop:     ld a, b
        "D0", // 84                 rcr a
        "34", // 85                 st a, b
        "65", // 86                 inc b
        "7A", // 87                 dec c
        "2C", // 88                 jnz d
        "03", // 89                 jmp step
        "25", // 8A
        "57", // 8B fire:           ldi d, 0x5C
        "5C", // 8C
        "4C", // 8D                 ld a, d
        "B0", // 8E                 test a
        "0C", // 8F                 jnz fire2
        "92", // 90
        "6F", // 91                 inc d
        "4D", // 92 fire2:          ld b, d
        "56", // 93                 ldi c, 14
        "0E", // 94
        "7F", // 95 fire_loop:      dec d
        "7F", // 96                 dec d
        "4C", // 97                 ld a, d
        "B4", // 98                 and a, b
        "0C", // 99                 jnz fire_hit
        "A0", // 9A
        "7A", // 9B                 dec c
        "0C", // 9C                 jnz fire_loop
        "95", // 9D
        "03", // 9E                 jmp step
        "25", // 9F

        // A0
        "4C", // A0 fire_hit:       ld a, d
        "D4", // A1                 xor a, b
        "3C", // A2                 st a, d
        "50", // A3                 ld a, win_left
        "3A", // A4
        "70", // A5                 dec a
        "30", // A6                 st a, win_left
        "3A", // A7
        "0C", // A8                 jnz step
        "25", // A9
        "55", // AA win:            ldi b, 0x40
        "40", // AB 
        "56", // AC                 ldi c, 0xE0
        "E0", // AD 
        "57", // AE                 ldi d, win_loop
        "B0", // AF 
        "48", // B0 win_loop:       ld a, c
        "34", // B1                 st a, b
        "65", // B2                 inc b
        "6A", // B3                 inc c
        "2C", // B4                 jnz d
        "01", // B5                 hlt
        "50", // B6 level:          ld a, step_cnt
        "3C", // B7
        "70", // B8                 dec a
        "70", // B9                 dec a
        "30", // BA                 st a, step_cnt
        "3C", // BB
        "30", // BC                 st a, step_left
        "3D", // BD
        "50", // BE                 ld a, 0x5A
        "5A", // BF

        // C0
        "51", // C0                 ld b, 0x5B
        "5B", // C1
        "56", // C2                 ldi c, 26
        "1A", // C3
        "57", // C4                 ldi d, 0x59
        "59", // C5
        "C4", // C6                 or a, b
        "08", // C7                 jz scroll
        "D1", // C8
        "6A", // C9 level_lose:     inc c
        "6A", // CA                 inc c
        "6F", // CB                 inc d
        "6F", // CC                 inc d
        "54", // CD                 ldi a, 0x01         ; hlt
        "01", // CE
        "30", // CF                 st a, random_jmp
        "1B", // D0
        "AD", // D1 scroll:         mov b, d
        "44", // D2                 ld a, b
        "65", // D3                 inc b
        "65", // D4                 inc b
        "34", // D5                 st a, b
        "7F", // D6                 dec d
        "7A", // D7                 dec c
        "0C", // D8                 jnz scroll
        "D1", // D9
        "6A", // DA                 inc c
        "6F", // DB                 inc d
        "6F", // DC                 inc d
        "03", // DD                 jmp random
        "0C", // DE
        "00", // DF ---

        // E0 (win_image)
        "00", // E0 00000000 00000000
        "00", // E1
        "00", // E2 00000000 00000000
        "00", // E3
        "03", // E4 00000011 11000000
        "C0", // E5
        "04", // E6 00000100 00100000
        "20", // E7
        "09", // E8 00001001 00010000
        "10", // E9
        "10", // EA 00010000 00101000
        "28", // EB
        "14", // EC 00010100 00001000
        "08", // ED
        "20", // EE 00100000 10000100
        "84", // EF
        "20", // F0 00100000 00000100
        "04", // F1
        "40", // F2 01000000 00001010
        "0A", // F3
        "53", // F4 01010011 11000010
        "C2", // F5
        "47", // F6 01000111 11100010
        "E2", // F7
        "47", // F8 01000111 11100010
        "E2", // F9
        "37", // FA 00110111 11101100
        "EC", // FB
        "0F", // FC 00001111 11110000
        "F0", // FD
        "00", // FE 00000000 00000000
        "00", // FF
    ];
}
