; ##################################################################################################
; ##             Source code for the game "Tetris" for a computer made of logic arrows            ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                         (c) 2025 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################



; Constants
KEY_LEFT        equ 0x11                    ; "Left" key code
KEY_UP          equ 0x12                    ; "Up" key code (turn)
KEY_RIGHT       equ 0x13                    ; "Right" key code
KEY_DOWN        equ 0x14                    ; "Down" key code
WALL            equ 0b00100000              ; Image of the wall between the fields
STEP_COUNT      equ 2                       ; Number of steps before shifting down
INI_COLUMN      equ 4                       ; Starting horizontal position of the piece
INI_BUFFER_PTR  equ buffer_end              ; Address of the end of the piece buffer
INI_DISPLAY_PTR equ display_b + 7           ; Address of the end of the piece area on the display

; Memory banks
BANK_SHOW       equ 1                       ; Collision check and display output
BANK_DOWN       equ 1                       ; Shifting the piece down
BANK_STEP       equ 2                       ; Keyboard polling and step control
BANK_LEFT       equ 2                       ; Shifting the piece left
BANK_RIGHT      equ 2                       ; Shifting the piece right
BANK_TURN_2     equ 3                       ; Continuation of piece rotation and rotation data
BANK_TURN_1     equ 4                       ; Start of piece rotation
BANK_DROP       equ 4                       ; Tower collapse
BANK_BLOCK      equ 5                       ; Locking the piece
BANK_INIT       equ 5                       ; Drawing the playing field
BANK_MINO       equ 6                       ; Proceed to the next piece
BANK_TITLE      equ 6                       ; Output the game title to the terminal



;===================================================================================================
; Common memory area
;===================================================================================================

; 8-byte buffer. Used for intermediate saving of the piece, checking it for collisions with the
; tower, and deciding whether to output the piece on the display or interrupt the step. Must be
; located at address 0x00, as most algorithms work from end to beginning, also using the buffer as a
; counter in a loop.
buffer:             ldi c, BANK_TITLE       ; Switch to output the game title to the terminal
                    st c, bank
                    jmp title_start
buffer_rest     db  0, 0
buffer_end      equ $ - 1

; Jump to the next piece
mino_next:          ldi c, BANK_MINO
                    st c, bank
                    jmp mino_start

; Jump to collision check and display output
check_n_show:       ldi c, BANK_SHOW
                    st c, bank
                    jmp show_start

; Interrupt the step with two possible outcomes: jumping to the next step or locking the piece
check_collided:     ld a, need_block
                    test a
                    jz step_next

; Jump to locking the piece
mino_block:         clr a
                    st a, need_block
                    ldi c, BANK_BLOCK
                    st c, bank
                    jmp block_start

; Jump to the next step
step_next:          ldi c, BANK_STEP
                    st c, bank
                    jmp step_start

; Universal jump between memory banks.
; Register C already contains the memory bank number.
; Register D already contains the address for the jump.
set_bank:           st c, bank
                    jmp d

; Variables
type            db  0                       ; Type of the current piece (1...7)
type_next       db  0                       ; Type of the next piece (1...7)
turn            db  0x00                    ; Reference to the data of the current piece rotation
turn_next       db  0x00                    ; Reference to the data of the next piece rotation
shown_bank      db  0                       ; Memory bank to switch to after display output
shown_addr      db  0x00                    ; Address to jump to after display output
need_block      db  0                       ; Flag indicating the need to lock the piece
step_remain     db  STEP_COUNT              ; Remaining number of steps before shifting down
column          db  INI_COLUMN              ; Horizontal position of the piece (0...9)
buffer_ptr      db  INI_BUFFER_PTR          ; Pointer to the buffer (0x00...0x07)
display_ptr     db  INI_DISPLAY_PTR         ; Pointer on the display (0x67...0x7F, always odd)
buffer_ptr_2    db  0x00                    ; Additional pointer to the buffer
display_ptr_2   db  0x00                    ; Additional pointer on the display

void0           db  0, 0

; Ports
bcd             db  0, 0
terminal        db  0, 0
in_out          db  0b00110001              ; Input/output port, connect color display and terminal
bank            db  0                       ; Memory bank port

