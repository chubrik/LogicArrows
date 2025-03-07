﻿####################################################################################################
##           Source code for the "Space Fight!" game for a computer made of logic arrows          ##
##             Исходный код игры "Space Fight!" для компьютера из логических стрелочек            ##
##                  https://github.com/chubrik/LogicArrows/tree/main/computer-v2                  ##
##                          (с) 2024 Arkadi Chubrik (arkadi@chubrik.org)                          ##
####################################################################################################



; Константы
WIN_LEFT    equ 30                      ; Количество врагов, которое необходимо сбить для победы
STEP_CNT    equ 14                      ; Количество доступных ходов на первом уровне
KEY_LEFT    equ 0x11                    ; Код клавиши "Влево"
KEY_RIGHT   equ 0x13                    ; Код клавиши "Вправо"
KEY_FIRE    equ 0x20                    ; Код клавиши "Пробел" (огонь)



; Очищаем нижнюю часть дисплея
clear:          ldi b, clear_loop
                ldi c, 4
                ldi d, 0x5B

clear_loop:     st a, d
                dec d
                dec c
                jnz b

                ldi c, 12

; Заполняем дисплей случайно расположенными врагами.
; Регистр C уже содержит счётчик для выхода из цикла.
; Регистр D уже содержит указатель на дисплее на нижнюю границу заполнения.
random:         rnd a                   ; Работаем с правой частью дисплея
                rnd b
                and a, b                ; Совмещаем два случайных байта, чтобы для каждого бита
                                        ;   получилась вероятность 25%
                shl a                   ; Отодвигаем биты от края дисплея, где невозможно произвести
                                        ;   выстрел
                st a, d
                dec d
                rnd a                   ; Повторяем то же самое для левой части дисплея
                rnd b
                and a, b
                shr a
                st a, d
                dec d
                dec c
                jnz random

random_jmp:     jmp score

; Выводим стартовый счёт на цифровой дисплей
score:          ld a, win_left
                st a, win_left
                ldi a, step
                st a, random_jmp +1     ; Т.к. блок "score" нужен лишь однократно, делаем так, чтобы
                                        ;   в дальнейшем его перепрыгивать

; Опрашиваем клавиатуру на нажатие одной из управляющих клавиш
step:           ldi b, KEY_LEFT
                ldi c, KEY_RIGHT
                ldi d, KEY_FIRE

step_loop:      ld a, step_left         ; Уменьшаем счётчик ходов
                dec a
                js level                ; Если ходов не осталось, переходим на следующий уровень
                st a, step_left
                ld a, in_out
                xor d, a
                jz fire
                xor c, a
                jmp step_end            ; Перепрыгиваем через зарезервированную область памяти

; Переменные и порты

win_left    db  WIN_LEFT                ; Адрес для вывода на цифровой индикатор, используется как
                                        ;   счётчик врагов, оставшихся до победы
void1       db  0

step_cnt    db  STEP_CNT                ; Количество доступных ходов на текущем уровне
step_left   db  STEP_CNT                ; Счётчик оставшихся ходов на текущем уровне
in_out:     db  0b_00000110             ; Порт ввода/вывода, подключён монохромный дисплей и
                                        ;   цифровой индикатор
bank        db  0                       ; Порт банка памяти (не используется)

; Область дисплея 0x40...0x5F содержит заставку, отображаемую при загрузке программы
display     db  0b_00101000, 0b_00000000,   ;     ██  ██                       ;
                0b_00100000, 0b_00101000,   ;     ██              ██  ██       ;
                0b_00000000, 0b_00001000,   ;                         ██       ;
                0b_00001001, 0b_00000000,   ;         ██    ██                 ;
                0b_00100001, 0b_00100000,   ;     ██        ██    ██           ;
                0b_00100011, 0b_10001000,   ;     ██      ██████      ██       ;
                0b_00000011, 0b_10001000,   ;             ██████      ██       ;
                0b_00001011, 0b_10100000,   ;         ██  ██████  ██           ;
                0b_00001010, 0b_10100000,   ;         ██  ██  ██  ██           ;
                0b_00101110, 0b_11101000,   ;     ██  ██████  ██████  ██       ;
                0b_00101111, 0b_11101000,   ;     ██  ██████████████  ██       ;
                0b_00111011, 0b_10111000,   ;     ██████  ██████  ██████       ;
                0b_00110101, 0b_01011000,   ;     ████  ██  ██  ██  ████       ;
                0b_00100000, 0b_00001000,   ;     ██                  ██       ;
                0b_00000001, 0b_00000000,   ;               ██                 ;
                0b_00000011, 0b_10000000    ;             ██████               ;

