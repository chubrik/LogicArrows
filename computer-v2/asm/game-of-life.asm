; ##################################################################################################
; ##            Source code for the "Game of Life" for a computer made of logic arrows            ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                         (c) 2024 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################



; Constants
BANK_INNER      equ 1                       ; Memory bank #1
BANK_MAIN       equ 2                       ; Memory bank #2
BANK_OUTER      equ 3                       ; Memory bank #3



;===================================================================================================
; Common memory area - address space 0x00...0x7F.
; Contains: code for displaying the game title in the terminal, memory bank switcher, ports,
; variables, display memory, cache for the next frame. After displaying the game title in the
; terminal, the entire memory area 0x00...0x2F is overwritten and then used to store neighbor
; counters for the cells. The counters are divided into three groups of 16, where each group
; corresponds to its own row on the display.
;===================================================================================================

; Start the game
                    jmp title_show          ; Jump over the string
title           db  "ьнзиЖ аргИ ",          ; The game's title in Russian (reversed)
                    "efiL fo emaG"          ; The game's title in English (reversed)

; Prepare to output the game title in the terminal
title_show:         ldi b, " "
                    st b, title - 1         ; Append a space to the game title string
                    ldi a, terminal
                    ldi c, title_show - 1   ; Pointer to the last character of the string. During
                                            ;   the loop, the pointer moves to the beginning of the
                                            ;   string and also acts as a counter to end the loop.
                    ldi d, title_show_loop

; Terminal output loop
title_show_loop:    ld b, c
                    st b, a
                    dec c
                    jnz d

; Switch output to monochrome display and digital indicator
                    ldi a, 0b00010100
                    st a, out

; Prepare registers C and D for switching between memory banks, and registers A and B for the
; "main_rnd" block
                    ldi a, display
                    ;                       ; Register B already contains " ", i.e., the number 32
                    ldi c, BANK_MAIN
                    ldi d, main_rnd

; Universal jump between memory banks.
; Register C already contains the memory bank number.
; Register D already contains the address for the jump.
set_bank:           st c, bank
                    jmp d

; Variables and ports

upper_area      db  0x00            ; Reference to the counter area for the row above the current
current_area    db  0x10            ; Reference to the counter area for the current row
lower_area      db  0x20            ; Reference to the counter area for the row below the current
upper_ptr       db  0x00            ; Pointer in the counter area for the row above the current
lower_ptr       db  0x20            ; Pointer in the counter area for the row below the current
display_ptr     db  display         ; Pointer on the display

bcd             db  255, 0          ; Frame counter. On the first increment, the value will change
                                    ;   to 0.
terminal        db  0
incrementor     db  0               ; Counter for some loops
out             db  0b00110001      ; Output port, connect color display and terminal
bank            db  0               ; Memory bank port

; Area 0x40...0x5F contains the red component of the splash screen displayed during program loading.
; This area is then used to show the current frame on the display.
display         db  0b01100000, 0b00000000, ;   ████                           ;
                    0b10001001, 0b10100010, ; ██      ██    ████  ██      ██   ;
                    0b10100101, 0b01010101, ; ██  ██    ██  ██  ██  ██  ██  ██ ;
                    0b10101101, 0b01010110, ; ██  ██  ████  ██  ██  ██  ████   ;
                    0b01101101, 0b01010011, ;   ████  ████  ██  ██  ██    ████ ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b00001010, 0b00101000, ;         ██  ██      ██  ██       ;
                    0b00010001, 0b01000000, ;       ██      ██  ██             ;
                    0b00100010, 0b00101000, ;     ██      ██      ██  ██       ;
                    0b00010100, 0b01000000, ;       ██  ██      ██             ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b10001110, 0b11101110, ; ██      ██████  ██████  ██████   ;
                    0b10000100, 0b10001000, ; ██        ██    ██      ██       ;
                    0b10000100, 0b11001100, ; ██        ██    ████    ████     ;
                    0b10000100, 0b10001000, ; ██        ██    ██      ██       ;
                    0b11101110, 0b10001110  ; ██████  ██████  ██      ██████   ;

