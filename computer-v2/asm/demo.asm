﻿####################################################################################################
##             Source code for the "Demo" program for a computer made of logic arrows             ##
##              Исходный код программы "Demo" для компьютера из логических стрелочек              ##
##                  https://github.com/chubrik/LogicArrows/tree/main/computer-v2                  ##
##                          (с) 2024 Arkadi Chubrik (arkadi@chubrik.org)                          ##
####################################################################################################


            jmp title                   ; Прыгаем через строку
text    db  "!иригинО\n,тевирП"         ; Строка "Привет,\nОнигири!" задом-наперёд

title:      ldi b, "\n"
            st b, 0x01                  ; Дополняем строку
            ldi b, title -1
            ldi c, 0x3C                 ; Адрес для вывода в терминал
            ldi d, loop

loop:       ld a, b
            st a, c
            dec b
            jnz d

            hlt

void    db  0, 0, 0, 0, 0, 0, 0, 0,     ; Заполняем пустыми байтами по адрес 0x3D
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0

in_out  db  0b_00000101                 ; Порт вывода, подключён дисплей и терминал
bank    db  0                           ; Порт банка памяти (не используется)

; Область дисплея 0x40...0x5F содержит заставку, отображаемую при загрузке программы
display db  0b_00000000, 0b_00000000,   ;                                  ;
            0b_00000000, 0b_00000000,   ;                                  ;
            0b_00000000, 0b_00000000,   ;                                  ;
            0b_00000010, 0b_10000000,   ;             ██  ██               ;
            0b_00111011, 0b_10111000,   ;     ██████  ██████  ██████       ;
            0b_00100101, 0b_01001000,   ;     ██    ██  ██  ██    ██       ;
            0b_00100011, 0b_10001000,   ;     ██      ██████      ██       ;
            0b_00100001, 0b_00001000,   ;     ██        ██        ██       ;
            0b_00010001, 0b_00010000,   ;       ██      ██      ██         ;
            0b_00001101, 0b_01100000,   ;         ████  ██  ████           ;
            0b_00010001, 0b_00010000,   ;       ██      ██      ██         ;
            0b_00010011, 0b_10010000,   ;       ██    ██████    ██         ;
            0b_00001101, 0b_01100000,   ;         ████  ██  ████           ;
            0b_00000000, 0b_00000000,   ;                                  ;
            0b_00000000, 0b_00000000,   ;                                  ;
            0b_00000000, 0b_00000000    ;                                  ;