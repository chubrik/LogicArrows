; ##################################################################################################
; ##       Source code for the "Maze Generator" program for a computer made of logic arrows       ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                     (c) 2026 Farmer_2010 (https://github.com/farmer2010)                     ##
; ##################################################################################################



COLORED equ 0b00110000
MONO    equ 0b00010000

BANK_MAIN equ 1
BANK_STACK equ 2
BANK_BORDER equ 3
BANK_POS equ 4

in_out equ 128


;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                        COMMON AREA                          W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;Display byte function, variables

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
ldi c, 7;if xpos > 7, add 1
sub a, c
jc plus_1_end
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

ldi a, display;add the display address to b
add b, a
ld a, b;read the needed byte from the display

;returns: a - display byte, b - display address, c - mask to extract the needed bit

jmp d;jump back
;###############################################################


void db 0,0

border db 0;whether there is a border in the direction
x db 0;current point position
y db 0
stack_length db 0;stack size
function_input db 0;function input data
function_output db 0;function output
function_output_index db 0, 0;function return index
buffer db 0, 0, 0, 0;buffer for storing data
terminal_input db 0;0x3C
terminal_graphics db 0;0x3D
connect db MONO;0x3E
bank db 1;0x3F


;display
display db          0b00000000, 0b00000000, ;                                  ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b10001001, 0b00111011, ; ██      ██    ██    ██████  ████ ;
                    0b11011010, 0b10001010, ; ████  ████  ██  ██      ██  ██   ;
                    0b10101011, 0b10010011, ; ██  ██  ██  ██████    ██    ████ ;
                    0b10001010, 0b10100010, ; ██      ██  ██  ██  ██      ██   ;
                    0b10001010, 0b10111011, ; ██      ██  ██  ██  ██████  ████ ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b00011011, 0b10100100, ;       ████  ██████  ██    ██     ;
                    0b00100010, 0b00110100, ;     ██      ██      ████  ██     ;
                    0b00101011, 0b10101100, ;     ██  ██  ██████  ██  ████     ;
                    0b00101010, 0b00100100, ;     ██  ██  ██      ██    ██     ;
                    0b00110011, 0b10100100, ;     ████    ██████  ██    ██     ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b00000000, 0b00000000  ;                                  ;


;###############################################################
;check the cell state to determine whether movement is possible
test_cell:

st a, function_output_index + 1;save the function return index

ld a, buffer + 3;restore register a

st c, border;save register c
st d, buffer + 2;save register d

ldi d, $ + 6
st d, function_output_index
jmp get_pixel_value

ld c, border;restore registers c and d
ld d, buffer + 2

jz border_cell;check the cell state 
jmp clear_cell

border_cell:;if the cell is occupied
or c, d;add 1 in the needed direction

clear_cell:

ld a, function_output_index + 1;restore the function return index
jmp a
;###############################################################

void0 db 0,0,0,0,0,0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 1                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;Main logic

;jump to/from the current bank. c - bank index, d - jump index
st c, bank;switch the bank
jmp d;this instruction is already executed in another bank. jump to the needed address


start:;code start

ldi a, MONO;connect the monochrome display
st a, connect

ldi a, 32
ldi b, 255
ldi c, display
clear:;fill the display
st b, c
inc c
dec a
jnz clear

rnd a;get random coordinates
ldi b, 0b11101110;clear the low bits of the coordinates so they are even
and a, b

ldi c, BANK_STACK;push a random position onto the stack
ldi d, stack_add
st a, function_input
ldi a, $ + 6
st a, function_output_index
jmp in_out


;###############################################################
;main loop
cycle:

;get coordinates from the stack into register b
ldi c, BANK_STACK
ldi d, stack_get
ldi a, $ + 6
st a, function_output_index
jmp in_out

ldi c, BANK_POS;extracting the position from a byte is moved to bank 4
ldi d, get_pos_from_byte
jmp in_out
get_pos_return:

ld c, buffer;restore c from the buffer

;drawing a point on the display
ldi d, $ + 4;get the display byte
jmp get_point_from_byte;

not c;invert c because we paint white
and a, c;and between c and the display byte(because we paint white. To paint with color, use or)
st a, b;put the modified byte back onto the display

ld a, x;load the position from memory
ld b, y

