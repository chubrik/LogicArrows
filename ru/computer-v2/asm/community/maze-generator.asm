; ##################################################################################################
; ##       Source code for the "Maze Generator" program for a computer made of logic arrows       ##
; ##     Исходный код программы "Генератор лабиринтов" для компьютера из логических стрелочек     ##
; ##                 https://github.com/chubrik/LogicArrows/tree/main/computer-v2                 ##
; ##                       (c) 2026 Farmer_2010 (https://t.me/farmer_2010)                        ##
; ##################################################################################################



COLORED equ 0b00110000
MONO    equ 0b00010000

BANK_MAIN equ 1
BANK_STACK equ 2
BANK_BORDER equ 3
BANK_POS equ 4

in_out equ 128


;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                       ОБЩАЯ ОБЛАСТЬ                         W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;Функция получения байта дисплея, переменные

jmp start


;###############################################################
;функция получения байта дисплея, его координаты и координаты бита. a - x, b - y, с - позиция(для однобайтового режима), d - индекс перехода

;перевод байта координат в два байта. c - позиция. Возвращает a и b
get_point_from_byte:

ldi a, 0xF0;a - xpos
and a, c
shr a;сдвигаем на 4 бита вправо
shr a
shr a
shr a

ldi b, 0x0F;b - ypos
and b, c

;сама функция
get_point:

ldi c, 0b00000111;индекс бита(0 - старший)
and c, a
st c, buffer;временно сохраняем в память

shl b;умножаем ypos на 2
ldi c, 7;если xpos > 7, прибавляем 1
sub a, c
jc plus_1_end
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

ldi a, display;прибавляем к b адрес дисплея
add b, a
ld a, b;считываем нужный байт из дисплея

;возвращает: a - байт дисплея, b - адрес на дисплее, c - маска для получения нужного бита

jmp d;переход обратно
;###############################################################


void db 0,0

border db 0;есть ли граница по направлению
x db 0;позиция текущей точки
y db 0
stack_length db 0;размер стека
function_input db 0;данные на вход функции
function_output db 0;выход функции
function_output_index db 0, 0;индекс возврата функции
buffer db 0, 0, 0, 0;буфер для хранения данных
terminal_input db 0;0x3C
terminal_graphics db 0;0x3D
connect db MONO;0x3E
bank db 1;0x3F


;дисплей
display db          0b00000000, 0b00000000, ;                                  ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b10001001, 0b00111011, ; ██      ██    ██    ██████  ████ ;
                    0b11011010, 0b10001010, ; ████  ████  ██  ██      ██  ██   ;
                    0b10101011, 0b10010011, ; ██  ██  ██  ██████    ██    ████ ;
                    0b10001010, 0b10100010, ; ██      ██  ██  ██  ██      ██   ;
                    0b10001010, 0b10111011, ; ██      ██  ██  ██  ██████  ████ ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b00011011, 0b10100100, ;       ████  ██████  ██    ██     ;
                    0b00100010, 0b00110100, ;     ██      ██      ████  ██     ;
                    0b00101011, 0b10101100, ;     ██  ██  ██████  ██  ████     ;
                    0b00101010, 0b00100100, ;     ██  ██  ██      ██    ██     ;
                    0b00110011, 0b10100100, ;     ████    ██████  ██    ██     ;
                    0b00000000, 0b00000000, ;                                  ;
                    0b00000000, 0b00000000  ;                                  ;


;###############################################################
;проверка состояния клетки для определения возможности передвижения
test_cell:

st a, function_output_index + 1;сохраняем индекс возврата функции

ld a, buffer + 3;восстанавливаем регистр a

st c, border;сохраняем регистр c
st d, buffer + 2;сохраняем регистр d

ldi d, $ + 6
st d, function_output_index
jmp get_pixel_value

ld c, border;восстанавливаем регистры c и d
ld d, buffer + 2

