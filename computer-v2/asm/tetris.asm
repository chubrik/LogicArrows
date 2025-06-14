####################################################################################################
##              Source code for the "Tetris" game for a computer made of logic arrows             ##
##                Исходный код игры "Тетрис" для компьютера из логических стрелочек               ##
##                  https://github.com/chubrik/LogicArrows/tree/main/computer-v2                  ##
##                          (с) 2025 Arkadi Chubrik (arkadi@chubrik.org)                          ##
####################################################################################################



; Константы
BANK_ROTATE_1   equ 0                       ; todo
BANK_ROTATE_2   equ 0                       ; todo

KEY_LEFT        equ 0x11                    ; Код клавиши "Влево"
KEY_UP          equ 0x12                    ; Код клавиши "Вверх" (поворот)
KEY_RIGHT       equ 0x13                    ; Код клавиши "Вправо"
KEY_DOWN        equ 0x14                    ; Код клавиши "Вниз"
WALL            equ 0b00100000

; Переменные
mino_type       db  0                       ; Тип текущей фигуры (1...7)
mino_type_next  db  0                       ; Тип следующей фигуры (1...7)
mino_data       db  0x00                    ; Адрес с данными о состоянии поворота фигуры
pos_row         db  0x60                    ; Адрес верхнего ряда фигуры, всегда чётный
pos_col         db  4                       ; Позиция середины фигуры по горизонтали (0...9)

right_cnt       db  0
display_ptr     db  0
buffer_ptr      db  0



                db  0, 0, 0, 0, 0, 0        ; Буфер должен лежать по адресу 0x00
buffer          equ $ -1                    ; Адрес конца буфера
buffer_ptr      db  0
display_ptr     db  0

step_done:          ld c, ___               ; todo
                    ld d, ___               ; todo
                    
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

                    st b, mino_type_next

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

; mino_type (48)
                    ldi c, 0x00001110       ; Выбираем следующую фигуру

mino_next_loop:     rnd a
                    and a, c
                    jz mino_next_loop

                    ld b, mino_type_next
                    st b, mino_type
                    st a, mino_type_next

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

                    ; a = mino_type_next
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

mino_type       db  0
mino_type_next  db  0
mino_up         db  display_b
mino_height     db  0

minos           db  0b00011110, 0b00000000, ; I
                    0b00001100, 0b00001100, ; O
                    0b00001000, 0b00011100, ; T
                    0b00001100, 0b00011000, ; S
                    0b00011000, 0b00001100, ; Z
                    0b00010000, 0b00011100, ; J
                    0b00000100, 0b00011100  ; L
                    


; =======================================================

                    ld a, pos_x             ; Проверяем, не упираемся ли в левую стену или пол
                    test a
                    jz step
                    ld b, pos_y
                    ldi c, 0x7C
                    xor b, c
                    jz step

                    ld c, mino_type_next    ; Копируем следующую фигуру в буфер
                    inc c
                    ldi d, buffer
                    ld a, c
                    st a, d
                    inc c
                    inc d
                    inc d
                    ld a, c
                    st a, d
                    inc c
                    inc d
                    inc d
                    ld a, c
                    st a, d

                    ld a, pos_x             ; Сдвигаем фигуру в нужную позицию
                    ldi b, 4
                    sub b, a
                    jz check
                    jns shift_right

shift_left:         ld a, d
                    mov c, b

shift_left_lp:      shl a
                    dec c
                    jns shift_left_lp

                    st a, d

shift_right:

check:



; ================================================

                    ld c, pos_bit
                    ld d, pos_byte
                    ld a, d
                    xor a, c
                    st a, d
                    inc d
                    inc d
                    ld a, d
                    xor a, c
                    st a, d
                    inc d
                    inc d
                    ld a, d
                    xor a, c
                    st a, d
                    shl c
                    jnc next1
                    rcl c
                    dec d
next1:              shl c
                    jnc next2
                    rcl c
                    dec d
