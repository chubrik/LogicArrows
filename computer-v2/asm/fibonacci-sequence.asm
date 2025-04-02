﻿####################################################################################################
##      Source code for the "Fibonacci Sequence" program for a computer made of logic arrows      ##
##       Исходный код программы "Fibonacci Sequence" для компьютера из логических стрелочек       ##
##                  https://github.com/chubrik/LogicArrows/tree/main/computer-v2                  ##
##                          (с) 2024 Arkadi Chubrik (arkadi@chubrik.org)                          ##
####################################################################################################


        ldi c, 0b00010100   ; Код для подключения дисплея и цифрового индикатора
        st c, 0x3E          ; Подключаем вывод
        inc b               ; Подготавливаем число 1
        ldi c, 0x3A         ; Адрес для вывода на цифровой индикатор
        ldi d, 0x41         ; Указатель для вывода на дисплей

loop:   add a, b            ; Складываем последние два числа, сохраняя сумму в первое из них
        jc end              ; Если сумма превысила 255, выходим из цикла
        st a, c             ; Выводим сумму на цифровой индикатор
        st a, d             ; Выводим сумму на дисплей
        inc d               ; Смещаем указатель на дисплее на ряд ниже
        inc d
        add b, a            ; Складываем последние два числа, сохраняя сумму во второе из них
        st b, c             ; Выводим сумму на цифровой индикатор
        st b, d             ; Выводим сумму на дисплей
        inc d               ; Смещаем указатель на дисплее на ряд ниже
        inc d
        jmp loop            ; Повторяем итерацию

end:    hlt                 ; Завершаем выполнение программы
