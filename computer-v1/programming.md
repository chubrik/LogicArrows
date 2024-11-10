﻿### [← Компьютер из стрелочек v1](index.md)

# Программирование

## Общие принципы
Для программирования используются команды ассемблера, которые располагаются в RAM и выполняются друг за другом, начиная с адреса `00`. Каждая команда занимает 1 байт. Некоторые команды требуют дополнительного аргумента, который также занимает 1 байт и располагается в RAM сразу вслед за командой. Команды работают с регистрами процессора `A` `B` `C` `D` и флагами `Z` `C` `S` `O`. Также, команды могут совершать переходы к различным участкам кода, создавая циклы, прыжки и пр. Регистры `A` `B` `C` `D` хранят по 1 байту каждый и имеют универсальное назначение. Флаги `Z` `C` `S` `O` выражают собой результат выполнения операций вычисления, а также могут влиять на ход других операций, в т. ч. быть условием для перехода к другому участку кода.

- **Флаг Z (ноль)** показывает, является ли результат вычисления нулём.
- **Флаг C (перенос)** показывает, был ли в результате вычисления выход одного из битов за пределы байта.
- **Флаг S (знак)** показывает состояние старшего бита у результата вычисления. В математике с отрицательным числами это означает, что результат меньше нуля.
- **Флаг O (переполнение)** показывает ситуацию, когда два операнда вычисления имеют одинаковый старший бит, а у результата старший бит имеет противоположное значение. В математике с отрицательными числами это означает, что результат вышел за допустимый диапазон и считается ошибочным.
<br><br>