; Area 0x60...0x7F contains the blue component of the splash screen displayed during program
; loading. This area is then used as a cache for the next frame.
frame_cache     db  0b01100000, 0b00000000, ;   ████                           ;
                    0b10001001, 0b10100010, ; ██      ██    ████  ██      ██   ;
                    0b10100101, 0b01010101, ; ██  ██    ██  ██  ██  ██  ██  ██ ;
                    0b10101101, 0b01010110, ; ██  ██  ████  ██  ██  ██  ████   ;
                    0b01101101, 0b01010011, ;   ████  ████  ██  ██  ██    ████ ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b00010100, 0b01010100, ;       ██  ██      ██  ██  ██     ;
                    0b00100010, 0b00100000, ;     ██      ██      ██           ;
                    0b00010001, 0b01010000, ;       ██      ██  ██  ██         ;
                    0b00001010, 0b00100000, ;         ██  ██      ██           ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b10001110, 0b11101110, ; ██      ██████  ██████  ██████   ;
                    0b10000100, 0b10001000, ; ██        ██    ██      ██       ;
                    0b10000100, 0b11001100, ; ██        ██    ████    ████     ;
                    0b10000100, 0b10001000, ; ██        ██    ██      ██       ;
                    0b11101110, 0b10001110  ; ██████  ██████  ██      ██████   ;



;===================================================================================================
; BANK_INNER - Memory Bank #1 - address space 0x80...0xFF.
; Contains the logic for processing all display rows except the top and bottom ones.
;===================================================================================================

; Start processing a display row
inner_begin:        ldi b, inner_center
                    st b, inner_edge_jmp + 1    ; Replace the jump address after processing the
                                                ;   leftmost pixel
                    ldi b, inner_right
                    st b, inner_center_jmp + 1  ; Replace the jump address after processing the
                                                ;   left half of the display row
                    ld b, display_ptr
                    ld a, b                     ; Load the left half of the display row
                    shr a                       ; A shift helps to unify further processing

                    ld c, current_area
                    inc c                       ; Pointer to the counter for the right neighbor

; Process the edge pixel on the display.
; Register A already contains the edge pixel in the 6th bit.
; Register C already contains the pointer to the counter for the only side neighbor.
inner_edge:         rcl a                       ; Shift the edge pixel to the 7th bit
                    jns inner_edge_end          ; If the pixel is empty, skip its processing

; Increment the counters for two neighbors in the row above
                    ld d, upper_ptr
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d

; Increment the counter for the only side neighbor
                    ld b, c
                    inc b
                    st b, c

; Increment the counters for two neighbors in the row below
                    ld d, lower_ptr
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d

inner_edge_end:     dec c
inner_edge_jmp:     jmp inner_center            ; Replaceable jump address

; Switch from processing the left half of the display to the right.
; Register C already contains the pointer to the counter for the left of the two side neighbors.
inner_right:        ldi b, inner_edge
                    st b, inner_center_jmp + 1  ; Replace the jump address after processing the
                                                ;   right half of the display row
                    ldi b, inner_end
                    st b, inner_edge_jmp + 1    ; Replace the jump address after processing the
                                                ;   rightmost pixel
                    ld b, display_ptr
                    inc b
                    ld a, b                     ; Load the right half of the display row
                    shr a                       ; A shift helps to unify further processing

; Process 7 pixels, except the edge one, on one half of the display.
; Register A already contains 7 pixels in bits 6 to 0.
; Register C already contains the pointer to the counter for the left of the two side neighbors.
inner_center:       ldi b, 8
                    st b, incrementor

; Loop for processing each of the 7 pixels
inner_center_loop:  ld b, incrementor
                    dec b
                    st b, incrementor
inner_center_jmp:   jz inner_right              ; Replaceable jump address

                    rcl a                       ; Shift the next pixel to the 7th bit
                    jns inner_center_end        ; If the pixel is empty, skip its processing

; Increment the counters for three neighbors in the row above
                    ld d, upper_ptr
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d

; Increment the counters for the two side neighbors
                    ld b, c
                    inc b
                    st b, c
                    inc c
                    inc c
                    ld b, c
                    inc b
                    st b, c
                    dec c
                    dec c

; Increment the counters for three neighbors in the row below
                    ld d, lower_ptr
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d

; Prepare to process the next pixel
inner_center_end:   ld d, upper_ptr
                    inc d
                    st d, upper_ptr
                    inc c
                    ld d, lower_ptr
                    inc d
                    st d, lower_ptr
                    jmp inner_center_loop

; Processing of the display row is complete. Proceed to calculate the row above the current one.
inner_end:          ldi c, BANK_MAIN
                    ldi d, main_calc
                    jmp set_bank

void3           db  0, 0, 0, 0



;===================================================================================================
; BANK_MAIN - Memory Bank #2 - address space 0x80...0xFF.
; Contains: generation of the starting frame with a random pattern, switching logic between display
; rows, calculation and display of the next frame, incrementing the digital indicator, and proceed
; to the next iteration.
;===================================================================================================

