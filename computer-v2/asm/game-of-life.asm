﻿####################################################################################################
##             Source code for the "Game of Life" for a computer made of logic arrows             ##
##                Исходный код игры "Жизнь" для компьютера из логических стрелочек                ##
##                  https://github.com/chubrik/LogicArrows/tree/main/computer-v2                  ##
##                          (с) 2024 Arkadi Chubrik (arkadi@chubrik.org)                          ##
####################################################################################################



; Константы
BANK_INNER      equ 1                           ; Номер банка 1
BANK_MAIN       equ 2                           ; Номер банка 2
BANK_OUTER      equ 3                           ; Номер банка 3
TERMINAL        equ 0x3C                        ; Адрес для вывода в терминал



;===================================================================================================
; Общая область памяти - адресное пространство 0x00...0x7F.
; Содержит: код вывода названия игры в терминал, переключатель банков, порты, переменные, память
; дисплея, кэш для следующего кадра. После вывода названия игры в терминал, вся область памяти
; 0x00...0x2F перетирается и далее используется для хранения счётчиков соседей у клеток. Счётчики
; разбиты на три группы по 16, где каждая группа отвечает за свой ряд на дисплее.
;===================================================================================================

; Старт игры
                    jmp title_show              ; Прыгаем через строку
title:          db  "ьнзиЖ аргИ efiL fo emaG"   ; Строка "Game of Life Игра Жизнь" задом-наперёд

; Готовим вывод названия игры в терминал
title_show:         ldi b, " "
                    st b, title -1              ; Дополняем пробелом строку с названием игры
                    ldi a, TERMINAL
                    ldi c, title_show -1        ; Указатель на последний символ строки с названием
                                                ;   игры. В течение цикла указатель постепенно
                                                ;   смещается к началу строки и одновременно
                                                ;   работает как счётчик, по которому цикл
                                                ;   завершается.
                    ldi d, title_show_loop
                    
; Цикл вывода в терминал
title_show_loop:    ld b, c
                    st b, a
                    dec c
                    jnz d

; Переключаем вывод на монохромный дисплей и цифровой индикатор
                    ldi a, 0b_00000110          
                    st a, in_out

; Готовим регистры C и D для прыжка, а регистры A и B для блока "main_rnd"
                    ldi a, display
                    ;                           ; Регистр B уже содержит " ", т.е. число 32
                    ldi c, BANK_MAIN
                    ldi d, main_rnd

; Универсальный код для переключения банка.
; Регистр C уже содержит номер банка.
; Регистр D уже содержит ссылку для прыжка.
set_bank:           st c, bank
                    jmp d

void1           db  0

; Переменные и порты

upper_area      db  0x00                    ; Ссылка на область счётчиков для ряда выше текущего
current_area    db  0x10                    ; Ссылка на область счётчиков для текущего ряда
lower_area      db  0x20                    ; Ссылка на область счётчиков для ряда ниже текущего
upper_ptr       db  0x00                    ; Указатель в области счётчиков для ряда выше текущего
lower_ptr       db  0x20                    ; Указатель в области счётчиков для ряда ниже текущего

step_count      db  0xFF                    ; Адрес для вывода на цифровой индикатор, используется
                                            ;   как счётчик кадров. Изначально содержит 0xFF,
                                            ;   чтобы при первой инкрементации получилось число 0.
void2           db  0

incrementor     db  0                       ; Адрес для вывода в терминал. После отключения
                                            ;   терминала используется как счётчик в некоторых
                                            ;   циклах.
display_ptr     db  display                 ; Указатель на дисплее
in_out          db  0b_00001101             ; Порт вывода, подключён цветной дисплей и терминал
bank            db  0                       ; Порт банка памяти

