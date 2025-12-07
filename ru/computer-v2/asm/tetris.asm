; ##################################################################################################
; ##             Source code for the "Tetris" game for a computer made of logic arrows            ##
; ##               Исходный код игры "Тетрис" для компьютера из логических стрелочек              ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                         (c) 2025 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################



; Константы
KEY_LEFT        equ 0x11                    ; Код клавиши "Влево"
KEY_UP          equ 0x12                    ; Код клавиши "Вверх" (поворот)
KEY_RIGHT       equ 0x13                    ; Код клавиши "Вправо"
KEY_DOWN        equ 0x14                    ; Код клавиши "Вниз"
WALL            equ 0b00100000              ; Изображение стены между полями
STEP_COUNT      equ 2                       ; Число шагов до смещения вниз
INI_COLUMN      equ 4                       ; Стартовая позиция фигуры по горизонтали
INI_BUFFER_PTR  equ buffer_end              ; Адрес конца буфера фигуры
INI_DISPLAY_PTR equ display_b + 7           ; Адрес конца области фигуры на дисплее

; Банки памяти
BANK_SHOW       equ 1                       ; Проверка на коллизии и вывод на дисплей
BANK_DOWN       equ 1                       ; Смещение фигуры вниз
BANK_STEP       equ 2                       ; Опрос клавиатуры и контроль шагов
BANK_LEFT       equ 2                       ; Смещение фигуры влево
BANK_RIGHT      equ 2                       ; Смещение фигуры вправо
BANK_TURN_2     equ 3                       ; Продолжение поворота фигуры и данные о поворотах
BANK_TURN_1     equ 4                       ; Начало поворота фигуры
BANK_DROP       equ 4                       ; Обрушение башни
BANK_BLOCK      equ 5                       ; Блокировка фигуры
BANK_INIT       equ 5                       ; Отрисовка игрового поля
BANK_MINO       equ 6                       ; Переход к следующей фигуре
BANK_TITLE      equ 6                       ; Вывод названия игры в терминал



;===================================================================================================
; Общая область памяти
;===================================================================================================

; Буфер на 8 байт. Используется для промежуточного сохранения фигуры, проверки её на коллизии с
; башней и принятия решения о выводе фигуры на дисплей либо прерывании шага. Должен лежать по адресу
; 0x00, т.к. большинство алгоритмов работает от конца к началу, используя буфер ещё и в качестве
; счётчика в цикле.
buffer:             ldi c, BANK_TITLE       ; Переходим к выводу названия игры в терминал
                    st c, bank
                    jmp title_start
buffer_rest     db  0, 0
buffer_end      equ $ - 1

; Переход к следующей фигуре
mino_next:          ldi c, BANK_MINO
                    st c, bank
                    jmp mino_start

; Переход к проверке на коллизии и выводу на дисплей
check_n_show:       ldi c, BANK_SHOW
                    st c, bank
                    jmp show_start

; Прерывание шага с двумя возможными исходами: переход к следующему шагу или блокировка фигуры
check_collided:     ld a, need_block
                    test a
                    jz step_next

; Переход к блокировке фигуры
mino_block:         clr a
                    st a, need_block
                    ldi c, BANK_BLOCK
                    st c, bank
                    jmp block_start

; Переход к следующему шагу
step_next:          ldi c, BANK_STEP
                    st c, bank
                    jmp step_start

; Универсальный переход между банками памяти.
; Регистр C уже содержит номер банка памяти.
; Регистр D уже содержит адрес для перехода.
set_bank:           st c, bank
                    jmp d

