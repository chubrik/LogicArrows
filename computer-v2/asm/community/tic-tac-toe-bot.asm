; ##################################################################################################
; ##     Source code for the "Tic-Tac-Toe" game (vs. bot) for a computer made of logic arrows     ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                     (c) 2026 Farmer_2010 (https://github.com/farmer2010)                     ##
; ##################################################################################################



COLORED equ 0b00110001
MONO equ 0b00010001

KEY_UP equ 0x12
KEY_RIGHT equ 0x13
KEY_DOWN equ 0x14
KEY_LEFT equ 0x11
KEY_SPACE equ 0x20

BANK_MAIN equ 1
BANK_LOGIC equ 2
BANK_WIN equ 3
BANK_DRAW equ 4
BANK_LINE equ 5
BANK_FIND equ 6
BANK_BOT equ 7


;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                        COMMON AREA                          W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


ldi a, display
ldi b, 64

clear:
st d, a

inc a
dec b
jnz clear

ldi a, BANK_LOGIC
st a, bank
jmp select_player

void db 0,0

jump_start:
ldi c, BANK_MAIN
st c, bank
jmp start
;###############################################################
change_bank:;switching between banks. c - bank index, d - jump index
st c, bank
jmp d
;###############################################################

buffer db 0,0,0,0

rotate_position db 255,;left
				   255,;up
				   1,  ;right
				   1   ;down

color db 0b00000001;01 - red, 10 - blue, 11 - magenta
render_buffer db 0b00000000, 0b00000000,
				 0b00000000, 0b00000000,
				 0b00000000, 0b00000000,
				 0b00000000, 0b00000000,
				 0b00000000, 0b00000000,
				 0b00000000, 0b00000000

player db 0

field db 0,0,0,;1 - X, 10 - O
		 0,0,0,
		 0,0,0
		 
stack_length equ render_buffer;these variables are only needed by the bot, so they will not disturb the render buffer.
finded_cells equ render_buffer + 1;put them there to save space

select_x db 1
select_y db 1

fn_output_index db 0

terminal_input db 0;0x3C
terminal_graphics db 0;0x3D
connect db COLORED;0x3E
bank db 1;0x3F

display db      0b00000000, 0b00000000,
				0b01001000, 0b00000000,
				0b00110000, 0b00000000,
				0b00110000, 0b00000000,
				0b01001000, 0b00000000,
				0b00000111, 0b11100000,
				0b00000110, 0b01100000,
				0b00000101, 0b10100000,
				0b00000101, 0b10100000,
				0b00000110, 0b01100000,
				0b00000111, 0b11100000,
				0b00000010, 0b01000000,
				0b00000001, 0b10000000,
				0b00000001, 0b10000000,
				0b00000010, 0b01000000,
				0b00000000, 0b00000000

display_blue db 0b00000000, 0b00000000,
				0b00000000, 0b00001100,
				0b00000000, 0b00010010,
				0b00000000, 0b00010010,
				0b00000000, 0b00001100,
				0b00000111, 0b11100000,
				0b00000100, 0b00100000,
				0b00000100, 0b00100000,
				0b00000100, 0b00100000,
				0b00000100, 0b00100000,
				0b00000111, 0b11100000,
				0b00110000, 0b00001100,
				0b01001000, 0b00010010,
				0b01001000, 0b00010010,
				0b00110000, 0b00001100,
				0b00000000, 0b00000000


;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 1                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

cycle:
ld c, player
test c
jnz get_bot_coord

ld c, connect

ldi d, KEY_SPACE
sub d, c
jnz move_selection
jmp step


get_bot_coord:
ldi c, BANK_BOT
ldi d, bot_input
jmp change_bank
step:
ldi c, BANK_LOGIC
ldi d, set_test
jmp change_bank

draw_O:
ldi a, 0b00000010
st a, color
ldi a, O
ldi b, draw_O_end
ldi c, BANK_DRAW
ldi d, draw
jmp change_bank

draw_X:
ldi a, 0b00000001
st a, color
ldi a, X
ldi b, draw_X_end
ldi c, BANK_DRAW
ldi d, draw
jmp change_bank

