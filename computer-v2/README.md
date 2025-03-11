# Компьютер из стрелочек <sup><sup>*Gen. 2*</sup></sup>
<br>

<table>
  <thead>
    <tr>
      <td valign="top" width="50%">
        Полноценный компьютер, целиком сделанный из стрелочек. Позволяет создавать и запускать
        различные программы и игры.<br><br>
        <a href="https://logic-arrows.io/map-computer"><i><b>На карту с компьютером
            →</b></i></a><br><br>
        <a href="specification.md">Устройство и характеристики</a><br><br>
        <a href="programming.md">Программирование</a><br><br>
        <a href="#examples">Готовые программы</a>
      </td>
      <td valign="top">
        <a href="https://logic-arrows.io/map-computer"><img src="img/summary.jpg"
            alt="Компьютер из стрелочек (Gen. 2)"></a>
      </td>
    </tr>
  </thead>
</table>
<br><br>


## Демонстрация работы
Зайдите на **[карту с компьютером](https://logic-arrows.io/map-computer).** В ползунке внизу справа
установите максимальную скорость. Нажмите на кнопку, подписанную `Demo`, чтобы загрузить
соответствующую программу с дискеты в оперативную память. Во время загрузки на дисплей выведется
цветная бабочка. Дождитесь окончания загрузки. Далее нажмите на кнопку `RUN` и наблюдайте за
выполнением программы, в ходе которого в терминал постепенно выведется надпись «Привет, Онигири!».
По окончании выполнения программы загорится лампочка `DONE`.
<br><br><br>


## <a name="examples"></a>Готовые программы
<table>
  <thead>
    <tr>
      <td valign="top" width="50%">
        <h3><a href="asm/game-of-life.asm">Игра «Жизнь»</a></h3>
        <a href="asm/game-of-life.asm"><img src="img/game-of-life.jpg" alt="Игра «Жизнь»"></a><br>
        В терминал выводится название игры, дисплей заполняется случайным наборов пикселей, а на
        цифровом индикаторе отображается счётчик кадров. Затем запускается бесконечный цикл
        вычислений, на обработку одного кадра уходит около часа.
      </td>
      <td valign="top">
        <h3><a href="asm/space-fight.asm">Игра «Space Fight!»</a></h3>
        <a href="asm/space-fight.asm"><img src="img/space-fight.jpg"
            alt="Игра «Space Fight!»"></a><br>
        На дисплее внизу расположен корабль, а остальная область заполнена врагами. Нужно уничтожить
        30 врагов за ограниченное число ходов. Периодически все враги приближаются к кораблю, причём
        с каждым разом это происходит всё чаще. Если кто-то из врагов долетит до корабля, игра
        проиграна. А в случае победы на дисплей выведется приз.
      </td>
    </tr>
    <tr>
      <td valign="top">
        <h3><a href="asm/demo.asm">Demo</a></h3>
        <a href="asm/demo.asm"><img src="img/demo.jpg" alt="Demo"></a><br>
        Во время загрузки выводит на дисплей цветную бабочку, а при запуске выводит в терминал
        надпись «Привет, Онигири!».
      </td>
      <td valign="top">
        <h3><a href="asm/prime-numbers.asm">Prime Numbers</a></h3>
        <a href="asm/prime-numbers.asm"><img src="img/prime-numbers.jpg"
            alt="Prime Numbers"></a><br>
        Находит первые 16 простых чисел и выводит их на цифровой индикатор, а также на дисплей в
        двоичном формате. Выполнение занимает 3091 операцию.
      </td>
     </tr>
    <tr>
      <td valign="top">
        <h3><a href="asm/fibonacci-sequence.asm">Fibonacci Sequence</a></h3>
        <a href="asm/fibonacci-sequence.asm"><img src="img/fibonacci-sequence.jpg"
            alt="Fibonacci Sequence"></a><br>
        Находит 12 чисел Фибоначчи. Выводит их на цифровой индикатор, а также на дисплей в двоичном
        формате.
      </td>
      <td valign="top">
        <h3><a href="asm/typewriter.asm">Typewriter</a></h3>
        <a href="asm/typewriter.asm"><img src="img/typewriter.jpg" alt="Typewriter"></a><br>
        Выводит в терминал текст, набираемый на клавиатуре.
      </td>
    </tr>
  </thead>
</table>
