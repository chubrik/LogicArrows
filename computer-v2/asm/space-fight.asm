; ##################################################################################################
; ##          Source code for the "Space Fight" game for a computer made of logic arrows          ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                         (c) 2024 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################



; Constants
WIN_LEFT    equ 30                      ; Number of enemies to shoot down to win
STEP_CNT    equ 14                      ; Number of available steps on the first level
KEY_LEFT    equ 0x11                    ; "Left" key code
KEY_RIGHT   equ 0x13                    ; "Right" key code
KEY_FIRE    equ 0x20                    ; "Space" key code (fire)



; Clear the bottom part of the display
clear:          ldi b, clear_loop
                ldi c, 4
                ldi d, 0x5B

clear_loop:     st a, d
                dec d
                dec c
                jnz b

                ldi c, 12

; Fill the display with randomly placed enemies.
; Register C already contains the counter to exit the loop.
; Register D already contains the display pointer to the lower fill boundary.
random:         rnd a                   ; Work with the right part of the display
                rnd b
                and a, b                ; Combine two random bytes so that each bit has a 25%
                                        ;   probability
                shl a                   ; Shift the bits away from the edge of the display where a
                                        ;   shot cannot be fired
                st a, d
                dec d
                rnd a                   ; Repeat the same for the left part of the display
                rnd b
                and a, b
                shr a
                st a, d
                dec d
                dec c
                jnz random

random_jmp:     jmp score

; Output the starting score to the digital indicator
score:          ld a, bcd
                st a, bcd
                ldi a, step
                st a, random_jmp + 1    ; The "score" block is only needed once, so we make it so
                                        ;   that we jump over it in the future

; Poll the keyboard for a press of one of the ship control keys
step:           ldi b, KEY_LEFT
                ldi c, KEY_RIGHT
                ldi d, KEY_FIRE

step_loop:      ld a, step_left         ; Decrement the step counter
                dec a
                js level                ; If no steps are left, go to the next level
                st a, step_left
                ld a, in_out
                xor d, a
                jz fire
                xor c, a
                jmp step_end            ; Jump over the reserved memory area

; Variables and ports
bcd         db  WIN_LEFT, 0             ; Counter of enemies left to win
step_cnt    db  STEP_CNT                ; Number of available steps on the current level
step_left   db  STEP_CNT                ; Counter of remaining steps on the current level
in_out      db  0b00010100              ; Input/output port, connect monochrome display and digital
                                        ;   indicator
bank        db  0                       ; Memory bank port (not used)

; Area 0x40...0x5F contains the splash screen displayed during program loading
display     db  0b00101000, 0b00000000, ;     ██  ██                       ;
                0b00100000, 0b00101000, ;     ██              ██  ██       ;
                0b00000000, 0b00001000, ;                         ██       ;
                0b00001001, 0b00000000, ;         ██    ██                 ;
                0b00100001, 0b00100000, ;     ██        ██    ██           ;
                0b00100011, 0b10001000, ;     ██      ██████      ██       ;
                0b00000011, 0b10001000, ;             ██████      ██       ;
                0b00001011, 0b10100000, ;         ██  ██████  ██           ;
                0b00001010, 0b10100000, ;         ██  ██  ██  ██           ;
                0b00101110, 0b11101000, ;     ██  ██████  ██████  ██       ;
                0b00101111, 0b11101000, ;     ██  ██████████████  ██       ;
                0b00111011, 0b10111000, ;     ██████  ██████  ██████       ;
                0b00110101, 0b01011000, ;     ████  ██  ██  ██  ████       ;
                0b00100000, 0b00001000, ;     ██                  ██       ;
                0b00000001, 0b00000000, ;               ██                 ;
                0b00000011, 0b10000000  ;             ██████               ;

; Continue keyboard processing
step_end:       jz right
                xor b, a
                jnz step_loop

; Move the ship left
left:           ld b, 0x5E
                shl b
                jc step                 ; If we are at the left edge, go to the next step
                ldi b, 0x5F
                ldi c, 4
                ldi d, left_loop

left_loop:      ld a, b
                rcl a
                st a, b
                dec b
                dec c
                jnz d

                jmp step

; Move the ship right
right:          ld b, 0x5F
                shr b
                jc step                 ; If we are at the right edge, go to the next step
                ldi b, 0x5C
                ldi c, 4
                ldi d, right_loop

right_loop:     ld a, b
                rcr a
                st a, b
                inc b
                dec c
                jnz d

                jmp step

; Fire a shot
fire:           ldi d, 0x5C             ; Determine the starting position of the shell
                ld a, d
                test a
                jnz fire2
                inc d

fire2:          ld b, d
                ldi c, 14

; Invisible shell flight
fire_loop:      dec d
                dec d
                ld a, d
                and a, b
                jnz fire_hit            ; If we hit, exit the loop
                dec c
                jnz fire_loop

                jmp step                ; Miss, go to the next step

; Hit. Remove the enemy from the display, decrease the enemy count, and go to the next step.
fire_hit:       ld a, d
                xor a, b
                st a, d
                ld a, bcd               ; Decrease the enemy count on the digital indicator
                dec a
                st a, bcd
                jnz step                ; If the enemy counter has not reached zero, go to the next
                                        ;   step

; We won! Display the prize splash screen and end the program.
win:            ldi b, display
                ldi c, prize
                ldi d, win_loop

win_loop:       ld a, c
                st a, b
                inc b
                inc c
                jnz d

                hlt

; Go to the next level. Here the enemies will be closer to us, and the number of available steps
; will decrease.
level:          ld a, step_cnt          ; Decrease the number of available steps by two
                dec a
                dec a
                st a, step_cnt
                st a, step_left
                ld a, 0x5A              ; Determine if there is at least one enemy in the bottom row
                ld b, 0x5B
                ldi c, 26
                ldi d, 0x59
                or a, b
                jz scroll               ; If there are no enemies in the bottom row, go to shifting
                                        ;   all enemies closer to us

; Game over. It remains to shift all enemies even closer and end the program.
level_lose:     inc c
                inc c
                inc d
                inc d
                ldi a, 0x01             ; "hlt" instruction code. Write it to the place where the
                                        ;   top row fill will end.
                st a, random_jmp

; Shift all enemies closer to us.
; Register C already contains the counter to exit the loop.
; Register D already contains the pointer to the lower boundary for shifting the map.
scroll:         mov b, d
                ld a, b
                inc b
                inc b
                st a, b
                dec d
                dec c
                jnz scroll

; After shifting, it remains to fill the top row of the display with new enemies
                inc c
                inc d
                inc d
                jmp random

void        db  0

; Area 0xE0...0xFF contains the prize splash screen for the winner
prize       db  0b00000000, 0b00000000,
                0b00001101, 0b10000000,
                0b00110010, 0b01000000,
                0b01000000, 0b00100000,
                0b01001011, 0b11100000,
                0b01010100, 0b00111100,
                0b00110000, 0b00100010,
                0b00101010, 0b10111010,
                0b00101010, 0b10101010,
                0b00101010, 0b10101010,
                0b00101010, 0b10111010,
                0b00101010, 0b10100010,
                0b00100000, 0b00111100,
                0b00100000, 0b00100000,
                0b00011111, 0b11000000,
                0b00000000, 0b00000000