; Area 0x40...0x5F contains the red component of the splash screen displayed during program loading
display_r       db  0b00100100, 0b10010010, ;     ██    ██    ██    ██    ██   ;
                    0b11111111, 0b11111111, ; ████████████████████████████████ ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b11111000, 0b11011100, ; ██████████      ████  ██████     ;
                    0b01010000, 0b10101000, ;   ██  ██        ██  ██  ██       ;
                    0b01011000, 0b11001000, ;   ██  ████      ████    ██       ;
                    0b01010000, 0b10101000, ;   ██  ██        ██  ██  ██       ;
                    0b01011000, 0b10111100, ;   ██  ████      ██  ████████     ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b11111000, 0b00011111, ; ██████████            ██████████ ;
                    0b01001000, 0b00010100, ;   ██    ██            ██  ██     ;
                    0b10011000, 0b00011001, ; ██    ████            ████    ██ ;
                    0b00101000, 0b00010010, ;     ██  ██            ██    ██   ;
                    0b01001000, 0b00010100, ;   ██    ██            ██  ██     ;
                    0b10011111, 0b11111001, ; ██    ████████████████████    ██ ;
                    0b00100100, 0b10010010  ;     ██    ██    ██    ██    ██   ;

; Area 0x60...0x7F contains the blue component of the splash screen displayed during program loading
display_b       db  0b10010010, 0b01001001, ; ██    ██    ██    ██    ██    ██ ;
                    0b11111111, 0b11111111, ; ████████████████████████████████ ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b00011111, 0b00011111, ;       ██████████      ██████████ ;
                    0b00010010, 0b00001010, ;       ██    ██          ██  ██   ;
                    0b00011010, 0b00001011, ;       ████  ██          ██  ████ ;
                    0b00010010, 0b00001001, ;       ██    ██          ██    ██ ;
                    0b00011010, 0b00011111, ;       ████  ██        ██████████ ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b11111000, 0b00011111, ; ██████████            ██████████ ;
                    0b00101000, 0b00010010, ;     ██  ██            ██    ██   ;
                    0b01001000, 0b00010100, ;   ██    ██            ██  ██     ;
                    0b10011000, 0b00011001, ; ██    ████            ████    ██ ;
                    0b00101000, 0b00010010, ;     ██  ██            ██    ██   ;
                    0b01001111, 0b11110100, ;   ██    ████████████████  ██     ;
                    0b10010010, 0b01001001  ; ██    ██    ██    ██    ██    ██ ;



;===================================================================================================
; Memory Bank #1: BANK_SHOW, BANK_DOWN
;===================================================================================================

; BANK_SHOW - Collision check and display output. The piece is already in the buffer.

; Check the buffer for collisions with the tower
show_start:         ld c, buffer_ptr
                    ld d, display_ptr
                    ldi a, 32
                    sub d, a

show_check_loop:    ld a, c
                    ld b, d
                    and a, b
                    jnz check_collided      ; If a collision is detected, interrupt the step
                    dec d
                    dec c
                    jns show_check_loop

; Output the buffer to the display
                    ld c, buffer_ptr
                    ld d, display_ptr

show_loop:          ld a, d
                    ldi b, 0b00111111
                    and a, b
                    ld b, c
                    or a, b
                    st a, d
                    dec d
                    dec c
                    ld a, c
                    st a, d
                    dec d
                    dec c
                    jns show_loop

; Jump to the previously saved address
                    ld c, shown_bank
                    ld d, shown_addr
                    jmp set_bank

;---------------------------------------------------------------------------------------------------

; BANK_DOWN - Shifting the piece down

; Set the flag to lock the piece and prepare separate pointers in case the step is interrupted
down_start:         ldi b, 0b11000000
                    st b, need_block
                    ld c, buffer_ptr
                    st c, buffer_ptr_2
                    ld d, display_ptr
                    st d, display_ptr_2

; Copy the piece to the buffer
down_copy_loop:     ld a, d
                    and a, b
                    st a, c
                    dec d
                    dec c
                    ld a, d
                    st a, c
                    dec d
                    dec c
                    jns down_copy_loop

