####################################################################################################
##           Source code for the "Space Fight!" game for a computer made of logic arrows          ##
##             Исходный код игры "Space Fight!" для компьютера из логических стрелочек            ##
##                  https://github.com/chubrik/LogicArrows/tree/main/computer-v1                  ##
##                          (с) 2024 Arkadi Chubrik (arkadi@chubrik.org)                          ##
####################################################################################################



; Константы
OUT_NUM     equ 0x10    ; Код для подключения цифрового индикатора
OUT_SCR     equ 0x80    ; Код для подключения дисплея
CLEAR_TO    equ 0x58    ; Граница между очищенной частью дисплея и заполненной врагами в начале игры
KEY_LEFT    equ 0x25    ; Код клавиши "влево"
KEY_RIGHT   equ 0x27    ; Код клавиши "вправо"
KEY_FIRE    equ 0x20    ; Код клавиши "пробел" (огонь)
STEP_CNT    equ 14      ; Количество доступных ходов на текущем уровне
WIN_LEFT    equ 30      ; Счётчик врагов, оставшихся до победы



; Очищаем нижнюю часть дисплея
CLEAR:          ldi c, 0x5C
                ldi d, CLEAR_TO     ; Верхняя граница очистки дисплея, а также для блока RND нижняя
                                    ;   граница заполнения врагами
loop1:          dec c
                st b, c
                mov a, c
                xor a, d
                jnz loop1
                
; Заполняем дисплей случайно расположенными врагами.
; Регистр D уже содержит указатель на дисплее на нижнюю границу заполнения.
RND:            ldi c, display      ; Адрес начала области дисплея как верхняя граница заполнения
                                    ;   врагами

loop2:          rnd a               ; Работаем с байтом в правой части дисплея
                rnd b
                and a, b            ; Совмещаем два случайных байта, чтобы для каждого бита
                                    ;   получилась вероятность 25%
                shl a               ; Отодвигаем биты от края дисплея, где невозможно произвести
                                    ;   выстрел
                dec d
                st a, d
                rnd a               ; Повторяем то же самое для левой части дисплея
                rnd b
                and a, b
                shr a
                dec d
                st a, d
                mov a, d
                xor a, c
                jnz loop2

; Выводим счётчик врагов на цифровой индикатор
SCORE:          ld a, win_left      ; Читаем счётчик врагов. При проигрыше игры эта команда будет
                                    ;   перезаписана на "hlt".
                ldi d, display      ; Адрес начала области дисплея, в т.ч. для блока WIN
                ld b, d             ; Запоминаем первый байт изображения на дисплее
                ldi c, OUT_NUM
                st c, out           ; Переключаем на цифровой индикатор
                st a, d             ; Выводим значение счётчика врагов
                ldi c, OUT_SCR
                st c, out           ; Переключаем на дисплей
                st b, d             ; Восстанавливаем в памяти первый байт изображения
                add a, 0            ; Если счётчик врагов равен нулю, то игра выиграна
                jz WIN

; Уменьшаем счётчик ходов
STEP:           ldi b, STEP2        ; Ссылка для перехода к следующему шагу для блоков KEYS, LEFT,
                                    ;   RIGHT
STEP2:          ld a, step_left
                dec a
                js LEVEL            ; Если ходов не осталось, переходим на следующий уровень
                st a, step_left
                jmp KEYS            ; Перепрыгиваем через зарезервированную область памяти

void1       db  0

; Переменные и порты

step_cnt    db  STEP_CNT            ; Количество доступных ходов на текущем уровне
step_left   db  STEP_CNT            ; Счётчик оставшихся ходов на текущем уровне
win_left    db  WIN_LEFT            ; Счётчик врагов, оставшихся до победы
bank        db  0                   ; Порт банка памяти (не используется)
in          db  0                   ; Порт ввода
out         db  OUT_SCR             ; Порт вывода

; Область дисплея 0x40...0x5F содержит заставку, отображаемую при загрузке программы
display     db  0b00101000, 0b00000000, ;     ██  ██                       ;
                0b00100000, 0b00101000, ;     ██              ██  ██       ;
                0b00000000, 0b00001000, ;                         ██       ;
                0b00001001, 0b00000000, ;         ██    ██                 ;
                0b00100001, 0b00100000, ;     ██        ██    ██           ;
                0b00100011, 0b10001000, ;     ██      ██████      ██       ;
                0b00000011, 0b10001000, ;             ██████      ██       ;
                0b00001011, 0b10100000, ;         ██  ██████  ██           ;
                0b00001010, 0b10100000, ;         ██  ██  ██  ██           ;
                0b00101110, 0b11101000, ;     ██  ██████  ██████  ██       ;
                0b00101111, 0b11101000, ;     ██  ██████████████  ██       ;
                0b00111011, 0b10111000, ;     ██████  ██████  ██████       ;
                0b00110101, 0b01011000, ;     ████  ██  ██  ██  ████       ;
                0b00100000, 0b00001000, ;     ██                  ██       ;
                0b00000001, 0b00000000, ;               ██                 ;
                0b00000011, 0b10000000  ;             ██████               ;
                
