; ##################################################################################################
; ##         Diagnostic disk #1: C and O flags after ADD (canaries) and SUB (main cases)          ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                         (c) 2026 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


                ldi d, terminal     ; Register D permanently holds the address for terminal output
                ldi c, "A" - 1      ; Probe counter
                ldi b, "1"          ; Disk id marker
                st b, d

; Case 1: add 255+1, expect C=1, O=0
                inc c
                ldi a, 255
                ldi b, 1
                add a, b
                jc t1o
                st c, d             ; "A" = no carry after add 255+1
t1o:            inc c
                jno t2
                st c, d             ; "B" = false overflow after add 255+1

; Case 2: add 1+1, expect C=0, O=0
t2:             inc c
                ldi a, 1
                ldi b, 1
                add a, b
                jnc t2o
                st c, d             ; "C" = false carry after add 1+1
t2o:            inc c
                jno t3
                st c, d             ; "D" = false overflow after add 1+1

; Case 3: add 127+1, expect C=0, O=1
t3:             inc c
                ldi a, 127
                ldi b, 1
                add a, b
                jnc t3o
                st c, d             ; "E" = false carry after add 127+1
t3o:            inc c
                jo t4
                st c, d             ; "F" = no overflow after add 127+1
                jmp t4

void        db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0

; Ports
bcd         db  0, 0
terminal    db  0, 0
in_out      db  0b00000001          ; Terminal connected
bank        db  0

; Case 4: add 128+128, expect C=1, O=1
t4:             inc c
                ldi a, 128
                ldi b, 128
                add a, b
                jc t4o
                st c, d             ; "G" = no carry after add 128+128
t4o:            inc c
                jo t5
                st c, d             ; "H" = no overflow after add 128+128

; Case 5: sub 5-3, expect C=0, O=0
t5:             inc c
                ldi a, 5
                ldi b, 3
                sub a, b
                jnc t5o
                st c, d             ; "I" = C set after 5-3, the raw-carry symptom
t5o:            inc c
                jno t6
                st c, d             ; "J" = false overflow after 5-3

; Case 6: sub 5-5, expect C=0, O=0. The ">" vs ">=" boundary.
t6:             inc c
                ldi a, 5
                ldi b, 5
                sub a, b
                jnc t6o
                st c, d             ; "K" = C set after 5-5: raw carry is set on equality too
t6o:            inc c
                jno t7
                st c, d             ; "L" = false overflow after 5-5

; Case 7: sub 3-5, expect C=1, O=0. The mirror of case 5.
t7:             inc c
                ldi a, 3
                ldi b, 5
                sub a, b
                jc t7o
                st c, d             ; "M" = no carry after 3-5
t7o:            inc c
                jno t8
                st c, d             ; "N" = false overflow after 3-5

; Case 8: sub 0-0, expect C=0, O=0. Equality at zero.
t8:             inc c
                clr a
                clr b
                sub a, b
                jnc t8o
                st c, d             ; "O" = C set after 0-0
t8o:            inc c
                jno t9
                st c, d             ; "P" = false overflow after 0-0

; Case 9: sub 0-1, expect C=1, O=0. Carry through zero, result 255.
t9:             inc c
                clr a
                ldi b, 1
                sub a, b
                jc t9o
                st c, d             ; "Q" = no carry after 0-1
t9o:            inc c
                jno t10
                st c, d             ; "R" = false overflow after 0-1

; Case 10: sub 255-255, expect C=0, O=0. Equality at maximum.
t10:            inc c
                ldi a, 255
                ldi b, 255
                sub a, b
                jnc t10o
                st c, d             ; "S" = C set after 255-255
t10o:           inc c
                jno t11
                st c, d             ; "T" = false overflow after 255-255

; Case 11: sub 0-255, expect C=1, O=0. Maximum carry.
t11:            inc c
                clr a
                ldi b, 255
                sub a, b
                jc t11o
                st c, d             ; "U" = no carry after 0-255
t11o:           inc c
                jno t12
                st c, d             ; "V" = false overflow after 0-255

; Case 12: sub 255-0, expect C=0, O=0. Subtracting zero from maximum.
t12:            inc c
                ldi a, 255
                clr b
                sub a, b
                jnc t12o
                st c, d             ; "W" = C set after 255-0
t12o:           inc c
                jno t13
                st c, d             ; "X" = false overflow after 255-0

; Case 13: sub 128-1, expect C=0, O=1. Signed overflow down: -128-1.
t13:            inc c
                ldi a, 128
                ldi b, 1
                sub a, b
                jnc t13o
                st c, d             ; "Y" = C set after 128-1
t13o:           inc c
                jo t14
                st c, d             ; "Z" = no overflow after 128-1

; Case 14: sub 127-255, expect C=1, O=1. Signed overflow up: 127-(-1).
t14:            ldi b, 7            ; The "+7" step: jump the probe counter over the codes between
                                    ;   "Z" and "a"
                add c, b
                ldi a, 127
                ldi b, 255
                sub a, b
                jc t14o
                st c, d             ; "a" = no carry after 127-255
t14o:           inc c
                jo t15
                st c, d             ; "b" = no overflow after 127-255

; Case 15: sub 200-100, expect C=0, O=1. Signed overflow: (-56)-100.
t15:            inc c
                ldi a, 200
                ldi b, 100
                sub a, b
                jnc t15o
                st c, d             ; "c" = C set after 200-100
t15o:           inc c
                jo t16
                st c, d             ; "d" = no overflow after 200-100

; Case 16: sub 128-128, expect C=0, O=0. Equal signed minimums.
t16:            inc c
                ldi a, 128
                ldi b, 128
                sub a, b
                jnc t16o
                st c, d             ; "e" = C set after 128-128
t16o:           inc c
                jno tchk
                st c, d             ; "f" = false overflow after 128-128

; Counter check: after 32 probes the probe counter must be exactly "f"
tchk:           ldi b, "f"
                xor b, c
                jz tdot
                ldi c, "#"          ; "#" = control flow went off plan, some probes did not run
                st c, d
tdot:           ldi c, "."          ; End marker "."
                st c, d
                hlt
