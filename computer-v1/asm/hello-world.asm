; ##################################################################################################
; ##         Source code for the "Hello World" program for a computer made of logic arrows        ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v1                 ##
; ##                         (c) 2023 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


            ldi a, 0x80             ; Code for connecting the display
            st a, 0x3F              ; Connect output
            ldi b, image_size       ; Counter that will end the program
            ldi c, image            ; Pointer to the start of the image
            ldi d, 0x40             ; Pointer to the start of the display area

; Loop for copying the image to the display
loop:       ld a, c                 ; Read one byte of the image
            st a, d                 ; Output the image byte to the display
            inc c                   ; Move the image pointer
            inc d                   ; Move the display pointer
            dec b                   ; Decrement the counter value
            jnz loop                ; If the counter has not reached zero, repeat the iteration

            hlt                     ; End the program execution

void    db  0, 0, 0, 0, 0, 0        ; Memory alignment (optional)

; Image for display output
image   db  0b00000010, 0b01000000, ;             ██    ██             ;
            0b00110101, 0b10101100, ;     ████  ██  ████  ██  ████     ;
            0b00000100, 0b00100000, ;           ██        ██           ;
            0b00110011, 0b11001100, ;     ████    ████████    ████     ;
            0b00000000, 0b00000000, ;                                  ;
            0b10100000, 0b10100000, ; ██  ██          ██  ██           ;
            0b10100100, 0b10100100, ; ██  ██    ██    ██  ██    ██     ;
            0b11101010, 0b10101010, ; ██████  ██  ██  ██  ██  ██  ██   ;
            0b10101100, 0b10101010, ; ██  ██  ████    ██  ██  ██  ██   ;
            0b10100110, 0b10100100, ; ██  ██    ████  ██  ██    ██     ;
            0b00000000, 0b00000000, ;                                  ;
            0b00000000, 0b00010001, ;                       ██      ██ ;
            0b10100100, 0b11010001, ; ██  ██    ██    ████  ██      ██ ;
            0b11101010, 0b10010011, ; ██████  ██  ██  ██    ██    ████ ;
            0b11101010, 0b10010101, ; ██████  ██  ██  ██    ██  ██  ██ ;
            0b01000100, 0b10010011  ;   ██      ██    ██    ██    ████ ;

image_size  equ $ - image           ; Image size
