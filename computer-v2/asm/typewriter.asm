﻿####################################################################################################
##          Source code for the "Typewriter" program for a computer made of logic arrows          ##
##           Исходный код программы "Typewriter" для компьютера из логических стрелочек           ##
##                  https://github.com/chubrik/LogicArrows/tree/main/computer-v2                  ##
##                          (с) 2024 Arkadi Chubrik (arkadi@chubrik.org)                          ##
####################################################################################################


        inc a           ; 0b00000001, код для подключения терминала
        ldi b, 0x3E     ; Порт ввода/вывода
        st a, b         ; Подключаем вывод
        ldi c, 0x3C     ; Адрес для вывода в терминал
        ldi d, loop     ; Запоминаем адрес начала итерации для ускорения цикла

loop:   ld a, b         ; Читаем код нажатой клавиши, порт ввода при этом обнуляется
        st a, c         ; Выводим символ в терминал
        jmp d           ; Повторяем итерацию
