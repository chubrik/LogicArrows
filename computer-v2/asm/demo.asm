; ##################################################################################################
; ##            Source code for the "Demo" program for a computer made of logic arrows            ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                         (c) 2025 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


JS_C        equ 0x19                    ; Instruction code "js c"

                jmp init                ; Jump over the data area

; Top part of the image for terminal output
img1        db  0b00000000,             ;                  ;
                0b00000000,             ;                  ;
                0b10000000,             ; ██               ;
                0b01100000,             ;   ████           ;
                0b00010000,             ;       ██         ;
                0b00101000,             ;     ██  ██       ;
                0b00000100,             ;           ██     ;
                0b10000100,             ; ██        ██     ;
                0b00010100,             ;       ██  ██     ;
                0b00000100,             ;           ██     ;
                0b01001000,             ;   ██    ██       ;
                0b00010000,             ;       ██         ;
                0b01100000,             ;   ████           ;
                0b10000000,             ; ██               ;
                0b00000000,             ;                  ;
                0b00000000,             ;                  ;
                0b00000000              ;                  ;

img1_last   equ $ - 1

; Prepare to output the bottom part of the image
img2_show:      ldi a, JS_C
                st a, img_cond          ; Replace the condition to exit the "img_loop"
                ldi b, img2_last        ; Pointer to the last byte of the image. During the loop,
                                        ;   the pointer moves to the first byte and simultaneously
                                        ;   acts as a counter to end the loop.
                jmp img_show

; Prepare to output the top part of the image
img1_show:      ldi b, img1_last        ; Pointer to the last byte of the image. During the loop,
                                        ;   the pointer moves to the first byte and simultaneously
                                        ;   acts as a counter to end the loop.

img_show:       ldi c, img_loop         ; Store a reference to the start of the iteration to speed
                                        ;   up the loop
                inc d                   ; Change the terminal output address for graphics mode

; Output part of the image to the terminal using a loop
img_loop:       ld a, b
                st a, d
                dec b
img_cond:       jnz c                   ; Replaceable condition to exit the loop

img_jmp:        jmp text2_show          ; Replaceable jump address

; Output part of the text to the terminal using a loop
text_loop:      ld a, b
                st a, d
                inc b
                dec c
                jnz text_loop

text_jmp:       jmp img1_show           ; Replaceable jump address

; Output the remaining text to the terminal
end:            ldi a, "\n"
                st a, d
                ldi a, ">"
                st a, d

; Ring the bell
                ldi a, "\a"             ; Terminal "bell" command code
                st a, d                 ; Activate the bell, the bell icon on the terminal lights up
                st a, d                 ; Activate the bell again, but this time the bell icon turns
                                        ;   off. The terminal is designed so that the bell turns off
                                        ;   with any further input, including a repeated "\a".
                st a, d
                st a, d
                st a, d                 ; Light up the bell for the third time and leave it on

; End the program execution
                hlt

terminal    db  0, 0
out         db  0b00110001              ; Output port, connect color display and terminal
bank        db  0                       ; Memory bank port (not used)

; Area 0x40...0x5F contains the red component of the splash screen displayed during program loading
display_r   db  0b00000000, 0b00000000, ;                                  ;
                0b00000000, 0b00000000, ;                                  ;
                0b00000000, 0b00000000, ;                                  ;
                0b00000010, 0b10000000, ;             ██  ██               ;
                0b00111011, 0b10111000, ;     ██████  ██████  ██████       ;
                0b00100101, 0b01111000, ;     ██    ██  ██  ████████       ;
                0b00100011, 0b11111000, ;     ██      ██████████████       ;
                0b00100001, 0b11111000, ;     ██        ████████████       ;
                0b00010001, 0b11110000, ;       ██      ██████████         ;
                0b00001101, 0b11100000, ;         ████  ████████           ;
                0b00010001, 0b11110000, ;       ██      ██████████         ;
                0b00010011, 0b11110000, ;       ██    ████████████         ;
                0b00001101, 0b01100000, ;         ████  ██  ████           ;
                0b00000000, 0b00000000, ;                                  ;
                0b00000000, 0b00000000, ;                                  ;
                0b00000000, 0b00000000  ;                                  ;

; Area 0x60...0x7F contains the blue component of the splash screen displayed during program loading
display_b   db  0b00000000, 0b00000000, ;                                  ;
                0b00000000, 0b00000000, ;                                  ;
                0b00000000, 0b00000000, ;                                  ;
                0b00000010, 0b10000000, ;             ██  ██               ;
                0b00111011, 0b10111000, ;     ██████  ██████  ██████       ;
                0b00111101, 0b01001000, ;     ████████  ██  ██    ██       ;
                0b00111111, 0b10001000, ;     ██████████████      ██       ;
                0b00111111, 0b00001000, ;     ████████████        ██       ;
                0b00011111, 0b00010000, ;       ██████████      ██         ;
                0b00001111, 0b01100000, ;         ████████  ████           ;
                0b00011111, 0b00010000, ;       ██████████      ██         ;
                0b00011111, 0b10010000, ;       ████████████    ██         ;
                0b00001101, 0b01100000, ;         ████  ██  ████           ;
                0b00000000, 0b00000000, ;                                  ;
                0b00000000, 0b00000000, ;                                  ;
                0b00000000, 0b00000000  ;                                  ;

; Bottom part of the image for terminal output
img2        db  0b00000000,             ;                  ;
                0b00000000,             ;                  ;
                0b00011110,             ;       ████████   ;
                0b00100001,             ;     ██        ██ ;
                0b00100010,             ;     ██      ██   ;
                0b01000000,             ;   ██             ;
                0b01111000,             ;   ████████       ;
                0b01111100,             ;   ██████████     ;
                0b01111100,             ;   ██████████     ;
                0b01111100,             ;   ██████████     ;
                0b01111100,             ;   ██████████     ;
                0b01111000,             ;   ████████       ;
                0b01000000,             ;   ██             ;
                0b00100100,             ;     ██    ██     ;
                0b00100001,             ;     ██        ██ ;
                0b00011110,             ;       ████████   ;
                0b00000000,             ;                  ;
                0b00000000              ;                  ;

img2_last   equ $ - 1

; Program initialization
init:           inc b
                st a, b                 ; Clear address 0x01, thereby completing the image
                ldi d, terminal

; Prepare to output the first line of text
text1_show:     ldi b, text1
                ldi c, text1_size

                jmp text_loop           ; Jump to output the first line

; Prepare to output the second line of text
text2_show:     ldi a, img2_show
                st a, text_jmp + 1      ; Replace the jump address for after text output
                ldi a, pre_end
                st a, img_jmp + 1       ; Replace the jump address for after image output
                ldi b, text2
                ldi c, text2_size
                dec d                   ; Change the terminal output address for text mode
                jmp text_loop

pre_end:        dec d                   ; Change the terminal output address for text mode
                jmp end                 ; Jump to output the remaining text

; First line of text for terminal output
text1       db  "Hello,\t "
text1_size  equ $ - text1

; Second line of text for terminal output
text2       db  "Onigiri! "
text2_size  equ $ - text2