; Check if the piece is hitting the floor
                    ldi b, WALL
                    ld a, 0x7F
                    xor a, b
                    jnz mino_block
                    ld a, 0x7E
                    test a
                    jnz mino_block

; Shift the display pointer. But if we are already at the very bottom, shift the buffer pointer
; instead, as if reducing both the piece area size on the display and the buffer size.
down_ptrs:          ld a, display_ptr
                    inc a
                    js down_ptrs_buffer
                    inc a
                    st a, display_ptr
                    jmp down_ptrs_after

down_ptrs_buffer:   ld a, buffer_ptr
                    dec a
                    dec a
                    st a, buffer_ptr

; Save the return address for after display output
down_ptrs_after:    ldi a, BANK_DOWN
                    st a, shown_bank
                    ldi a, down_shown
                    st a, shown_addr

; Jump to collision check and display output
                    jmp show_start

; After displaying, clear the row above the piece
down_shown:         ld c, buffer_ptr
                    ld d, display_ptr
                    sub d, c
                    dec d
                    ld a, d
                    ldi b, 0b00111111
                    and a, b
                    st a, d
                    dec d
                    clr a
                    st a, d

; Reset the piece lock flag and jump to the next step
                    st a, need_block
                    jmp step_next

void1           db  0, 0, 0, 0, 0, 0, 0, 0



;===================================================================================================
; Memory Bank #2: BANK_STEP, BANK_LEFT, BANK_RIGHT
;===================================================================================================

; BANK_STEP - Keyboard polling and step control

step_start:         ld a, step_remain
                    dec a
                    js step_down
                    st a, step_remain

                    ld a, in_out

                    ldi b, KEY_DOWN
                    xor b, a
                    jz step_down

                    ldi b, KEY_LEFT
                    xor b, a
                    jz left_start

                    ldi b, KEY_RIGHT
                    xor b, a
                    jz right_start

                    ldi b, KEY_UP
                    xor b, a
                    jnz step_start

                    ldi c, BANK_TURN_1
                    ldi d, turn_start
                    jmp set_bank

; Prepare to shift down
step_down:          ldi a, STEP_COUNT
                    st a, step_remain       ; Restore the number of steps before shifting down
                    ldi c, BANK_DOWN
                    ldi d, down_start
                    jmp set_bank

;---------------------------------------------------------------------------------------------------

; BANK_LEFT - Shifting the piece left

; Copy the piece to the buffer
left_start:         ldi b, 0b11000000
                    ld c, buffer_ptr
                    ld d, display_ptr

left_copy_loop:     ld a, d
                    and a, b
                    shl a
                    st a, c
                    dec d
                    dec c
                    ld a, d
                    rcl a
                    jc step_next            ; If moved past the left edge, interrupt the step
                    st a, c
                    dec d
                    dec c
                    jns left_copy_loop

; Save the return address for after display output
                    ldi a, BANK_LEFT
                    st a, shown_bank
                    ldi a, left_shown
                    st a, shown_addr

; Jump to collision check and display output
                    jmp check_n_show

; After displaying, shift the piece's position and jump to the next step
left_shown:         ld a, column
                    dec a
                    st a, column
                    jmp step_next

;---------------------------------------------------------------------------------------------------

; BANK_RIGHT - Shifting the piece right

; Copy the piece to the buffer
right_start:        ldi b, 0b11000000
                    ld c, buffer_ptr
                    ld d, display_ptr

right_copy_loop:    dec d
                    dec c
                    ld a, d
                    shr a
                    st a, c
                    inc d
                    inc c
                    ld a, d
                    and a, b
                    rcr a
                    st a, c
                    dec d
                    dec d
                    dec c
                    dec c
                    jns right_copy_loop

; Save the return address for after display output
                    ldi a, BANK_RIGHT
                    st a, shown_bank
                    ldi a, right_shown
                    st a, shown_addr

; Jump to collision check and display output
                    jmp check_n_show

; After displaying, shift the piece's position and jump to the next step
right_shown:        ld a, column
                    inc a
                    st a, column
                    jmp step_next

void2           db  0, 0, 0, 0, 0



;===================================================================================================
; Memory Bank #3: BANK_TURN_2
;===================================================================================================

; Continuation of piece rotation and rotation data