jz border_cell;проверка состояния клетки 
jmp clear_cell

border_cell:;если клетка занята
or c, d;добавляем 1 по нужному направлению

clear_cell:

ld a, function_output_index + 1;восстанавливаем индекс возврата функции
jmp a
;###############################################################

void0 db 0,0,0,0,0,0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           БАНК 1                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;Основная логика

;переход в/из текущего банка. c - индекс банка, d - индекс перехода
st c, bank;смена банка
jmp d;эта инструкция выполняется уже в другом банке. совершаем переход по нужному адресу


start:;начало кода

ldi a, MONO;подключаем монохромный дисплей
st a, connect

ldi a, 32
ldi b, 255
ldi c, display
clear:;заполняем дисплей
st b, c
inc c
dec a
jnz clear

rnd a;получаем случайные координаты
ldi b, 0b11101110;обрезаем у координат младшие биты, чтобы координаты были четными
and a, b

ldi c, BANK_STACK;ложим в стек случайную позицию
ldi d, stack_add
st a, function_input
ldi a, $ + 6
st a, function_output_index
jmp in_out


;###############################################################
;главный цикл
cycle:

;получаем координаты из стека в регистр b
ldi c, BANK_STACK
ldi d, stack_get
ldi a, $ + 6
st a, function_output_index
jmp in_out

ldi c, BANK_POS;получение позиции из байта вынесено в банк 4
ldi d, get_pos_from_byte
jmp in_out
get_pos_return:

ld c, buffer;восстанавливаем c из буфера

;рисование точки на дисплее
ldi d, $ + 4;получаем байт дисплея
jmp get_point_from_byte;

not c;инвертируем c, так как красим в белый
and a, c;and между c и байтом дисплея(потому что красим в белый. Если красить цветом, то нужен or)
st a, b;устанавливаем измененный байт обратно на дисплей

ld a, x;загружаем позицию из памяти
ld b, y

ldi c, BANK_BORDER;проверка границ и соседних клеток
ldi d, test_borders
jmp in_out

remove:
;если клетка окружена, удаляем из стека

ldi c, BANK_STACK
ldi d, stack_remove
ldi a, continue
st a, function_output_index
jmp in_out

move:

rnd d;генерируем случайное направление в регистр d
ldi b, 0b00000011
and d, b;оставляем младшие 2 бита

ldi c, 0b00010000;маска для получения из байта границ 

;цикл для получения направления
get_rotate:;получаем маску из направления при помощи побитового сдвига вправо

shr c;маска в регистре c

dec d
jns get_rotate
;

ld d, function_output;загружаем байт границ из памяти

and d, c;проверяем границу по направлению
test d
jnz move;если граница, пробуем другое направление

mov b, c
ldi c, BANK_POS;определение позиции соседних клеток вынесено в банк 4
ldi d, get_coord
jmp in_out
get_coord_return:

;рисование точки на дисплее
;рисуем промежуточную точку между старой и новой позициями
ldi d, $ + 4;получаем байт дисплея
jmp get_point;

not c;инвертируем c, так как красим в белый
and a, c;and между c и байтом дисплея(потому что красим в белый. Если красить цветом, то нужен or)
st a, b;устанавливаем измененный байт обратно на дисплей

ldi c, BANK_STACK;ложим в стек новую позицию
ldi d, stack_add
ldi a, $ + 6
st a, function_output_index
jmp in_out

continue:

ld a, stack_length;продолжаем цикл, если длина стека > 0
test a
jnz cycle

hlt;лабиринт сгенерирован, останавливаем программу
;###############################################################

void1 db 0,0,0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           БАНК 2                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;Стек и функции для работы со стеком

;переход в/из текущего банка. c - индекс банка, d - индекс перехода
st c, bank;смена банка
jmp d;эта инструкция выполняется уже в другом банке. совершаем переход по нужному адресу


;###############################################################
;функция добавления числа в стек. fn_input - число
stack_add:

