namespace ComputerEmulator.V2;

internal static class Game
{
    public static IReadOnlyList<MyByte> Bytes()
    {
        return _bytes.Select(x => new MyByte(x)).ToList();
    }

    private static readonly IReadOnlyList<string> _bytes = [
        
        // 0000: BANK_CACHE (0)
        "03", // 00 jmp start_title         ; start
        "19", // 01                         ; ; будет перезаписан на " "
        "FC", // 02 "ь"
        "ED", // 03 "н"
        "E7", // 04 "з"
        "E8", // 05 "и"
        "C6", // 06 "Ж"
        "20", // 07 " "
        "E0", // 08 "а"
        "F0", // 09 "р"
        "E3", // 0A "г"
        "C8", // 0B "И"
        "20", // 0C " "
        "65", // 0D "e"
        "66", // 0E "f"
        "69", // 0F "i"
        "4C", // 10 "L"
        "20", // 11 " "
        "66", // 12 "f"
        "6F", // 13 "o"
        "20", // 14 " "
        "65", // 15 "e"
        "6D", // 16 "m"
        "61", // 17 "a"
        "47", // 18 "G"                     ; ; end_of_title
        "55", // 19 ldi b, " "              ; ; start_title
        "20", // 1A
        "35", // 1B st b, 0x01
        "01", // 1C
        "54", // 1D ldi a, terminal
        "3C", // 1E
        "56", // 1F ldi c, end_of_title
        
        // 0020
        "18", // 20
        "57", // 21 ldi d, title_loop
        "23", // 22
        "49", // 23 ld b, c               ; ; title_loop
        "31", // 24 st b, a                 ;
        "7A", // 25 dec c                   ;
        "2C", // 26 jnz d                   ;
        "54", // 27 ldi a, 00000110       ; ; bw screen + bcd
        "06", // 28
        "30", // 29 st a, in/out
        "3E", // 2A
        "54", // 2B ldi a, SCREEN_BEGIN   ; ; b = 0x20
        "40", // 2C
        "56", // 2D ldi c, BANK_MAIN
        "02", // 2E
        "57", // 2F ldi d, main_rnd
        "F6", // 30
        "3A", // 31 st c, bank          ; set_bank (c, d)
        "3F", // 32 
        "07", // 33 jmp d
        "00", // 34 ---
        "00", // 35 0x00                ; upper_start
        "10", // 36 0x10                ; current_start
        "20", // 37 0x20                ; lower_start
        "00", // 38 0x00                ; upper_cur
        "20", // 39 0x20                ; lower_cur
        "FF", // 3A 0xFF                ; step_count                ; bcd
        "00", // 3B ---                                             ; bcd (reserved)
        "00", // 3C                     ; incrementor               ; terminal
        "00", // 3D                     ; screen_cur                ; terminal (reserved)
        "0D", // 3E 00001101            ; color screen + terminal   ; in/out
        "00", // 3F 0                                               ; bank
        
        // 0040 (screen)
        "60", // 40 01100000 00000000
        "00", // 41
        "89", // 42 10001001 10100010
        "A2", // 43
        "A5", // 44 10100101 01010101
        "55", // 45
        "AD", // 46 10101101 01010110
        "56", // 47
        "6D", // 48 01101101 01010011
        "53", // 49
        "00", // 4A 00000000 00000000
        "00", // 4B
        "00", // 4C 00000000 01100000
        "60", // 4D
        "04", // 4E 00000100 10000000
        "80", // 4F
        "0A", // 50 00001010 11000000
        "C0", // 51
        "04", // 52 00000100 10000000
        "80", // 53
        "00", // 54 00000000 00000000
        "00", // 55
        "8E", // 56 10001110 11101110
        "EE", // 57
        "84", // 58 10000100 10001000
        "88", // 59
        "84", // 5A 10000100 11001100
        "CC", // 5B
        "84", // 5C 10000100 10001000
        "88", // 5D
        "EE", // 5E 11101110 10001110
        "8E", // 5F
        
        // 0060
        "00", // 60 ---
        "00", // 61 ---
        "00", // 62 ---
        "00", // 63 ---
        "00", // 64 ---
        "00", // 65 ---
        "00", // 66 ---
        "00", // 67 ---
        "00", // 68 ---
        "00", // 69 ---
        "00", // 6A ---
        "00", // 6B ---
        "00", // 6C ---
        "00", // 6D ---
        "00", // 6E ---
        "00", // 6F ---
        "00", // 70 ---
        "00", // 71 ---
        "00", // 72 ---
        "00", // 73 ---
        "00", // 74 ---
        "00", // 75 ---
        "00", // 76 ---
        "00", // 77 ---
        "00", // 78 ---
        "00", // 79 ---
        "00", // 7A ---
        "00", // 7B ---
        "00", // 7C ---
        "00", // 7D ---
        "00", // 7E ---
        "00", // 7F ---

        // 0080: BANK_INNER (1)
        "55", // 80 ldi b, inner_center ; inner_begin
        "B7", // 81
        "35", // 82 st b, inner_edge_jmp
        "A9", // 83
        "55", // 84 ldi b, inner_right
        "AA", // 85
        "35", // 86 st b, inner_center_jmp
        "C1", // 87
        "51", // 88 ld b, screen_cur
        "3D", // 89
        "44", // 8A ld a, b
        "E4", // 8B shr a
        "52", // 8C ld c, current_start
        "36", // 8D
        "6A", // 8E inc c
        "C0", // 8F rcl a               ; inner_edge (a, c)
        "0D", // 90 jns inner_edge_end
        "A7", // 91
        "53", // 92 ld d, upper_cur
        "38", // 93
        "4D", // 94 ld b, d
        "65", // 95 inc b
        "3D", // 96 st b, d
        "6F", // 97 inc d
        "4D", // 98 ld b, d
        "65", // 99 inc b
        "3D", // 9A st b, d
        "49", // 9B ld b, c
        "65", // 9C inc b
        "39", // 9D st b, c
        "53", // 9E ld d, lower_cur
        "39", // 9F

        // 00A0
        "4D", // A0 ld b, d
        "65", // A1 inc b
        "3D", // A2 st b, d
        "6F", // A3 inc d
        "4D", // A4 ld b, d
        "65", // A5 inc b
        "3D", // A6 st b, d
        "7A", // A7 dec c               ; ; inner_edge_end
        "03", // A8 jmp inner_center
        "B7", // A9                     ; ; inner_edge_jmp
        "55", // AA ldi b, inner_edge   ; inner_right (c)
        "8F", // AB
        "35", // AC st b, inner_center_jmp
        "C1", // AD
        "55", // AE ldi b, inner_end
        "F6", // AF
        "35", // B0 st b, inner_edge_jmp
        "A9", // B1
        "51", // B2 ld b, screen_cur
        "3D", // B3
        "65", // B4 inc b
        "44", // B5 ld a, b
        "E4", // B6 shr a
        "55", // B7 ldi b, 0x08         ; inner_center (a, c)
        "08", // B8
        "35", // B9 st b, incrementor
        "3C", // BA
        "51", // BB ld b, incrementor   ; ; inner_center_loop
        "3C", // BC
        "75", // BD dec b
        "35", // BE st b, incrementor
        "3C", // BF

        // 00C0
        "08", // C0 jz inner_right
        "AA", // C1                     ; ; inner_center_jmp
        "C0", // C2 rcl a
        "0D", // C3 jns inner_center_end
        "E9", // C4
        "53", // C5 ld d, upper_cur
        "38", // C6
        "4D", // C7 ld b, d
        "65", // C8 inc b
        "3D", // C9 st b, d
        "6F", // CA inc d
        "4D", // CB ld b, d
        "65", // CC inc b
        "3D", // CD st b, d
        "6F", // CE inc d
        "4D", // CF ld b, d
        "65", // D0 inc b
        "3D", // D1 st b, d
        "49", // D2 ld b, c
        "65", // D3 inc b
        "39", // D4 st b, c
        "6A", // D5 inc c
        "6A", // D6 inc c
        "49", // D7 ld b, c
        "65", // D8 inc b
        "39", // D9 st b, c
        "7A", // DA dec c
        "7A", // DB dec c
        "53", // DC ld d, lower_cur
        "39", // DD
        "4D", // DE ld b, d
        "65", // DF inc b

        // 00E0
        "3D", // E0 st b, d
        "6F", // E1 inc d
        "4D", // E2 ld b, d
        "65", // E3 inc b
        "3D", // E4 st b, d
        "6F", // E5 inc d
        "4D", // E6 ld b, d
        "65", // E7 inc b
        "3D", // E8 st b, d
        "53", // E9 ld d, upper_cur     ; ; inner_center_end
        "38", // EA
        "6F", // EB inc d
        "3F", // EC st d, upper_cur
        "38", // ED
        "6A", // EE inc c
        "53", // EF ld d, lower_cur
        "39", // F0
        "6F", // F1 inc d
        "3F", // F2 st d, lower_cur
        "39", // F3
        "03", // F4 jmp inner_center_loop
        "BB", // F5
        "56", // F6 ldi c, BANK_MAIN    ; inner_end
        "02", // F7
        "57", // F8 ldi d, main_calc
        "AC", // F9
        "03", // FA jmp set_bank
        "31", // FB
        "00", // FC ---
        "00", // FD ---
        "00", // FE ---
        "00", // FF ---
        
        // 0100: BANK_MAIN (2)
        "51", // 80 ld b, upper_start   ; main_row
        "35", // 81
        "52", // 82 ld c, current_start
        "36", // 83
        "53", // 84 ld d, lower_start
        "37", // 85
        "3A", // 86 st c, upper_start
        "35", // 87
        "3F", // 88 st d, current_start
        "36", // 89
        "35", // 8A st b, lower_start
        "37", // 8B
        "3A", // 8C st c, upper_cur
        "38", // 8D
        "35", // 8E st b, lower_cur
        "39", // 8F
        "53", // 90 ld d, screen_cur
        "3D", // 91
        "54", // 92 ldi a, 0x5E
        "5E", // 93
        "DC", // 94 xor a, d
        "08", // 95 jz main_row_end
        "A6", // 96
        "54", // 97 ldi a, 0xFE         ; ; b = lower_start
        "FE", // 98
        "56", // 99 ldi c, 0x10
        "10", // 9A
        "57", // 9B ldi d, main_row_loop
        "9D", // 9C 
        "34", // 9D st a, b             ; ; main_row_loop
        "65", // 9E inc b                 ;
        "7A", // 9F dec c                 ;

        // 0120
        "2C", // A0 jnz d                 ;
        "6A", // A1 inc c               ; ; = BANK_INNER
        "57", // A2 ldi d, inner_begin
        "80", // A3 
        "03", // A4 jmp set_bank
        "31", // A5 
        "56", // A6 ldi c, BANK_OUTER   ; ; main_row_end
        "03", // A7 
        "57", // A8 ldi d, outer_down
        "93", // A9 
        "03", // AA jmp set_bank
        "31", // AB 
        "52", // AC ld c, screen_cur    ; main_calc
        "3D", // AD 
        "53", // AE ld d, upper_start
        "35", // AF 
        "7A", // B0 dec c               ; ; main_calc_iteration (c, d)
        "7A", // B1 dec c
        "48", // B2 ld a, c
        "56", // B3 ldi c, 0x80
        "80", // B4 
        "4D", // B5 ld b, d             ; ; main_calc_loop
        "B5", // B6 test b
        "08", // B7 jz main_calc_next
        "BE", // B8
        "C8", // B9 or a, c
        "75", // BA dec b
        "08", // BB jz main_calc_next
        "BE", // BC
        "D8", // BD xor a, c
        "6F", // BE inc d               ; ; main_calc_next
        "E6", // BF shr c

        // 0140
        "0C", // C0 jnz main_calc_loop
        "B5", // C1 
        "52", // C2 ld c, screen_cur
        "3D", // C3 
        "55", // C4 ldi b, 0x1E         ; ; = 30
        "1E", // C5 
        "69", // C6 add b, c
        "34", // C7 st a, b
        "6A", // C8 inc c
        "3A", // C9 st c, screen_cur
        "3D", // CA 
        "E5", // CB shr b
        "0E", // CC jnc main_calc_iteration
        "B0", // CD 
        "03", // CE jmp main_row
        "80", // CF                     ; ; main_calc_jmp
        "55", // D0 ldi b, main_final2  ; main_final
        "D6", // D1 
        "35", // D2 st b, main_calc_jmp
        "CF", // D3 
        "03", // D4 jmp main_calc
        "AC", // D5 
        "55", // D6 ldi b, main_final3  ; ; main_final2 (c, d)
        "DC", // D7 
        "35", // D8 st b, main_calc_jmp
        "CF", // D9 
        "03", // DA jmp main_calc_iteration
        "B0", // DB 
        "55", // DC ldi b, main_row     ; ; main_final3
        "80", // DD 
        "35", // DE st b, main_calc_jmp
        "CF", // DF 

        // 0160
        "55", // E0 ldi b, SCREEN_BEGIN ; main_frame
        "40", // E1 
        "56", // E2 ldi c, 0x60
        "60", // E3 
        "57", // E4 ldi d, main_frame_loop
        "E6", // E5 
        "48", // E6 ld a, c             ; ; main_frame_loop
        "34", // E7 st a, b               ;
        "65", // E8 inc b                 ;
        "6A", // E9 inc c                 ;
        "2D", // EA jns d                 ;
        "50", // EB ld a, step_count    ; main_count
        "3A", // EC
        "60", // ED inc a
        "30", // EE st a, step_count
        "3A", // EF
        "56", // F0 ldi c, BANK_OUTER   ; ; d = outer_up
        "03", // F1 
        "57", // F2 ldi d, outer_up
        "80", // F3 
        "03", // F4 jmp set_bank
        "31", // F5 
        "EE", // F6 rnd c               ; main_rnd (a, b) ; ; main_rnd_loop
        "EF", // F7 rnd d                                   ;
        "BE", // F8 and c, d                                ;
        "32", // F9 st c, a                                 ;
        "60", // FA inc a                                   ;
        "75", // FB dec b                                   ;
        "0C", // FC jnz main_rnd_loop                       ;
        "F6", // FD                                         ;
        "03", // FE jmp main_count
        "EB", // FF

        // 0180: BANK_OUTER (3)
        "56", // 80 ldi c, SCREEN_BEGIN ; outer_up
        "40", // 81
        "3A", // 82 st c, screen_cur
        "3D", // 83
        "E6", // 84 shr c               ; ; = lower_start
        "3A", // 85 st c, lower_start
        "37", // 86
        "54", // 87 ldi a, 0xFE
        "FE", // 88
        "51", // 89 ld b, current_start ; ; c = 0x20
        "36", // 8A
        "57", // 8B ldi d, outer_up_loop
        "8D", // 8C
        "34", // 8D st a, b             ; ; outer_up_loop
        "65", // 8E inc b                 ;
        "7A", // 8F dec c                 ;
        "2C", // 90 jnz d                 ;
        "03", // 91 jmp outer_begin
        "96", // 92
        "AA", // 93 clr c               ; outer_down ; ; = upper_start
        "3A", // 94 st c, lower_start
        "37", // 95
        "55", // 96 ldi b, outer_center ; outer_begin
        "C4", // 97
        "35", // 98 st b, outer_edge_jmp
        "B6", // 99
        "55", // 9A ldi b, outer_right
        "B7", // 9B
        "35", // 9C st b, outer_center_jmp
        "CE", // 9D
        "51", // 9E ld b, screen_cur
        "3D", // 9F

        // 01A0
        "44", // A0 ld a, b
        "E4", // A1 shr a
        "56", // A2 ldi c, 0x11         ; ; = current_start + 1
        "11", // A3
        "53", // A4 ld d, lower_start
        "37", // A5
        "C0", // A6 rcl a               ; outer_edge (a, c, d)
        "0D", // A7 jns outer_edge_end
        "B4", // A8
        "49", // A9 ld b, c
        "65", // AA inc b
        "39", // AB st b, c
        "4D", // AC ld b, d
        "65", // AD inc b
        "3D", // AE st b, d
        "6F", // AF inc d
        "4D", // B0 ld b, d
        "65", // B1 inc b
        "3D", // B2 st b, d
        "7F", // B3 dec d
        "7A", // B4 dec c               ; ; outer_edge_end
        "03", // B5 jmp outer_center
        "C4", // B6                     ; ; outer_edge_jmp
        "55", // B7 ldi b, outer_edge   ; outer_right (c, d)
        "A6", // B8
        "35", // B9 st b, outer_center_jmp
        "CE", // BA
        "55", // BB ldi b, outer_end
        "ED", // BC
        "35", // BD st b, outer_edge_jmp
        "B6", // BE
        "51", // BF ld b, screen_cur

        // 01C0
        "3D", // C0
        "65", // C1 inc b
        "44", // C2 ld a, b
        "E4", // C3 shr a
        "55", // C4 ldi b, 0x08         ; outer_center (a, c, d)
        "08", // C5
        "35", // C6 st b, incrementor
        "3C", // C7 
        "51", // C8 ld b, incrementor   ; ; outer_center_loop
        "3C", // C9 
        "75", // CA dec b
        "35", // CB st b, incrementor
        "3C", // CC 
        "08", // CD jz outer_right
        "B7", // CE                     ; ; outer_center_jmp
        "C0", // CF rcl a
        "0D", // D0 jns outer_center_else
        "E9", // D1 
        "49", // D2 ld b, c
        "65", // D3 inc b
        "39", // D4 st b, c
        "6A", // D5 inc c
        "6A", // D6 inc c
        "49", // D7 ld b, c
        "65", // D8 inc b
        "39", // D9 st b, c
        "7A", // DA dec c
        "4D", // DB ld b, d
        "65", // DC inc b
        "3D", // DD st b, d
        "6F", // DE inc d
        "4D", // DF ld b, d

        // 01E0     
        "65", // E0 inc b
        "3D", // E1 st b, d
        "6F", // E2 inc d
        "4D", // E3 ld b, d
        "65", // E4 inc b
        "3D", // E5 st b, d
        "7F", // E6 dec d
        "03", // E7 jmp outer_center_loop
        "C8", // E8
        "6A", // E9 inc c               ; ; outer_center_else
        "6F", // EA inc d
        "03", // EB jmp outer_center_loop
        "C8", // EC 
        "56", // ED ldi c, BANK_MAIN    ; outer_end
        "02", // EE 
        "50", // EF ld a, lower_start
        "37", // F0 
        "B0", // F1 test a
        "08", // F2 jz outer_end_down
        "FC", // F3
        "54", // F4 ldi a, 0x42         ; ; outer_end_up
        "42", // F5
        "30", // F6 st a, screen_cur
        "3D", // F7
        "57", // F8 ldi d, main_row
        "80", // F9
        "03", // FA jmp set_bank
        "31", // FB 
        "57", // FC ldi d, main_final   ; ; outer_end_down
        "D0", // FD 
        "03", // FE jmp set_bank
        "31", // FF 
    ];
}
