; ##################################################################################################
; ##        Diagnostic diskette #4: S and Z flags after the logical operations (and/or/xor)       ##
; ##        Диагностическая дискета №4: флаги S и Z после логических операций (and/or/xor)        ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v1                 ##
; ##                         (c) 2026 Arkadi Chubrik (arkadi@chubrik.org)                         ##
; ##################################################################################################


                ldi d, terminal     ; В регистре D постоянно лежит адрес для вывода в терминал
                ldi c, "A" - 1      ; Счётчик проб
                ldi b, "4"          ; Маркер номера дискеты
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

; Случай 2: xor 0xFF, 0x7F = 0x80, ожидаем S=1
t2:             inc c
                ldi a, 0xFF
                ldi b, 0x7F
                xor a, b
                js t3
                st c, d             ; "C" = нет знака после xor с результатом 0x80

; Случай 3: xor 0xFF, 0xFE = 0x01, ожидаем S=0
t3:             inc c
                ldi a, 0xFF
                ldi b, 0xFE
                xor a, b
                jns t4
                st c, d             ; "D" = ложный знак после xor с результатом 0x01

; Случай 4: and 0x81, 0x80 = 0x80, ожидаем S=1
t4:             inc c
                ldi a, 0x81
                ldi b, 0x80
                and a, b
                js t5
                st c, d             ; "E" = нет знака после and с результатом 0x80
                jmp t5

void        db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

; Порты
keyboard    db  0                   ; Порт клавиатуры
output      db  0x40                ; Порт выбора вывода: терминал подключается уже при загрузке
terminal    db  0                   ; Байт, отправленный сюда, печатается в терминал

; Случай 5: and 0x7F, 0x01 = 0x01, ожидаем S=0
t5:             inc c
                ldi a, 0x7F
                ldi b, 0x01
                and a, b
                jns t6
                st c, d             ; "F" = ложный знак после and с результатом 0x01

; Случай 6: or 0x80, 0x00 = 0x80, ожидаем S=1
t6:             inc c
                ldi a, 0x80
                ldi b, 0
                or a, b
                js t7
                st c, d             ; "G" = нет знака после or с результатом 0x80

; Случай 7: or 0x01, 0x00 = 0x01, ожидаем S=0
t7:             inc c
                ldi a, 0x01
                ldi b, 0
                or a, b
                jns t8
                st c, d             ; "H" = ложный знак после or с результатом 0x01

; Случай 8: xor 0xAA, 0xAA = 0, ожидаем Z=1: ноль особенный для кадра со стоповым битом
t8:             inc c
                ldi a, 0xAA
                ldi b, 0xAA
                xor a, b
                jz tchk
                st c, d             ; "I" = нет нуля после xor равных значений

; Проверка счётчика: после 9 проб счётчик должен быть ровно на букве "I"
tchk:           mov a, c
                ldi b, "I"
                xor a, b
                jz tdot
                ldi c, "#"          ; "#" = поток управления пошёл не по плану, часть проб
                                    ;   не выполнилась
                st c, d
tdot:           ldi c, "."          ; Маркер конца "."
                st c, d
                hlt