next2:              dec d
                    dec d
                    ld a, d
                    xor a, c
                    st a, d

; ================================================

; Сдвиг фигуры влево

                    ld d, mino_ptr
                    ld a, d
                    inc d
                    ld b, d
                    inc d
                    id c, d
                    ld d, left_cnt

loop:               shl a
                    shl b
                    shl c
                    dec d
                    jns loop

                    ld d, buffer
                    st a, d
                    clr a
                    inc d
                    st a, d
                    inc d
                    st b, d
                    inc d
                    st a, d
                    inc d
                    st c, d
                    inc d
                    st a, d

                    jmp check

; =================================================

; Сдвиг фигуры вправо

                    ldi c, 3

row:                ld d, mino_ptr
                    ld a, d
                    clr b
                    inc d
                    st d, mino_ptr
                    ld d, right_cnt

loop:               shr a
                    rcr b
                    dec d
                    jns loop

                    ld d, buffer_ptr
                    st a, d
                    inc d
                    st b, d
                    inc d
                    st a, buffer_ptr

                    dec c
                    jnz row

                    jmp check

; ==================================================================================================

; Сдвиг вниз

down_end        db  0

down:               ld d, pos_row
                    ldi a, 6
                    add a, d
                    st a, down_end
                    mov c, d
                    ldi a, 30
                    sub c, a

down_loop:          ld a, c
                    ld b, d
                    and a, b
                    jnz down_block
                    inc c
                    inc d

                    ld b, d
                    ldi a, WALL
                    xor b, a
                    ld a, c
                    and b, a
                    jnz down_block
                    inc c
                    inc d

                    ld a, down_end
                    xor a, d
                    jz down_move

                    ldi a, 0x7E
                    xor a, d
                    jnz down_loop

                    ld a, d
                    test a
                    jnz down_block
                    inc d
                    ld a, d
                    ldi b, WALL
                    xor a, b
                    jnz down_block
                    inc d

down_move           mov c, d
                    dec c
                    dec c
                    ldi b, 6

down_move_loop:     ld a, d
                    st a, c
                    dec c
                    dec d
                    dec b
                    jnz down_move_loop

                    ldi a, WALL
                    st a, d
                    dec d
                    clr a
                    st a, d

                    ld a, pos_row
                    inc a
                    inc a
                    st a, pos_row

                    jmp return

; Блокировка (down_end актуален)

down_block:         ld d, pos_row
                    mov c, d
                    ldi a, 32
                    sub c, a

down_block_loop:    ld a, c
                    ld b, d
                    or a, b
                    clr b
                    st a, c
                    st b, d
                    inc c
                    inc d

                    ld a, c
                    ld b, d
                    or a, b
                    ldi b, 0x11100000
                    and a, b
                    ldi b, 0x00111111
                    st a, c
                    ld a, d
                    and a, b
                    st a, d
                    inc c
                    inc d

                    js collapse
                    ld a, down_end
                    xor a, d
                    jnz down_block_loop

; Падение башни

collapse            ...



; ==================================================================================================
; BANK_ROTATE_1 - 59 байт
; ==================================================================================================

; 25 байт
                    ; Проверяем возможность поворота по типу фигуры
rotate_start:       ld a, mino_type
                    dec a
                    jz rotate_i             ; Фигура I требует отдельного решения
                    dec a
                    jz step_done            ; Фигура O не поворачивается

                    ; Проверяем возможность поворота по положению фигуры: это не должна быть
                    ;   крайняя колонка или предпоследний ряд
                    ld a, pos_col
                    test a
                    jz step_done
                    ldi b, 9
                    xor a, b
                    jz step_done
                    ld a, pos_row
                    ldi b, 0x7C
                    xor b, a
                    jz step_done

; 15 байт
                    ; Подготавливаем указатели на дисплей, на пиксели повёрнутой фигуры и на буфер
                    ldi b, 32
                    sub a, b
                    st a, display_ptr
                    ld a, buffer
                    st a, buffer_ptr

                    ldi c, BANK_ROTATE_2
                    ldi d, rotate_main
                    jmp set_bank