; Переменные
type            db  0                       ; Тип текущей фигуры (1...7)
type_next       db  0                       ; Тип следующей фигуры (1...7)
turn            db  0x00                    ; Ссылка на данные о текущем повороте фигуры
turn_next       db  0x00                    ; Ссылка на данные о следующем повороте фигуры
shown_bank      db  0                       ; Банк памяти для перехода после вывода на дисплей
shown_addr      db  0x00                    ; Адрес для перехода после вывода на дисплей
need_block      db  0                       ; Признак необходимости блокировки фигуры
step_remain     db  STEP_COUNT              ; Оставшееся число шагов до смещения вниз
column          db  INI_COLUMN              ; Позиция фигуры по горизонтали (0...9)
buffer_ptr      db  INI_BUFFER_PTR          ; Указатель на буфер (0x00...0x07)
display_ptr     db  INI_DISPLAY_PTR         ; Указатель на дисплее (0x67...0x7F, всегда нечётный)
buffer_ptr_2    db  0x00                    ; Дополнительный указатель на буфер
display_ptr_2   db  0x00                    ; Дополнительный указатель на дисплее

void0           db  0, 0

; Порты
bcd             db  0, 0
terminal        db  0, 0
in_out          db  0b00110001              ; Порт ввода/вывода, подключаем цветной дисплей и
                                            ;   терминал
bank            db  0                       ; Порт банка памяти

; Область 0x40...0x5F содержит красный компонент заставки, отображаемой на дисплее во время загрузки
; программы
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

; Область 0x60...0x7F содержит синий компонент заставки, отображаемой на дисплее во время загрузки
; программы
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
; Банк памяти № 1: BANK_SHOW, BANK_DOWN
;===================================================================================================

; BANK_SHOW - Проверка на коллизии и вывод на дисплей. Фигура уже находится в буфере.

; Проверяем буфер на коллизии с башней
show_start:         ld c, buffer_ptr
                    ld d, display_ptr
                    ldi a, 32
                    sub d, a

show_check_loop:    ld a, c
                    ld b, d
                    and a, b
                    jnz check_collided      ; Если обнаружена коллизия, прерываем шаг
                    dec d
                    dec c
                    jns show_check_loop

; Выводим буфер на дисплей
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

; Переходим по заранее сохранённому адресу
                    ld c, shown_bank
                    ld d, shown_addr
                    jmp set_bank

;---------------------------------------------------------------------------------------------------

; BANK_DOWN - Смещение фигуры вниз

; Устанавливаем признак необходимости блокировки фигуры и готовим отдельные указатели, на случай
; если шаг будет прерван
down_start:         ldi b, 0b11000000
                    st b, need_block
                    ld c, buffer_ptr
                    st c, buffer_ptr_2
                    ld d, display_ptr
                    st d, display_ptr_2

; Копируем фигуру в буфер
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

; Проверяем, не упирается ли фигура в пол
                    ldi b, WALL
                    ld a, 0x7F
                    xor a, b
                    jnz mino_block
                    ld a, 0x7E
                    test a
                    jnz mino_block

; Смещаем указатель на дисплее. Но, если мы уже в самом низу, то вместо этого смещаем указатель
; на буфер, как бы уменьшая и размер области фигуры на дисплее, и размер буфера.
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

; Сохраняем адрес для возврата после вывода на дисплей
down_ptrs_after:    ldi a, BANK_DOWN
                    st a, shown_bank
                    ldi a, down_shown
                    st a, shown_addr

; Переходим к проверке на коллизии и выводу на дисплей
                    jmp show_start

; После вывода на дисплей стираем ряд над фигурой
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

; Сбрасываем признак необходимости блокировки фигуры и переходим к следующему шагу
                    st a, need_block
                    jmp step_next

void1           db  0, 0, 0, 0, 0, 0, 0, 0



;===================================================================================================
; Банк памяти № 2: BANK_STEP, BANK_LEFT, BANK_RIGHT
;===================================================================================================

; BANK_STEP - Опрос клавиатуры и контроль шагов

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

; Подготовка к смещению вниз
step_down:          ldi a, STEP_COUNT
                    st a, step_remain       ; Восстанавливаем число шагов до смещения вниз
                    ldi c, BANK_DOWN
                    ldi d, down_start
                    jmp set_bank

;---------------------------------------------------------------------------------------------------

; BANK_LEFT - Смещение фигуры влево

; Копируем фигуру в буфер
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
                    jc step_next            ; Если вышли за левый край, прерываем шаг
                    st a, c
                    dec d
                    dec c
                    jns left_copy_loop

