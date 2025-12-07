; ##################################################################################################
; ##          Source code for the "Space Fight" game for a computer made of logic arrows          ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v1                 ##
; ##                         (c) 2024 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################



; Constants
WIN_LEFT    equ 30                      ; Number of enemies to shoot down to win
STEP_CNT    equ 14                      ; Number of available steps on the first level
KEY_LEFT    equ 0x11                    ; "Left" key code
KEY_RIGHT   equ 0x13                    ; "Right" key code
KEY_FIRE    equ 0x20                    ; "Space" key code (fire)
OUT_BCD     equ 0x10                    ; Code for connecting the digital indicator
OUT_DISPLAY equ 0x80                    ; Code for connecting the display



; Clear the bottom part of the display
clear:          ldi c, 0x5C
                ldi d, 0x58             ; Upper boundary for clearing the display, and also for the
                                        ;   "random" block, the lower boundary for filling with
                                        ;   enemies
clear_loop:     dec c
                st b, c
                mov a, c
                xor a, d
                jnz clear_loop

; Fill the display with randomly placed enemies.
; Register D already contains the display pointer to the lower fill boundary.
random:         ldi c, display          ; Reference to the start of the display area as the upper
                                        ;   boundary for filling with enemies

random_loop:    rnd a                   ; Work with the byte in the right part of the display
                rnd b
                and a, b                ; Combine two random bytes so that each bit has a 25%
                                        ;   probability
                shl a                   ; Shift the bits away from the edge of the display where a
                                        ;   shot cannot be fired
                dec d
                st a, d
                rnd a                   ; Repeat the same for the left part of the display
                rnd b
                and a, b
                shr a
                dec d
                st a, d
                mov a, d
                xor a, c
                jnz random_loop

; Output the enemy count to the digital indicator
score:          ld a, win_left          ; Read the enemy counter. If the game is lost, this
                                        ;   instruction will be overwritten with "hlt".
                ldi d, display          ; Reference to the start of the display area, also for the
                                        ;   "win" block
                ld b, d                 ; Store the first byte of the display image
                ldi c, OUT_BCD
                st c, out               ; Switch output to the digital indicator
                st a, d                 ; Output the enemy counter value
                ldi c, OUT_DISPLAY
                st c, out               ; Switch output to the display
                st b, d                 ; Restore the first byte of the image in memory
                add a, 0                ; If the enemy counter reaches zero, the game is won
                jz win

; Decrement the step counter
step:           ldi b, step2            ; Store the address to jump to the next step for the "keys",
                                        ;   "left", "right" blocks
step2:          ld a, step_left
                dec a
                js level                ; If no steps are left, go to the next level
                st a, step_left
                jmp keys                ; Jump over the reserved memory area

void1       db  0

; Variables and ports
step_cnt    db  STEP_CNT                ; Number of available steps on the current level
step_left   db  STEP_CNT                ; Counter of remaining steps on the current level
win_left    db  WIN_LEFT                ; Counter of enemies left to win
bank        db  0                       ; Memory bank port (not used)
in          db  0                       ; Input port
out         db  OUT_DISPLAY             ; Output port, connect display

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

; Poll the keyboard for a press of one of the ship control keys.
; Register B already contains the address to return to "step2".
keys:           mov a, 0
                ld c, in                ; Read the pressed key code
                st a, in                ; Zero out the value in the port to detect repeated presses
                ldi a, KEY_FIRE
                xor a, c
                jz fire
                ldi a, KEY_RIGHT
                xor a, c
                jz right
                ldi a, KEY_LEFT
                xor a, c
                jnz b                   ; Go to the next step

; Move the ship left.
; Register B already contains the address to return to "step2".
left:           ld a, 0x5E
                shl a
                jc b                    ; If we are at the left edge, go to the next step
                ldi d, 0x5F
                ldi c, 4

left_loop:      ld a, d
                rcl a
                st a, d
                dec d
                dec c
                jnz left_loop

                jmp b                   ; Go to the next step

; Move the ship right.
; Register B already contains the address to return to "step2".
right:          ld a, 0x5F
                shr a
                jc b                    ; If we are at the right edge, go to the next step
                ldi d, 0x5C
                ldi c, 4

right_loop:     ld a, d
                rcr a
                st a, d
                inc d
                dec c
                jnz right_loop

                jmp b                   ; Go to the next step

; Fire a shot
fire:           ldi d, 0x5C             ; Determine the starting position of the shell
                ld a, d
                add a, 0
                jnz fire_shot
                inc d

fire_shot:      ld b, d
                ldi c, 14

; Invisible shell flight
fire_loop:      dec d
                dec d
                ld a, d
                and a, b                ; If we hit, exit the loop
                jnz fire_hit
                dec c
                jnz fire_loop

                jmp step                ; Miss, go to the next step

; Hit. Remove the enemy from the display, decrease the enemy count, and go to the next step.
fire_hit:       ld a, d
                xor a, b
                st a, d
                ld a, win_left
                dec a
                st a, win_left
                jmp score

; Go to the next level. Here the enemies will be closer to us, and the number of available steps
; will decrease.
level:          ld a, step_cnt          ; Decrease the number of available steps by two
                dec a
                dec a
                st a, step_cnt
                st a, step_left
                ldi c, 0x5A             ; Lower boundary for shifting the map for the "scroll" block
                ld a, c
                ld b, 0x5B
                or a, b
                jz scroll               ; If there are no enemies in the third row from the bottom,
                                        ;   jump to shifting the map
                inc c                   ; Game over, shift the lower boundary of the map one row
                                        ;   down
                inc c
                ldi a, 0xEC             ; In the "score" block, overwrite the first instruction with
                                        ;   "hlt"
                st a, score

; Shift all enemies closer to us.
; Register C already contains the pointer to the lower boundary for shifting the map.
scroll:         ldi d, 0x42             ; Upper boundary for shifting the map, and also for the
                                        ;   "random" block, the lower boundary for filling with
                                        ;   enemies
scroll_loop:    dec c
                mov a, c
                ld b, a
                inc a
                inc a
                st b, a
                xor a, d
                jnz scroll_loop

                jmp random              ; Jump to generating enemies in the top row, and then to the
                                        ;   next step

; We won! Display the prize splash screen and end the program.
; Register D already contains the pointer to the start of the display area.
win:            ldi c, prize

win_loop:       ld a, c
                st a, d
                inc d
                inc c                   ; After 0xFF, the value will turn to 0x00, which means the
                                        ;   end of output
                jnz win_loop

                hlt

void2       db  0, 0

; Area 0xE0...0xFF contains the prize splash screen for the winner
prize       db  0b00000000, 0b00000000,
                0b00000000, 0b00000000,
                0b00000011, 0b11000000,
                0b00000100, 0b00100000,
                0b00001001, 0b00010000,
                0b00010000, 0b00101000,
                0b00010100, 0b00001000,
                0b00100000, 0b10000100,
                0b00100000, 0b00000100,
                0b01000000, 0b00001010,
                0b01010011, 0b11000010,
                0b01000111, 0b11100010,
                0b01000111, 0b11100010,
                0b00110111, 0b11101100,
                0b00001111, 0b11110000,
                0b00000000, 0b00000000