## Сводная таблица команд
Каждая команда ассемблера имеет свой уникальный HEX-код. К примеру, команда `st a, b` имеет код `B4` (ряд, затем колонка). Ниже идёт описание каждой команды.
<table>
  <thead>
    <tr>
      <th></th>
      <th>0</th><th>1</th><th>2</th><th>3</th>
      <th>4</th><th>5</th><th>6</th><th>7</th>
      <th>8</th><th>9</th><th>A</th><th>B</th>
      <th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td align="center">mov a, 0</td><td align="center">mov a, b</td><td align="center">mov a, c</td><td align="center">mov a, d</td>
      <td align="center">mov a, 0</td><td align="center">mov b, a</td><td align="center">mov c, a</td><td align="center">mov d, a</td>
      <td align="center">and a, 0</td><td align="center">and a, b</td><td align="center">and a, c</td><td align="center">and a, d</td>
      <td align="center">and a, 0</td><td align="center">and b, a</td><td align="center">and c, a</td><td align="center">and d, a</td>
    </tr>
    <tr>
      <th>1</th>
      <td align="center">or a, 0</td><td align="center">or a, b</td><td align="center">or a, c</td><td align="center">or a, d</td>
      <td align="center">or a, 0</td><td align="center">or b, a</td><td align="center">or c, a</td><td align="center">or d, a</td>
      <td align="center">xor a, 0</td><td align="center">xor a, b</td><td align="center">xor a, c</td><td align="center">xor a, d</td>
      <td align="center">xor a, 0</td><td align="center">xor b, a</td><td align="center">xor c, a</td><td align="center">xor d, a</td>
    </tr>
    <tr>
      <th>2</th>
      <td align="center">add a, 0</td><td align="center">add a, b</td><td align="center">add a, c</td><td align="center">add a, d</td>
      <td align="center">add a, 0</td><td align="center">add b, a</td><td align="center">add c, a</td><td align="center">add d, a</td>
      <td align="center">adc a, 0</td><td align="center">adc a, b</td><td align="center">adc a, c</td><td align="center">adc a, d</td>
      <td align="center">adc a, 0</td><td align="center">adc b, a</td><td align="center">adc c, a</td><td align="center">adc d, a</td>
    </tr>
    <tr>
      <th>3</th>
      <td align="center">sub a, 0</td><td align="center">sub a, b</td><td align="center">sub a, c</td><td align="center">sub a, d</td>
      <td align="center">sub a, 0</td><td align="center">sub b, a</td><td align="center">sub c, a</td><td align="center">sub d, a</td>
      <td align="center">sbb a, 0</td><td align="center">sbb a, b</td><td align="center">sbb a, c</td><td align="center">sbb a, d</td>
      <td align="center">sbb a, 0</td><td align="center">sbb b, a</td><td align="center">sbb c, a</td><td align="center">sbb d, a</td>
    </tr>
    <tr>
      <th>4</th>
      <td align="center">not a</td><td align="center">not b</td><td align="center">not c</td><td align="center">not d</td>
      <td align="center">neg a</td><td align="center">neg b</td><td align="center">neg c</td><td align="center">neg d</td>
      <td align="center">inc a</td><td align="center">inc b</td><td align="center">inc c</td><td align="center">inc<br> d</td>
      <td align="center">dec a</td><td align="center">dec b</td><td align="center">dec c</td><td align="center">dec d</td>
    </tr>
    <tr>
      <th>5</th>
      <td align="center">shl a</td><td align="center">shl b</td><td align="center">shl c</td><td align="center">shl d</td>
      <td align="center">shr a</td><td align="center">shr b</td><td align="center">shr c</td><td align="center">shr d</td>
      <td align="center">sar a</td><td align="center">sar b</td><td align="center">sar c</td><td align="center">sar d</td>
      <td align="center">exp a</td><td align="center">exp b</td><td align="center">exp c</td><td align="center">exp d</td>
    </tr>
    <tr>
      <th>6</th>
      <td align="center">rcl a</td><td align="center">rcl b</td><td align="center">rcl c</td><td align="center">rcl d</td>
      <td align="center">rcr a</td><td align="center">rcr b</td><td align="center">rcr c</td><td align="center">rcr d</td>
      <td align="center" colspan="8"><i>reserved</i></td>
    </tr>
    <tr>
      <th>7</th>
      <td align="center" colspan="16"><i>reserved</i></td>
    </tr>
    <tr>
      <th>8</th>
      <td align="center">ld a</td><td align="center">ld b</td><td align="center">ld c</td><td align="center">ld d</td>
      <td align="center">ld a</td><td align="center">ld b</td><td align="center">ld c</td><td align="center">ld d</td>
      <td align="center">ldi a</td><td align="center">ldi b</td><td align="center">ldi c</td><td align="center">ldi d</td>
      <td align="center">ldi a</td><td align="center">ldi b</td><td align="center">ldi c</td><td align="center">ldi d</td>
    </tr>
    <tr>
      <th>9</th>
      <td align="center">ld a, a</td><td align="center">ld b, a</td><td align="center">ld c, a</td><td align="center">ld d, a</td>
      <td align="center">ld a, b</td><td align="center">ld b, b</td><td align="center">ld c, b</td><td align="center">ld d, b</td>
      <td align="center">ld a, c</td><td align="center">ld b, c</td><td align="center">ld c, c</td><td align="center">ld d, c</td>
      <td align="center">ld a, d</td><td align="center">ld b, d</td><td align="center">ld c, d</td><td align="center">ld d, d</td>
    </tr>
    <tr>
      <th>A</th>
      <td align="center">st a</td><td align="center">st b</td><td align="center">st c</td><td align="center">st d</td>
      <td align="center">st a</td><td align="center">st b</td><td align="center">st c</td><td align="center">st d</td>
      <td align="center">rnd a</td><td align="center">rnd b</td><td align="center">rnd c</td><td align="center">rnd d</td>
      <td align="center">rnd a</td><td align="center">rnd b</td><td align="center">rnd c</td><td align="center">rnd d</td>
    </tr>
    <tr>
      <th>B</th>
      <td align="center">st a, a</td><td align="center">st b, a</td><td align="center">st c, a</td><td align="center">st d, a</td>
      <td align="center">st a, b</td><td align="center">st b, b</td><td align="center">st c, b</td><td align="center">st d, b</td>
      <td align="center">st a, c</td><td align="center">st b, c</td><td align="center">st c, c</td><td align="center">st d, c</td>
      <td align="center">st a, d</td><td align="center">st b, d</td><td align="center">st c, d</td><td align="center">st d, d</td>
    </tr>
    <tr>
      <th>C</th>
      <td align="center">jz a</td><td align="center">jc a</td><td align="center">js a</td><td align="center">jo a</td>
      <td align="center">jz b</td><td align="center">jc b</td><td align="center">js b</td><td align="center">jo b</td>
      <td align="center">jz c</td><td align="center">jc c</td><td align="center">js c</td><td align="center">jo c</td>
      <td align="center">jz d</td><td align="center">jc d</td><td align="center">js d</td><td align="center">jo d</td>
    </tr>
    <tr>
      <th>D</th>
      <td align="center">jnz a</td><td align="center">jnc a</td><td align="center">jns a</td><td align="center">jno a</td>
      <td align="center">jnz b</td><td align="center">jnc b</td><td align="center">jns b</td><td align="center">jno b</td>
      <td align="center">jnz c</td><td align="center">jnc c</td><td align="center">jns c</td><td align="center">jno c</td>
      <td align="center">jnz d</td><td align="center">jnc d</td><td align="center">jns d</td><td align="center">jno d</td>
    </tr>
    <tr>
      <th>E</th>
      <td align="center">jz</td><td align="center">jc</td><td align="center">js</td><td align="center">jo</td>
      <td align="center">jnz</td><td align="center">jnc</td><td align="center">jns</td><td align="center">jno</td>
      <td align="center" colspan="4">jmp</td>
      <td align="center" colspan="4">hlt</td>
    </tr>
    <tr>
      <th>F</th>
      <td align="center" colspan="4">jmp a</td>
      <td align="center" colspan="4">jmp b</td>
      <td align="center" colspan="4">jmp c</td>
      <td align="center" colspan="4">jmp d</td>
    </tr>
  </tbody>
</table>
<br>

