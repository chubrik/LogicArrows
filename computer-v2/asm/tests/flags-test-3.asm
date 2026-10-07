; ##################################################################################################
; ##        Diagnostic diskette #3: S and Z flags after the logical operations (and/or/xor)       ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                         (c) 2026 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


                ldi d, terminal     ; Register D permanently holds the address for terminal output
                ldi c, "A" - 1      ; Probe counter
                ldi b, "3"          ; Diskette id marker
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

; Case 2: xor 0xFF, 0x7F = 0x80, expect S=1
t2:             inc c
                ldi a, 0xFF
                ldi b, 0x7F
                xor a, b
                js t3
                st c, d             ; "C" = no sign after xor with result 0x80

; Case 3: xor 0xFF, 0xFE = 0x01, expect S=0
t3:             inc c
                ldi a, 0xFF
                ldi b, 0xFE
                xor a, b
                jns t4
                st c, d             ; "D" = false sign after xor with result 0x01

; Case 4: and 0x81, 0x80 = 0x80, expect S=1
t4:             inc c
                ldi a, 0x81
                ldi b, 0x80
                and a, b
                js t5
                st c, d             ; "E" = no sign after and with result 0x80

; Case 5: and 0x7F, 0x01 = 0x01, expect S=0
t5:             inc c
                ldi a, 0x7F
                ldi b, 0x01
                and a, b
                jns t6
                st c, d             ; "F" = false sign after and with result 0x01
                jmp t6

; Ports (loaded with the disk; the in_out value connects the terminal during loading)
bcd         db  0, 0
terminal    db  0, 0
in_out      db  0b00000001
bank        db  0

; Case 6: or 0x80, 0x00 = 0x80, expect S=1
t6:             inc c
                ldi a, 0x80
                clr b
                or a, b
                js t7
                st c, d             ; "G" = no sign after or with result 0x80

; Case 7: or 0x01, 0x00 = 0x01, expect S=0
t7:             inc c
                ldi a, 0x01
                clr b
                or a, b
                jns t8
                st c, d             ; "H" = false sign after or with result 0x01

; Case 8: xor 0xAA, 0xAA = 0, expect Z=1: zero is special for a frame with a stop bit
t8:             inc c
                ldi a, 0xAA
                ldi b, 0xAA
                xor a, b
                jz tchk
                st c, d             ; "I" = no zero after xor of equal values

; Counter check: after 9 probes the probe counter must be exactly "I"
tchk:           ldi b, "I"
                xor b, c
                jz tdot
                ldi c, "#"          ; "#" = control flow went off plan, some probes did not run
                st c, d
tdot:           ldi c, "."          ; End marker: the program ran to the end
                st c, d

                hlt
