﻿####################################################################################################
##      Source code for the "Fibonacci Sequence" program for a computer made of logic arrows      ##
##       Исходный код программы "Fibonacci Sequence" для компьютера из логических стрелочек       ##
##                  https://github.com/chubrik/LogicArrows/tree/main/computer-v1                  ##
##                          (с) 2023 Arkadi Chubrik (arkadi@chubrik.org)                          ##
####################################################################################################


        ldi a, 0x80         ; Код для подключения дисплея
        st a, 0x3F          ; Подключаем вывод
        inc b               ; Подготавливаем число 1
        inc c               ; Подготавливаем число 1
        ldi d, 0x3F         ; Указатель для вывода на дисплей

loop:   inc d               ; Смещаем указатель на дисплее на ряд ниже
        inc d
        mov a, b            ; Берём первое число
        add a, c            ; Складываем последние два числа
        mov b, a            ; Сохраняем сумму в первое число
        st a, d             ; Выводим сумму на дисплей
        inc d               ; Смещаем указатель на дисплее на ряд ниже
        inc d
        mov a, c            ; Берём второе число
        add a, b            ; Складываем последние два числа
        mov c, a            ; Сохраняем сумму во второе число
        st a, d             ; Выводим сумму на дисплей
        ldi a, 0x53         ; Адрес на дисплее для последнего числа
        xor a, d
        jnz loop            ; Если мы ещё не достигли этого адреса, повторяем итерацию

        hlt                 ; Завершаем выполнение программы
