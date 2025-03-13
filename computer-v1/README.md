# Компьютер из стрелочек <sup><sup>*Gen. 1*</sup></sup>

> [!TIP]
> См. новый **[Компьютер из стрелочек <sup>*Gen. 2*</sup>](../computer-v2/README.md)**.

<br>

<table>
  <thead>
    <tr>
      <td valign="top" width="50%">
        Полноценный компьютер, целиком сделанный из стрелочек. Позволяет создавать и запускать
        различные программы и игры.<br><br>
        <a href="https://logic-arrows.io/map-lVeJ9jtX"><i><b>На карту с компьютером
            →</b></i></a><br><br>
        <a href="specification.md">Устройство и характеристики</a><br><br>
        <a href="programming.md">Программирование</a><br><br>
        <a href="#examples">Готовые программы</a>
      </td>
      <td valign="top">
        <a href="https://logic-arrows.io/map-lVeJ9jtX"><img src="img/summary.jpg"
            alt="Компьютер из стрелочек (Gen. 1)"></a>
      </td>
    </tr>
  </thead>
</table>
<br><br>


## Демонстрация работы
Зайдите на **[карту с компьютером](https://logic-arrows.io/map-lVeJ9jtX).** В ползунке внизу справа
установите максимальную скорость. Нажмите на кнопку, подписанную `Hello world`, чтобы загрузить
соответствующую программу с дискеты в оперативную память. Дождитесь окончания загрузки. Далее
нажмите на кнопку `RUN` и наблюдайте за выполнением программы, в ходе которого на дисплее постепенно
выведется надпись «Hello world» и котик. По окончании выполнения программы загорится лампочка
`DONE`.
<br><br><br>


## <a name="examples"></a>Готовые программы

### Space Fight!
На дисплее внизу располагается твой корабль, а остальная область заполнена врагами. Нужно уничтожить
30 врагов за ограниченное число ходов. Периодически все враги перемещаются к тебе, причём с каждым
разом это происходит всё чаще. Если кто-то из врагов долетит до тебя — ты проиграл. А в случае
победы ты получить главный галактический приз!

[Перейти на карту](https://logic-arrows.io/map-space-fight) &nbsp;|&nbsp;
[Исходный код игры](asm/space-fight.asm)

<a href="asm/space-fight.asm"><img src="img/space-fight.jpg" width="60%" alt="Space Fight!"></a>
<br><br>


<table>
  <thead>
    <tr>
      <td valign="top" width="50%">
        <h3><a href="asm/hello-world.asm">Hello World</a></h3>
        <a href="asm/hello-world.asm"><img src="img/summary.jpg" alt="Hello World"></a><br>
        Выводит на дисплей котика и надпись «Hello world».
      </td>
      <td valign="top">
        <h3><a href="asm/prime-numbers.asm">Prime Numbers</a></h3>
        <a href="asm/prime-numbers.asm"><img src="img/prime-numbers.jpg"
            alt="Prime Numbers"></a><br>
        Находит первые 16 простых чисел и выводит их на дисплей в двоичном формате. Выполнение
        занимает 3691 операцию.
      </td>
    </tr>
    <tr>
      <td valign="top">
        <h3><a href="asm/fibonacci-sequence.asm">Fibonacci Sequence</a></h3>
        <a href="asm/fibonacci-sequence.asm"><img src="img/fibonacci-sequence.jpg"
            alt="Fibonacci Sequence"></a><br>
        Находит 10 чисел Фибоначчи и выводит их на дисплей в двоичном формате.
      </td>
      <td valign="top">
        <h3><a href="asm/typewriter.asm">Typewriter</a></h3>
        <a href="asm/typewriter.asm"><img src="img/terminal.jpg" alt="Typewriter"></a><br>
        Выводит в терминал текст, набираемый на клавиатуре.
      </td>
    </tr>
  </thead>
</table>
