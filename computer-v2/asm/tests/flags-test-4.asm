; ##################################################################################################
; ##   Diagnostic diskette #4: CMP flags - Z is equality, S is signed less, C is unsigned less    ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                         (c) 2026 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


                ldi d, terminal     ; Register D permanently holds the address for terminal output
                ldi c, "A" - 1      ; Probe counter
                ldi b, "4"          ; Diskette ID marker
                st b, d

; Case 1 (canary): add 255+1, expect C=1, O=0
                inc c
                ldi a, 255
                ldi b, 1
                add a, b
                jc t1o
                st c, d             ; "A" = no carry after add 255+1
t1o:            inc c
                jno t2
                st c, d             ; "B" = false overflow after add 255+1

; Case 2: cmp 5, 3 - greater on both readings, expect Z=0, S=0, C=0
t2:             inc c
                ldi a, 5
                ldi b, 3
                cmp a, b
                jnz t2s
                st c, d             ; "C" = false equality after cmp 5, 3
t2s:            inc c
                jns t2c
                st c, d             ; "D" = false signed less after cmp 5, 3
t2c:            inc c
                jnc t3
                st c, d             ; "E" = false unsigned less after cmp 5, 3

; Case 3: cmp 3, 5 - less on both readings, expect S=1, C=1, O=0
t3:             inc c
                ldi a, 3
                ldi b, 5
                cmp a, b
                js t3c
                st c, d             ; "F" = no signed less after cmp 3, 5
t3c:            inc c
                jc t3o
                st c, d             ; "G" = no unsigned less after cmp 3, 5
t3o:            inc c
                jno t4
                st c, d             ; "H" = false overflow after cmp 3, 5
                jmp t4

void        db  0, 0

; Ports (loaded with the diskette; the in_out value connects the terminal during loading)
bcd         db  0, 0
terminal    db  0, 0
in_out      db  0b00000001
bank        db  0

; Case 4: cmp 5, 5 - equality, expect Z=1, S=0, C=0
t4:             inc c
                ldi a, 5
                ldi b, 5
                cmp a, b
                jz t4s
                st c, d             ; "I" = no equality after cmp 5, 5
t4s:            inc c
                jns t4c
                st c, d             ; "J" = false signed less after cmp 5, 5
t4c:            inc c
                jnc t5
                st c, d             ; "K" = false unsigned less after cmp 5, 5

; Case 5: cmp 255, 1 - the readings disagree: -1 < 1 signed, 255 > 1 unsigned. Expect S=1, C=0, O=0
t5:             inc c
                ldi a, 255
                ldi b, 1
                cmp a, b
                js t5c
                st c, d             ; "L" = no signed less after cmp 255, 1
t5c:            inc c
                jnc t5o
                st c, d             ; "M" = false unsigned less after cmp 255, 1
t5o:            inc c
                jno t6
                st c, d             ; "N" = false overflow after cmp 255, 1

; Case 6: cmp 1, 255 - the mirror of case 5: 1 > -1 signed, 1 < 255 unsigned. Expect S=0, C=1, O=0
t6:             inc c
                ldi a, 1
                ldi b, 255
                cmp a, b
                jns t6c
                st c, d             ; "O" = false signed less after cmp 1, 255
t6c:            inc c
                jc t6o
                st c, d             ; "P" = no unsigned less after cmp 1, 255
t6o:            inc c
                jno t7
                st c, d             ; "Q" = false overflow after cmp 1, 255

; Case 7: cmp 200, 100 - the difference -56-100 overflows, and its raw byte reads as positive;
; the true signed answer is -56 < 100. Expect S=1, C=0, O=1
t7:             inc c
                ldi a, 200
                ldi b, 100
                cmp a, b
                js t7c
                st c, d             ; "R" = no signed less after cmp 200, 100
t7c:            inc c
                jnc t7o
                st c, d             ; "S" = false unsigned less after cmp 200, 100
t7o:            inc c
                jo t8
                st c, d             ; "T" = no overflow after cmp 200, 100

; Case 8: cmp 100, 200 - the mirror of case 7, the raw byte reads as negative. Expect S=0, C=1, O=1
t8:             inc c
                ldi a, 100
                ldi b, 200
                cmp a, b
                jns t8c
                st c, d             ; "U" = false signed less after cmp 100, 200
t8c:            inc c
                jc t8o
                st c, d             ; "V" = no unsigned less after cmp 100, 200
t8o:            inc c
                jo t9
                st c, d             ; "W" = no overflow after cmp 100, 200

; Case 9: cmp 128, 127 - the extreme: -128 vs 127, difference -255. Expect S=1, C=0, O=1
t9:             inc c
                ldi a, 128
                ldi b, 127
                cmp a, b
                js t9c
                st c, d             ; "X" = no signed less after cmp 128, 127
t9c:            inc c
                jnc t9o
                st c, d             ; "Y" = false unsigned less after cmp 128, 127
t9o:            inc c
                jo t10
                st c, d             ; "Z" = no overflow after cmp 128, 127

; Case 10: cmp 127, 128 - the mirror of case 9: 127 vs -128, difference +255. Expect S=0, C=1, O=1
t10:            ldi b, 7            ; The "+7" step: jump the probe counter over the codes between
                                    ;   "Z" and "a"
                add c, b
                ldi a, 127
                ldi b, 128
                cmp a, b
                jns t10c
                st c, d             ; "a" = false signed less after cmp 127, 128
t10c:           inc c
                jc t10o
                st c, d             ; "b" = no unsigned less after cmp 127, 128
t10o:           inc c
                jo t11
                st c, d             ; "c" = no overflow after cmp 127, 128

; Case 11: cmp 128, 128 - equality at the signed minimum, expect Z=1, S=0
t11:            inc c
                ldi a, 128
                ldi b, 128
                cmp a, b
                jz t11s
                st c, d             ; "d" = no equality after cmp 128, 128
t11s:           inc c
                jns t12
                st c, d             ; "e" = false signed less after cmp 128, 128

; Case 12: cmp b, a - another opcode, the pair of case 7 reversed: 100 vs -56. Expect S=0, C=1, O=1
t12:            inc c
                ldi a, 200
                ldi b, 100
                cmp b, a
                jns t12c
                st c, d             ; "f" = false signed less after cmp b, a (100 vs 200)
t12c:           inc c
                jc t12o
                st c, d             ; "g" = no unsigned less after cmp b, a (100 vs 200)
t12o:           inc c
                jo t13
                st c, d             ; "h" = no overflow after cmp b, a (100 vs 200)

; Case 13: cmp a, d - the pair with register D: both hold the terminal address. Expect Z=1, C=0
t13:            inc c
                ldi a, terminal
                cmp a, d
                jz t13c
                st c, d             ; "i" = no equality after cmp a, d (equal values)
t13c:           inc c
                jnc tchk
                st c, d             ; "j" = false unsigned less after cmp a, d (equal values)

; Counter check: after 36 probes the probe counter must be exactly "j"
tchk:           ldi b, "j"
                xor b, c
                jz tdot
                ldi c, "#"          ; "#" = control flow went off plan, some probes did not run
                st c, d
tdot:           ldi c, "."          ; End marker: the program ran to the end
                st c, d

                hlt
