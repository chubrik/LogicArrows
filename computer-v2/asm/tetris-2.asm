####################################################################################################
##              Source code for the "Tetris" game for a computer made of logic arrows             ##
##                Исходный код игры "Тетрис" для компьютера из логических стрелочек               ##
##                  https://github.com/chubrik/LogicArrows/tree/main/computer-v2                  ##
##                          (с) 2025 Arkadi Chubrik (arkadi@chubrik.org)                          ##
####################################################################################################



; Константы
KEY_LEFT        equ 0x11                    ; Код клавиши "Влево"
KEY_UP          equ 0x12                    ; Код клавиши "Вверх" (поворот)
KEY_RIGHT       equ 0x13                    ; Код клавиши "Вправо"
KEY_DOWN        equ 0x14                    ; Код клавиши "Вниз"
WALL            equ 0b00100000

buffer          db  0, 0, 0, 0, 0, 0, 0, 0  ; Буфер фигуры. Должен лежать по адресу 0x00.
buffer_end      equ $ -1                    ; Адрес конца буфера

; Переменные
type            db  0                       ; Тип текущей фигуры (1...7)
type_next       db  0                       ; Тип следующей фигуры (1...7)
turn            db  0x00                    ; Адрес данных о текущем повороте фигуры
turn_next       db  0x00                    ; Адрес данных о следующем повороте фигуры
column          db  4                       ; Позиция второй колонки области фигуры (0...9)
displayed_bank  db  0                       ; Банк для перехода после вывода на дисплей
displayed_addr  db  0x00				    ; Адрес для перехода после вывода на дисплей
need_block      db  0                       ; Флаг необходимости блокировки фигуры

buffer_ptr      db  buffer_end              ; Указатель на буфер. Если область фигуры спускается
                                            ;   ниже экрана дисплея, указатель смещается назад, как
                                            ;   бы уменьшая размер буфера.
display_ptr     db  0x67                    ; Указатель на конец области фигуры на дисплее. Если
                                            ;   область фигуры спускается ниже экрана дисплея,
                                            ;   указатель остаётся на месте, как бы уменьшая размер
                                            ;   области фигуры. (0x67...7F, всегда нечётный)
turn_buffer_ptr db  buffer_end              ; Указатель на буфер, используемый при повороте фигуры.
                                            ;   В отличие от buffer_ptr, не учитывает положение
                                            ;   области фигуры на дисплее.



check_n_show:       ldi c, BANK_SHOW
                    ldi d, show_start
                    jmp set_bank

step_done:          ld c, ???               ; todo
                    ld d, ???               ; todo
                    
; Универсальный код для перехода между банками.
; Регистр C уже содержит номер банка.
; Регистр D уже содержит адрес для перехода.
set_bank:           st c, bank
                    jmp d

;;;;;;;;;;;;;

; init (29)
                    ldi c, 0x00001110       ; Выбираем следующую фигуру

init_next_loop:     rnd b
                    and b, c
                    jz init_next_loop

                    st b, type_next

                    ldi b, 0b00100000       ; Рисуем игровое поле
                    ldi c, 0b00010000       ; = 16
                    ldi d, display_r
                    st c, in_out            ; Отключаем цветной режим у дисплея

init_area_loop:     st a, d                 ; a = 0
                    inc d
                    st b, d
                    inc d
                    dec c
                    jnz init_area_loop

                    ldi c, 0x00110100
                    st c, in_out            ; Подключаем цветной дисплей и цифровой индикатор
                    st a, bcd

; type (48)
                    ldi c, 0x00001110       ; Выбираем следующую фигуру

mino_next_loop:     rnd a
                    and a, c
                    jz mino_next_loop

                    ld b, type_next
                    st b, type
                    st a, type_next

                    ldi d, minos -2         ; Выводим текущую фигуру на игровое поле
                    add d, b
                    ld b, d
                    inc d
                    ld c, d
                    st b, display_b
                    st c, display_b +2

                    ld d, display_r         ; Проверяем на коллизии
                    and b, d
                    jnz game_over
                    ld d, display_r +2
                    and c, d
                    jnz game_over

                    ; a = type_next
                    ldi d, minos -2         ; Выводим следующую фигуру на запасное поле
                    add d, a
                    ldi c, 0b00100000
                    ld b, d
                    inc d
                    ld c, d
                    shr b
                    shr c
                    or b, c
                    or c, c
                    st b, display_b +3
                    st c, display_b +5

; step (...)
step:               ld a, in_out
                    ldi b, KEY_DOWN
                    xor b, a
                    jz step_down
                    ldi b, KEY_LEFT
                    xor b, a
                    jz step_left
                    ldi b, KEY_RIGHT
                    xor b, a
                    jz step_right
                    ldi b, KEY_UP
                    xor b, a
                    jz step_turn
                    ...

; step_down (64)
                    ld c, mino_height       ; Проверяем на коллизии
                    ld d, mino_up