; Сохраняем адрес для возврата после вывода на дисплей
                    ldi a, BANK_LEFT
                    st a, shown_bank
                    ldi a, left_shown
                    st a, shown_addr

; Переходим к проверке на коллизии и выводу на дисплей
                    jmp check_n_show

; После вывода на дисплей смещаем позицию фигуры и переходим к следующему шагу
left_shown:         ld a, column
                    dec a
                    st a, column
                    jmp step_next

;---------------------------------------------------------------------------------------------------

; BANK_RIGHT - Смещение фигуры вправо

; Копируем фигуру в буфер
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

; Сохраняем адрес для возврата после вывода на дисплей
                    ldi a, BANK_RIGHT
                    st a, shown_bank
                    ldi a, right_shown
                    st a, shown_addr

; Переходим к проверке на коллизии и выводу на дисплей
                    jmp check_n_show

; После вывода на дисплей смещаем позицию фигуры и переходим к следующему шагу
right_shown:        ld a, column
                    inc a
                    st a, column
                    jmp step_next

void2           db  0, 0, 0, 0, 0



;===================================================================================================
; Банк памяти № 3: BANK_TURN_2
;===================================================================================================

; Продолжение поворота фигуры и данные о поворотах

turn_data_ptr   db  0                       ; Указатель на данные о следующем повороте фигуры

; Сохраняем указатель и ссылку на данные о следующем повороте фигуры
turn_proceed:       ld d, turn
                    st d, turn_data_ptr
                    ld a, d
                    st a, turn_next

; Ряд за рядом читаем данные с пикселями фигуры, сдвигаем вправо до нужной позиции и сохраняем в
; буфер
turn_row:           ld d, turn_data_ptr
                    inc d
                    ld a, d
                    st d, turn_data_ptr
                    clr b
                    ld c, column
                    dec c
                    jz turn_shift_after

                    ldi d, turn_shift_loop

turn_shift_loop:    shr a                   ; Сдвигаем ряд фигуры вправо
                    rcr b
                    dec c
                    jnz d

turn_shift_after:   ld d, buffer_ptr_2      ; Сохраняем ряд фигуры в буфер
                    st b, d
                    dec d
                    st a, d
                    dec d
                    st d, buffer_ptr_2
                    jns turn_row

; Переходим к проверке на коллизии и выводу на дисплей
                    jmp check_n_show

; Данные о поворотах каждой фигуры. Фигура O отсутствует, т.к. её поворот невозможен. Для
; оптимизации ряды с пикселями хранятся в обратном порядке.

turn_i0         db  turn_i1, 0b00000000, 0b00000000, 0b11110000, 0b00000000 ; Фигура I
turn_i1         db  turn_i0, 0b01000000, 0b01000000, 0b01000000, 0b01000000

turn_s0         db  turn_s1, 0b00000000, 0b00000000, 0b11000000, 0b01100000 ; Фигура S
turn_s1         db  turn_s0, 0b00000000, 0b00100000, 0b01100000, 0b01000000

turn_z0         db  turn_z1, 0b00000000, 0b00000000, 0b01100000, 0b11000000 ; Фигура Z
turn_z1         db  turn_z0, 0b00000000, 0b01000000, 0b01100000, 0b00100000

turn_t0         db  turn_t1, 0b00000000, 0b00000000, 0b11100000, 0b01000000 ; Фигура T
turn_t1         db  turn_t2, 0b00000000, 0b01000000, 0b01100000, 0b01000000
turn_t2         db  turn_t3, 0b00000000, 0b01000000, 0b11100000, 0b00000000
turn_t3         db  turn_t0, 0b00000000, 0b01000000, 0b11000000, 0b01000000

turn_j0         db  turn_j1, 0b00000000, 0b00000000, 0b11100000, 0b10000000 ; Фигура J
turn_j1         db  turn_j2, 0b00000000, 0b01000000, 0b01000000, 0b01100000
turn_j2         db  turn_j3, 0b00000000, 0b00000000, 0b00100000, 0b11100000
turn_j3         db  turn_j0, 0b00000000, 0b01100000, 0b00100000, 0b00100000

