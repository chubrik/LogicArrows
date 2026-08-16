; ##################################################################################################
; ##           Source code for the "Arkanoid" game for a computer made of logic arrows            ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                       (c) 2026 Farmer_2010 (https://t.me/farmer_2010)                        ##
; ##################################################################################################



MONO equ 0b00010000
COLORED equ 0b00110100
INDICATOR equ 0b00000100
TERMINAL equ 0b00000001

BANK_MAIN equ 1
BANK_MOVE equ 2
BANK_COLLIDE equ 3
BANK_SENSOR equ 4
BANK_BREAK equ 5

BALL_SPEED equ 2

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                        SHARED AREA                          W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


jmp start


;###############################################################
;function to get a display byte, its address and the bit position. a - x, b - y, c - position(for single-byte mode), d - jump index

;converts a coordinate byte into two bytes. c - position. Returns a and b
get_point_from_byte:

ldi a, 0xF0;a - xpos
and a, c
shr a;shift right by 4 bits
shr a
shr a
shr a

ldi b, 0x0F;b - ypos
and b, c

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


;###############################################################
bank_change:;switching between banks. c - bank index, d - jump index
st c, bank;switch the bank
jmp d;jump to the needed address
;###############################################################

buffer db 0,0,0

x db 6
y db 14

can_move db 0
speed_x db 1
speed_y db 255
c_pos db 5
new_x db 0

points db 0;0x3A
indicator2 db 0;0x3B
new_y db 0;0x3C
timer db 0;0x3D timer so the ball does not move every turn(do not forget to disable the terminal)
connect db COLORED;0x3E
bank db 1;0x3F

display db          0b00000000, 0b00000000,
                    0b00000000, 0b00000000,
                    0b11001100, 0b11001100,
                    0b00110011, 0b00110011,
                    0b11001100, 0b11001100,
                    0b00110011, 0b00110011,
                    0b11001100, 0b11001100,
                    0b00110011, 0b00110011,
                    0b11001100, 0b11001100,
                    0b00110011, 0b00000011,
                    0b00000000, 0b00000000,
                    0b00000000, 0b00000000,
                    0b00000000, 0b01000000,
                    0b00000000, 0b00000000,
                    0b00000000, 0b00000000,
                    0b00000011, 0b10000000

display_blue db     0b00000000, 0b00000000,
                    0b00000000, 0b00000000,
                    0b00110011, 0b00110011,
                    0b11001100, 0b11001100,
                    0b00110011, 0b00110011,
                    0b11001100, 0b11001100,
                    0b00110011, 0b00110011,
                    0b11001100, 0b11001100,
                    0b00110011, 0b00110011,
                    0b11001100, 0b11000000,
                    0b00000000, 0b00000000,
                    0b00000000, 0b00000000,
                    0b00000000, 0b01000000,
                    0b00000000, 0b00000000,
                    0b00000000, 0b00000000,
                    0b00000011, 0b10000000


;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 1                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;paddle movement and game start

start:

ldi a, 0b00110011
ldi b, 0b11001100
st a, display + 19
st b, display_blue + 19
st c, display + 25
st c, display_blue + 25
st c, display + 31
st c, display_blue + 31

ldi a, 0b00000010
st a, display + 28
st a, display_blue + 28

ldi b, 0b00000111
st b, display + 30
st b, display_blue + 30


cycle:

ld d, c_pos
;paddle movement
ld a, connect
ldi b, 0x11;"<-"
sub b, a
jz left

ldi b, 0x13;"->"
sub b, a
jz right
jmp lr_end

left:
clr a
sub a, d
jz lr_end

dec d

ld c, display + 31
shl c
st c, display + 31
st c, display_blue + 31

ld c, display + 30
rcl c
st c, display + 30
st c, display_blue + 30
jmp lr_end

right:
ldi a, 13
sub a, d
jz lr_end

inc d

ld c, display + 30
shr c
st c, display + 30
st c, display_blue + 30

ld c, display + 31
rcr c
st c, display + 31
st c, display_blue + 31

lr_end:
st d, c_pos


