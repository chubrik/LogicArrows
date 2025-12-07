; ##################################################################################################
; ##          Source code for the "Font Test" program for a computer made of logic arrows         ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v1                 ##
; ##                         (c) 2025 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


        ldi c, 0x40     ; Code for connecting the terminal and also the address for outputting to it
        st c, 0x3F      ; Connect output
        ldi d, loop     ; Store a reference to the start of the iteration to speed up the loop

repeat: ldi a, 0x20     ; Take the code of the first character (space)

loop:   st a, c         ; Output the character to the terminal
        inc a           ; Take the code of the next character
        jnz d           ; Repeat the iteration until the character code after 0xFF becomes 0x00

        jmp repeat      ; Repeat the program indefinitely
