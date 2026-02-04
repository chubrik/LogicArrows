; ##################################################################################################
; ##        Source code for the "Guess the Number" game for a computer made of logic arrows       ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                         (c) 2026 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


; Constants
TRIES_STR   equ 0x36                ; "6" - number of tries as a character

                jmp start

; Universal string output.
; Register C already contains the string start pointer.
; Register D already contains the jump address after output.
write:          ldi a, "\n"
                ldi b, terminal
                st a, b
write_loop:     ld a, c
                test a
                jz d
                st a, b
                inc c
                jmp write_loop

; Game start. Output 0 to the digital indicator and a greeting message to the terminal. Then move on
; to choosing the number.
start:          st a, bcd           ; a = 0
                ldi c, start_str
                ldi d, random
                jmp write

; Win: the player guessed the number. Increase the win counter and output the win message. Then move
; on to offering another game.
win:            ldi b, bcd
                ldi c, win_str
                ldi d, again
                ld a, b
                inc a
                st a, b
                jnz write
                inc b
                ld a, b
                inc a
                st a, b
                jmp write

; Lose: the player used all attempts. Decrease the win counter and output the lose message. Then
; move on to offering another game.
lose:           ldi b, bcd
                ldi c, lose_str
                ldi d, again
                ld a, b
                dec a
                st a, b
                inc a
                jnz write
                inc b
                ld a, b
                dec a
                st a, b
                jmp write

; Variables and ports
number      db  0                   ; Secret number
bcd         db  0, 0                ; Win counter, value can be negative
terminal    db  0, 0                ; Terminal port
in_out      db  0b00001101          ; I/O port: connect terminal and digital indicator in signed
                                    ;   mode
bank        db  0                   ; Memory bank port (unused)

; Start a new game. Reset the try counter, print the prompt, and proceed to choose a new number.
again:          ldi a, "0"
                st a, try_count
                ldi c, again_str
                ldi d, random
                jmp write

; Choose a number from 1 to 99
random:         rnd a
                js random
                inc a
                ldi b, 256 - 100
                add b, a
                jns random
                st a, number

; Check and increment the try counter. If attempts are over, go to lose.
try:            ld a, try_count
                ldi b, TRIES_STR
                xor b, a
                jz lose
                inc a
                st a, try_count
                ldi c, try_str
                ldi d, input_1
                jmp write

; Read the first character. Only digits 1 through 9 are allowed.
input_1:        ld c, in_out
                mov a, c
                ldi d, "1"
                sub a, d
                js input_1
                inc a
                ldi d, 9
                sub d, a
                js input_1
                st c, terminal

; Read the second character. Digits 0 through 9 and Enter are allowed.
input_2:        ld c, in_out
                ldi d, "\n"
                xor d, c
                jz compare          ; If Enter is pressed, compare immediately
                mov b, c
                ldi d, "0"
                sub b, d
                js input_2
                ldi d, 9
                sub d, b
                js input_2
                st c, terminal

; Combine the two entered digits into a single number
sum:            mov c, a
                shl a
                shl a
                add a, c
                shl a
                add a, b

; Compare the entered number with the secret
compare:        ld b, number
                sub a, b
                jz win              ; If numbers match, go to win
                ldi d, try
                js higher

; Output "Lower" and proceed to the next try
lower:          ldi c, lower_str
                jmp write

; Output "Higher" and proceed to the next try
higher:         ldi c, higher_str
                jmp write

; String array for terminal output
start_str   db  "Guess my number 1…99 in ", TRIES_STR, " tries.", 0
win_str     db  "You win!", 0
lose_str    db  "You lose…", 0
again_str   db  "Play again.", 0
try_str     db  "Try #0: ", 0       ; Try counter is embedded inside the string
lower_str   db  "Lower", 0
higher_str  db  "Higher", 0

; Address of the try counter inside the string
try_count   equ try_str + 5