ld a, points
ldi b, 64
sub a, b
;ball movement in bank 2
ldi c, BANK_MOVE
ldi d, move
jmp bank_change

cycle_continue:

jmp cycle


win:
ldi a, TERMINAL
st a, connect
ldi b, text
ldi a, text_len
win_cycle:
ld c, b
st c, new_y
inc b
dec a
jnz win_cycle
hlt
text db "  You win!\n"
text_len equ 11


void1 db 0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 2                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;ball movement

move:

;win check
jnz win_end
ldi c, BANK_MAIN
ldi d, win
jmp bank_change
win_end:

st b, can_move;B contains 64, we need a number greater than 0


ld a, x
ld b, y

ld c, speed_x
ld d, speed_y

add a, c
add b, d
st a, new_x
st b, new_y


;Y - border
ldi c, 255;-1 is 255
sub c, b
jz vert_border

ldi c, 16
sub c, b
jz die
jmp vert_border_end

die:
hlt

vert_border:;y speed is in D
neg d
st d, speed_y
st c, can_move;if we are here, C contains 0
vert_border_end:


;part of the code is in bank 3
ldi c, BANK_COLLIDE
ldi d, collide
jmp bank_change
move_continue:


ld a, can_move
test a
jz move_break


;the movement itself

;erase the ball
ld a, x
ld b, y
ldi d, $ + 4
jmp get_point
not c;invert c because we paint white
and a, c;and between c and the display byte(because we paint white. To paint with color, use or)
st a, b;put the modified byte back onto the display

ldi a, display_blue
st a, INDEX_CHANGE
ld a, x
ld b, y
ldi d, $ + 4
jmp get_point
not c;invert c because we paint white
and a, c;and between c and the display byte(because we paint white. To paint with color, use or)
st a, b;put the modified byte back onto the display

ld a, new_x;move the ball
ld b, new_y

st a, x
st b, y

ldi d, $ + 4
jmp get_point
or a, c;or between c and the display byte(because we paint with color)
st a, b;put the modified byte back onto the display

ldi a, display
st a, INDEX_CHANGE
ld a, new_x
ld b, new_y
ldi d, $ + 4
jmp get_point
or a, c;or between c and the display byte(because we paint with color)
st a, b;put the modified byte back onto the display


move_break:
;return to bank 1
ldi c, BANK_MAIN
ldi d, cycle_continue
jmp bank_change

void2 db 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 3                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;checking collisions with cells
collide:

ld c, timer;the ball moves every 12th step
inc c
ldi d, BALL_SPEED
sub d, c
jz zero_timer
jmp zero_timer_else
zero_timer:
clr c
jmp zero_timer_end
zero_timer_else:
clr d
st d, can_move
zero_timer_end:
st c, timer


;X - border
ldi c, 255;-1 is 255
sub c, a
jz hor_border

ldi c, 16
sub c, a
jz hor_border
jmp hor_border_end

hor_border:
ld d, speed_x
neg d
st d, speed_x
st c, can_move;if we are here, C contains 0
hor_border_end:


ld a, can_move
test a
jz collide_continue


ldi c, BANK_SENSOR;get the state of the three neighboring cells
ldi d, get_3cells
jmp bank_change
get_3cells_return:;register b holds data about the three neighbors

test b
jz stop_move_cell_collide_else
clr a
st a, can_move
jmp stop_move_cell_collide_end
stop_move_cell_collide_else:
jmp collide_continue
stop_move_cell_collide_end:


st b, buffer
ld c, speed_x
ld d, speed_y

ldi a, 0b00110000;check the vertical cell

and a, b
jz vert_cell_collide_end
neg d
st d, speed_y

vert_cell_collide_end:

ldi a, 0b00001100;check the horizontal cell
and a, b
jz hor_cell_collide_end
neg c
st c, speed_x

hor_cell_collide_end:

ldi a, 0b00111100;if both cells are empty, turn 180*
and a, b

jnz straight_cell_collide_end

neg d
st d, speed_y
neg c
st c, speed_x

straight_cell_collide_end:


ld a, x
ld b, y