; 19 байт
; Коллизий нет. Выводим фигуру на дисплей.

rotate_proceed:     ; Готовимся к циклу вывода
                    ldi b, WALL
                    ld c, pos_row
                    ld d, buffer

                    ; Цикл вывода фигуры на дисплей
rotate_show_loop:   ld a, d
                    st a, c
                    inc c
                    inc d
                    ld a, d
                    or a, b
                    st a, c
                    inc c
                    dec d
                    jns rotate_show_loop

                    jmp step_done

; Отдельное решение для поворота фигуры I
rotate_i:           ...



; ==================================================================================================
; BANK_ROTATE_2 - 124 байта
; ==================================================================================================

; 6 байт
rotate_main         ld d, mino_data
                    ld a, d
                    inc a
                    st a, mino_data_ptr
                    
; 42
; Проходимся по каждому ряду фигуры и проверяем на коллизии с башней

                    ; Готовимся к циклу сдвига
rotate_row:         ld d, mino_data_ptr
                    ld a, d
                    inc d
                    st d, mino_data_ptr
                    ld c, pos_col
                    dec c
                    jz rotate_shift_after
                    clr b
                    ld d, rotate_shift_loop

                    ; Цикл сдвига фигуры вправо
rotate_shift_loop:  shr a
                    rcr b
                    dec c
                    jnz d

                    ; Проверяем на коллизии с башней
rotate_shift_after: ld d, display_ptr
                    ld c, d
                    and c, a
                    jnz step_done
                    inc d
                    ld c, d
                    and c, b
                    jnz step_done
                    inc d
                    st d, display_ptr

                    ; Сохраняем пиксели в буфер
                    ld d, buffer_ptr
                    st a, d
                    dec d
                    st b, d
                    dec d
                    st d, buffer_ptr
                    jns rotate_row

; 11 байт                    
; Коллизий нет
                    ; Сохраняем состояние поворота фигуры
                    ld d, mino_data
                    ld a, d
                    st a, mino_data

                    ldi c, BANK_ROTATE_1
                    ldi d, rotate_proceed
                    jmp set_bank

; 1 байт
mino_data_ptr   db  0

; 64 байта
mino_t0         db  mino_t1,
                    0b01000000,
                    0b11100000,
                    0b00000000
mino_t1         db  mino_t2,
                    0b01000000,
                    0b01100000,
                    0b01000000
mino_t2         db  mino_t3,
                    0b00000000,
                    0b11100000,
                    0b01000000
mino_t3         db  mino_t0,
                    0b01000000,
                    0b11000000,
                    0b01000000

mino_s0         db  mino_s1,
                    0b01100000,
                    0b11000000,
                    0b00000000
mino_s1         db  mino_s0,
                    0b01000000,
                    0b01100000,
                    0b00100000

mino_z0         db  mino_z1,
                    0b11000000,
                    0b01100000,
                    0b00000000
mino_z1         db  mino_z0,
                    0b00100000,
                    0b01100000,
                    0b01000000

mino_j0         db  mino_j1,
                    0b10000000,
                    0b11100000,
                    0b00000000
mino_j1         db  mino_j2,
                    0b01100000,
                    0b01000000,
                    0b01000000
mino_j2         db  mino_j3,
                    0b11100000,
                    0b00100000,
                    0b00000000
mino_j3         db  mino_j0,
                    0b00100000,
                    0b00100000,
                    0b01100000

mino_l0         db  mino_l1,
                    0b00100000,
                    0b11100000,
                    0b00000000
mino_l1         db  mino_l2,
                    0b01000000,
                    0b01000000,
                    0b01100000
mino_l2         db  mino_l3,
                    0b11100000,
                    0b10000000,
                    0b00000000
mino_l3         db  mino_l0,
                    0b01100000,
                    0b00100000,
                    0b00100000