### Команды вычисления
Команды из этого набора читают информацию из одного или двух регистров, производят вычисление и сохраняют результат в один из этих же регистров. Также, в зависимости от типа операции, они могут воздействовать на те или иные флаги. В названиях команд используются условные обозначения ***X*** и ***Y***, которые означают любой из регистров `A` `B` `C` `D`, в зависимости от конкретной команды из сводной таблицы (выше).

Команда|Описание|На какие флаги воздействует
---|---|---
mov ***X***, ***Y*** |Копирует из ***Y*** в ***X***.<br> Если в качестве ***Y*** указан 0, то в ***X*** записывает ноль.|не воздействует
and ***X***, ***Y*** |Побитовое И между ***X*** и ***Y***, результат сохраняет в ***X***.<br> Если в качестве ***Y*** указан 0, то ничего не сохраняет, а лишь воздействует на флаги.|Z и S
or ***X***, ***Y*** |Побитовое ИЛИ между ***X*** и ***Y***, результат сохраняет в ***X***.<br> Если в качестве ***Y*** указан 0, то ничего не сохраняет, а лишь воздействует на флаги.|Z и S
xor ***X***, ***Y*** |Побитовое исключающее ИЛИ между ***X*** и ***Y***, результат сохраняет в ***X***.<br> Если в качестве ***Y*** указан 0, то ничего не сохраняет, а лишь воздействует на флаги.|Z и S
add ***X***, ***Y*** |Складывает ***X*** и ***Y***, результат сохраняет в ***X***.<br> Если в качестве ***Y*** указан 0, то ничего не сохраняет, а лишь воздействует на флаги.|все флаги
adc ***X***, ***Y*** |То же, что и предыдущее, но если ранее был установлен флаг `C`, к результату дополнительно прибавляется 1.|все флаги
sub ***X***, ***Y*** |Из ***X*** вычитает ***Y***, результат сохраняет в ***X***.<br> Если в качестве ***Y*** указан 0, то ничего не сохраняет, а лишь воздействует на флаги.|все флаги
sbb ***X***, ***Y*** |То же, что и предыдущее, но если ранее был установлен флаг `C`, из результата дополнительно вычитается 1.|все флаги
not ***X*** |Заменяет каждый бит на противоположный.|Z и S
neg ***X*** |Меняет знак у числа. (Число необходимо воспринимать как знаковое.)|Z и S
inc ***X*** |Прибавляет 1.|Z и S
dec ***X*** |Вычитает 1.|Z и S
shl ***X*** |Сдвигает все биты на один влево. Левый бит переходит во флаг `С`. Правый бит становится нулём.|Z, C и S
shr ***X*** |Сдвигает все биты на один вправо. Левый бит становится нулём. Правый бит переходит во флаг `С`.|Z, C и S
sar ***X*** |То же, что и предыдущее, но левый бит не меняет своего значения.|Z, C и S
exp ***X*** |Копирует флаг `С` в каждый бит числа.|Z и S
rcl ***X*** |Сдвигает все биты на один влево. Правый бит берётся из флага `С`. Левый бит переходит во флаг `С`.|Z, C и S
rcr ***X*** |Сдвигает все биты на один вправо. Левый бит берётся из флага `С`. Правый бит переходит во флаг `С`.|Z, C и S

<br>

### Команды управления
Команды из этого набора отвечают за операции ввода/вывода и переходы. Воздействия на флаги здесь не происходит, однако флаги могут использоваться в качестве условия. В названиях команд используются условные обозначения ***X*** и ***Y***, которые означают любой из регистров `A` `B` `C` `D`, а также ***F***, которое означает любой из флагов `Z` `C` `S` `O`, в зависимости от конкретной команды из сводной таблицы (выше).

Команда|Описание
---|---
ld ***X*** |Читает из RAM в регистр ***X***, используя следующий байт в RAM как адрес.
ld ***X***, ***Y*** |Читает из RAM в регистр ***X***, используя регистр ***Y*** как адрес.
ldi ***X*** |Читает из RAM следующий байт непосредственно в регистр ***X***.
st ***X*** |Пишет в RAM из регистра ***X***, используя следующий байт в RAM как адрес.
st ***X***, ***Y*** |Пишет в RAM из регистра ***X***, используя регистр ***Y*** как адрес.
rnd ***X*** |Генерирует случайный байт и кладёт в регистр ***X***.
jmp|Совершает переход, используя следующий байт в RAM как адрес.
jmp ***X*** |Совершает переход, используя регистр ***X*** как адрес.
j***F*** |Совершает переход, если флаг ***F*** в состоянии 1, используя следующий байт в RAM как адрес.
jn***F*** |Совершает переход, если флаг ***F*** в состоянии 0, используя следующий байт в RAM как адрес.
j***F*** ***X*** |Совершает переход, если флаг ***F*** в состоянии 1, используя регистр ***X*** как адрес.
jn***F*** ***X*** |Совершает переход, если флаг ***F*** в состоянии 0, используя регистр ***X*** как адрес.
hlt|Останавливает выполнение программы.