; Switch to the next display row. To do this, swap the references to the counter areas: the current
; row becomes the row above, the row below becomes the current row, and the row above becomes the
; row below and requires its counters to be reset. When we reach the bottom row, all references will
; automatically get their initial values.
main_row:           ld b, upper_area
                    ld c, current_area
                    ld d, lower_area
                    st c, upper_area
                    st d, current_area
                    st b, lower_area

                    st c, upper_ptr
                    st b, lower_ptr

; If display_ptr has the value 0x5E, it means we have reached the bottom row of the display, and
; different code is needed to process it.
                    ld d, display_ptr
                    ldi a, 0x5E
                    xor a, d
                    jz main_row_end

; Reset the counters for the display row below the current one. Instead of zeros, use 0xFE, which
; optimizes the further calculation.
                    ldi a, 0xFE
                    ;                           ; Register B already contains lower_area
                    ldi c, 16
                    ldi d, main_row_loop

; Counter reset loop
main_row_loop:      st a, b
                    inc b
                    dec c
                    jnz d

; Jump to process the display row (except the bottom one)
                    inc c                       ; Value 1 corresponds to BANK_INNER
                    ldi d, inner_begin
                    jmp set_bank

; Jump to process the bottom display row
main_row_end:       ldi c, BANK_OUTER
                    ldi d, outer_down
                    jmp set_bank

; Calculate one row of the next frame, for which all counters are already filled
main_calc:          ld c, display_ptr
                    ld d, upper_area

; Calculate half of the display row. For the second half, execute this code again.
; Register C already contains the display pointer.
; Register D already contains the pointer to the counter area.
main_calc_iter:     dec c                       ; Decrement the display pointer twice to move to the
                    dec c                       ;   row above
                    ld a, c                     ; Load one of the halves of the display row
                    ldi c, 0b10000000           ; Create a mask for the left pixel

; Loop for calculating each of the 8 pixels
main_calc_loop:     ld b, d                     ; Load the counter value
                    test b
                    jz main_calc_next           ; If the counter shows zero, it means the number of
                                                ;   neighbors is 2, and the pixel is not changed
                    or a, c                     ; Fill the pixel
                    dec b                       ; Decrease the counter value by 1
                    jz main_calc_next           ; Now, if the counter shows zero, it means the
                                                ;   number of neighbors is 3, and the pixel is no
                                                ;   longer changed
                    xor a, c                    ; The number of neighbors is not 2 or 3, so clear
                                                ;   the pixel

; Prepare the next pixel
main_calc_next:     inc d                       ; Move the pointer to the next counter
                    shr c                       ; Shift the pixel mask to the right
                    jnz main_calc_loop          ; Repeat the iteration

; Apply the calculation result
                    ld c, display_ptr
                    ldi b, 30                   ; Shift amount for the save address
                    add b, c
                    st a, b                     ; Save the result to the next frame cache
                    inc c
                    st c, display_ptr           ; Move the display pointer
                    shr b
                    jnc main_calc_iter          ; If the save address is even, repeat the
                                                ;   calculation

main_calc_jmp:      jmp main_row                ; Replaceable jump address

; Processing of the entire display is complete. It remains to perform calculations for the two
; bottom rows.
main_final:         ldi b, main_final2
                    st b, main_calc_jmp + 1     ; Replace the jump address after calculating the
                                                ;   second to last row
                    jmp main_calc

; It remains to perform the calculation for one bottom row of the display.
; Register C already contains the display pointer.
; Register D already contains a reference to the beginning of the counter area for the bottom row
; of the display.
main_final2:        ldi b, main_final3
                    st b, main_calc_jmp + 1     ; Replace the jump address after calculating the
                                                ;   bottom row
                    jmp main_calc_iter

main_final3:        ldi b, main_row
                    st b, main_calc_jmp + 1     ; Restore the jump address after calculation

; Output the next frame from the cache on the display
main_frame:         ldi b, display
                    ldi c, frame_cache
                    ldi d, main_frame_loop

main_frame_loop:    ld a, c
                    st a, b
                    inc b
                    inc c
                    jns d

; Update the frame counter on the digital indicator. At this point, all work on the frame is
; complete, and we move on to the next frame.
main_count:         ld a, bcd
                    inc a
                    st a, bcd

                    ldi c, BANK_OUTER
                    ldi d, outer_up
                    jmp set_bank

; Generate and output the starting frame with a random pattern on the display.
; Register A already contains "display".
; Register B already contains the number 32.
main_rnd:
main_rnd_loop:      rnd c
                    rnd d
                    and c, d
                    st c, a
                    inc a
                    dec b
                    jnz main_rnd_loop

                    jmp main_count



;===================================================================================================
; BANK_OUTER - Memory Bank #3 - address space 0x80...0xFF.
; Contains the logic for processing the top and bottom rows of the display.
;===================================================================================================

