; ##################################################################################################
; ##        Source code for the "Prime Numbers" program for a computer made of logic arrows       ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v1                 ##
; ##                         (c) 2023 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


        ldi a, 0x80         ; Code for connecting the display
        st a, 0x3F          ; Connect output
        ldi b, 2            ; First prime number is 2
        ldi d, 0x41         ; Display pointer for the first number
        st b, d             ; Output the number to the display
        inc b               ; Second prime number is 3
        inc d               ; Shift the display pointer twice to move to the next row
        inc d
        st b, d             ; Output the number to the display

; Loop for selecting prime number candidates
next:   inc b               ; Increment the candidate number twice - we only check odd numbers
        inc b
        ldi d, 0x41         ; Set the pointer to the first prime number on the display

; Loop for selecting factors from already found prime numbers
factor: inc d               ; Move the pointer to the next prime number on the display
        inc d
        ld c, d             ; Take a prime number from the display as a factor
        mov a, b            ; Copy the candidate number
        shr a               ; Divide it by 2
        sub a, c            ; Subtract the current factor from it
        js prime            ; If the factor is greater than half of the candidate number, the result
                            ;   will be less than zero, meaning there's no point in checking
                            ;   further factors - we've already found a new prime number
        mov a, b            ; Copy the candidate number

; Loop for subtracting the factor from the candidate number
loop:   sub a, c            ; Subtraction
        jz next             ; If the result is zero, the number is not prime, so jump to the next
                            ;   candidate
        jns loop            ; If the result is greater than zero, continue subtracting

        jmp factor          ; If the result is less than zero, jump to the next factor

; Work with the found prime number
prime:  ld d, last          ; Read the pointer to the last found prime number on the display
        inc d               ; Move the pointer to the row below
        inc d
        st d, last          ; Save the pointer
        st b, d             ; Output the new prime number to the display
        ldi a, 0x5F         ; Get the pointer to the last possible position in the bottom row of the
                            ;   display
        xor a, d            ; Compare the two pointers
        jnz next            ; If they are not equal, proceed to the next candidate number

        hlt                 ; End the program execution

last db 0x43                ; Pointer to the last found prime number on the display
