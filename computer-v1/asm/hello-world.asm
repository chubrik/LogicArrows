﻿####################################################################################################
##          Source code for the "Hello World" program for a computer made of logic arrows         ##
##           Исходный код программы "Hello World" для компьютера из логических стрелочек          ##
##                  https://github.com/chubrik/LogicArrows/tree/main/computer-v1                  ##
##                          (с) 2023 Arkadi Chubrik (arkadi@chubrik.org)                          ##
####################################################################################################


            ldi a, 0x80             ; Код для подключения дисплея
            st a, 0x3F              ; Подключаем вывод
            ldi b, image_size       ; Счётчик, по которому программа завершится
            ldi c, image            ; Указатель на начало картинки
            ldi d, 0x40             ; Указатель на начало области дисплея

; Цикл копирования картинки на дисплей
loop:       ld a, c                 ; Читаем один байт картинки
            st a, d                 ; Выводим байт картинки на дисплей
            inc c                   ; Смещаем указатель на картинку
            inc d                   ; Смещаем указатель на дисплей
            dec b                   ; Уменьшаем счётчик
            jnz loop                ; Если счётчик не равеен нулю, повторяем итерацию

            hlt                     ; Завершаем выполнение программы

void    db  0, 0, 0, 0, 0, 0        ; Выравнивание памяти (необязательно)

; Картинка для вывода на дисплей
image   db  0b00000010, 0b01000000, ;             ██    ██             ;
            0b00110101, 0b10101100, ;     ████  ██  ████  ██  ████     ;
            0b00000100, 0b00100000, ;           ██        ██           ;
            0b00110011, 0b11001100, ;     ████    ████████    ████     ;
            0b00000000, 0b00000000, ;                                  ;
            0b10100000, 0b10100000, ; ██  ██          ██  ██           ;
            0b10100100, 0b10100100, ; ██  ██    ██    ██  ██    ██     ;
            0b11101010, 0b10101010, ; ██████  ██  ██  ██  ██  ██  ██   ;
            0b10101100, 0b10101010, ; ██  ██  ████    ██  ██  ██  ██   ;
            0b10100110, 0b10100100, ; ██  ██    ████  ██  ██    ██     ;
            0b00000000, 0b00000000, ;                                  ;
            0b00000000, 0b00010001, ;                       ██      ██ ;
            0b10100100, 0b11010001, ; ██  ██    ██    ████  ██      ██ ;
            0b11101010, 0b10010011, ; ██████  ██  ██  ██    ██    ████ ;
            0b11101010, 0b10010101, ; ██████  ██  ██  ██    ██  ██  ██ ;
            0b01000100, 0b10010011  ;   ██      ██    ██    ██    ████ ;

image_size  equ $ - image           ; Размер картинки