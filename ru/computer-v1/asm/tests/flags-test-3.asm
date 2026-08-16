; ##################################################################################################
; ##       Diagnostic disk #3: the X, 0 forms - effect on the C and O flags and the result        ##
; ##          Диагностический диск №3: формы X, 0 — влияние на флаги C, O и на результат          ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v1                 ##
; ##                         (c) 2026 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


                ldi d, terminal     ; В регистре D постоянно лежит адрес для вывода в терминал
                ldi c, 0x40         ; Счётчик проб: код перед буквой "A"
                ldi b, 0x33         ; Маркер номера диска: "3"
                st b, d

; Случай 1 (канарейка): add 255+1, ожидаем C=1, O=0
                inc c
                ldi a, 255
                ldi b, 1
                add a, b
                jc t1o
                st c, d             ; "A" = нет переноса после add 255+1
t1o:            inc c
                jno t2
                st c, d             ; "B" = ложное переполнение после add 255+1

; Случай 2: sub a, 0 при A=5 с подготовленными C=1, O=1, ожидаем честное 5-0: A=5, C=0, O=0
t2:             inc c
                ldi a, 128
                ldi b, 128
                add a, b            ; Готовим C=1, O=1
                ldi a, 5
                sub a, 0
                jnc t2o
                st c, d             ; "C" = sub a, 0 не сбросил C
t2o:            inc c
                jno t2r
                st c, d             ; "D" = sub a, 0 не сбросил O
t2r:            inc c
                ldi b, 5
                xor a, b
                jz t3
                st c, d             ; "E" = sub a, 0 изменил значение A (ожидаем 5-0 = 5)
                jmp t3

void        db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

; Порты
keyboard    db  0                   ; Порт клавиатуры
output      db  0x40                ; Порт выбора вывода: терминал подключается уже при загрузке
terminal    db  0                   ; Байт, отправленный сюда, печатается в терминал

; Случай 3: add a, 0 при A=5 с подготовленными C=1, O=1, ожидаем честное 5+0: A=5, C=0, O=0
t3:             inc c
                ldi a, 128
                ldi b, 128
                add a, b            ; Готовим C=1, O=1
                ldi a, 5
                add a, 0
                jnc t3o
                st c, d             ; "F" = add a, 0 не сбросил C
t3o:            inc c
                jno t3r
                st c, d             ; "G" = add a, 0 не сбросил O
t3r:            inc c
                ldi b, 5
                xor a, b
                jz t4
                st c, d             ; "H" = add a, 0 изменил значение A (ожидаем 5+0 = 5)

; Случай 4: adc a, 0 при A=5 с подготовленными C=1, O=1, ожидаем честное 5+0+C: A=6, C=0, O=0.
; Программы сообщества используют эту форму как "A += C" при переносе старшего байта.
t4:             inc c
                ldi a, 128
                ldi b, 128
                add a, b            ; Готовим C=1, O=1
                ldi a, 5
                adc a, 0
                jnc t4o
                st c, d             ; "I" = adc a, 0 не сбросил C
t4o:            inc c
                jno t4r
                st c, d             ; "J" = adc a, 0 не сбросил O
t4r:            inc c
                ldi b, 6
                xor a, b
                jz t5
                st c, d             ; "K" = adc a, 0 не учёл флаг C (ожидаем 5+0+C = 6)

; Случай 5: sbb a, 0 при A=5 с подготовленными C=1, O=1, ожидаем честное 5-0-C: A=4, C=0, O=0
t5:             inc c
                ldi a, 128
                ldi b, 128
                add a, b            ; Готовим C=1, O=1
                ldi a, 5
                sbb a, 0
                jnc t5o
                st c, d             ; "L" = sbb a, 0 не сбросил C
t5o:            inc c
                jno t5r
                st c, d             ; "M" = sbb a, 0 не сбросил O
t5r:            inc c
                ldi b, 4
                xor a, b
                jz tchk
                st c, d             ; "N" = sbb a, 0 не учёл флаг C (ожидаем 5-0-C = 4)

; Проверка счётчика: после 14 проб счётчик должен быть ровно на букве "N"
tchk:           mov a, c
                ldi b, 0x4E         ; Код буквы "N"
                xor a, b
                jz tdot
                ldi c, 0x23         ; "#" = поток управления пошёл не по плану, часть проб не
                                    ;   выполнилась
                st c, d
tdot:           ldi c, 0x2E         ; Маркер конца "."
                st c, d
                hlt
