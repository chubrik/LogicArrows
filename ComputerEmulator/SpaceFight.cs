namespace ComputerEmulator;

internal static class SpaceFight
{
    public static IReadOnlyList<MyByte> Bytes()
    {
        return _bytes.Select(x => new MyByte(x)).ToList();
    }

    private static readonly IReadOnlyList<string> _bytes = [

        // 00
        "8A", // 00 CLEAR: ldi c, 0x5C
        "5C", // 01
        "8B", // 02        ldi d, CLEAR_TO
        "58", // 03
        "4E", // 04        loop1: dec c
        "B9", // 05               st b, c
        "02", // 06               mov a, c
        "1B", // 07               xor a, d
        "E4", // 08               jnz loop1
        "04", // 09
        "8A", // 0A RND (d): ldi c, 0x40
        "40", // 0B
        "A8", // 0C          loop2: rnd a
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
        "E4", // 1A                 jnz loop2
        "0C", // 1B
        "80", // 1C SCORE: ld a, &win_left
        "3C", // 1D
        "20", // 1E        add a, 0
        "8B", // 1F        ldi d, 0x40       ; for WIN

        // 20
        "40", // 20
        "9D", // 21        ld b, d
        "8A", // 22        ldi c, OUT_NUM
        "10", // 23        
        "A2", // 24        st c, &out
        "3F", // 25        
        "BC", // 26        st a, d
        "8A", // 27        ldi c, OUT_SCR
        "80", // 28        
        "A2", // 29        st c, &out
        "3F", // 2A        
        "BD", // 2B        st b, d
        "E0", // 2C        jz WIN
        "D4", // 2D
        "89", // 2E STEP:  ldi b, STEP+      ; for KEYS, LEFT, RIGHT
        "30", // 2F
        "80", // 30 STEP+: ld a, &step_left
        "3B", // 31
        "4C", // 32        dec a
        "E2", // 33        js LEVEL
        "B1", // 34
        "A0", // 35        st a, &step_left
        "3B", // 36
        "00", // 37 KEYS (b): mov a, 0
        "E8", // 38           jmp 0x60
        "60", // 39
        "0E", // 3A step_cnt: 14
        "0E", // 3B step_left: 14
        "1E", // 3C win_left: 30
        "00", // 3D (bank): 0
        "00", // 3E (in): 0
        "80", // 3F (out): 0x80

        // 40 (screen)
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

        // 60 (...KEYS)
        "82", // 60           ld c, &in
        "3E", // 61
        "A0", // 62           st a, &in
        "3E", // 63
        "88", // 64           ldi a, KEY_FIRE
        "20", // 65
        "1A", // 66           xor a, c
        "E0", // 67           jz FIRE
        "92", // 68
        "88", // 69           ldi a, KEY_RIGHT
        "27", // 6A
        "1A", // 6B           xor a, c
        "E0", // 6C           jz RIGHT
        "82", // 6D
        "88", // 6E           ldi a, KEY_LEFT
        "25", // 6F
        "1A", // 70           xor a, c
        "D4", // 71           jnz b          ; STEP+
        "80", // 72 LEFT (b): ld a, 0x5E
        "5E", // 73
        "50", // 74           shl a
        "C5", // 75           jc b           ; STEP+
        "8B", // 76           ldi d, 0x5F    ; move
        "5F", // 77
        "8A", // 78           ldi c, 4
        "04", // 79
        "9C", // 7A           loop3: ld a, d
        "60", // 7B                  rcl a
        "BC", // 7C                  st a, d
        "4F", // 7D                  dec d
        "4E", // 7E                  dec c
        "E4", // 7F                  jnz loop3

        // 80
        "7A", // 80
        "F4", // 81           jmp b          ; STEP+
        "80", // 82 RIGHT (b): ld a, 0x5F
        "5F", // 83
        "54", // 84            shr a
        "C5", // 85            jc b          ; STEP+
        "8B", // 86            ldi d, 0x5C   ; move
        "5C", // 87
        "8A", // 88            ldi c, 4
        "04", // 89
        "9C", // 8A            loop4: ld a, d
        "64", // 8B                   rcr a
        "BC", // 8C                   st a, d
        "4B", // 8D                   inc d
        "4E", // 8E                   dec c
        "E4", // 8F                   jnz loop4
        "8A", // 90
        "F4", // 91            jmp b         ; STEP+
        "8B", // 92 FIRE: ldi d, 0x5C
        "5C", // 93
        "9C", // 94       ld a, d
        "20", // 95       add a, 0
        "E4", // 96       jnz shot
        "99", // 97
        "4B", // 98       inc d
        "9D", // 99       shot: ld b, d
        "8A", // 9A             ldi c, 14
        "0E", // 9B
        "4F", // 9C       loop5: dec d
        "4F", // 9D              dec d
        "9C", // 9E              ld a, d
        "09", // 9F              and a, b

        // A0
        "E4", // A0              jnz hit
        "A7", // A1
        "4E", // A2              dec c
        "E4", // A3              jnz loop5
        "9C", // A4
        "E8", // A5       jmp STEP
        "2E", // A6
        "9C", // A7       hit: ld a, d
        "19", // A8            xor a, b
        "BC", // A9            st a, d
        "80", // AA            ld a, &win_left
        "3C", // AB
        "4C", // AC            dec a
        "A0", // AD            st a, &win_left
        "3C", // AE
        "E8", // AF            jmp SCORE
        "1C", // B0
        "80", // B1 LEVEL: ld a, &step_cnt
        "3A", // B2
        "4C", // B3        dec a
        "4C", // B4        dec a
        "A0", // B5        st a, &step_cnt
        "3A", // B6
        "A0", // B7        st a, &step_left
        "3B", // B8
        "8A", // B9        ldi c, 0x5A       ; for SCROLL
        "5A", // BA
        "98", // BB        ld a, c
        "81", // BC        ld b, 0x5B
        "5B", // BD
        "11", // BE        or a, b
        "E0", // BF        jz SCROLL

        // C0
        "C7", // C0
        "4A", // C1        inc c             ; lose
        "4A", // C2        inc c
        "88", // C3        ldi a, (hlt)
        "EC", // C4
        "A0", // C5        st a, SCORE
        "1C", // C6
        "8B", // C7 SCROLL (c): ldi d, 0x42  ; for RND
        "42", // C8
        "4E", // C9             loop6: dec c
        "02", // CA                    mov a, c
        "91", // CB                    ld b, a
        "48", // CC                    inc a
        "48", // CD                    inc a
        "B1", // CE                    st b, a
        "1B", // CF                    xor a, d
        "E4", // D0                    jnz loop6
        "C9", // D1
        "E8", // D2             jmp RND
        "0A", // D3
        "8A", // D4 WIN (d): ldi c, 0xE0
        "E0", // D5
        "98", // D6          loop7: ld a, c
        "BC", // D7                 st a, d
        "4B", // D8                 inc d
        "4A", // D9                 inc c
        "E4", // DA                 jnz loop7
        "D6", // DB
        "EC", // DC          hlt
        "00", // DD ---
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