turn_data_ptr   db  0                       ; Pointer to the data of the next piece rotation

; Save the pointer and reference to the data of the next piece rotation
turn_proceed:       ld d, turn
                    st d, turn_data_ptr
                    ld a, d
                    st a, turn_next

; Row by row, read the pixel data of the piece, shift it right to the desired position, and save to
; the buffer
turn_row:           ld d, turn_data_ptr
                    inc d
                    ld a, d
                    st d, turn_data_ptr
                    clr b
                    ld c, column
                    dec c
                    jz turn_shift_after

                    ldi d, turn_shift_loop

turn_shift_loop:    shr a                   ; Shift the piece row to the right
                    rcr b
                    dec c
                    jnz d

turn_shift_after:   ld d, buffer_ptr_2      ; Save the piece row to the buffer
                    st b, d
                    dec d
                    st a, d
                    dec d
                    st d, buffer_ptr_2
                    jns turn_row

; Jump to collision check and display output
                    jmp check_n_show

; Rotation data for each piece. The O piece is missing as it cannot be rotated. For optimization,
; the pixel rows are stored in reverse order.

turn_i0         db  turn_i1, 0b00000000, 0b00000000, 0b11110000, 0b00000000 ; I piece
turn_i1         db  turn_i0, 0b01000000, 0b01000000, 0b01000000, 0b01000000

turn_s0         db  turn_s1, 0b00000000, 0b00000000, 0b11000000, 0b01100000 ; S piece
turn_s1         db  turn_s0, 0b00000000, 0b00100000, 0b01100000, 0b01000000

turn_z0         db  turn_z1, 0b00000000, 0b00000000, 0b01100000, 0b11000000 ; Z piece
turn_z1         db  turn_z0, 0b00000000, 0b01000000, 0b01100000, 0b00100000

turn_t0         db  turn_t1, 0b00000000, 0b00000000, 0b11100000, 0b01000000 ; T piece
turn_t1         db  turn_t2, 0b00000000, 0b01000000, 0b01100000, 0b01000000
turn_t2         db  turn_t3, 0b00000000, 0b01000000, 0b11100000, 0b00000000
turn_t3         db  turn_t0, 0b00000000, 0b01000000, 0b11000000, 0b01000000

turn_j0         db  turn_j1, 0b00000000, 0b00000000, 0b11100000, 0b10000000 ; J piece
turn_j1         db  turn_j2, 0b00000000, 0b01000000, 0b01000000, 0b01100000
turn_j2         db  turn_j3, 0b00000000, 0b00000000, 0b00100000, 0b11100000
turn_j3         db  turn_j0, 0b00000000, 0b01100000, 0b00100000, 0b00100000

turn_l0         db  turn_l1, 0b00000000, 0b00000000, 0b11100000, 0b00100000 ; L piece
turn_l1         db  turn_l2, 0b00000000, 0b01100000, 0b01000000, 0b01000000
turn_l2         db  turn_l3, 0b00000000, 0b00000000, 0b10000000, 0b11100000
turn_l3         db  turn_l0, 0b00000000, 0b00100000, 0b00100000, 0b01100000



;===================================================================================================
; Memory Bank #4: BANK_TURN_1, BANK_DROP
;===================================================================================================

; BANK_TURN_1 - Start of piece rotation

; Check if the piece can be rotated based on its type and location
turn_start:         ld a, column
                    ld b, display_ptr
                    ld c, type
                    test a
                    jz step_next            ; Rotation is not possible in the leftmost column
                    dec c
                    jz step_next            ; Rotation of O piece is not possible
                    dec c
                    jz turn_check_i         ; Separate restrictions for the I piece

turn_check:         ldi c, 8                ; Rotation is not possible in the rightmost column
                    ldi d, 0x82             ; Rotation is not possible in the two bottom rows
                    jmp turn_check_end

turn_check_i:       ldi c, 7                ; Rotation is not possible in the two rightmost columns
                    ldi d, 0x80             ; Rotation is not possible in the three bottom rows

; If one of the restrictions is met, interrupt the step
turn_check_end:     sub c, a
                    js step_next
                    sub d, b
                    js step_next

