; ##################################################################################################
; ##       Diagnostic disk #3: the X, 0 forms - effect on the C and O flags and the result        ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v1                 ##
; ##                         (c) 2026 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


                ldi d, terminal     ; Register D permanently holds the address for terminal output
                ldi c, 0x40         ; Probe counter: the code before the letter "A"
                ldi b, 0x33         ; Disk id marker: "3"
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

; Case 2: sub a, 0 with A=5 and C=1, O=1 prepared, expect honest 5-0: A=5, C=0, O=0
t2:             inc c
                ldi a, 128
                ldi b, 128
                add a, b            ; Prepare C=1, O=1
                ldi a, 5
                sub a, 0
                jnc t2o
                st c, d             ; "C" = sub a, 0 did not clear C
t2o:            inc c
                jno t2r
                st c, d             ; "D" = sub a, 0 did not clear O
t2r:            inc c
                ldi b, 5
                xor a, b
                jz t3
                st c, d             ; "E" = sub a, 0 changed the value of A (expect 5-0 = 5)
                jmp t3

void        db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

; Ports
keyboard    db  0                   ; Keyboard port
output      db  0x40                ; Output select port: the terminal is connected at load time
terminal    db  0                   ; A byte stored here is printed to the terminal

; Case 3: add a, 0 with A=5 and C=1, O=1 prepared, expect honest 5+0: A=5, C=0, O=0
t3:             inc c
                ldi a, 128
                ldi b, 128
                add a, b            ; Prepare C=1, O=1
                ldi a, 5
                add a, 0
                jnc t3o
                st c, d             ; "F" = add a, 0 did not clear C
t3o:            inc c
                jno t3r
                st c, d             ; "G" = add a, 0 did not clear O
t3r:            inc c
                ldi b, 5
                xor a, b
                jz t4
                st c, d             ; "H" = add a, 0 changed the value of A (expect 5+0 = 5)

; Case 4: adc a, 0 with A=5 and C=1, O=1 prepared, expect honest 5+0+C: A=6, C=0, O=0.
; Community programs use this form as "A += C" when carrying into the high byte.
t4:             inc c
                ldi a, 128
                ldi b, 128
                add a, b            ; Prepare C=1, O=1
                ldi a, 5
                adc a, 0
                jnc t4o
                st c, d             ; "I" = adc a, 0 did not clear C
t4o:            inc c
                jno t4r
                st c, d             ; "J" = adc a, 0 did not clear O
t4r:            inc c
                ldi b, 6
                xor a, b
                jz t5
                st c, d             ; "K" = adc a, 0 did not consume the C flag (expect 5+0+C = 6)

; Case 5: sbb a, 0 with A=5 and C=1, O=1 prepared, expect honest 5-0-C: A=4, C=0, O=0
t5:             inc c
                ldi a, 128
                ldi b, 128
                add a, b            ; Prepare C=1, O=1
                ldi a, 5
                sbb a, 0
                jnc t5o
                st c, d             ; "L" = sbb a, 0 did not clear C
t5o:            inc c
                jno t5r
                st c, d             ; "M" = sbb a, 0 did not clear O
t5r:            inc c
                ldi b, 4
                xor a, b
                jz tchk
                st c, d             ; "N" = sbb a, 0 did not consume the C flag (expect 5-0-C = 4)

; Counter check: after 14 probes the probe counter must be exactly "N"
tchk:           mov a, c
                ldi b, 0x4E         ; The code of the letter "N"
                xor a, b
                jz tdot
                ldi c, 0x23         ; "#" = control flow went off plan, some probes did not run
                st c, d
tdot:           ldi c, 0x2E         ; End marker "."
                st c, d
                hlt
