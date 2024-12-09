namespace ComputerEmulator.V1;

internal static class SpaceFight
{
    public static IReadOnlyList<MyByte> Bytes()
    {
        return _bytes.Select(x => new MyByte(x)).ToList();
    }

    // WIN_LEFT     equ 30
    // STEP_CNT     equ 14
    // KEY_LEFT     equ 0x25
    // KEY_RIGHT    equ 0x27
    // KEY_FIRE     equ 0x20
    // OUT_BCD      equ 0x10
    // OUT_DISPLAY  equ 0x80

    private static readonly IReadOnlyList<string> _bytes = [

        // 00
        "8A", // 00 clear:          ldi c, 0x5C
        "5C", // 01
        "8B", // 02                 ldi d, 0x58
        "58", // 03
        "4E", // 04 clear_loop:     dec c
        "B9", // 05                 st b, c
        "02", // 06                 mov a, c
        "1B", // 07                 xor a, d
        "E4", // 08                 jnz clear_loop
        "04", // 09
        "8A", // 0A random:         ldi c, display
        "40", // 0B
        "A8", // 0C random_loop:    rnd a
        "A9", // 0D                 rnd b
        "09", // 0E                 and a, b
        "50", // 0F                 shl a
        "4F", // 10                 dec d
        "BC", // 11                 st a, d
        "A8", // 12                 rnd a
        "A9", // 13                 rnd b
        "09", // 14                 and a, b
        "54", // 15                 shr a
        "4F", // 16                 dec d
        "BC", // 17                 st a, d
        "03", // 18                 mov a, d
        "1A", // 19                 xor a, c
        "E4", // 1A                 jnz random_loop
        "0C", // 1B
        "80", // 1C score:          ld a, win_left
        "3C", // 1D
        "8B", // 1E                 ldi d, display
        "40", // 1F

        // 20
        "9D", // 20                 ld b, d
        "8A", // 21                 ldi c, OUT_BCD
        "10", // 22                 
        "A2", // 23                 st c, out
        "3F", // 24                 
        "BC", // 25                 st a, d
        "8A", // 26                 ldi c, OUT_DISPLAY
        "80", // 27                 
        "A2", // 28                 st c, out
        "3F", // 29                 
        "BD", // 2A                 st b, d
        "20", // 1B                 add a, 0
        "E0", // 2C                 jz win
        "D5", // 2D
        "89", // 2E step:           ldi b, step2
        "30", // 2F
        "80", // 30 step2:          ld a, step_left
        "3B", // 31
        "4C", // 32                 dec a
        "E2", // 33                 js level
        "B2", // 34
        "A0", // 35                 st a, step_left
        "3B", // 36
        "E8", // 37                 jmp keys
        "60", // 38
        "00", // 39 ---
        "0E", // 3A step_cnt:       STEP_CNT
        "0E", // 3B step_left:      STEP_CNT
        "1E", // 3C win_left:       WIN_LEFT
        "00", // 3D bank:           0
        "00", // 3E in:             0
        "80", // 3F out:            OUT_DISPLAY

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
        "00", // 60 keys:           mov a, 0
        "82", // 61                 ld c, in
        "3E", // 62
        "A0", // 63                 st a, in
        "3E", // 64
        "88", // 65                 ldi a, KEY_FIRE
        "20", // 66
        "1A", // 67                 xor a, c
        "E0", // 68                 jz fire
        "93", // 69
        "88", // 6A                 ldi a, KEY_RIGHT
        "27", // 6B
        "1A", // 6C                 xor a, c
        "E0", // 6D                 jz right
        "83", // 6E
        "88", // 6F                 ldi a, KEY_LEFT
        "25", // 70
        "1A", // 71                 xor a, c
        "D4", // 72                 jnz b               ; step2
        "80", // 73 left:           ld a, 0x5E
        "5E", // 74
        "50", // 75                 shl a
        "C5", // 76                 jc b                ; step2
        "8B", // 77                 ldi d, 0x5F
        "5F", // 78
        "8A", // 79                 ldi c, 4
        "04", // 7A
        "9C", // 7B left_loop:      ld a, d
        "60", // 7C                 rcl a
        "BC", // 7D                 st a, d
        "4F", // 7E                 dec d
        "4E", // 7F                 dec c

        // 80
        "E4", // 80                 jnz left_loop
        "7B", // 81
        "F4", // 82                 jmp b               ; step2
        "80", // 83 right:          ld a, 0x5F
        "5F", // 84
        "54", // 85                 shr a
        "C5", // 86                 jc b                ; step2
        "8B", // 87                 ldi d, 0x5C
        "5C", // 88
        "8A", // 89                 ldi c, 4
        "04", // 8A
        "9C", // 8B right_loop:     ld a, d
        "64", // 8C                 rcr a
        "BC", // 8D                 st a, d
        "4B", // 8E                 inc d
        "4E", // 8F                 dec c
        "E4", // 90                 jnz right_loop
        "8B", // 91
        "F4", // 92                 jmp b               ; step2
        "8B", // 93 fire:           ldi d, 0x5C
        "5C", // 94
        "9C", // 95                 ld a, d
        "20", // 96                 add a, 0
        "E4", // 97                 jnz fire_shot
        "9A", // 98
        "4B", // 99                 inc d
        "9D", // 9A fire_shot:      ld b, d
        "8A", // 9B                 ldi c, 14
        "0E", // 9C
        "4F", // 9D fire_loop:      dec d
        "4F", // 9E                 dec d
        "9C", // 9F                 ld a, d

        // A0
        "09", // A0                 and a, b
        "E4", // A1                 jnz fire_hit
        "A8", // A2
        "4E", // A3                 dec c
        "E4", // A4                 jnz fire_loop
        "9D", // A5
        "E8", // A6                 jmp step
        "2E", // A7
        "9C", // A8 fire_hit:       ld a, d
        "19", // A9                 xor a, b
        "BC", // AA                 st a, d
        "80", // AB                 ld a, win_left
        "3C", // AC
        "4C", // AD                 dec a
        "A0", // AE                 st a, win_left
        "3C", // AF
        "E8", // B0                 jmp score
        "1C", // B1
        "80", // B2 level:          ld a, step_cnt
        "3A", // B3
        "4C", // B4                 dec a
        "4C", // B5                 dec a
        "A0", // B6                 st a, step_cnt
        "3A", // B7
        "A0", // B8                 st a, step_left
        "3B", // B9
        "8A", // BA                 ldi c, 0x5A
        "5A", // BB
        "98", // BC                 ld a, c
        "81", // BD                 ld b, 0x5B
        "5B", // BE
        "11", // BF                 or a, b

        // C0
        "E0", // C0                 jz scroll
        "C8", // C1
        "4A", // C2                 inc c
        "4A", // C3                 inc c
        "88", // C4                 ldi a, 0xEC         ; "hlt"
        "EC", // C5
        "A0", // C6                 st a, score
        "1C", // C7
        "8B", // C8 scroll:         ldi d, 0x42
        "42", // C9
        "4E", // CA scroll_loop:    dec c
        "02", // CB                 mov a, c
        "91", // CC                 ld b, a
        "48", // CD                 inc a
        "48", // CE                 inc a
        "B1", // CF                 st b, a
        "1B", // D0                 xor a, d
        "E4", // D1                 jnz scroll_loop
        "CA", // D2
        "E8", // D3                 jmp random
        "0A", // D4
        "8A", // D5 win:            ldi c, prize
        "E0", // D6
        "98", // D7 win_loop:       ld a, c
        "BC", // D8                 st a, d
        "4B", // D9                 inc d
        "4A", // DA                 inc c
        "E4", // DB                 jnz win_loop
        "D7", // DC
        "EC", // DD                 hlt
        "00", // DE ---
        "00", // DF ---

        // E0 (prize)
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
