; ##################################################################################################
; ##       Source code for the "Langton's Ant" program for a computer made of logic arrows        ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                     (c) 2026 Farmer_2010 (https://github.com/farmer2010)                     ##
; ##################################################################################################



COLORED equ 0b00110100


;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                        COMMON AREA                          W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

ldi a, 32
ldi c, display
ldi d, display_blue
clear:;fill the display
st b, c
st b, d
inc c
inc d
dec a
jnz clear

jmp cycle


;###############################################################
;function to get a display byte, its address and the bit position. a - x, b - y, c - position(for single-byte mode), d - jump index

;the function itself
get_point:

ldi c, 0b00000111;bit index(0 - most significant)
and c, a
st c, buffer;temporarily store in memory

shl b;multiply ypos by 2

ldi c, 0b00001000;if xpos > 7, add 1
and c, a
test c
jz plus_1_end

inc b
plus_1_end:
ld a, buffer;a - bit index(0 - most significant), b - byte index

ldi c, 7;subtract a from 7 so that 0 becomes the least significant bit
sub c, a
mov a, c

ldi c, 1
pow:;get into c a number with bit a set
test a
jz pow_end
shl c
dec a
jmp pow
pow_end:

INDEX_CHANGE equ $ + 1;to read from the needed part of the display, we edit the byte of the next instruction
ldi a, display;add the display address to b
add b, a
ld a, b;read the needed byte from the display

;returns: a - display byte, b - display address, c - mask to extract the needed bit

jmp d;jump back
;###############################################################

buffer db 0,0,0,0,0

x db 8
y db 8
new_x db 0
new_y db 0
rotate db 3

counter db 0;0x3A
indicator2 db 0;0x3B
terminal_input db 0;0x3C
terminal_graphics db 0;0x3D
connect db COLORED;0x3E
bank db 1;0x3F

display db          0b00000000, 0b00000000,
                    0b00000000, 0b00000000,
                    0b10010000, 0b00000000,
                    0b01001000, 0b00000000,
                    0b01001000, 0b00000000,
                    0b01111000, 0b00000000,
                    0b11111011, 0b00011000,
                    0b11011111, 0b10111100,
                    0b01110111, 0b11111110,
                    0b00000111, 0b10111111,
                    0b00001001, 0b00001000,
                    0b00010010, 0b00000100,
                    0b00100100, 0b00000010,
                    0b00000000, 0b00000000,
                    0b00000000, 0b00000000,
                    0b00000000, 0b00000000

display_blue db     0b00000000, 0b00000000,
                    0b00000000, 0b00000000,
                    0b10010000, 0b00000000,
                    0b01001000, 0b00000000,
                    0b01001000, 0b00000000,
                    0b01111000, 0b00000000,
                    0b11111011, 0b00011000,
                    0b11011111, 0b10111100,
                    0b01110111, 0b11111110,
                    0b00000111, 0b10111111,
                    0b00001001, 0b00001000,
                    0b00010010, 0b00000100,
                    0b00100100, 0b00000010,
                    0b00000000, 0b00000000,
                    0b00000000, 0b00000000,
                    0b00000000, 0b00000000
					
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 1                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

cycle:

ld a, x
ld b, y
ldi d, $ + 4
jmp get_point
or a, c;or between c and the display byte(because we paint with color)
st a, b;put the modified byte back onto the display


ldi a, display_blue
st a, INDEX_CHANGE
ld a, x
ld b, y
ldi d, $ + 4
jmp get_point
mov d, a
and d, c

xor a, c;invert the display bit
st a, b

ld b, rotate
ldi c, 0b00000011
test d
jnz left_rotate
inc b
and b, c
jmp left_rotate_end
left_rotate:
dec b
and b, c
left_rotate_end:
st b, rotate


ld a, x
ld b, y
ld c, rotate

clr d
sub d, c
jnz up_else
dec b
up_else:

ldi d, 1
sub d, c
jnz right_else
inc a
right_else:

ldi d, 2
sub d, c
jnz down_else
inc b
down_else:

ldi d, 3
sub d, c
jnz left_else
dec a
left_else:

ldi c, 0b00001111
and a, c
and b, c

st a, new_x
st b, new_y

ldi a, display
st a, INDEX_CHANGE

ld a, x
ld b, y
ldi d, $ + 4
jmp get_point
not c;invert c because we paint white
and a, c;and between c and the display byte(because we paint white. To paint with color, use or)
st a, b;put the modified byte back onto the display

ld a, new_x
st a, x
ld a, new_y
st a, y

ld a, counter
ld b, indicator2
clr c
ldi d, 1
add a, d
adc b, c
st a, counter
st b, indicator2
jmp cycle