turn_l0         db  turn_l1, 0b00000000, 0b00000000, 0b11100000, 0b00100000 ; Фигура L
turn_l1         db  turn_l2, 0b00000000, 0b01100000, 0b01000000, 0b01000000
turn_l2         db  turn_l3, 0b00000000, 0b00000000, 0b10000000, 0b11100000
turn_l3         db  turn_l0, 0b00000000, 0b00100000, 0b00100000, 0b01100000



;===================================================================================================
; Банк памяти № 4: BANK_TURN_1, BANK_DROP
;===================================================================================================

; BANK_TURN_1 - Начало поворота фигуры

; Проверяем возможность поворота фигуры по её типу и расположению
turn_start:         ld a, column
                    ld b, display_ptr
                    ld c, type
                    test a
                    jz step_next            ; В крайней левой колонке поворот невозможен
                    dec c
                    jz step_next            ; Поворот фигуры O невозможен
                    dec c
                    jz turn_check_i         ; Для фигуры I отдельные ограничения

turn_check:         ldi c, 8                ; В крайней правой колонке поворот невозможен
                    ldi d, 0x82             ; В двух нижних рядах поворот невозможен
                    jmp turn_check_end

turn_check_i:       ldi c, 7                ; В двух правых колонках поворот невозможен
                    ldi d, 0x80             ; В трёх нижних рядах поворот невозможен

; Если сработало одно из ограничений, прерываем шаг
turn_check_end:     sub c, a
                    js step_next
                    sub d, b
                    js step_next

; Готовим отдельный указатель на буфер, не зависящий от положения фигуры на дисплее
                    ldi a, buffer_end
                    st a, buffer_ptr_2

; Сохраняем адрес для возврата после вывода на дисплей
                    ldi a, BANK_TURN_1
                    st a, shown_bank
                    ldi a, turn_shown
                    st a, shown_addr

; Переходим к продолжению поворота в другом банке памяти, там же запускаем проверку на коллизии и
; вывод на дисплей
                    ldi c, BANK_TURN_2
                    ldi d, turn_proceed
                    jmp set_bank

; После вывода на дисплей обновляем ссылку на данные о текущем повороте фигуры и переходим к
; следующему шагу
turn_shown:         ld a, turn_next
                    st a, turn
                    jmp step_next

;---------------------------------------------------------------------------------------------------

; BANK_DROP - Обрушение башни

; Подготавливаем указатели копирования и вставки. Поначалу они совпадают.
drop_start:         ld d, display_ptr_2
                    mov c, d

; Фаза drop1. Идём снизу вверх по области фигуры на дисплее. Когда встречаем пустой ряд, смещаем
; указатель копирования на ряд выше, не меняя указатель вставки.

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

; Фаза drop2. Продолжаем двигаться по дисплею выше области фигуры. Когда указатель копирования
; встречает пустой ряд или достигает верхней границы дисплея, переходим к следующей фазе.

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

; Фаза drop3. Заполняем экран пустыми рядами, пока указатель вставки не совпадёт с указателем
; копирования.

drop3_start:        ldi b, WALL

drop3_loop:         clr a
                    st b, d
                    dec d
                    st a, d
                    dec d
                    mov a, c
                    xor a, d
                    jnz drop3_loop

; Переходим к следующей фигуре
                    jmp mino_next

void4           db  0, 0



;===================================================================================================
; Банк памяти № 5: BANK_BLOCK, BANK_INIT
;===================================================================================================

; BANK_BLOCK - Блокировка фигуры

block_not_full  db  0                       ; Признак неполноты правой части ряда
block_need_drop db  0                       ; Признак необходимости обрушения башни

; Подготавливаем признаки и указатели
block_start:        clr a
                    st a, block_need_drop
                    ld c, buffer_ptr_2
                    st c, buffer_ptr
                    ld d, display_ptr_2
                    ldi c, 256 - 32
                    add c, d
                    st c, display_ptr_2     ; Указатель на красную часть области дисплея