; Опрашиваем клавиатуру на нажатие одной из управляющих клавиш.
; Регистр B уже содержит ссылку для возврата к STEP2.
KEYS:           mov a, 0
                ld c, in            ; Читаем код нажатой клавиши
                st a, in            ; Обнуляем значение в порту, чтобы определять повторные нажатия
                ldi a, KEY_FIRE
                xor a, c
                jz FIRE
                ldi a, KEY_RIGHT
                xor a, c
                jz RIGHT
                ldi a, KEY_LEFT
                xor a, c
                jnz b               ; Переходим к следующему ходу

; Сдвигаем корабль влево.
; Регистр B уже содержит ссылку для возврата к STEP2.
LEFT:           ld a, 0x5E          ; Если мы у левого края, переходим к следующему ходу
                shl a
                jc b
                ldi d, 0x5F
                ldi c, 4

loop3:          ld a, d
                rcl a
                st a, d
                dec d
                dec c
                jnz loop3

                jmp b               ; Переходим к следующему ходу

; Сдвигаем корабль вправо.
; Регистр B уже содержит ссылку для возврата к STEP2.
RIGHT:          ld a, 0x5F          ; Если мы у правого края, переходим к следующему ходу
                shr a
                jc b
                ldi d, 0x5C
                ldi c, 4

loop4:          ld a, d
                rcr a
                st a, d
                inc d
                dec c
                jnz loop4

                jmp b               ; Переходим к следующему ходу

; Производим выстрел
FIRE:           ldi d, 0x5C         ; Определяем стартовое положение снаряда
                ld a, d
                add a, 0
                jnz shot
                inc d

shot:           ld b, d
                ldi c, 14

; Невидимый полёт снаряда
loop5:          dec d
                dec d
                ld a, d
                and a, b            ; Если попали, выходим из цикла
                jnz hit
                dec c
                jnz loop5

                jmp STEP            ; Промах, переходим к следующему ходу
                
; Попадание. Убираем врага с дисплея, уменьшаем счётчик врагов и переходим к следующему ходу.
hit:            ld a, d
                xor a, b
                st a, d
                ld a, win_left
                dec a
                st a, win_left
                jmp SCORE
                
; Переходим на следующий уровень.
; Здесь враги станут ближе к нам, а число доступных ходов уменьшится.
LEVEL:          ld a, step_cnt      ; Уменьшаем число доступных ходов на два
                dec a
                dec a
                st a, step_cnt
                st a, step_left
                ldi c, 0x5A         ; Нижняя граница сдвига карты для блока SCROLL
                ld a, c
                ld b, 0x5B
                or a, b             ; Если в третьем снизу ряду нет врагов, переходим к сдвигу карты
                jz SCROLL
                inc c               ; Игра проиграна, смещаем нижнюю границу сдвига карты на один
                                    ;   ряд ниже
                inc c
                ldi a, 0xEC         ; В блоке SCORE первую команду перезаписываем на hlt
                st a, SCORE
                
; Сдвигаем всех врагов ближе к нам.
; Регистр C уже содержит указатель на нижнюю границу для сдвига карты.
SCROLL:         ldi d, 0x42         ; Верхняя граница сдвига карты, а также для блока RND нижняя
                                    ;   граница заполнения врагами
loop6:          dec c
                mov a, c
                ld b, a
                inc a
                inc a
                st b, a
                xor a, d
                jnz loop6

                jmp RND             ; Переходим к генерации врагов в верхнем ряду, а затем к
                                    ;   следующему шагу
                                    
; Мы выиграли! Выводим на дисплей заставку-приз и завершаем выполнение программы.
; Регистр D уже содержит указатель на начало области дисплея.
WIN:            ldi c, win_image

loop7:          ld a, c
                st a, d
                inc d
                inc c               ; После 0xFF значение перейдёт в 0x00, что означает окончание
                                    ;   вывода
                jnz loop7

                hlt                 ; Остановка программы

void2       db  0, 0

; Область 0xE0...0xFF содержит заставку-приз для победителя
win_image   db  0b00000000, 0b00000000,
                0b00000000, 0b00000000,
                0b00000011, 0b11000000,
                0b00000100, 0b00100000,
                0b00001001, 0b00010000,
                0b00010000, 0b00101000,
                0b00010100, 0b00001000,
                0b00100000, 0b10000100,
                0b00100000, 0b00000100,
                0b01000000, 0b00001010,
                0b01010011, 0b11000010,
                0b01000111, 0b11100010,
                0b01000111, 0b11100010,
                0b00110111, 0b11101100,
                0b00001111, 0b11110000,
                0b00000000, 0b00000000