draw_O_end:

ldi c, BANK_LINE
ldi d, load_pos
jmp change_bank
load_pos_return:

draw_X_end:

ld c, player
not c
st c, player

ldi c, BANK_WIN
ldi d, test_win
jmp change_bank

skip_set:
jmp cycle

move_selection:
ldi d, 0x11
sub c, d

ldi d, 3
sub d, c
jc cycle

ldi a, select_x
ldi d, 0b00000001
and d, c
add a, d
ld b, a

ldi d, rotate_position
add c, d

ld d, c
add b, d
js cycle
ldi d, 3
sub d, b
jz cycle

st a, buffer + 1
st b, buffer + 2
ldi b, $ + 4
jmp draw_selection

ld a, buffer + 1
ld b, buffer + 2
st b, a

start:
ldi b, cycle

draw_selection:
ldi a, 0b00000011
st a, color
ldi a, selection
ldi c, BANK_DRAW
ldi d, draw
jmp change_bank

void1 db 0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 2                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


set_test:
ld a, select_x
ld b, select_y
mov c, b
shl c
add c, b
add c, a
ldi d, field
add c, d

ld d, c
test d
jnz not_free


ld d, player
test d
jz write_x

write_o:
ldi d, 10
st d, c
jmp write_o_end

write_x:
inc d;if we are here, d is 0
st d, c

write_o_end:
ld a, player
test a
jz ret_x
ldi d, draw_O
ldi a, "X"
st a, step_text_change_byte
jmp render_step_text

ret_x:
ldi d, draw_X
ldi a, "O"
st a, step_text_change_byte
jmp render_step_text

not_free:
ldi d, skip_set
jmp set_return


select_text db "Who starts\n(x/o)?\n>"
select_text_len equ $ - select_text

step_text db "\f\t\bO step\n"
step_text_len equ $ - step_text
step_text_change_byte equ step_text + 3


select_player:

ldi a, select_text
ldi b, select_text_len
select_text_cycle:
ld c, a
st c, terminal_input

inc a
dec b
jnz select_text_cycle

select_player_cycle:
ld a, connect
ldi b, "x"
sub b, a
jz to_start

ldi b, "o"
sub b, a
jnz select_player_cycle

ldi b, 255
st b, player

to_start:
st a, terminal_input
jmp jump_start


render_step_text:
ldi a, step_text
ldi b, step_text_len
step_text_cycle:
ld c, a
st c, terminal_input

inc a
dec b
jnz step_text_cycle
set_return:
ldi c, BANK_MAIN
jmp change_bank

void2 db 0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 3                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;checking for a win or a tie, printing the messages


test_win:

;a - sum
ldi c, 8
ldi d, lines
line_test_cycle:

ld b, d
ld a, b
inc d

ld b, d
ld b, b
add a, b
inc d

ld b, d
ld b, b
add a, b
inc d

ldi b, 30
sub b, a
jz blue_win

ldi b, 3
sub b, a
jz red_win

dec c
jnz line_test_cycle


ldi a, field
ldi b, 9
test_tie_cycle:

ld c, a
test c
jz not_tie

inc a
dec b
jnz test_tie_cycle


tie:
ldi a, tie_text
ldi b, tie_text_len
jmp text_cycle
red_win:
ldi a, red_text
ldi b, red_text_len
jmp text_cycle
blue_win:
ldi a, blue_text
ldi b, blue_text_len
text_cycle:
ld c, a
st c, terminal_input

inc a
dec b
jnz text_cycle

hlt

not_tie:
ldi c, BANK_MAIN
ldi d, skip_set
jmp change_bank


blue_text db "\f\t\bO win!\n"
blue_text_len equ $ - blue_text

red_text db "\f\t\bX win!\n"
red_text_len equ $ - red_text

tie_text db "\f\t\bA tie\n"
tie_text_len equ $ - tie_text