; Ряд за рядом переносим фигуру из синей области дисплея в красную, объединяя её с башней
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

; Проверяем, заполнен ли ряд
                    not a                   ; Признак неполноты левой части ряда
                    ld b, block_not_full    ; Признак неполноты правой части ряда
                    or a, b                 ; Признак неполноты всего ряда
                    jnz block_row_end

; Стираем заполненный ряд, запоминаем необходимость обрушения башни и повышаем счёт на цифровом
; индикаторе
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

; Проверяем необходимость обрушения башни, если её нет, переходим к следующей фигуре
                    ld a, block_need_drop
                    test a
                    jz mino_next

; Переходим к обрушению башни
                    ldi c, BANK_DROP
                    ldi d, drop_start
                    jmp set_bank

;---------------------------------------------------------------------------------------------------

; BANK_INIT - Отрисовка игрового поля

; Случайно выбираем тип следующей фигуры. Она же станет первой фигурой в игре.
init_start:         ldi a, 0b00000111

init_next_loop:     rnd c
                    and c, a
                    jz init_next_loop

                    st c, type_next

; Отключаем цветной режим у дисплея и рисуем игровое поле
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

; Возвращаем цветной режим у дисплея и подключаем цифровой индикатор
                    ldi c, 0b00110100
                    st c, in_out
                    st a, bcd               ; Выводим 0 на цифровой индикатор

; Переходим к началу игрового процесса
                    ldi c, BANK_MINO
                    ldi d, mino_start
                    jmp set_bank

void5           db  0, 0, 0, 0, 0, 0, 0, 0, 0



;===================================================================================================
; Банк памяти № 6: BANK_MINO, BANK_TITLE
;===================================================================================================

; BANK_MINO - Переход к следующей фигуре

; Случайно выбираем тип следующей фигуры
mino_start:         ldi a, 0b00000111

mino_next_loop:     rnd c
                    and c, a
                    jz mino_next_loop

; Предыдущая следующая фигура становится текущей
                    ld a, type_next
                    st a, type
                    st c, type_next

; Выводим текущую фигуру на игровое поле
                    ldi d, minos - 3
                    add d, a                ; Умножение на 3
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

; Если есть коллизии с башней, завершаем игру
                    ld d, display_r
                    and a, d
                    jnz game_over
                    ld d, display_r + 2
                    and b, d
                    jnz game_over

; Выводим следующую фигуру на запасное поле
                    ; c = type_next
                    ldi d, minos - 2
                    add d, c                ; Умножение на 3
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

; Устанавливаем позицию фигуры и указатели в начальное состояние
                    ldi a, INI_COLUMN
                    st a, column
                    ldi a, INI_BUFFER_PTR
                    st a, buffer_ptr
                    ldi a, INI_DISPLAY_PTR
                    st a, display_ptr

; Переходим к следующему шагу
                    jmp step_next

; Завершаем игру
game_over:          hlt

; Данные о каждой фигуре: ссылка на данные о повороте и стартовое изображение
minos           db  0,       0b00001100, 0b00001100,    ; Фигура O
                    turn_i1, 0b00000000, 0b00011110,    ; Фигура I
                    turn_s1, 0b00001100, 0b00011000,    ; Фигура S
                    turn_z1, 0b00011000, 0b00001100,    ; Фигура Z
                    turn_t1, 0b00001000, 0b00011100,    ; Фигура T
                    turn_j1, 0b00010000, 0b00011100,    ; Фигура J
                    turn_l1, 0b00000100, 0b00011100     ; Фигура L

;---------------------------------------------------------------------------------------------------

; BANK_TITLE - Вывод названия игры в терминал

title_start:        ldi b, title_size
                    ldi c, title
                    ldi d, terminal

title_loop:         ld a, c
                    st a, d
                    inc c
                    dec b
                    jnz title_loop

; Переходим к инициализации игры
                    ldi c, BANK_INIT
                    ldi d, init_start
                    jmp set_bank

; Название игры для вывода в терминал
title           db  "\t\b", "TETRIS", "\n"
title_size      equ $ - title