; Область дисплея 0x40...0x5F содержит заставку, отображаемую при загрузке программы
display         db  0b_01100000, 0b_00000000,   ;   ████                           ;
                    0b_10001001, 0b_10100010,   ; ██      ██    ████  ██      ██   ;
                    0b_10100101, 0b_01010101,   ; ██  ██    ██  ██  ██  ██  ██  ██ ;
                    0b_10101101, 0b_01010110,   ; ██  ██  ████  ██  ██  ██  ████   ;
                    0b_01101101, 0b_01010011,   ;   ████  ████  ██  ██  ██    ████ ;
                    0b_00000000, 0b_00000000,   ;                                  ;
                    0b_00000000, 0b_01100000,   ;                   ████           ;
                    0b_00000100, 0b_10000000,   ;           ██    ██               ;
                    0b_00001010, 0b_11000000,   ;         ██  ██  ████             ;
                    0b_00000100, 0b_10000000,   ;           ██    ██               ;
                    0b_00000000, 0b_00000000,   ;                                  ;
                    0b_10001110, 0b_11101110,   ; ██      ██████  ██████  ██████   ;
                    0b_10000100, 0b_10001000,   ; ██        ██    ██      ██       ;
                    0b_10000100, 0b_11001100,   ; ██        ██    ████    ████     ;
                    0b_10000100, 0b_10001000,   ; ██        ██    ██      ██       ;
                    0b_11101110, 0b_10001110    ; ██████  ██████  ██      ██████   ;

; Область 0x60...0x7F для кэша следующего кадра
frame_cache     db  0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0



;===================================================================================================
; BANK_INNER - Банк памяти № 1 - адресное пространство 0x80...0xFF.
; Содержит логику обработки всех рядов на дисплее, кроме верхнего и нижнего.
;===================================================================================================

; Начинаем обработку ряда на дисплее
inner_begin:        ldi b, inner_center
                    st b, inner_edge_jmp +1     ; Заменяем ссылку для прыжка после обработки левого
                                                ;   крайнего пикселя
                    ldi b, inner_right
                    st b, inner_center_jmp +1   ; Заменяем ссылку для прыжка после обработки левой
                                                ;   половины ряда на дисплее
                    ld b, display_ptr
                    ld a, b                     ; Загружаем левую половину ряда на дисплее
                    shr a                       ; Сдвиг помогает унифицировать дальнейшую обработку

                    ld c, current_area
                    inc c                       ; Указатель на счётчик для соседа справа
                    
; Обрабатываем крайний пиксель на дисплее.
; Регистр A уже содержит крайний пиксель в 6-м бите.
; Регистр C уже содержит указатель на счётчик для единственного бокового соседа.
inner_edge:         rcl a                       ; Сдвигаем крайний пиксель в 7-й бит
                    jns inner_edge_end          ; Если пиксель пустой, пропускаем его обработку
                    
; Инкрементируем счётчики для двух соседей в ряду выше
                    ld d, upper_ptr
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d
                    
; Инкрементируем счётчик для единственного бокового соседа
                    ld b, c
                    inc b
                    st b, c
                    
; Инкрементируем счётчики для двух соседей в ряду ниже
                    ld d, lower_ptr
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d

inner_edge_end:     dec c
inner_edge_jmp:     jmp inner_center            ; Заменяемая ссылка для прыжка

; Переходим с обработки левой половины дисплея на правую.
; Регистр C уже содержит указатель на счётчик для левого из двух боковых соседей.
inner_right:        ldi b, inner_edge
                    st b, inner_center_jmp +1   ; Заменяем ссылку для прыжка после обработки правой
                                                ;   половины ряда на дисплее
                    ldi b, inner_end
                    st b, inner_edge_jmp +1     ; Заменяем ссылку для прыжка после обработки правого
                                                ;   крайнего пикселя
                    ld b, display_ptr
                    inc b
                    ld a, b                     ; Загружаем правую половину ряда на дисплее
                    shr a                       ; Сдвиг помогает унифицировать дальнейшую обработку
                    
; Обрабатываем 7 пикселей, кроме крайнего, на одной половине дисплея.
; Регистр A уже содержит 7 пикселей в битах с 6 по 0-й.
; Регистр C уже содержит указатель на счётчик для левого из двух боковых соседей.
inner_center:       ldi b, 8
                    st b, incrementor
                    
; Цикл обработки каждого из 7 пикселей
inner_center_loop:  ld b, incrementor
                    dec b
                    st b, incrementor
inner_center_jmp:   jz inner_right              ; Заменяемая ссылка для прыжка

                    rcl a                       ; Сдвигаем очередной пиксель в 7-й бит
                    jns inner_center_end        ; Если пиксель пустой, пропускаем его обработку
                    