ldi c, BANK_BORDER;check borders and neighboring cells
ldi d, test_borders
jmp in_out

remove:
;if the cell is surrounded, remove it from the stack

ldi c, BANK_STACK
ldi d, stack_remove
ldi a, continue
st a, function_output_index
jmp in_out

move:

rnd d;generate a random direction into register d
ldi b, 0b00000011
and d, b;keep the low 2 bits

ldi c, 0b00010000;mask to extract from the border byte 

;loop to get the direction
get_rotate:;get a mask from the direction using bitwise right shift

shr c;mask in register c

dec d
jns get_rotate
;

ld d, function_output;load the border byte from memory

and d, c;check the border in the direction
test d
jnz move;if there is a border, try another direction

mov b, c
ldi c, BANK_POS;determining neighboring cell positions is moved to bank 4
ldi d, get_coord
jmp in_out
get_coord_return:

;drawing a point on the display
;draw an intermediate point between the old and new positions
ldi d, $ + 4;get the display byte
jmp get_point;

not c;invert c because we paint white
and a, c;and between c and the display byte(because we paint white. To paint with color, use or)
st a, b;put the modified byte back onto the display

ldi c, BANK_STACK;push the new position onto the stack
ldi d, stack_add
ldi a, $ + 6
st a, function_output_index
jmp in_out

continue:

ld a, stack_length;continue the loop if the stack length > 0
test a
jnz cycle

hlt;the maze is generated, halt the program
;###############################################################

void1 db 0,0,0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 2                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;Stack and stack functions

;jump to/from the current bank. c - bank index, d - jump index
st c, bank;switch the bank
jmp d;this instruction is already executed in another bank. jump to the needed address


;###############################################################
;function to push a number onto the stack. fn_input - the number
stack_add:

ld c, function_input;load the function input into c

ld a, stack_length;add the stack length and the stack address
ldi b, stack
add b, a;final index in register b

st c, b;write the number to the needed address and increase the stack length
inc a
st a, stack_length

ld d, function_output_index;load the address into d
ldi c, BANK_MAIN;return to bank 1 at the needed address
jmp in_out
;###############################################################


;###############################################################
;function to remove the last element of the stack
stack_remove:

ld a, stack_length;add the stack length and the stack address
ldi b, stack
add b, a;final index in register b

clr c;write 0 to the cell
st c, b

dec a;decrease the stack length
st a, stack_length

ld d, function_output_index;load the address into d
ldi c, BANK_MAIN;return to bank 1 at the needed address
jmp in_out
;###############################################################


;###############################################################
;function to get the last stack element into b
stack_get:

ld a, stack_length;add the stack length and the stack address
dec a;decrease a because it is the stack length, not the index of the last element
ldi b, stack
add b, a;final index in register b

ld b, b;load the last stack element into register b

ld d, function_output_index;load the address into d
ldi c, BANK_MAIN;return to bank 1 at the needed address
jmp in_out
;###############################################################


stack db 0,0,0,0,0,0,0,0,;stack of 64 positions
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0

void2 db 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 3                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;Checking borders and neighboring cells

;jump to/from the current bank. c - bank index, d - jump index
st c, bank;switch the bank
jmp d;this instruction is already executed in another bank. jump to the needed address


;###############################################################
;function to get the display pixel value at coordinates from a, b into flag z. fn_output_index - jump index
get_pixel_value:

ldi d, $ + 4;get the display byte
jmp get_point;a - display byte, c - mask

and a, c;get the bit value into a

test a;flag z - a = 0

ld d, function_output_index
jmp d;jump back
;###############################################################


;###############################################################
;function to determine whether movement is possible in all directions
;a - xpos, b - ypos
test_borders:

clr c;register c - for borders
ldi d, 0b00001000;mask

;
;UP
;
dec b;check the top border
js up
jns up_else

up:;if there is a border above, add d to c
or c, d
jmp up_end

up_else:;if it is free above, check the contents of the cell above
dec b;subtract a second time

st a, buffer + 3;cell check is moved to a function
ldi a, $ + 4
jmp test_cell

up_end:
shr d;shift d to the next direction

;
;RIGHT
;
ld a, x;load the original coordinates
ld b, y

inc a;check the right border
inc a;add twice because the screen size is even

st d, buffer;save d