; Prepare a separate buffer pointer, independent of the piece's position on the display
                    ldi a, buffer_end
                    st a, buffer_ptr_2

; Save the return address for after display output
                    ldi a, BANK_TURN_1
                    st a, shown_bank
                    ldi a, turn_shown
                    st a, shown_addr

; Jump to continue rotation in another memory bank, there also start collision check and display
; output
                    ldi c, BANK_TURN_2
                    ldi d, turn_proceed
                    jmp set_bank

; After displaying, update the reference to the current piece rotation data and jump to the next
; step
turn_shown:         ld a, turn_next
                    st a, turn
                    jmp step_next

;---------------------------------------------------------------------------------------------------

; BANK_DROP - Tower collapse

; Prepare copy and paste pointers. Initially, they are the same.
drop_start:         ld d, display_ptr_2
                    mov c, d

; Phase drop1. Go from bottom to top of the piece area on the display. When an empty row is
; encountered, shift the copy pointer one row up, without changing the paste pointer.

drop1_loop:         ld b, c
                    ldi a, WALL
                    xor b, a
                    dec c
                    ld a, c
                    inc c
                    or a, b
                    jnz drop1_loop_copy

                    dec c
                    dec c
                    jmp drop1_loop_end

drop1_loop_copy:    ld b, c
                    dec c
                    ld a, c
                    dec c
                    st b, d
                    dec d
                    st a, d
                    dec d

drop1_loop_end:     ld a, buffer_ptr_2
                    dec a
                    dec a
                    st a, buffer_ptr_2
                    jns drop1_loop

; Phase drop2. Continue moving up the display above the piece area. When the copy pointer encounters
; an empty row or reaches the top of the display, proceed to the next phase.

drop2_loop:         ldi a, display_r
                    sub a, c
                    jns drop3_start

                    ld b, c
                    ldi a, WALL
                    xor b, a
                    dec c
                    ld a, c
                    inc c
                    or a, b
                    jz drop3_start

drop2_loop_copy:    ld b, c
                    dec c
                    ld a, c
                    dec c
                    st b, d
                    dec d
                    st a, d
                    dec d

                    jmp drop2_loop

; Phase drop3. Fill the screen with empty rows until the paste pointer matches the copy pointer.

drop3_start:        ldi b, WALL

drop3_loop:         clr a
                    st b, d
                    dec d
                    st a, d
                    dec d
                    mov a, c
                    xor a, d
                    jnz drop3_loop

; Jump to the next piece
                    jmp mino_next

void4           db  0, 0



;===================================================================================================
; Memory Bank #5: BANK_BLOCK, BANK_INIT
;===================================================================================================

; BANK_BLOCK - Locking the piece

block_not_full  db  0                       ; Flag for incompleteness of the right part of the row
block_need_drop db  0                       ; Flag for the need to collapse the tower

; Prepare flags and pointers
block_start:        clr a
                    st a, block_need_drop
                    ld c, buffer_ptr_2
                    st c, buffer_ptr
                    ld d, display_ptr_2
                    ldi c, 256 - 32
                    add c, d
                    st c, display_ptr_2     ; Pointer to the red part of the display area

; Row by row, transfer the piece from the blue area of the display to the red, merging it with the
; tower
block_row:          ld b, d
                    ldi a, 0b00111111
                    and a, b
                    st a, d
                    ld a, c
                    or a, b
                    ldi b, 0b11100000
                    and a, b
                    st a, c
                    xor b, a
                    st b, block_not_full
                    dec d
                    dec c

                    ld b, d
                    ld a, c
                    or a, b
                    clr b
                    st b, d
                    st a, c

; Check if the row is full
                    not a                   ; Flag for incompleteness of the left part of the row
                    ld b, block_not_full    ; Flag for incompleteness of the right part of the row
                    or a, b                 ; Flag for incompleteness of the entire row
                    jnz block_row_end

; Clear the filled row, remember the need to collapse the tower, and increase the score on the
; digital indicator
                    ldi b, WALL
                    st b, block_need_drop
                    inc c
                    st b, c
                    dec c
                    st a, c                 ; a = 0

                    ld a, bcd
                    inc a
                    st a, bcd