ld c, function_input;загружаем в c вход функции

ld a, stack_length;складываем длину стека и адрес стека
ldi b, stack
add b, a;конечный индекс в регистре b

st c, b;записываем число по нужному адресу и увеличиваем длину стека
inc a
st a, stack_length

ld d, function_output_index;загружаем в d адрес
ldi c, BANK_MAIN;возвращаемся в банк 1 по нужному адресу
jmp in_out
;###############################################################


;###############################################################
;функция удаления последнего элемента стека
stack_remove:

ld a, stack_length;складываем длину стека и адрес стека
ldi b, stack
add b, a;конечный индекс в регистре b

clr c;записываем 0 в ячейку
st c, b

dec a;уменьшаем длину стека
st a, stack_length

ld d, function_output_index;загружаем в d адрес
ldi c, BANK_MAIN;возвращаемся в банк 1 по нужному адресу
jmp in_out
;###############################################################


;###############################################################
;функция получения последнего элемента из стека в b
stack_get:

ld a, stack_length;складываем длину стека и адрес стека
dec a;уменьшаем а, т.к. это длина стека, а не индекс последнего элемента
ldi b, stack
add b, a;конечный индекс в регистре b

ld b, b;загружаем в регистр b последний элемент стека

ld d, function_output_index;загружаем в d адрес
ldi c, BANK_MAIN;возвращаемся в банк 1 по нужному адресу
jmp in_out
;###############################################################


stack db 0,0,0,0,0,0,0,0,;стек из 64 позиций
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0

void2 db 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           БАНК 3                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;Проверка границ и соседних клеток

;переход в/из текущего банка. c - индекс банка, d - индекс перехода
st c, bank;смена банка
jmp d;эта инструкция выполняется уже в другом банке. совершаем переход по нужному адресу


;###############################################################
;функция получения значения пикселя дисплея по координатам из a, b во флаг z. fn_output_index - индекс перехода
get_pixel_value:

ldi d, $ + 4;получаем байт дисплея
jmp get_point;a - байт дисплея, c - маска

and a, c;в a получаем значение бита

test a;флаг z - a = 0

ld d, function_output_index
jmp d;переход обратно
;###############################################################


;###############################################################
;функция определения возможности передвижения по всем направлениям
;a - xpos, b - ypos
test_borders:

clr c;регистр с - для границ
ldi d, 0b00001000;маска

;
;ВВЕРХ
;
dec b;проверка верхней границы
js up
jns up_else

up:;если сверху граница, прибавляем d к c
or c, d
jmp up_end

up_else:;если сверху свободно, проверяем содержимое ячейки сверху
dec b;вычитаем второй раз

st a, buffer + 3;проверка клетки вынесена в функцию
ldi a, $ + 4
jmp test_cell

up_end:
shr d;сдвигаем d на следующее направление

;
;ВПРАВО
;
ld a, x;загружаем изначальные координаты
ld b, y

inc a;проверка правой границы
inc a;прибавляем два раза, потому что размер экрана четный

st d, buffer;сохраняем d

ldi d, 0x0F;обрезаем первые 4 бита позиции(имитация 4битной переменной)
and d, a

ld d, buffer;восстанавливаем d

jz right
jnz right_else

right:;если справа граница, прибавляем d к c
or c, d
jmp right_end

right_else:;если справа свободно, проверяем содержимое ячейки справа

st a, buffer + 3;проверка клетки вынесена в функцию
ldi a, $ + 4
jmp test_cell

right_end:
shr d;сдвигаем d на следующее направление

;
;ВНИЗ
;
ld a, x;загружаем изначальные координаты
ld b, y

inc b;проверка нижней границы
inc b;прибавляем два раза, потому что размер экрана четный

st d, buffer;сохраняем d

ldi d, 0x0F;обрезаем первые 4 бита позиции(имитация 4битной переменной)
and d, b

