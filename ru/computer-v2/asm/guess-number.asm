; ##################################################################################################
; ##        Source code for the "Guess the Number" game for a computer made of logic arrows       ##
; ##            Исходный код игры "Угадай число" для компьютера из логических стрелочек           ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                         (c) 2026 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


; Константы
TRIES_STR   equ 0x36                ; "6" - число попыток в виде символа

                jmp start

; Универсальный вывод строки.
; Регистр C уже содержит указатель на начало строки.
; Регистр D уже содержит адрес для перехода после вывода строки.
write:          ldi a, "\n"
                ldi b, terminal
                st a, b
write_loop:     ld a, c
                test a
                jz d
                st a, b
                inc c
                jmp write_loop

; Начало игры. Выводом 0 на цифровой индикатор и приветственное сообщение в терминал. Затем
; переходим к загадыванию числа.
start:          st a, bcd           ; a = 0
                ldi c, start_str
                ldi d, random
                jmp write

; Победа: игрок угадал число. Увеличиваем счёт побед и выводим сообщение о победе. Затем переходим к
; предложению сыграть ещё раз.
win:            ldi b, bcd
                ldi c, win_str
                ldi d, again
                ld a, b
                inc a
                st a, b
                jnz write
                inc b
                ld a, b
                inc a
                st a, b
                jmp write

; Поражение: игрок исчерпал все попытки. Уменьшаем счёт побед и выводим сообщение о поражении. Затем
; переходим к предложению сыграть ещё раз.
lose:           ldi b, bcd
                ldi c, lose_str
                ldi d, again
                ld a, b
                dec a
                st a, b
                inc a
                jnz write
                inc b
                ld a, b
                dec a
                st a, b
                jmp write

; Переменные и порты
number      db  0                   ; Загаданное число
bcd         db  0, 0                ; Счётчик побед, значение может быть отрицательным
terminal    db  0, 0                ; Порт терминала
in_out      db  0b00001101          ; Порт ввода-вывода, подключаем терминал и цифровой индикатор в
                                    ;   знаковом режиме
bank        db  0                   ; Порт банка памяти (не используется)

; Переход к новой игре. Сбрасываем счётчик попыток, выводим приглашение к игре и переходим к
; загадыванию нового числа.
again:          ldi a, "0"
                st a, try_count
                ldi c, again_str
                ldi d, random
                jmp write

; Загадывание числа от 1 до 99
random:         rnd a
                js random
                inc a
                ldi b, 256 - 100
                add b, a
                jns random
                st a, number

; Проверка и инкрементация счётчика попыток. Если попытки закончились, переходим к поражению.
try:            ld a, try_count
                ldi b, TRIES_STR
                xor b, a
                jz lose
                inc a
                st a, try_count
                ldi c, try_str
                ldi d, input_1
                jmp write

; Ввод первого символа. Допускаются только цифры от 1 до 9.
input_1:        ld c, in_out
                mov a, c
                ldi d, "1"
                sub a, d
                js input_1
                inc a
                ldi d, 9
                sub d, a
                js input_1
                st c, terminal

; Ввод второго символа. Допускаются цифры от 0 до 9 и Enter.
input_2:        ld c, in_out
                ldi d, "\n"
                xor d, c
                jz compare          ; Если введён Enter, сразу переходим к сравнению
                mov b, c
                ldi d, "0"
                sub b, d
                js input_2
                ldi d, 9
                sub d, b
                js input_2
                st c, terminal

; Суммирование двух введённых цифр для получения единого числа
sum:            mov c, a
                shl a
                shl a
                add a, c
                shl a
                add a, b

; Сравнение введённого числа с загаданным
compare:        ld b, number
                sub a, b
                jz win              ; Если числа совпадают, переходим к победе
                ldi d, try
                js higher

; Вывод сообщения "Lower" и переход к следующей попытке
lower:          ldi c, lower_str
                jmp write

; Вывод сообщения "Higher" и переход к следующей попытке
higher:         ldi c, higher_str
                jmp write

; Массив строк для вывода в терминал
start_str   db  "Guess my number 1…99 in ", TRIES_STR, " tries.", 0
win_str     db  "You win!", 0
lose_str    db  "You lose…", 0
again_str   db  "Play again.", 0
try_str     db  "Try #0: ", 0       ; Счётчик попыток находится прямо внутри строки
lower_str   db  "Lower", 0
higher_str  db  "Higher", 0

; Адрес счётчика попыток внутри строки
try_count   equ try_str + 5
