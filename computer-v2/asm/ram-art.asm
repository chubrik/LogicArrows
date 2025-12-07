; ##################################################################################################
; ##           Source code for the "RAM Art" program for a computer made of logic arrows          ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                         (c) 2025 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


INC_C       equ 0x6A                    ; Instruction code "inc c"
HLT         equ 0x01                    ; Instruction code "hlt"

start:          jmp stage1

; Left part of the image, except for the first two bytes, which are restored in the "stage1" block
data1       db                          0b11100011, 0b00000010,

                0b10100111, 0b11100010, 0b00100000, 0b10000101,
                0b00100100, 0b00000000, 0b00000011, 0b11100100,
                0b01000100, 0b00000010, 0b00000000, 0b00000010,
                0b10100000, 0b00110011, 0b11100011, 0b11100101,

                0b10000001, 0b11100010, 0b00000001, 0b10000001,
                0b01000010, 0b00100000, 0b00000010, 0b01100010,
                0b10100011, 0b11100011, 0b11110000, 0b00000101,
                0b00100000, 0b00110010, 0b01000011, 0b11000100

data1_end   equ $ - 1

; Top-level loop, iterating through memory banks for writing
bank_start:     ld a, bank
                dec a
bank_set:       st a, bank
                ldi d, 0xFF             ; Pointer for writing

; Mid-level loop, iterating through source bytes.
; Register C already contains the read pointer.
byte_start:     dec c                   ; Replaceable direction of movement through the source
byte_jmp:       js stage2               ; Replaceable jump address
                inc b

; Low-level loop, iterating through bits in the source byte
bit_start:      ld a, c
                and a, b
                jz bit_end

; Writing to RAM, which visually results in the appearance of a "pixel"
                ldi a, 0xFF
                st a, d

; End of a loop at one level or another
bit_end:        shl b
                dec d
                jnc bit_start
                js byte_start
                jmp bank_start

in_out      db  0
bank        db  4                       ; The memory bank is not connected when loading from a disk,
                                        ;   but decrementing the value allows starting writing from
                                        ;   the correct place

; Right part of the image
data2       db  0b00000010, 0b10000000, 0b00000000, 0b01000000,
                0b00000001, 0b10000000, 0b00000000, 0b10000000,
                0b00000101, 0b00000000, 0b00000000, 0b10100000,
                0b00000010, 0b11000000, 0b00000001, 0b01000000,

                0b00000100, 0b00100000, 0b00000010, 0b00100000,
                0b00000101, 0b11000000, 0b00000001, 0b10100000,
                0b00000010, 0b00000000, 0b00000000, 0b01000000,
                0b00000001, 0b11100000, 0b00000011, 0b10000000,

                0b10100101, 0b00000111, 0b00000010, 0b10100000,
                0b00000010, 0b11100000, 0b00000001, 0b01000000,
                0b00000100, 0b00000011, 0b00000000, 0b00100000,
                0b10100101, 0b00100100, 0b00000001, 0b10100000,

                0b00000010, 0b10100010, 0b00100010, 0b01000001,
                0b00000001, 0b11000000, 0b10100001, 0b10000010,
                0b11100101, 0b00000011, 0b11000000, 0b10100001,
                0b00100010, 0b10000000, 0b00000001, 0b01000000

; Preparing to output the left part of the image
stage1:         ldi c, 0b01000000       ; Restore the first two bytes in the left part of the image
                ldi d, 0b00000011
                st c, b                 ; b = 0x00
                st d, 0x01
                ldi c, data1_end + 1    ; Pointer to the source
                jmp bank_start

; Preparing to output the right part of the image
stage2:         ldi c, INC_C            ; Replace the direction of movement through the source
                st c, byte_start
                st b, byte_jmp + 1      ; Replace the loop exit address with 0x00
                ldi c, HLT              ; Write the program termination instruction to address 0x00
                st c, b
                ldi a, 7                ; Number of the rightmost memory bank
                ldi c, data2 - 1        ; Pointer to the source
                jmp bank_set