; Prepare to process the top row of the display
outer_up:           ldi c, display
                    st c, display_ptr           ; Set the pointer to the beginning of the display
                                                ;   area

                    shr c                       ; The value becomes 0x20
                    st c, lower_area            ; Restore the value of the lower_area variable after
                                                ;   processing the previous frame

; Reset the counters for the current display row and the row below. Instead of zeros, use 0xFE,
; which optimizes the further calculation.
                    ldi a, 0xFE
                    ld b, current_area
                    ;                           ; Register C already contains the number 32
                    ldi d, outer_up_loop

; Counter reset loop
outer_up_loop:      st a, b
                    inc b
                    dec c
                    jnz d

                    jmp outer_begin

; Prepare to process the bottom row of the display. Temporarily write the reference upper_area to
; the lower_area variable. This allows using a single program code for both the top and bottom rows
; of the display.
outer_down:         clr c                       ; Value 0x00 corresponds to upper_area
                    st c, lower_area

; Start processing the display row
outer_begin:        ldi b, outer_center
                    st b, outer_edge_jmp + 1    ; Replace the jump address after processing the
                                                ;   top-left corner pixel
                    ldi b, outer_right
                    st b, outer_center_jmp + 1  ; Replace the jump address after processing the left
                                                ;   half of the display row
                    ld b, display_ptr
                    ld a, b                     ; Load the left half of the display row
                    shr a                       ; A shift helps to unify further processing

                    ldi c, 0x11                 ; current_area + 1, i.e., pointer to the counter for
                                                ;   the neighbor to the right
                    ld d, lower_area            ; Pointer to the counter for the left of the two
                                                ;   neighbors in the other row

; Process the corner pixel on the display.
; Register A already contains the corner pixel in the 6th bit.
; Register C already contains the pointer to the counter for the only side neighbor.
; Register D already contains the pointer to the counter for the left of the two neighbors in the
; other row.
outer_edge:         rcl a                       ; Shift the corner pixel to the 7th bit
                    jns outer_edge_end          ; If the pixel is empty, skip its processing

; Increment the counter for the only side neighbor
                    ld b, c
                    inc b
                    st b, c

; Increment the counters for the two neighbors in the other row
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d
                    dec d

outer_edge_end:     dec c
outer_edge_jmp:     jmp outer_center            ; Replaceable jump address

; Switch from processing the left half of the display to the right.
; Register C already contains the pointer to the counter for the left of the two side neighbors.
; Register D already contains the pointer to the counter for the left of the three neighbors in the
; other row.
outer_right:        ldi b, outer_edge
                    st b, outer_center_jmp + 1  ; Replace the jump address after processing the
                                                ;   right half of the display row
                    ldi b, outer_end
                    st b, outer_edge_jmp + 1    ; Replace the jump address after processing the
                                                ;   bottom-right corner pixel
                    ld b, display_ptr
                    inc b
                    ld a, b                     ; Load the right half of the display row
                    shr a                       ; A shift helps to unify further processing

; Process 7 pixels, except the corner one, on one half of the display.
; Register A already contains 7 pixels in bits 6 to 0.
; Register C already contains the pointer to the counter for the left of the two side neighbors.
; Register D already contains the pointer to the counter for the left of the three neighbors in the
; other row.
outer_center:       ldi b, 8
                    st b, incrementor

; Loop for processing each of the 7 pixels
outer_center_loop:  ld b, incrementor
                    dec b
                    st b, incrementor
outer_center_jmp:   jz outer_right              ; Replaceable jump address

                    rcl a                       ; Shift the next pixel to the 7th bit
                    jns outer_center_else       ; If the pixel is empty, skip its processing

; Increment the counters for the two side neighbors
                    ld b, c
                    inc b
                    st b, c
                    inc c
                    inc c
                    ld b, c
                    inc b
                    st b, c
                    dec c

; Increment the counters for the three neighbors in the other row
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d
                    dec d

                    jmp outer_center_loop

; Prepare to process the next pixel
outer_center_else:  inc c
                    inc d
                    jmp outer_center_loop

; Processing of the display row is complete. To determine if it was the top or bottom row, look at
; the lower_area variable. For the bottom row, we changed its value with 0x00.
outer_end:          ldi c, BANK_MAIN

                    ld a, lower_area
                    test a
                    jz outer_end_down

; Processing of the top row of the display is complete. Proceed to process the next rows.
outer_end_up:       ldi a, 0x42
                    st a, display_ptr
                    ldi d, main_row
                    jmp set_bank

; Processing of the bottom row of the display is complete. Proceed to calculate the remaining two
; bottom rows and display the next frame.
outer_end_down:     ldi d, main_final
                    jmp set_bank