ldi d, 12
sub d, b
jc collide_continue


ldi c, BANK_BREAK
ldi d, try_break
jmp bank_change

collide_continue:
;return to bank 2
ldi c, BANK_MOVE
ldi d, move_continue
jmp bank_change

void3 db 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 4                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;determining the state of neighbors
buffer_b4 db 0,0,0,0
neighbours db 0;0b00yyxxzz y - vertical cell, x - horizontal cell, z - straight-ahead cell

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;function to get the red and blue components of a cell by coordinates. a, b - coordinates, d - jump index
get_point_rb:

st d, buffer_b4
st a, buffer_b4 + 1
st b, buffer_b4 + 2
clr c
st c, buffer_b4 + 3


ldi d, $ + 4;get the red component of the cell the ball is flying into
jmp get_point

and a, c
jz red_end

ldi d, 0b00000001
st d, buffer_b4 + 3

red_end:


ld a, buffer_b4 + 1;get the blue component of the cell the ball is flying into
ld b, buffer_b4 + 2
ldi c, display_blue
st c, INDEX_CHANGE
ldi d, $ + 4
jmp get_point
and a, c
jz blue_end

ld c, buffer_b4 + 3
ldi d, 0b00000010
or d, c
st d, buffer_b4 + 3

blue_end:

ldi c, display
st c, INDEX_CHANGE

;return the data in register C
ld c, buffer_b4 + 3
ld d, buffer_b4
jmp d
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;get the contents of the three neighboring cells into register B
get_3cells:

ld a, new_x;get the state of the cell ahead
ld b, new_y
ldi d, $ + 4
jmp get_point_rb
st c, neighbours

ld a, x;get the state of the vertical cell
ld b, new_y
ldi d, $ + 4
jmp get_point_rb

shl c
shl c
shl c
shl c
ld d, neighbours
or d, c
st d, neighbours
vert_test_end:
ld b, neighbours


ld a, new_x;get the state of the horizontal cell
ld b, y
ldi d, $ + 4
jmp get_point_rb

shl c
shl c
ld d, neighbours
or d, c
st d, neighbours
hor_test_end:

ld b, neighbours
ldi c, BANK_COLLIDE
ldi d, get_3cells_return
jmp bank_change
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


void4 db 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 5                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;destroying cells
buffer_b5 db 0,0,0


clear_pixel:

ld a, buffer_b5
ld b, buffer_b5 + 1
st d, buffer + 2

st c, INDEX_CHANGE
ldi d, $ + 4
jmp get_point
not c;invert c because we paint white
and a, c;and between c and the display byte(because we paint white. To paint with color, use or)
st a, b;put the modified byte back onto the display

ld d, buffer + 2
jmp d


;function to destroy a cell by coordinates
;a, b - coordinates
break:

st d, buffer + 1

ldi c, 0b00001110
and a, c
st a, buffer_b5
st b, buffer_b5 + 1


ldi c, display
ldi d, $ + 4
jmp clear_pixel

ldi c, display_blue
ldi d, $ + 4
jmp clear_pixel

ld a, buffer_b5
inc a
st a, buffer_b5

ldi c, display_blue
ldi d, $ + 4
jmp clear_pixel

ldi c, display
ldi d, $ + 4
jmp clear_pixel


ld a, points;scoring points
inc a
st a, points

ld d, buffer + 1
jmp d


try_break:

ld c, buffer
st c, buffer_b5 + 2

ldi d, 0b00110000
and d, c
jz vert_break_else
ld b, new_y
ldi d, $ + 4
jmp break

vert_break_else:

ld c, buffer_b5 + 2
ldi d, 0b00001100
and d, c
jz hor_break_else
ld a, new_x
ld b, y
jmp break_block
hor_break_else:

ld c, buffer_b5 + 2
ldi d, 4
sub d, c
jc break_continue
jz break_continue
ld a, new_x
ld b, new_y

break_block:

ldi d, $ + 4
jmp break

break_continue:


ldi c, BANK_COLLIDE
ldi d, collide_continue
jmp bank_change

void5 db 0,0,0,0,0,0,0,0,0,0
