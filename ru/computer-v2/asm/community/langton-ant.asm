; ##################################################################################################
; ##       Source code for the "Langton's Ant" program for a computer made of logic arrows        ##
; ##       Исходный код программы "Муравей Лэнгтона" для компьютера из логических стрелочек       ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                     (c) 2026 Farmer_2010 (https://github.com/farmer2010)                     ##
; ##################################################################################################



COLORED equ 0b00110100


;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                       ОБЩАЯ ОБЛАСТЬ                         W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

ldi a, 32
ldi c, display
ldi d, display_blue
clear:;заполняем дисплей
st b, c
st b, d
inc c
inc d
dec a
jnz clear

jmp cycle


;###############################################################
;функция получения байта дисплея, его координаты и координаты бита. a - x, b - y, с - позиция(для однобайтового режима), d - индекс перехода

;сама функция
get_point:

ldi c, 0b00000111;индекс бита(0 - старший)
and c, a
st c, buffer;временно сохраняем в память

shl b;умножаем ypos на 2

ldi c, 0b00001000;если xpos > 7, прибавляем 1
and c, a
test c
jz plus_1_end

inc b
plus_1_end:
ld a, buffer;a - индекс бита(0 - старший), b - индекс байта

ldi c, 7;вычитаем a из 7, чтобы 0 стал младшим битом
sub c, a
mov a, c

ldi c, 1
pow:;получаем в c число с активным битом номер a
test a
jz pow_end
shl c
dec a
jmp pow
pow_end:

INDEX_CHANGE equ $ + 1;для чтения из необходимой части дисплея редактируем байт следующей команды
ldi a, display;прибавляем к b адрес дисплея
add b, a
ld a, b;считываем нужный байт из дисплея

;возвращает: a - байт дисплея, b - адрес на дисплее, c - маска для получения нужного бита

jmp d;переход обратно
;###############################################################

buffer db 0,0,0,0,0

x db 8
y db 8
new_x db 0
new_y db 0
rotate db 3

counter db 0;0x3A
indicator2 db 0;0x3B
terminal_input db 0;0x3C
terminal_graphics db 0;0x3D
connect db COLORED;0x3E
bank db 1;0x3F

display db          0b00000000, 0b00000000,
                    0b00000000, 0b00000000,
                    0b10010000, 0b00000000,
                    0b01001000, 0b00000000,
                    0b01001000, 0b00000000,
                    0b01111000, 0b00000000,
                    0b11111011, 0b00011000,
                    0b11011111, 0b10111100,
                    0b01110111, 0b11111110,
                    0b00000111, 0b10111111,
                    0b00001001, 0b00001000,
                    0b00010010, 0b00000100,
                    0b00100100, 0b00000010,
                    0b00000000, 0b00000000,
                    0b00000000, 0b00000000,
                    0b00000000, 0b00000000

display_blue db     0b00000000, 0b00000000,
                    0b00000000, 0b00000000,
                    0b10010000, 0b00000000,
                    0b01001000, 0b00000000,
                    0b01001000, 0b00000000,
                    0b01111000, 0b00000000,
                    0b11111011, 0b00011000,
                    0b11011111, 0b10111100,
                    0b01110111, 0b11111110,
                    0b00000111, 0b10111111,
                    0b00001001, 0b00001000,
                    0b00010010, 0b00000100,
                    0b00100100, 0b00000010,
                    0b00000000, 0b00000000,
                    0b00000000, 0b00000000,
                    0b00000000, 0b00000000
					
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           БАНК 1                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

cycle:

ld a, x
ld b, y
ldi d, $ + 4
jmp get_point
or a, c;or между c и байтом дисплея(потому что красим цветом)
st a, b;устанавливаем измененный байт обратно на дисплей


ldi a, display_blue
st a, INDEX_CHANGE
ld a, x
ld b, y
ldi d, $ + 4
jmp get_point
mov d, a
and d, c

xor a, c;инвертируем бит дисплея
st a, b

ld b, rotate
ldi c, 0b00000011
test d
jnz left_rotate
inc b
and b, c
jmp left_rotate_end
left_rotate:
dec b
and b, c
left_rotate_end:
st b, rotate


ld a, x
ld b, y
ld c, rotate

clr d
sub d, c
jnz up_else
dec b
up_else:

ldi d, 1
sub d, c
jnz right_else
inc a
right_else:

ldi d, 2
sub d, c
jnz down_else
inc b
down_else:

ldi d, 3
sub d, c
jnz left_else
dec a
left_else:

ldi c, 0b00001111
and a, c
and b, c

st a, new_x
st b, new_y

ldi a, display
st a, INDEX_CHANGE

ld a, x
ld b, y
ldi d, $ + 4
jmp get_point
not c;инвертируем c, так как красим в белый
and a, c;and между c и байтом дисплея(потому что красим в белый. Если красить цветом, то нужен or)
st a, b;устанавливаем измененный байт обратно на дисплей

ld a, new_x
st a, x
ld a, new_y
st a, y

ld a, counter
ld b, indicator2
clr c
ldi d, 1
add a, d
adc b, c
st a, counter
st b, indicator2
jmp cycle
