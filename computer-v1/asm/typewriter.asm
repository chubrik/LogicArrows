; ##################################################################################################
; ##         Source code for the "Typewriter" program for a computer made of logic arrows         ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v1                 ##
; ##                         (c) 2024 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


        ldi b, 0x3E     ; Input port address
        ldi c, 0x40     ; Code for connecting the terminal and also the address for outputting to it
        st c, 0x3F      ; Connect output
        ldi d, loop     ; Store a reference to the start of the iteration to speed up the loop

loop:   ld a, b         ; Read the character code entered from the keyboard
        st a, c         ; Output the character to the terminal
        st d, b         ; Write a non-printable character to the input port, thereby resetting the
                        ;   port. This makes it possible to detect repeated input.
        jmp d           ; Repeat the iteration