; Продолжаем обработку клавиатуры
step_end:       jz right
                xor b, a
                jnz step_loop

; Сдвигаем корабль влево
left:           ld b, 0x5E
                shl b
                jc step                 ; Если мы у левого края, переходим к следующему ходу
                ldi b, 0x5F
                ldi c, 4
                ldi d, left_loop

left_loop:      ld a, b
                rcl a
                st a, b
                dec b
                dec c
                jnz d

                jmp step

; Сдвигаем корабль вправо
right:          ld b, 0x5F
                shr b
                jc step                 ; Если мы у правого края, переходим к следующему ходу
                ldi b, 0x5C
                ldi c, 4
                ldi d, right_loop

right_loop:     ld a, b
                rcr a
                st a, b
                inc b
                dec c
                jnz d

                jmp step

; Производим выстрел
fire:           ldi d, 0x5C             ; Определяем стартовое положение снаряда
                ld a, d
                test a
                jnz fire2
                inc d

fire2:          ld b, d
                ldi c, 14

; Невидимый полёт снаряда
fire_loop:      dec d
                dec d
                ld a, d
                and a, b
                jnz fire_hit            ; Если попали, выходим из цикла
                dec c
                jnz fire_loop

                jmp step                ; Промах, переходим к следующему ходу

; Попадание. Убираем врага с дисплея, уменьшаем счётчик врагов и переходим к следующему ходу.
fire_hit:       ld a, d
                xor a, b
                st a, d
                ld a, win_left
                dec a
                st a, win_left          ; Выводим счётчик врагов на цифровой индикатор
                jnz step                ; Если счётчик врагов не равен нулю, переходим к следующему
                                        ;   ходу

; Мы выиграли! Выводим на дисплей заставку-приз и завершаем выполнение программы.
win:            ldi b, display
                ldi c, prize
                ldi d, win_loop

win_loop:       ld a, c
                st a, b
                inc b
                inc c
                jnz d

                hlt

; Переходим на следующий уровень.
; Здесь враги станут ближе к нам, а число доступных ходов уменьшится.
level:          ld a, step_cnt          ; Уменьшаем число доступных ходов на два
                dec a
                dec a
                st a, step_cnt
                st a, step_left
                ld a, 0x5A              ; Определяем, есть ли хоть один враг в нижнем ряду
                ld b, 0x5B
                ldi c, 26
                ldi d, 0x59
                or a, b
                jz scroll               ; Если в нижнем ряду нет врагов, переходим к сдвигу всех
                                        ;   врагов ближе к нам

; Игра проиграна. Осталось сдвинуть всех врагов ещё ближе и завершить выполнение программы.
level_lose:     inc c
                inc c
                inc d
                inc d
                ldi a, 0x01             ; Код команды "hlt". Записываем его в то место, где
                                        ;   закончится заполнение верхнего ряда.
                st a, random_jmp

; Сдвигаем всех врагов ближе к нам.
; Регистр C уже содержит счётчик для выхода из цикла.
; Регистр D уже содержит указатель на нижнюю границу для сдвига карты.
scroll:         mov b, d
                ld a, b
                inc b
                inc b
                st a, b
                dec d
                dec c
                jnz scroll

; После сдвига остаётся заполнить верхний ряд дисплея новыми врагами
                inc c
                inc d
                inc d
                jmp random

void2       db  0

; Область 0xE0...0xFF содержит заставку-приз для победителя
prize       db  0b_00000000, 0b_00000000,
                0b_00000000, 0b_00000000,
                0b_00000011, 0b_11000000,
                0b_00000100, 0b_00100000,
                0b_00001001, 0b_00010000,
                0b_00010000, 0b_00101000,
                0b_00010100, 0b_00001000,
                0b_00100000, 0b_10000100,
                0b_00100000, 0b_00000100,
                0b_01000000, 0b_00001010,
                0b_01010011, 0b_11000010,
                0b_01000111, 0b_11100010,
                0b_01000111, 0b_11100010,
                0b_00110111, 0b_11101100,
                0b_00001111, 0b_11110000,
                0b_00000000, 0b_00000000
