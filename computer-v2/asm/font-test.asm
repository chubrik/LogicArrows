; ##################################################################################################
; ##          Source code for the "Font Test" program for a computer made of logic arrows         ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                         (c) 2025 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


        inc a           ; 0b00000001, code for connecting the terminal
        st a, 0x3E      ; Connect output
        ldi c, 0x3C     ; Address for output to the terminal
        ldi d, loop     ; Store a reference to the start of the iteration to speed up the loop

repeat: ldi a, " "      ; Take the first character

loop:   st a, c         ; Output the character to the terminal
        inc a           ; Take the next character
        jnz d           ; Repeat the iteration until the character code after 0xFF becomes 0x00

        jmp repeat      ; Repeat the program indefinitely
