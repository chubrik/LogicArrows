# Программирование
Чтобы запустить на компьютере вашу собственную программу, выполните следующие шаги:
- Изучите язык ассемблера на этой странице.
- Откройте [онлайн-компилятор](https://chubrik.github.io/arrows-compiler/) и в его левой части
  напишите программу.
- Скопируйте из правой части скомпилированный код.
- Зайдите на [карту с компьютером](https://logic-arrows.io/map-computer) и нажмите `Ctrl+V`, чтобы
  вставить дискету с программой.
- Подсоедините провод от дискеты к общему проводу от других дискет.
- Нажмите на кнопку у дискеты и дождитесь загрузки программы в память компьютера.
- Нажмите на кнопку `RUN` у компьютера и наблюдайте за ходом выполнения вашей программы.
<br><br><br>


## Общие принципы
Программа состоит из последовательности инструкций и набора данных. Каждая инструкция занимает в
памяти 1 байт. Некоторые инструкции требуют дополнительный операнд, который также занимает 1 байт и
располагается в памяти сразу вслед за инструкцией. Процессор выполняет инструкции друг за другом,
начиная с адреса `00`. Согласно программе, процессор также может совершать переходы к различным
участкам кода, тем самым создавая циклы, подпрограммы и пр.

Выполняя программу, процессор взаимодействует с регистрами `A` `B` `C` `D` и флагами `Z` `S` `C`
`O`. Каждый регистр хранит 1 байт и имеет универсальное назначение. Флаги выражают собой результат
выполнения вычислительных операций и могут использоваться как условия для переходов:
- **Флаг Z (ноль)** показывает, что результат равен нулю.
- **Флаг S (знак)** показывает, что у результата активен старший бит. В знаковой арифметике это
  означает отрицательное число.
- **Флаг C (перенос)** показывает, что во время операции один из битов вышел за пределы байта.
- **Флаг O (переполнение)** показывает, что два операнда имели одинаковый старший бит, но в
  результате операции он изменился. В знаковой арифметике это означает выход за допустимый диапазон.
<br><br><br>


## Синтаксис
Для наилучшего понимания ассемблера и его синтаксиса ознакомьтесь с [примерами программ](asm),
созданных автором компьютера. Здесь рассмотрим основные моменты:
```asm
MY_CONST equ 196                ; Объявляем константу MY_CONST со значением 196 при помощи ключевого
                                ; слова "equ". В качестве значений в любом месте кода можно исполь-
                                ; зовать числа от 0 до 255 в десятичной (196), шестнадцатеричной
                                ; (0xC4), восьмеричной (0304) или двоичной (0b11000100) форме. Также
                                ; можно использовать символ в кавычках ("Д"), что аналогично числу
                                ; в кодировке cp1251.

ldi a, MY_CONST                 ; При сборке кода "MY_CONST" заменяется на конечное значение,
                                ; поэтому фактически программа выполнит "ldi a, 196"

my_label:                       ; Объявляем метку, она обозначает текущий адрес в коде
  inc a
  jnz my_label                  ; Программа совершит переход к метке my_label, т.е. возникнет цикл

my_data db 1, 2, 3, 0x4, "абв"  ; Объявляем область данных при помощи ключевого слова "db". Метка
                                ; my_data обозначает адрес начала этой области. В качестве данных
                                ; через запятую можно указывать числа, константы, метки и строки.

my_data_size equ $ - my_data    ; "$" обозначает текущий адрес в коде. Вычитая адрес my_data,
                                ; получаем размер области данных, что и присваиваем константе
                                ; my_data_size.
```
<br><br>


## Инструкции

### Управляющие инструкции
Инструкции из этого набора отвечают за работу с памятью и переходы. В таблице ниже используются
условные ***X*** и ***Y*** для обозначения любых регистров, а также ***F*** для обозначения любого
флага.

Инструкция | Описание
---|---
nop | Ничего не делает, переходит к следующей инструкции
ld ***X*** | Загружает в ***X*** значение из памяти, используя операнд как адрес
ld ***X***, ***Y*** | Загружает в ***X*** значение из памяти, используя ***Y*** как адрес
ldi ***X*** | Загружает операнд непосредственно в ***X***
st ***X*** | Сохраняет значение ***X*** в память по адресу из операнда
st ***X***, ***Y*** | Сохраняет значение ***X*** в память по адресу из ***Y***
jmp | Безусловный переход по адресу из операнда
jmp ***X*** | Безусловный переход по адресу из ***X***
j***F*** | Переход по адресу из операнда, если ***F*** = 1
jn***F*** | Переход по адресу из операнда, если ***F*** = 0
j***F*** ***X*** | Переход по адресу из ***X***, если ***F*** = 1
jn***F*** ***X*** | Переход по адресу из ***X***, если ***F*** = 0
hlt | Завершает выполнение программы

<br>


### Вычислительные инструкции
Инструкции из этого набора производят вычисления на основе регистров и воздействуют на флаги. В
таблице ниже используются условные ***X*** и ***Y*** для обозначения любых регистров.

Инструкция | Описание | Воздействие<br> на флаги
---|---|---
clr ***X*** | Обнуляет ***X*** | –
mov ***X***, ***Y*** | Копирует из ***Y*** в ***X*** | –
and ***X***, ***Y*** | Побитовое И между ***X*** и ***Y***, результат записывает в ***X*** | Z, S
or ***X***, ***Y*** | Побитовое ИЛИ между ***X*** и ***Y***, результат записывает в ***X*** | Z, S
xor ***X***, ***Y*** | Исключающее ИЛИ между ***X*** и ***Y***, результат записывает в ***X*** | Z, S
add ***X***, ***Y*** | Складывает ***X*** и ***Y***, результат записывает в ***X*** | Z, S, C, O
adc ***X***, ***Y*** | Складывает ***X***, ***Y*** и флаг `C`, результат записывает в ***X*** | Z, S, C, O
sub ***X***, ***Y*** | Из ***X*** вычитает ***Y***, результат записывает в ***X*** | Z, S, C, O
sbb ***X***, ***Y*** | Из ***X*** вычитает ***Y*** и флаг `C`, результат записывает в ***X*** | Z, S, C, O
test ***X*** | Обновляет флаги по значению ***X*** | Z, S
inc ***X*** | Прибавляет 1 | Z, S
dec ***X*** | Вычитает 1 | Z, S
not ***X*** | Заменяет каждый бит на противоположный | Z, S
neg ***X*** | Меняет знак (значение трактует как число со знаком) | Z, S
rnd ***X*** | Генерирует случайное значение | Z, S
shl ***X*** | Сдвигает все биты на один влево, правый бит обнуляет | Z, S, C
shr ***X*** | Сдвигает все биты на один вправо, левый бит обнуляет | Z, S, C
sar ***X*** | Сдвигает все биты на один вправо, левый бит не меняет | Z, S, C
rcl ***X*** | Сдвигает все биты на один влево, правый бит берёт из флага `С` | Z, S, C
rcr ***X*** | Сдвигает все биты на один вправо, левый бит берёт из флага `С` | Z, S, C

<br>


### Таблица инструкций
Каждая инструкция имеет свой код (opcode). К примеру, `st a, d` имеет код `3C` (ряд,
затем колонка).
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
      <td align="center">nop</td><td align="center">hlt</td><td align="center">–</td><td align="center">jmp</td>
      <td align="center">jmp a</td><td align="center">jmp b</td><td align="center">jmp c</td><td align="center">jmp d</td>
      <td align="center">jz</td><td align="center">js</td><td align="center">jc</td><td align="center">jo</td>
      <td align="center">jnz</td><td align="center">jns</td><td align="center">jnc</td><td align="center">jno</td>
    </tr>
    <tr>
      <th>1</th>
      <td align="center">jz a</td><td align="center">js a</td><td align="center">jc a</td><td align="center">jo a</td>
      <td align="center">jz b</td><td align="center">js b</td><td align="center">jc b</td><td align="center">jo b</td>
      <td align="center">jz c</td><td align="center">js c</td><td align="center">jc c</td><td align="center">jo c</td>
      <td align="center">jz d</td><td align="center">js d</td><td align="center">jc d</td><td align="center">jo d</td>
    </tr>
    <tr>
      <th>2</th>
      <td align="center">jnz a</td><td align="center">jns a</td><td align="center">jnc a</td><td align="center">jno a</td>
      <td align="center">jnz b</td><td align="center">jns b</td><td align="center">jnc b</td><td align="center">jno b</td>
      <td align="center">jnz c</td><td align="center">jns c</td><td align="center">jnc c</td><td align="center">jno c</td>
      <td align="center">jnz d</td><td align="center">jns d</td><td align="center">jnc d</td><td align="center">jno d</td>
    </tr>
    <tr>
      <th>3</th>
      <td align="center">st a</td><td align="center">st b, a</td><td align="center">st c, a</td><td align="center">st d, a</td>
      <td align="center">st a, b</td><td align="center">st b</td><td align="center">st c, b</td><td align="center">st d, b</td>
      <td align="center">st a, c</td><td align="center">st b, c</td><td align="center">st c</td><td align="center">st d, c</td>
      <td align="center">st a, d</td><td align="center">st b, d</td><td align="center">st c, d</td><td align="center">st d</td>
    </tr>
    <tr>
      <th>4</th>
      <td align="center">ld a, a</td><td align="center">ld b, a</td><td align="center">ld c, a</td><td align="center">ld d, a</td>
      <td align="center">ld a, b</td><td align="center">ld b, b</td><td align="center">ld c, b</td><td align="center">ld d, b</td>
      <td align="center">ld a, c</td><td align="center">ld b, c</td><td align="center">ld c, c</td><td align="center">ld d, c</td>
      <td align="center">ld a, d</td><td align="center">ld b, d</td><td align="center">ld c, d</td><td align="center">ld d, d</td>
    </tr>
    <tr>
      <th>5</th>
      <td align="center">ld a</td><td align="center">ld b</td><td align="center">ld c</td><td align="center">ld d</td>
      <td align="center">ldi a</td><td align="center">ldi b</td><td align="center">ldi c</td><td align="center">ldi d</td>
      <td align="center" colspan="8"><i>reserved</i></td>
    </tr>
    <tr>
      <th>6</th>
      <td align="center">inc a</td><td align="center">add b, a</td><td align="center">add c, a</td><td align="center">add d, a</td>
      <td align="center">add a, b</td><td align="center">inc<br> b</td><td align="center">add c, b</td><td align="center">add d, b</td>
      <td align="center">add a, c</td><td align="center">add b, c</td><td align="center">inc<br> c</td><td align="center">add d, c</td>
      <td align="center">add a, d</td><td align="center">add b, d</td><td align="center">add c, d</td><td align="center">inc<br> d</td>
    </tr>
    <tr>
      <th>7</th>
      <td align="center">dec a</td><td align="center">sub b, a</td><td align="center">sub c, a</td><td align="center">sub d, a</td>
      <td align="center">sub a, b</td><td align="center">dec b</td><td align="center">sub c, b</td><td align="center">sub d, b</td>
      <td align="center">sub a, c</td><td align="center">sub b, c</td><td align="center">dec c</td><td align="center">sub d, c</td>
      <td align="center">sub a, d</td><td align="center">sub b, d</td><td align="center">sub c, d</td><td align="center">dec d</td>
    </tr>
    <tr>
      <th>8</th>
      <td align="center">not a</td><td align="center">adc b, a</td><td align="center">adc c, a</td><td align="center">adc d, a</td>
      <td align="center">adc a, b</td><td align="center">not b</td><td align="center">adc c, b</td><td align="center">adc d, b</td>
      <td align="center">adc a, c</td><td align="center">adc b, c</td><td align="center">not c</td><td align="center">adc d, c</td>
      <td align="center">adc a, d</td><td align="center">adc b, d</td><td align="center">adc c, d</td><td align="center">not d</td>
    </tr>
    <tr>
      <th>9</th>
      <td align="center">neg a</td><td align="center">sbb b, a</td><td align="center">sbb c, a</td><td align="center">sbb d, a</td>
      <td align="center">sbb a, b</td><td align="center">neg b</td><td align="center">sbb c, b</td><td align="center">sbb d, b</td>
      <td align="center">sbb a, c</td><td align="center">sbb b, c</td><td align="center">neg c</td><td align="center">sbb d, c</td>
      <td align="center">sbb a, d</td><td align="center">sbb b, d</td><td align="center">sbb c, d</td><td align="center">neg d</td>
    </tr>
    <tr>
      <th>A</th>
      <td align="center">clr a</td><td align="center">mov b, a</td><td align="center">mov c, a</td><td align="center">mov d, a</td>
      <td align="center">mov a, b</td><td align="center">clr b</td><td align="center">mov c, b</td><td align="center">mov d, b</td>
      <td align="center">mov a, c</td><td align="center">mov b, c</td><td align="center">clr c</td><td align="center">mov d, c</td>
      <td align="center">mov a, d</td><td align="center">mov b, d</td><td align="center">mov c, d</td><td align="center">clr d</td>
    </tr>
    <tr>
      <th>B</th>
      <td align="center">test a</td><td align="center">and b, a</td><td align="center">and c, a</td><td align="center">and d, a</td>
      <td align="center">and a, b</td><td align="center">test b</td><td align="center">and c, b</td><td align="center">and d, b</td>
      <td align="center">and a, c</td><td align="center">and b, c</td><td align="center">test c</td><td align="center">and d, c</td>
      <td align="center">and a, d</td><td align="center">and b, d</td><td align="center">and c, d</td><td align="center">test d</td>
    </tr>
    <tr>
      <th>C</th>
      <td align="center">rcl a</td><td align="center">or b, a</td><td align="center">or c, a</td><td align="center">or d, a</td>
      <td align="center">or a, b</td><td align="center">rcl b</td><td align="center">or c, b</td><td align="center">or d, b</td>
      <td align="center">or a, c</td><td align="center">or b, c</td><td align="center">rcl c</td><td align="center">or d, c</td>
      <td align="center">or a, d</td><td align="center">or b, d</td><td align="center">or c, d</td><td align="center">rcl d</td>
    </tr>
    <tr>
      <th>D</th>
      <td align="center">rcr a</td><td align="center">xor b, a</td><td align="center">xor c, a</td><td align="center">xor d, a</td>
      <td align="center">xor a, b</td><td align="center">rcr b</td><td align="center">xor c, b</td><td align="center">xor d, b</td>
      <td align="center">xor a, c</td><td align="center">xor b, c</td><td align="center">rcr c</td><td align="center">xor d, c</td>
      <td align="center">xor a, d</td><td align="center">xor b, d</td><td align="center">xor c, d</td><td align="center">rcr d</td>
    </tr>
    <tr>
      <th>E</th>
      <td align="center">shl a</td><td align="center">shl b</td><td align="center">shl c</td><td align="center">shl d</td>
      <td align="center">shr a</td><td align="center">shr b</td><td align="center">shr c</td><td align="center">shr d</td>
      <td align="center">sar a</td><td align="center">sar b</td><td align="center">sar c</td><td align="center">sar d</td>
      <td align="center">rnd a</td><td align="center">rnd b</td><td align="center">rnd c</td><td align="center">rnd d</td>
    </tr>
    <tr>
      <th>F</th>
      <td align="center" colspan="16"><i>reserved</i></td>
    </tr>
  </tbody>
</table>
