; ##################################################################################################
; ##      Diagnostic disk #2: flag preservation (inc/dec/not/mov/shr), NEG flags, SBB chain       ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v1                 ##
; ##                         (c) 2026 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


                ldi d, terminal     ; Register D permanently holds the address for terminal output
                ldi c, 0x40         ; Probe counter: the code before the letter "A"
                ldi b, 0x32         ; Disk id marker: "2"
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

; Case 2: inc must preserve C=1, O=0 (raw inc 127 gives carry 0, overflow 1 - the opposite
; values)
t2:             inc c
                ldi a, 255
                ldi b, 1
                add a, b            ; Prepare C=1, O=0
                ldi a, 127
                inc a
                jc t2o
                st c, d             ; "C" = inc 127 destroyed C=1
t2o:            inc c
                jno t3
                st c, d             ; "D" = inc 127 latched its raw overflow into O

; Case 3: inc must preserve C=0, O=1 (raw inc 255 gives carry 1, overflow 0 - the opposite
; values)
t3:             inc c
                ldi a, 127
                ldi b, 1
                add a, b            ; Prepare C=0, O=1
                ldi a, 255
                inc a
                jnc t3o
                st c, d             ; "E" = inc 255 latched its raw carry into C
t3o:            inc c
                jo t4
                st c, d             ; "F" = inc 255 destroyed O=1
                jmp t4

void        db  0, 0, 0, 0, 0, 0, 0, 0

; Ports
keyboard    db  0                   ; Keyboard port
output      db  0x40                ; Output select port: the terminal is connected at load time
terminal    db  0                   ; A byte stored here is printed to the terminal

; Case 4: dec must preserve C=1, O=1 (raw dec 0 gives carry 0, overflow 0)
t4:             inc c
                ldi a, 128
                ldi b, 128
                add a, b            ; Prepare C=1, O=1
                mov a, 0
                dec a
                jc t4o
                st c, d             ; "G" = dec 0 destroyed C=1
t4o:            inc c
                jo t5
                st c, d             ; "H" = dec 0 destroyed O=1

; Case 5: dec must preserve C=0, O=1 (raw dec 5 gives carry 1, overflow 0)
t5:             inc c
                ldi a, 127
                ldi b, 1
                add a, b            ; Prepare C=0, O=1
                ldi a, 5
                dec a
                jnc t5o
                st c, d             ; "I" = dec 5 latched its raw carry into C
t5o:            inc c
                jo t6
                st c, d             ; "J" = dec 5 destroyed O=1

; Case 6: not must preserve C=1, O=1. Operand is 0 left in A by the prepare add.
t6:             inc c
                ldi a, 128
                ldi b, 128
                add a, b            ; Prepare C=1, O=1; A = 0
                not a
                jc t6o
                st c, d             ; "K" = not destroyed C=1
t6o:            inc c
                jo t7
                st c, d             ; "L" = not destroyed O=1

; Case 7: mov must preserve C=1, O=1 (not an ALU operation at all)
t7:             inc c
                ldi a, 128
                ldi b, 128
                add a, b            ; Prepare C=1, O=1
                mov a, b
                jc t7o
                st c, d             ; "M" = mov destroyed C=1
t7o:            inc c
                jo t8
                st c, d             ; "N" = mov destroyed O=1

; Case 8: shr 5 must set C=1 from the shifted-out bit and preserve O=1
t8:             inc c
                ldi a, 127
                ldi b, 1
                add a, b            ; Prepare C=0, O=1
                ldi a, 5
                shr a
                jc t8o
                st c, d             ; "O" = shr 5 did not set C from the shifted-out bit
t8o:            inc c
                jo t9
                st c, d             ; "P" = shr destroyed O=1

; NEG checks: behaves like sub with zero on the left - C for a non-zero operand, O only for 128

; Case 9: neg 5 with C=0, O=0 prepared, expect C=1, O=0
t9:             inc c
                ldi a, 1
                ldi b, 1
                add a, b            ; Prepare C=0, O=0
                ldi a, 5
                neg a
                jc t9o
                st c, d             ; "Q" = no carry after neg 5
t9o:            inc c
                jno t10
                st c, d             ; "R" = false overflow after neg 5

; Case 10: neg 5 with C=1 prepared, expect C=1, O=0
t10:            inc c
                ldi a, 255
                ldi b, 1
                add a, b            ; Prepare C=1, O=0
                ldi a, 5
                neg a
                jc t10o
                st c, d             ; "S" = no carry after neg 5 with C=1 prepared
t10o:           inc c
                jno t11
                st c, d             ; "T" = false overflow after neg 5 with C=1 prepared

; Case 11: neg 0 with C=1 prepared, expect C=0, O=0
t11:            inc c
                ldi a, 255
                ldi b, 1
                add a, b            ; Prepare C=1, O=0
                mov a, 0
                neg a
                jnc t11o
                st c, d             ; "U" = neg 0 did not clear C=1
t11o:           inc c
                jno t12
                st c, d             ; "V" = false overflow after neg 0

; Case 12: neg 128 with C=0, O=0 prepared, expect C=1, O=1 (-128 has no pair)
t12:            inc c
                ldi a, 1
                ldi b, 1
                add a, b            ; Prepare C=0, O=0
                ldi a, 128
                neg a
                jc t12o
                st c, d             ; "W" = no carry after neg 128
t12o:           inc c
                jo t13
                st c, d             ; "X" = no overflow after neg 128 (-128 has no pair)

; Case 13: direct sbb: 5-3-1 with C=1 prepared, expect result 1, C=0, O=0
t13:            inc c
                ldi a, 255
                ldi b, 1
                add a, b            ; Prepare C=1
                ldi a, 5
                ldi b, 3
                sbb a, b            ; 5-3-1 = 1
                jnc t13o
                st c, d             ; "Y" = false carry after sbb 5-3-1
t13o:           inc c
                jno t14
                st c, d             ; "Z" = false overflow after sbb 5-3-1

; Case 14: 16-bit chain 0x0100 - 0x0001 = 0x00FF: sub makes the carry, sbb must consume it
t14:            ldi a, 7            ; The "+7" step: jump the probe counter over the codes between
                                    ;   "Z" and "a"
                add c, a
                mov a, 0
                ldi b, 1
                sub a, b            ; Low byte: 0-1 = 255, carry out
                ldi a, 1
                ldi b, 0
                sbb a, b            ; High byte: 1-0-C = 0, no carry out
                jz t14o             ; The Z probe must run before "inc c", which legally rewrites Z
                st c, d             ; "a" = high byte of 0x0100-0x0001 is not zero, the chain is
                                    ;   broken
t14o:           inc c
                jnc tchk
                st c, d             ; "b" = carry out of the high byte of 0x0100-0x0001

; Counter check: after 28 probes the probe counter must be exactly "b"
tchk:           mov a, c
                ldi b, 0x62         ; The code of the letter "b"
                xor a, b
                jz tdot
                ldi c, 0x23         ; "#" = control flow went off plan, some probes did not run
                st c, d
tdot:           ldi c, 0x2E         ; End marker "."
                st c, d
                hlt