; Инкрементируем счётчики для трёх соседей в ряду выше
                    ld d, upper_ptr
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d
                    
; Инкрементируем счётчики для двух боковых соседей
                    ld b, c
                    inc b
                    st b, c
                    inc c
                    inc c
                    ld b, c
                    inc b
                    st b, c
                    dec c
                    dec c
                    
; Инкрементируем счётчики для трёх соседей в ряду ниже
                    ld d, lower_ptr
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d

; Готовим к обработке следующий пиксель
inner_center_end:   ld d, upper_ptr
                    inc d
                    st d, upper_ptr
                    inc c
                    ld d, lower_ptr
                    inc d
                    st d, lower_ptr
                    jmp inner_center_loop
                    
; Обработка ряда на дисплее завершена. Переходим к калькуляции ряда выше текущего.
inner_end:          ldi c, BANK_MAIN
                    ldi d, main_calc
                    jmp set_bank

void3           db  0, 0, 0, 0



;===================================================================================================
; BANK_MAIN - Банк памяти № 2 - адресное пространство 0x80...0xFF.
; Содержит: генерацию стартового кадра со случайным рисунком, переключение логики между рядами на
; дисплее, калькуляцию и вывод на дисплей следующего кадра, инкрементацию цифрового индикатора и
; переход к следующей итерации.
;===================================================================================================

; Переключаемся на следующий ряд на дисплее. Для этого меняем местами ссылки на области счётчиков:
; текущий ряд становится рядом выше, ряд ниже становится текущим рядом, а ряд выше становится рядом
; ниже и требует сброса счётчиков. С каждым рядом ссылки на области счётчиков будут меняться между
; собой, причём при достижении последнего ряда они автоматически получат свои изначальные значения.
main_row:           ld b, upper_area
                    ld c, current_area
                    ld d, lower_area
                    st c, upper_area
                    st d, current_area
                    st b, lower_area

                    st c, upper_ptr
                    st b, lower_ptr

; Если display_ptr имеет значение 0x5E, значит мы достигли нижнего ряда на дисплее, и для его
; обработки нужно перейти к другому коду.
                    ld d, display_ptr
                    ldi a, 0x5E
                    xor a, d
                    jz main_row_end

; Сбрасываем счётчики для ряда на дисплее ниже текущего. Вместо нулей используем 0xFE, что
; оптимизирует последующую калькуляцию.
                    ldi a, 0xFE
                    ;                           ; Регистр B уже содержит lower_area
                    ldi c, 16
                    ldi d, main_row_loop
                    
; Цикл сброса счётчиков
main_row_loop:      st a, b
                    inc b
                    dec c
                    jnz d

; Переходим к обработке ряда на дисплее (кроме нижнего)
                    inc c                       ; Значение 1 соответствует BANK_INNER
                    ldi d, inner_begin
                    jmp set_bank
                    
; Переходим к обработке нижнего ряда на дисплее
main_row_end:       ldi c, BANK_OUTER
                    ldi d, outer_down
                    jmp set_bank

; Калькулируем один ряд следующего кадра, для которого все счётчики уже заполнены
main_calc:          ld c, display_ptr
                    ld d, upper_area

; Калькулируем половину ряда на дисплее. Для второй половины выполняем этот код повторно.
; Регистр C уже содержит указатель на дисплее.
; Регистр D уже содержит указатель в области счётчиков.
main_calc_iter:     dec c                       ; Дважды декрементируем указатель на дисплее, чтобы
                    dec c                       ;   перейти на ряд выше.
                    ld a, c                     ; Загружаем одну из половин ряда на дисплее
                    ldi c, 0b_10000000          ; Создаём маску для левого пикселя

; Цикл калькуляции каждого из 8 пикселей.
main_calc_loop:     ld b, d                     ; Загружаем значение счётчика
                    test b
                    jz main_calc_next           ; Если счётчик показывает ноль, значит число соседей
                                                ;   равно 2, и пиксель не меняем.
                    or a, c                     ; Закрашиваем пиксель
                    dec b                       ; Уменьшаем значение счётчика на 1
                    jz main_calc_next           ; Теперь, если счётчик показывает ноль, значит число
                                                ;   соседей 3, и пиксель больше не меняем.
                    xor a, c                    ; Число соседей не 2 и не 3, значит очищаем пиксель