lines db field,   field+1, field+2,
		 field+3, field+4, field+5,
		 field+6, field+7, field+8,
		 field,   field+3, field+6,
		 field+1, field+4, field+7,
		 field+2, field+5, field+8,
		 field,   field+4, field+8,
		 field+2, field+4, field+6

void3 db 0,0,0,0,0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 4                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;drawing

draw:;a - image address, b - return address

st b, fn_output_index
ldi c, 6
ldi d, render_buffer
load_image_cycle:

ld b, a
st b, d

ldi b, 4
sub b, c
jz dec_end
jnc dec_a
inc a
jmp dec_end
dec_a:
dec a
dec_end:

inc d
clr b
st b, d
inc d
dec c
jnz load_image_cycle


ld a, select_x
mov b, a
shl b
shl b
add a, b
jz skip_shift
st a, buffer


ldi b, 6
ldi c, render_buffer
for_bytes:

ld a, buffer
shift_right:

ld d, c
shr d
st d, c
inc c
ld d, c
rcr d
st d, c

dec c

dec a
jnz shift_right

inc c
inc c
dec b
jnz for_bytes

skip_shift:

ldi c, display
ld b, select_y
mov a, b
shl a
shl a
shl a
add a, b
add a, b
add c, a
ldi a, 12
st a, buffer
ldi b, render_buffer

render:

ld a, color
ldi d, 0b00000001
and a, d
jz red_end

ld d, b
ld a, c
xor a, d
st a, c
red_end:

ld a, color
ldi d, 0b00000010
and a, d
jz blue_end

ldi a, 32
add c, a
ld d, b
ld a, c
xor a, d
st a, c

ldi a, 32
sub c, a
blue_end:


inc b
inc c
ld a, buffer
dec a
st a, buffer
jnz render

ldi c, BANK_MAIN
ld d, fn_output_index
jmp change_bank


X db		 0b00000000,
			 0b01001000,
			 0b00110000

O db		 0b00000000,
			 0b00110000,
			 0b01001000

selection db 0b11111100,
			 0b10000100,
			 0b10000100

void4 db 0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 5                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


test_lines:;a - control sum, b - output
	st a, buffer
	st b, fn_output_index

	ldi a, 7
	st a, buffer + 3

	ldi a, lines2

	test_lines_cycle:
			;###############################################################
			;a - line index
			ld d, a;cell #1
			ld c, d

			inc a
			ld d, a;cell #2
			ld d, d
			add c, d

			inc a
			ld d, a;cell #3
			ld d, d
			add c, d
			
			dec a
			dec a

			ld b, buffer
			sub b, c
			jnz continue

			ldi b, 3
			find_void_cycle:

				ld c, a
				ld d, c
				test d
				jz return_void_pos

			inc a
			dec b
			jnz find_void_cycle


			return_void_pos:
			mov a, c
			jmp test_lines_find


			continue:
			;###############################################################

		ld c, buffer + 3
		dec c
		js test_lines_output_zero
		st c, buffer + 3
		
		ldi d, 3
		add a, d
	jmp test_lines_cycle

test_lines_output_zero:
clr a
test_lines_find:
ldi c, BANK_BOT
ld d, fn_output_index
jmp change_bank



find_rnd_cell:
	st b, fn_output_index

	ldi b, finded_cells
	ldi d, 0b00001111

	find_rnd_cell_cycle:
		ld a, stack_length
		test a
		jz ret_if_stack_clear
		dec a
		
		rnd c
		and c, d
		sub a, c
	jnc cell_finded
	jmp find_rnd_cell_cycle

	cell_finded:
	add b, c
	ld a, b
	
ret_if_stack_clear:
ldi c, BANK_BOT
ld d, fn_output_index
jmp change_bank


load_pos:
ld a, buffer + 1
ld b, buffer + 2
st a, select_x
st b, select_y

ldi c, BANK_MAIN
ldi d, load_pos_return
jmp change_bank


lines2 db field,   field+1, field+2,
		  field+3, field+4, field+5,
		  field+6, field+7, field+8,
		  field,   field+3, field+6,
		  field+1, field+4, field+7,
		  field+2, field+5, field+8,
		  field,   field+4, field+8,
		  field+2, field+4, field+6