step_down_row:      ldi b, 0x7E
                    xor b, d
                    jz step_down_btm
                    ld a, d
                    ldi b, 30
                    sub d, b
                    ld b, d
                    and a, b
                    jnz block
                    inc d
                    ld b, d
                    ldi a, 30
                    add d, a
                    ld a, d
                    and a, b
                    jnz block
                    dec c
                    jnz step_down_row

                    ld c, mino_height
                    inc d
                    jmp step_down_do

step_down_btm:      ld a, d                 ; Проверяем на коллизии нижний ряд
                    test a
                    jnz block
                    inc d
                    ld a, d
                    ldi b, 0b00100000
                    xor a, b
                    jnz block
                    ld c, mino_height
                    dec c
                    dec d

step_down_do:       shl c                   ; Сдвигаем фигуру вниз
                    mov b, d
                    inc b
                    inc b

step_down_loop:     dec b
                    dec d
                    ld a, d
                    st a, b
                    dec c
                    jns step_down_loop

                    st b, mino_up
                    jmp step



; Game over
game_over:          hlt

; ...
bcd             db  0
void            db  0, 0, 0
in_out          db  0b00110000              ; Порт ввода/вывода, подключаем цветной дисплей
bank            db  0                       ; Порт банка памяти

display_r       db  0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0

display_b       db  0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0

type            db  0
type_next       db  0
mino_up         db  display_b
mino_height     db  0

minos           db  0b00001100, 0b00001100, ; O
                    0b00000000, 0b00011110, ; I
                    0b00001100, 0b00011000, ; S
                    0b00011000, 0b00001100, ; Z
                    0b00001000, 0b00011100, ; T
                    0b00010000, 0b00011100, ; J
                    0b00000100, 0b00011100  ; L
                    


; ==================================================================================================
; (41) BANK_SHOW - Проверяем буфер на коллизии с башней и выводим на дисплей
; ==================================================================================================

; (16) Проверяем буфер на коллизии с башней
show_start:         ld c, buffer_ptr
                    ld d, display_ptr
                    ldi a, 32
                    sub d, a
                    
show_check_loop:    ld a, c
                    ld b, d
                    and a, b
                    jnz step_done
                    dec d
                    dec c
                    jns show_check_loop

; (25) Выводим буфер на дисплей
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

                    ld c, displayed_bank
                    ld d, displayed_addr
                    jmp set_bank



; ==================================================================================================
; (38) BANK_LEFT - Сдвиг фигуры влево
; ==================================================================================================

; (21) Копируем фигуру в буфер
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
                    jc step_done            ; Если вышли за левый край, завершаем шаг
                    st a, c
                    dec d
                    dec c
                    jns left_copy_loop
                    
; (8) Сохраняем адрес для возврата после вывода на дисплей
                    ldi a, BANK_LEFT
                    st a, displayed_bank
                    ldi a, left_displayed
                    st a, displayed_addr

; (2) Проверяем на коллизии и выводим на дисплей
                    jmp check_n_show
                    
; (7) После вывода на дисплей смещаем позицию фигуры и завершаем шаг
left_displayed:     ld a, column
                    dec a
                    st a, column
                    jmp step_done



; ==================================================================================================
; (40) BANK_RIGHT - Сдвиг фигуры вправо
; ==================================================================================================

; (23) Копируем фигуру в буфер
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
                    
; (8) Сохраняем адрес для возврата после вывода на дисплей
                    ldi a, BANK_RIGHT
                    st a, displayed_bank
                    ldi a, right_displayed
                    st a, displayed_addr
                    
; (2) Проверяем на коллизии и выводим на дисплей
                    jmp check_n_show
                    
; (7) После вывода на дисплей смещаем позицию фигуры и завершаем шаг
right_displayed:    ld a, column
                    inc a
                    st a, column
                    jmp step_done



; ==================================================================================================
; (74) BANK_DOWN - Сдвиг фигуры вниз
; ==================================================================================================

; (4) Выставляем флаг блокировки фигуры, на случай если шаг будет прерван
down_start:         ldi b, WALL
                    st b, need_block

; (10) Проверяем, не упирается ли фигура в пол
                    ld a, 0x7F
                    xor a, b
                    jnz step_done
                    ld a, 0x7E
                    test a
                    jnz step_done

; (17) Копируем фигуру в буфер
                    ldi b, 0b11000000
                    ld c, buffer_ptr
                    ld d, display_ptr

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

; (16) Смещаем указатель на дисплей, но если мы уже в самом низу, то вместо этого смещаем указатель
; на буфер
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

; (8) Сохраняем адрес для возврата после вывода на дисплей
down_ptrs_after:    ldi a, BANK_DOWN
                    st a, displayed_bank
                    ldi a, down_displayed
                    st a, displayed_addr

; (2) Проверяем на коллизии и выводим на дисплей
                    jmp check_n_show

; (13) После вывода на дисплей стираем ряд над фигурой
down_displayed:     ld d, display_ptr
                    ldi a, 8
                    sub d, a
                    ld a, d
                    ldi b, 0b00111111
                    and a, b
                    st a, d
                    dec d
                    clr a
                    st a, d

; (4) Сбрасываем флаг блокировки фигуры и завершаем шаг
                    st a, need_block
                    jmp step_done



; ==================================================================================================
; (55) BANK_TURN_1
; ==================================================================================================