block_row_end:      dec d
                    dec c
                    ld a, buffer_ptr
                    dec a
                    dec a
                    st a, buffer_ptr
                    jns block_row

; Check if the tower needs to be collapsed, if not, jump to the next piece
                    ld a, block_need_drop
                    test a
                    jz mino_next

; Jump to collapse the tower
                    ldi c, BANK_DROP
                    ldi d, drop_start
                    jmp set_bank

;---------------------------------------------------------------------------------------------------

; BANK_INIT - Drawing the playing field

; Randomly choose the type of the next piece. It will also be the first piece in the game.
init_start:         ldi a, 0b00000111

init_next_loop:     rnd c
                    and c, a
                    jz init_next_loop

                    st c, type_next

; Disable color mode on the display and draw the playing field
                    ldi a, 0b00010000
                    st a, in_out

                    clr a
                    ldi b, WALL
                    ldi c, display_r
                    ldi d, display_b

init_area_loop:     st a, c
                    inc c
                    st b, c
                    inc c
                    st a, d
                    inc d
                    st b, d
                    inc d
                    jns init_area_loop

; Restore color mode on the display and connect the digital indicator
                    ldi c, 0b00110100
                    st c, in_out
                    st a, bcd               ; Output 0 to the digital indicator

; Jump to the start of the game process
                    ldi c, BANK_MINO
                    ldi d, mino_start
                    jmp set_bank

void5           db  0, 0, 0, 0, 0, 0, 0, 0, 0



;===================================================================================================
; Memory Bank #6: BANK_MINO, BANK_TITLE
;===================================================================================================

; BANK_MINO - Proceed to the next piece

; Randomly choose the type of the next piece
mino_start:         ldi a, 0b00000111

mino_next_loop:     rnd c
                    and c, a
                    jz mino_next_loop

; The previous next piece becomes the current one
                    ld a, type_next
                    st a, type
                    st c, type_next

; Output the current piece on the playing field
                    ldi d, minos - 3
                    add d, a                ; Multiplication by 3
                    add d, a
                    add d, a
                    ld a, d
                    st a, turn
                    inc d
                    ld a, d
                    inc d
                    ld b, d
                    st a, display_b
                    st b, display_b + 2

; If there are collisions with the tower, end the game
                    ld d, display_r
                    and a, d
                    jnz game_over
                    ld d, display_r + 2
                    and b, d
                    jnz game_over

; Output the next piece on the side field
                    ; c = type_next
                    ldi d, minos - 2
                    add d, c                ; Multiplication by 3
                    add d, c
                    add d, c
                    ld a, d
                    inc d
                    ld b, d
                    shr a
                    shr b
                    ldi c, WALL
                    or a, c
                    or b, c
                    st a, display_b + 3
                    st b, display_b + 5

; Set the piece's position and pointers to their initial state
                    ldi a, INI_COLUMN
                    st a, column
                    ldi a, INI_BUFFER_PTR
                    st a, buffer_ptr
                    ldi a, INI_DISPLAY_PTR
                    st a, display_ptr

; Jump to the next step
                    jmp step_next

; End the game
game_over:          hlt

; Data for each piece: reference to rotation data and starting image
minos           db  0,       0b00001100, 0b00001100,    ; O piece
                    turn_i1, 0b00000000, 0b00011110,    ; I piece
                    turn_s1, 0b00001100, 0b00011000,    ; S piece
                    turn_z1, 0b00011000, 0b00001100,    ; Z piece
                    turn_t1, 0b00001000, 0b00011100,    ; T piece
                    turn_j1, 0b00010000, 0b00011100,    ; J piece
                    turn_l1, 0b00000100, 0b00011100     ; L piece

;---------------------------------------------------------------------------------------------------

; BANK_TITLE - Output the game title to the terminal

title_start:        ldi b, title_size
                    ldi c, title
                    ldi d, terminal

title_loop:         ld a, c
                    st a, d
                    inc c
                    dec b
                    jnz title_loop

; Jump to game initialization
                    ldi c, BANK_INIT
                    ldi d, init_start
                    jmp set_bank

; Game title for terminal output
title           db  "\t\b", "TETRIS", "\n"
title_size      equ $ - title