; Готовим следующий пиксель
main_calc_next:     inc d                       ; Сдвигаем указатель на следующий счётчик
                    shr c                       ; Сдвигаем вправо маску для пикселя
                    jnz main_calc_loop          ; Повторяем итерацию

; Применяем результат калькуляции
                    ld c, display_ptr
                    ldi b, 30                   ; Величина сдвига для адреса сохранения
                    add b, c
                    st a, b                     ; Сохраняем результат в кэш следующего кадра
                    inc c
                    st c, display_ptr           ; Сдвигаем указатель на дисплее
                    shr b
                    jnc main_calc_iter          ; Если адрес сохранения чётный, повторяем калькуляцию

main_calc_jmp:      jmp main_row                ; Заменяемая ссылка для прыжка

; Обработка всего дисплея завершена. Осталось провести калькуляцию для двух нижних рядов.
main_final:         ldi b, main_final2
                    st b, main_calc_jmp +1      ; Заменяем ссылку для прыжка после калькуляции
                                                ;   предпоследнего ряда
                    jmp main_calc

; Осталось провести калькуляцию одного нижнего ряда на дисплее.
; Регистр C уже содержит указатель на дисплее.
; Регистр D уже содержит ссылку на область счётчиков для нижнего ряда на дисплее.
main_final2:        ldi b, main_final3
                    st b, main_calc_jmp +1      ; Заменяем ссылку для прыжка после калькуляции
                                                ;   нижнего ряда
                    jmp main_calc_iter

main_final3:        ldi b, main_row
                    st b, main_calc_jmp +1      ; Восстанавливаем ссылку для прыжка после
                                                ;   калькуляции

; Выводим следующий кадр из кэша на дисплей
main_frame:         ldi b, display
                    ldi c, frame_cache
                    ldi d, main_frame_loop

main_frame_loop:    ld a, c
                    st a, b
                    inc b
                    inc c
                    jns d

; Обновляем счётчик кадров на цифровом индикаторе.
; На этом вся работа над кадром завершена, и мы переходим к работе над следующим кадром.
main_count:         ld a, step_count
                    inc a
                    st a, step_count

                    ldi c, BANK_OUTER
                    ldi d, outer_up
                    jmp set_bank

; Генерируем и выводим на дисплей стартовый кадр со случайным рисунком.
; Регистр A уже содержит display.
; Регистр B уже содержит число 32.
main_rnd:
main_rnd_loop:      rnd c
                    rnd d
                    and c, d
                    st c, a
                    inc a
                    dec b
                    jnz main_rnd_loop

                    jmp main_count



;===================================================================================================
; BANK_OUTER - Банк памяти № 3 - адресное пространство 0x80...0xFF.
; Содержит логику обработки верхнего и нижнего рядов на дисплее.
;===================================================================================================

; Готовим к обработке верхний ряд на дисплее
outer_up:           ldi c, display
                    st c, display_ptr           ; Устанавливаем указатель на начало области дисплея

                    shr c                       ; Значение становится 0x20
                    st c, lower_area            ; Восстанавливаем ссылку на lower_area после
                                                ;   обработки предыдущего кадра
                                                
; Сбрасываем счётчики для текущего ряда на дисплее и для ряда ниже. Вместо нулей используем 0xFE,
; что оптимизирует последующую калькуляцию.
                    ldi a, 0xFE
                    ld b, current_area
                    ;                           ; Регистр C уже содержит число 32
                    ldi d, outer_up_loop

; Цикл сброса счётчиков
outer_up_loop:      st a, b
                    inc b
                    dec c
                    jnz d

                    jmp outer_begin

; Готовим к обработке нижний ряд на дисплее.
; Тут мы временно подменяем ссылку, отвечающую за ряд ниже, ссылкой на ряд выше. Это позволяет
; использовать единый код программы как для верхнего ряда на дисплее, так и для нижнего.
outer_down:         clr c                       ; Значение 0x00 соответствует upper_area
                    st c, lower_area