ld d, buffer;восстанавливаем d

jz down
jnz down_else

down:;если снизу граница, прибавляем d к c
or c, d
jmp down_end

down_else:;если снизу свободно, проверяем содержимое ячейки снизу

st a, buffer + 3;проверка клетки вынесена в функцию
ldi a, $ + 4
jmp test_cell

down_end:
shr d;сдвигаем d на следующее направление

;
;ВЛЕВО
;
ld a, x;загружаем изначальные координаты
ld b, y

dec a;проверка левой границы
js left
jns left_else

left:;если слева граница, прибавляем d к c
or c, d
jmp left_end

left_else:;если слева свободно, проверяем содержимое ячейки слева
dec a;вычитаем второй раз

st a, buffer + 3;проверка клетки вынесена в функцию
ldi a, $ + 4
jmp test_cell

left_end:


st c, function_output;сохраняем байт границ в память

ldi d, 0x0F;если со всех сторон граница, переходим на remove, иначе на move
sub c, d

jz jmp_remove
ldi d, move
jmp jmp_end

jmp_remove:
ldi d, remove

jmp_end:

ldi c, BANK_MAIN
jmp in_out
;###############################################################

void3 db 0,0,0,0,0,0,0

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;W                           БАНК 4                            W
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;Получение координат соседней клетки по направлению

;переход в/из текущего банка. c - индекс банка, d - индекс перехода
st c, bank;смена банка
jmp d;эта инструкция выполняется уже в другом банке. совершаем переход по нужному адресу


;###############################################################
;функция определения положения соседней клетки по направлению
;b - направление
;fn_input - на сколько увеличивать/уменьшать
get_rotate_position:

mov c, b;копируем направление в c

ld a, x;загружаем координаты
ld b, y

;вверх
ldi d, 0b00001000
sub d, c
jz test_up
jmp test_up_end

test_up:
ld d, function_input
sub b, d
test_up_end:

;вправо
ldi d, 0b00000100
sub d, c
jz test_right
jmp test_right_end

test_right:
ld d, function_input
add a, d
test_right_end:

;вниз
ldi d, 0b00000010
sub d, c
jz test_down
jmp test_down_end

test_down:
ld d, function_input
add b, d
test_down_end:

;влево
ldi d, 0b00000001
sub d, c
jz test_left
jmp test_left_end

test_left:
ld d, function_input
sub a, d
test_left_end:

ld d, function_output_index
jmp d
;###############################################################


;###############################################################
;записывает координаты из регистра b
get_pos_from_byte:

st b, buffer;сохраняем позицию в буфер, потому что функция рисования точки берет позицию из регистра c

ldi a, 0xF0;a - xpos
and a, b
shr a;сдвигаем на 4 бита вправо
shr a
shr a
shr a

ldi c, 0x0F;b - ypos
and b, c

st a, x;сохраняем x в память
st b, y;сохраняем y в память

ldi c, BANK_MAIN
ldi d, get_pos_return
jmp in_out
;###############################################################


;###############################################################
;продолжение кода из банка 1
get_coord:

st b, buffer;сохраняем направление в буфер(во избежание перезаписи регистра)

ldi d, 2;получаем новые координаты(для стека)
st d, function_input
ldi d, $ + 6
st d, function_output_index
jmp get_rotate_position

shl a;переводим 2 байта координат в 1
shl a
shl a
shl a
or a, b
st a, function_output;сохраняем в fn_output


ld b, buffer;загружаем направление из буфера

ldi d, 1;получаем координаты для рисования линии
st d, function_input
ldi d, $ + 6
st d, function_output_index
jmp get_rotate_position


ld d, function_output;копируем из fn_out в fn_in(потому, что функция добавления элемента в стек получает координаты в fn_in)
st d, function_input

ldi c, BANK_MAIN
ldi d, get_coord_return
jmp in_out
;###############################################################
