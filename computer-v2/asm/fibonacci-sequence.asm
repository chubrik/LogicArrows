; ##################################################################################################
; ##     Source code for the "Fibonacci Sequence" program for a computer made of logic arrows     ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                         (c) 2024 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


        ldi c, 0b00010100   ; Code to connect monochrome display and digital indicator
        st c, 0x3E          ; Connect output
        inc b               ; Prepare the number 1
        ldi c, 0x3A         ; Address for output to the digital indicator
        ldi d, 0x41         ; Pointer for output to the display

loop:   add a, b            ; Add the last two numbers, storing the sum in the first of them
        jc end              ; If the sum exceeds 255, exit the loop
        st a, c             ; Output the sum to the digital indicator
        st a, d             ; Output the sum to the display
        inc d               ; Move the display pointer to the row below
        inc d
        add b, a            ; Add the last two numbers, storing the sum in the second of them
        st b, c             ; Output the sum to the digital indicator
        st b, d             ; Output the sum to the display
        inc d               ; Move the display pointer to the row below
        inc d
        jmp loop            ; Repeat the iteration

end:    hlt                 ; End the program execution
