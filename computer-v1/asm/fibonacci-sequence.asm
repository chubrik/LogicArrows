; ##################################################################################################
; ##     Source code for the "Fibonacci Sequence" program for a computer made of logic arrows     ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v1                 ##
; ##                         (c) 2023 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


        ldi a, 0x80         ; Code for connecting the display
        st a, 0x3F          ; Connect output
        inc b               ; Prepare the number 1
        inc c               ; Prepare the number 1
        ldi d, 0x3F         ; Pointer for output to the display

loop:   inc d               ; Move the display pointer to the row below
        inc d
        mov a, b            ; Take the first number
        add a, c            ; Add the last two numbers
        mov b, a            ; Store the sum in the first number
        st a, d             ; Output the sum to the display
        inc d               ; Move the display pointer to the row below
        inc d
        mov a, c            ; Take the second number
        add a, b            ; Add the last two numbers
        mov c, a            ; Store the sum in the second number
        st a, d             ; Output the sum to the display
        ldi a, 0x53         ; Address on the display for the last number
        xor a, d
        jnz loop            ; If we have not yet reached this address, repeat the iteration

        hlt                 ; End the program execution