; (35) Проверяем возможность поворота фигуры по её типу и расположению
turn_start:         ld a, column
                    ld b, display_ptr
                    ld c, type
                    test a
                    jz step_done            ; В крайней левой колонке поворот невозможен
                    dec c
                    jz step_done            ; Поворот фигуры O невозможен
                    dec c
                    jz turn_check_i         ; Для фигуры I отдельные ограничения
                    
turn_check:         ldi c, 8                ; В крайней правой колонке поворот невозможен
                    ldi d, 0x82             ; В двух нижних рядах поворот невозможен
                    jmp turn_check_end

turn_check_i:       ldi c, 7                ; В двух правых колонках поворот невозможен
                    ldi d, 0x80             ; В трёх нижних рядах поворот невозможен

turn_check_end:     sub c, a
                    js step_done
                    sub d, b
                    js step_done

                    ldi a, buffer_end
                    st a, turn_buffer_ptr   ; Сбрасываем указатель буфера
                    
; (8) Сохраняем адрес для возврата после вывода на дисплей
                    ldi a, BANK_TURN_1
                    st a, displayed_bank
                    ldi a, turn_displayed
                    st a, displayed_addr

; (6) Переходим в другой банк для продолжения, там же запускаем проверку на коллизии и вывод на
; дисплей
                    ldi c, BANK_TURN_2
                    ldi d, turn_proceed
                    jmp set_bank

; (6) После вывода на дисплей обновляем адрес данных о текущем повороте фигуры и завершаем шаг
turn_displayed:     ld a, turn_next
                    st a, turn
                    jmp step_done



; ==================================================================================================
; (128) BANK_TURN_2
; ==================================================================================================

; (1)
turn_data_ptr   db  0

; (7)
turn_proceed:       ld d, turn
                    st d, turn_data_ptr
                    ld a, d
                    st a, turn_next        ; Сохраняем ссылку на данные о повёрнутой фигуре
                    
; (28) Ряд за рядом читаем пиксели фигуры, сдвигаем вправо до нужной позиции и сохраняем в буфер
turn_row:           ld d, turn_data_ptr
                    inc d
                    ld a, d
                    st d, turn_data_ptr
                    clr b
                    ld c, column
                    dec c
                    jz turn_shift_after
                    ld d, turn_shift_loop
                    
turn_shift_loop:    shr a                   ; Сдвигаем ряд фигуры вправо
                    rcr b
                    dec c
                    jnz d
                    
turn_shift_after:   ld d, turn_buffer_ptr   ; Сохраняем ряд фигуры в буфер
                    st b, d
                    dec d
                    st a, d
                    dec d
                    st d, turn_buffer_ptr
                    jns turn_row

; (2) Проверяем на коллизии и выводим на дисплей
                    jmp check_n_show

; (90) Данные о следующем состоянии поворота фигур, вверх-ногами
turn_i0         db  turn_i1,
                    0b01000000,
                    0b01000000,
                    0b01000000,
                    0b01000000
turn_i1         db  turn_i0,
                    0b00000000,
                    0b00000000,
                    0b11110000,
                    0b00000000

turn_s0         db  turn_s1,
                    0b00000000,
                    0b00100000,
                    0b01100000,
                    0b01000000
turn_s1         db  turn_s0,
                    0b00000000,
                    0b00000000,
                    0b11000000,
                    0b01100000

turn_z0         db  turn_z1,
                    0b00000000,
                    0b01000000,
                    0b01100000,
                    0b00100000
turn_z1         db  turn_z0,
                    0b00000000,
                    0b00000000,
                    0b01100000,
                    0b11000000

turn_t0         db  turn_t1,
                    0b00000000,
                    0b01000000,
                    0b01100000,
                    0b01000000
turn_t1         db  turn_t2,
                    0b00000000,
                    0b01000000,
                    0b11100000,
                    0b00000000
turn_t2         db  turn_t3,
                    0b00000000,
                    0b01000000,
                    0b11000000,
                    0b01000000
turn_t3         db  turn_t0,
                    0b00000000,
                    0b00000000,
                    0b11100000,
                    0b01000000

turn_j0         db  turn_j1,
                    0b00000000,
                    0b01000000,
                    0b01000000,
                    0b01100000
turn_j1         db  turn_j2,
                    0b00000000,
                    0b00000000,
                    0b00100000,
                    0b11100000
turn_j2         db  turn_j3,
                    0b00000000,
                    0b01100000,
                    0b00100000,
                    0b00100000
turn_j3         db  turn_j0,
                    0b00000000,
                    0b00000000,
                    0b11100000,
                    0b10000000

turn_l0         db  turn_l1,
                    0b00000000,
                    0b01100000,
                    0b01000000,
                    0b01000000
turn_l1         db  turn_l2,
                    0b00000000,
                    0b00000000,
                    0b10000000,
                    0b11100000
turn_l2         db  turn_l3,
                    0b00000000,
                    0b00100000,
                    0b00100000,
                    0b01100000
turn_l3         db  turn_l0,
                    0b00000000,
                    0b00000000,
                    0b11100000,
                    0b00100000
