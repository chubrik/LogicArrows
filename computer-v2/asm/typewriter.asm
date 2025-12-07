; ##################################################################################################
; ##         Source code for the "Typewriter" program for a computer made of logic arrows         ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                         (c) 2024 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


        inc a           ; 0b00000001, code for connecting the terminal
        ldi b, 0x3E     ; Input/output port address
        st a, b         ; Connect output
        ldi c, 0x3C     ; Address for output to the terminal
        ldi d, loop     ; Store a reference to the start of the iteration to speed up the loop

loop:   ld a, b         ; Read the character code entered from the keyboard. The input port is
                        ;   automatically reset.
        st a, c         ; Output the character to the terminal
        jmp d           ; Repeat the iteration
