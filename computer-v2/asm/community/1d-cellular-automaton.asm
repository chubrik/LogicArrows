; ##################################################################################################
; ##   Source code for the "1D Cellular Automaton" program for a computer made of logic arrows    ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                     (c) 2026 Farmer_2010 (https://github.com/farmer2010)                     ##
; ##################################################################################################



COLORED equ 0b00110101
MONO    equ 0b00010101

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                        COMMON AREA                          W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

ldi a, 32
ldi c, display
clear:;fill the display
st b, c
inc c
dec a
jnz clear


ldi a, 16;fill the first row with random cells
ldi b, display + 1
ldi c, 0b00000001
rand:
rnd d
and d, c
st d, b

inc b
inc b
dec a
jnz rand

jmp select_rule

cycle:


ldi a, 16
ldi b, display + 31
ldi d, display + 30
shift:
ld c, b
shl c
st c, b

ld c, d
rcl c
st c, d

dec d
dec d
dec b
dec b
dec a
jnz shift

ldi a, 16
ldi b, display + 31


jmp continue

void db 0,0,0,0,0

buffer db 0,0
rule db 0b01111001
indicator1 db 0;0x3A
indicator2 db 0;0x3B
terminal_input db 0;0x3C
terminal_graphics db 0;0x3D
connect db MONO;0x3E
bank_change db 1;0x3F

;display
display db          0b00000000, 0b00000000, ;                                  ;
                    0b00010000, 0b00111000, ;                                  ;
                    0b00110000, 0b00100100, ; ██      ██    ██    ██████  ████ ;
                    0b00010000, 0b00100100, ; ████  ████  ██  ██      ██  ██   ;
                    0b00010000, 0b00100100, ; ██  ██  ██  ██████    ██    ████ ;
                    0b00010000, 0b00100100, ; ██      ██  ██  ██  ██      ██   ;
                    0b00111000, 0b00111000, ; ██      ██  ██  ██  ██████  ████ ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b00011000, 0b00011000, ;       ████  ██████  ██    ██     ;
                    0b00100000, 0b00100100, ;     ██      ██      ████  ██     ;
                    0b00100000, 0b00100100, ;     ██  ██  ██████  ██  ████     ;
                    0b00100000, 0b00111100, ;     ██  ██  ██      ██    ██     ;
                    0b00100000, 0b00100100, ;     ████    ██████  ██    ██     ;
                    0b00011000, 0b00100100, ;                                  ;
                    0b00000000, 0b00000000  ;                                  ;

continue:

new_gen:
st a, buffer

clr a;a - state of neighboring cells

ld c, b
ldi d, 0b00000010
and c, d
or a, c

dec b
dec b
ldi d, display - 1
sub d, b
jnz up
jmp up_end

up:

ld c, b
ldi d, 0b00000010
and c, d
shl c
or a, c
up_end:

ldi d, 4
add b, d
ldi d, display + 33
sub d, b
jnz down
jmp down_end

down:

ld c, b
ldi d, 0b00000010
and c, d
shr c
or a, c
down_end:

dec b
dec b

ldi d, 0b00000001
rotate:
test a
jz rotate_end

shl d
dec a
jmp rotate
rotate_end:

ld c, rule
and c, d
test c
jnz add_cell
jmp add_cell_end

add_cell:

ld c, b
ldi d, 0b00000001
or c, d
st c, b

add_cell_end:

dec b
dec b
ld a, buffer
dec a
jnz new_gen

ld a, indicator1
inc a
st a, indicator1

jmp cycle


select_rule:

ldi a, 18
ldi b, text
select_cycle:

ld c, b
st c, terminal_input

inc b
dec a
jnz select_cycle


ldi a, 0b10000000
clr d
enter_cycle:
ld b, connect
ldi c, "1"
sub c, b
jz one
jmp one_else

one:
add c, b
st c, terminal_input
or d, a
shr a
jmp select_continue
one_else:
ldi c, "0"
sub c, b
jz zero
jmp select_continue

zero:
add c, b
st c, terminal_input
shr a

select_continue:
test a
jnz enter_cycle

st d, rule

jmp cycle

text db "Enter bin\nrule:\n>"
