﻿### [← В начало](../README.md)

# Компьютер из стрелочек v1
[Перейти на карту →](https://logic-arrows.io/map-lVeJ9jtX)

[![Компьютер из стрелочек v1](../img/computer-v1.jpg)](https://logic-arrows.io/map-lVeJ9jtX)

Полноценный компьютер, состоящий из процессора, оперативной памяти, ввода/вывода и набора программ. Характеристики:
- 8-битная архитектура, процессор с 4 регистрами и флагами
- 256 байт RAM с интегрированной видеопамятью, других видов памяти нет
- Собственный язык ассемблера (см. ниже)
- Возможность подключать множество средств ввода и вывода и программно переключаться между ними
- Возможность загружать в RAM разный исполняемый код со специальных «дискет»
<br><br><br>


## Содержание
[Демонстрация работы](#demo)

Устройство:
- [Процессор](#cpu)
- [Оперативная память](#ram)
- [Система ввода](#input)
- [Система вывода](#output)

[Создание программ](#programming)

[Примеры готовых программ](#examples)
<br><br><br>


## <a name="demo"></a>Демонстрация работы
Зайдите на [карту](https://logic-arrows.io/map-lVeJ9jtX) с компьютером. В ползунке внизу справа установите максимальную скорость. Нажмите на кнопку, подписанную `Hello world`, чтобы загрузить соответствующую программу с дискеты в оперативную память. Дождитесь окончания загрузки. Далее нажмите на кнопку `RUN` и наблюдайте выполнение программы, в процессе которого на пиксельном дисплее слева постепенно выведется надпись «Hello world» и котик. По окончании выполнения программы загорится лампочка `DONE`.
<br><br><br>


## <a name="cpu"></a>Процессор
Процессор состоит из двух частей: управляющей и вычислительной (ALU). Управляющая часть состоит из указателя операции `IP`, регистра операции `IR`, блока управления и 4 свободных регистров `A` `B` `C` `D`. Вычислительная часть состоит из регистра операции `IR`, 4 флагов `Z` `C` `S` `O`, блока управления и исполняющих механизмов, включающих многофункциональный сумматор.

Процессор читает команду из RAM по адресу, лежащему в `IP`, после чего `IP` инкрементируется. Прочитанная команда попадает в `IR`, и блоки управления инициируют ту или иную операцию. Некоторые команды требуют дополнительного аргумента, который читается из RAM по адресу, следующему за командой. Команды активно работают с регистрами `A` `B` `C` `D`, подготавливая данные для ALU.

Типичная операция ALU читает информацию из двух регистров, производит между ними вычисление и сохраняет результат в один из этих же регистров. Также, в зависимости от типа вычисления ALU выставляет или сбрасывает те или иные флаги. Эти флаги впоследствии могут быть использованы программой в качестве условия для принятия решений.

Подробнее см. [Программирование](programming.md).

![Процессор](../img/computer-v1-cpu.jpg)
<br><br><br>


## <a name="ram"></a>Оперативная память
Единственной памятью компьютера является RAM на 256 байт. Единицей хранимой информации является 1 байт, адрес доступа к памяти также представляет собой 1 байт.

Адрес `3E` подключён к системе ввода. По этому адресу всегда можно прочитать актуальную информацию, например, о нажатой клавише на клавиатуре.

Адрес `3F` подключён к управлению выводом. К примеру, если записать по этому адресу байт `80`, то вывод переключится на пиксельный дисплей.

Адреса `40...7F` являются совмещённой видеопамятью. Запись по этим адресам может параллельно воздействовать на текущее средство вывода, в зависимости от его типа.

![Оперативная память](../img/computer-v1-ram.jpg)
<br><br><br>


## <a name="input"></a>Система ввода
Представлена клавиатурой, где у каждой клавиши есть уникальный код. При нажатии на любую клавишу, её код попадает в RAM по адресу `3E`, откуда он в любой момент может быть прочитан программой. Если необходимо определить повторное нажатие на одну и ту же клавишу, то после определения первого нажатия программе следует самостоятельно в RAM сбросить значение адреса `3E`.
<br><br><br>


## <a name="output"></a>Система вывода

### Пиксельный дисплей
Для переключения вывода на пиксельный дисплей необходимо в RAM по адресу `3F` записать байт `80`. Ниже показано адресное пространство дисплея. Запись в RAM по адресу из этого пространства будет приводить к появлению на дисплее пикселей, соответствующих записанным битам.

![Пиксельный дисплей](../img/computer-v1-display.jpg)
<br>

### Терминал
Для переключения вывода на терминал необходимо в RAM по адресу `3F` записать байт `40`. Далее, каждый байт, записанный в RAM по адресу `40`, будет выводиться на терминал в виде символа в кодировке [cp1251](https://ru.wikipedia.org/wiki/Windows-1251), сдигая все предыдущие символы влево.

![Терминал](../img/computer-v1-terminal.jpg)
<br>
<br><br><br>


## <a name="programming"></a>Создание программ
Чтобы запустить на компьютере вашу собственную программу, нужно выполнить следующие шаги:
- Изучить язык ассемблера на странице [Программирование](programming.md).
- Написать на ассемблере саму программу.
- Открыть специальный [онлайн-компилятор](https://github.com/GulgDev/chubrik-compiler/tree/main) и вставить программу в его левую часть.
- Устранить в программе все ошибки, о которых компилятор сообщит в своей правой части.
- После устранения ошибок правая часть заполнится скомпилированным кодом, который нужно целиком скопировать.
- Далее, зайти на карту с [компьютером](https://logic-arrows.io/map-lVeJ9jtX) и в свободном месте нажать Ctrl+V, при этом на карту вставится дискета с вашей программой.
- Подсоединить провод, выходящий из дискеты к проводу, идущему от других дискет.
- Включить у карты максимальную скорость.
- Нажать на кнопку внизу слева у вашей дискеты и дождаться окончания загрузки программы в память компьютера.
- Нажать у компьютера на кнопку `RUN` и наблюдать ход выполнения вашей программы.
<br><br><br>


## <a name="examples"></a>Примеры готовых программ
См. [Примеры готовых программ](examples.md).