; Начало обработки ряда на дисплее
outer_begin:        ldi b, outer_center
                    st b, outer_edge_jmp +1     ; Заменяем ссылку для прыжка после обработки левого
                                                ;   углового пикселя
                    ldi b, outer_right
                    st b, outer_center_jmp +1   ; Заменяем ссылку для прыжка после обработки левой
                                                ;   половины ряда на дисплее
                    ld b, display_ptr
                    ld a, b                     ; Загружаем левую половину ряда на дисплее
                    shr a                       ; Сдвиг помогает унифицировать дальнейшую обработку

                    ldi c, 0x11                 ; current_area +1, т.е. указатель на счётчик для
                                                ;   соседа справа
                    ld d, lower_area            ; Указатель на счётчик для левого из двух соседей в
                                                ;   другом ряду
                    
; Обрабатываем угловой пиксель на дисплее.
; Регистр A уже содержит угловой пиксель в 6-м бите.
; Регистр C уже содержит указатель на счётчик для единственного бокового соседа.
; Регистр D уже содержит указатель на счётчик для левого из двух соседей в другом ряду.
outer_edge:         rcl a                       ; Сдвигаем угловой пиксель в 7-й бит
                    jns outer_edge_end          ; Если пиксель пустой, пропускаем его обработку

; Инкрементируем счётчик для единственного бокового соседа
                    ld b, c
                    inc b
                    st b, c
                    
; Инкрементируем счётчики для двух соседей в другом ряду
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d
                    dec d

outer_edge_end:     dec c
outer_edge_jmp:     jmp outer_center            ; Заменяемая ссылка для прыжка

; Переходим с обработки левой половины дисплея на правую.
; Регистр C уже содержит указатель на счётчик для левого из двух боковых соседей.
; Регистр D уже содержит указатель на счётчик для левого из трёх соседей в другом ряду.
outer_right:        ldi b, outer_edge
                    st b, outer_center_jmp +1   ; Заменяем ссылку для прыжка после обработки правой
                                                ;   половины ряда на дисплее
                    ldi b, outer_end
                    st b, outer_edge_jmp +1     ; Заменяем ссылку для прыжка после обработки правого
                                                ;   углового пикселя
                    ld b, display_ptr
                    inc b
                    ld a, b                     ; Загружаем правую половину ряда на дисплее
                    shr a                       ; Сдвиг помогает унифицировать дальнейшую обработку
                    
; Обрабатываем 7 пикселей, кроме углового, на одной половине дисплея.
; Регистр A уже содержит 7 пикселей в битах с 6 по 0-й.
; Регистр C уже содержит указатель на счётчик для левого из двух боковых соседей.
; Регистр D уже содержит указатель на счётчик для левого из трёх соседей в другом ряду.
outer_center:       ldi b, 8
                    st b, incrementor

; Цикл обработки каждого из 7 пикселей
outer_center_loop:  ld b, incrementor
                    dec b
                    st b, incrementor
outer_center_jmp:   jz outer_right              ; Заменяемая ссылка для прыжка

                    rcl a                       ; Сдвигаем очередной пиксель в 7-й бит
                    jns outer_center_else       ; Если пиксель пустой, пропускаем его обработку
                    
; Инкрементируем счётчики для двух боковых соседей
                    ld b, c
                    inc b
                    st b, c
                    inc c
                    inc c
                    ld b, c
                    inc b
                    st b, c
                    dec c
                    
; Инкрементируем счётчики для трёх соседей в другом ряду
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d
                    inc d
                    ld b, d
                    inc b
                    st b, d
                    dec d

                    jmp outer_center_loop
                    
; Готовим к обработке следующий пиксель
outer_center_else:  inc c
                    inc d
                    jmp outer_center_loop

; Обработка ряда на дисплее завершена. Чтобы определить, верхний это был ряд или нижний, смотрим на
; переменную lower_area. Для нижнего ряда мы подменяли её значение на 0x00.
outer_end:          ldi c, BANK_MAIN

                    ld a, lower_area
                    test a
                    jz outer_end_down

; Обработка верхнего ряда на дисплее завершена. Переходим к обработке следующих рядов.
outer_end_up:       ldi a, 0x42
                    st a, display_ptr
                    ldi d, main_row
                    jmp set_bank

; Обработка нижнего ряда на дисплее завершена. Переходим к калькуляции оставшихся двух нижних рядов
; и выводу следующего кадра на дисплей.
outer_end_down:     ldi d, main_final
                    jmp set_bank