void5 db 0,0,0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 6                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


find_clear_cell:

clr a
st a, stack_length

ldi d, 9
ldi c, field
ldi b, finded_cells
find_clear_cells_cycle:
	ld a, c
	test a
	jnz skip_add_to_stack

	st c, b
	inc b
	ld a, stack_length
	inc a
	st a, stack_length

	skip_add_to_stack:

inc c
dec d
jnz find_clear_cells_cycle

ldi b, find_clear_cell_return
ldi c, BANK_LINE
ldi d, find_rnd_cell
jmp change_bank


find_clear_corners:
	clr a
	st a, stack_length
	
	ldi d, 4
	ldi c, corners
	ldi b, finded_cells
	find_clear_corners_cycle:
		ld a, c
		ld a, a
		test a
		jnz skip_add_corn_to_stack
		
		ld a, c
		st a, b
		ld a, stack_length
		inc a
		st a, stack_length
		inc b
		
		skip_add_corn_to_stack:
		inc c
	dec d
	jnz find_clear_corners_cycle
ldi b, find_clear_corners_return
ldi c, BANK_LINE
ldi d, find_rnd_cell
jmp change_bank



find_opposite_clear_corner:
	clr a
	st a, stack_length
	
	ldi d, 4
	st d, buffer
	ldi c, corners
	ldi b, finded_cells
	find_opposite_clear_corner_cycle:
		ld a, c
		ld a, a
		ldi d, 1
		sub d, a
		jnz opposite_cell_not_enemy
			inc c
			ld a, c
			ld d, a
			test d
			jnz skip_add_opposite_to_stack
				st a, b
				ld a, stack_length
				inc a
				st a, stack_length
				inc b
				jmp succesful_add
		opposite_cell_not_enemy:
		inc c
		skip_add_opposite_to_stack:
		succesful_add:
		inc c
	ld d, buffer
	dec d
	st d, buffer
	jnz find_opposite_clear_corner_cycle
ldi b, find_opposite_clear_corner_return
ldi c, BANK_LINE
ldi d, find_rnd_cell
jmp change_bank

corners db field,   field+8,
		   field+2, field+6,
		   field+8, field,
		   field+6, field+2
		   
void6 db 0,0,0,0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           BANK 7                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

bot_input:
ld a, select_x
ld b, select_y
st a, buffer + 1
st b, buffer + 2


ldi a, 9
ldi b, field
test_field_for_clear_cycle:

ld c, b
test c
jnz field_not_clear

inc b
dec a
jnz test_field_for_clear_cycle
jmp find_clear_cell_if_field_is_clear

field_not_clear:
ldi a, 20
ldi b, $ + 8
ldi c, BANK_LINE
ldi d, test_lines
jmp change_bank
test a
jnz unpack_coord

ldi a, 2
ldi b, $ + 8
ldi c, BANK_LINE
ldi d, test_lines
jmp change_bank
test a
jnz unpack_coord

ldi c, BANK_FIND
ldi d, find_opposite_clear_corner
jmp change_bank
find_opposite_clear_corner_return:
test a
jnz unpack_coord

ldi a, field + 4
ld b, a
test b
jz cent_cell_finded
clr a
cent_cell_finded:
test a
jnz unpack_coord

ldi c, BANK_FIND
ldi d, find_clear_corners
jmp change_bank
find_clear_corners_return:
test a
jnz unpack_coord

find_clear_cell_if_field_is_clear:
ldi c, BANK_FIND
ldi d, find_clear_cell
jmp change_bank
find_clear_cell_return:


unpack_coord:
ldi c, field
sub a, c
ldi c, addr_to_coord
add a, c
ld a, a

ldi b, 0b0011;b - ypos
and b, a
shr a;a - xpos
shr a

st a, select_x
st b, select_y


ldi c, BANK_MAIN
ldi d, step
jmp change_bank

addr_to_coord db 0b0000, 0b0100, 0b1000,
				 0b0001, 0b0101, 0b1001,
				 0b0010, 0b0110, 0b1010

void7 db 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0