ldi d, 0x0F;trim the first 4 bits of the position(simulating a 4-bit variable)
and d, a

ld d, buffer;restore d

jz right
jnz right_else

right:;if there is a border on the right, add d to c
or c, d
jmp right_end

right_else:;if it is free on the right, check the contents of the cell on the right

st a, buffer + 3;cell check is moved to a function
ldi a, $ + 4
jmp test_cell

right_end:
shr d;shift d to the next direction

;
;DOWN
;
ld a, x;load the original coordinates
ld b, y

inc b;check the bottom border
inc b;add twice because the screen size is even

st d, buffer;save d

ldi d, 0x0F;trim the first 4 bits of the position(simulating a 4-bit variable)
and d, b

ld d, buffer;restore d

jz down
jnz down_else

down:;if there is a border below, add d to c
or c, d
jmp down_end

down_else:;if it is free below, check the contents of the cell below

st a, buffer + 3;cell check is moved to a function
ldi a, $ + 4
jmp test_cell

down_end:
shr d;shift d to the next direction

;
;LEFT
;
ld a, x;load the original coordinates
ld b, y

dec a;check the left border
js left
jns left_else

left:;if there is a border on the left, add d to c
or c, d
jmp left_end

left_else:;if it is free on the left, check the contents of the cell on the left
dec a;subtract a second time

st a, buffer + 3;cell check is moved to a function
ldi a, $ + 4
jmp test_cell

left_end:


st c, function_output;save the border byte to memory

ldi d, 0x0F;if there are borders on all sides, jump to remove, otherwise to move
sub c, d

jz jmp_remove
ldi d, move
jmp jmp_end

jmp_remove:
ldi d, remove

jmp_end:

ldi c, BANK_MAIN
jmp in_out
;###############################################################

void3 db 0,0,0,0,0,0,0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 4                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;Getting the coordinates of a neighboring cell by direction

;jump to/from the current bank. c - bank index, d - jump index
st c, bank;switch the bank
jmp d;this instruction is already executed in another bank. jump to the needed address


;###############################################################
;function to determine the position of a neighboring cell by direction
;b - direction
;fn_input - how much to increase/decrease
get_rotate_position:

mov c, b;copy the direction into c

ld a, x;load the coordinates
ld b, y

;up
ldi d, 0b00001000
sub d, c
jz test_up
jmp test_up_end

test_up:
ld d, function_input
sub b, d
test_up_end:

;right
ldi d, 0b00000100
sub d, c
jz test_right
jmp test_right_end

test_right:
ld d, function_input
add a, d
test_right_end:

;down
ldi d, 0b00000010
sub d, c
jz test_down
jmp test_down_end

test_down:
ld d, function_input
add b, d
test_down_end:

;left
ldi d, 0b00000001
sub d, c
jz test_left
jmp test_left_end

test_left:
ld d, function_input
sub a, d
test_left_end:

ld d, function_output_index
jmp d
;###############################################################


;###############################################################
;writes the coordinates from register b
get_pos_from_byte:

st b, buffer;save the position to the buffer because the point drawing function takes the position from register c

ldi a, 0xF0;a - xpos
and a, b
shr a;shift right by 4 bits
shr a
shr a
shr a

ldi c, 0x0F;b - ypos
and b, c

st a, x;save x to memory
st b, y;save y to memory

ldi c, BANK_MAIN
ldi d, get_pos_return
jmp in_out
;###############################################################


;###############################################################
;continuation of the code from bank 1
get_coord:

st b, buffer;save the direction to the buffer(to avoid overwriting the register)

ldi d, 2;get the new coordinates(for the stack)
st d, function_input
ldi d, $ + 6
st d, function_output_index
jmp get_rotate_position

shl a;convert 2 coordinate bytes into 1
shl a
shl a
shl a
or a, b
st a, function_output;save to fn_output


ld b, buffer;load the direction from the buffer

ldi d, 1;get the coordinates for drawing the line
st d, function_input
ldi d, $ + 6
st d, function_output_index
jmp get_rotate_position


ld d, function_output;copy from fn_out to fn_in(because the stack push function takes the coordinates in fn_in)
st d, function_input

ldi c, BANK_MAIN
ldi d, get_coord_return
jmp in_out
;###############################################################
