# Компьютер из стрелочек <sup>*Gen. 2*</sup>
<br>

<table>
  <thead>
    <tr>
      <td valign="top" width="50%">
        Полноценный компьютер, целиком сделанный из стрелочек. Позволяет создавать и запускать
        различные программы и игры.<br><br>
        <a href="https://logic-arrows.io/map-computer"><b>Карта с компьютером</b></a><br><br>
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
<br>


## Демонстрация работы
Зайдите на [карту с компьютером](https://logic-arrows.io/map-computer). В нижнем ползунке установите
максимальную скорость. Нажмите на кнопку `Demo` и дождитесь загрузки программы в память компьютера.
Во время загрузки на дисплей будет выведена цветная бабочка. Далее нажмите на кнопку `RUN` и
наблюдайте, как программа в терминале напишет «Привет, Онигири!», нарисует изображение онигири и
трижды позвонит в колокольчик. По окончании загорится лампочка `DONE`. Чтобы запустить на компьютере
вашу собственную программу, см. [Программирование](programming.md).
<br><br><br>


## <a name="examples"></a>Готовые программы
<table>
  <thead>
    <tr>
      <td valign="top" width="50%">
        <h3><a href="asm/tetris.asm">Игра «Тетрис»</a></h3>
        <a href="asm/tetris.asm"><img src="img/tetris.jpg" alt="Игра «Тетрис»"></a><br>
        Классическая компьютерная игра-головоломка.<br><br>
        Программа занимает 888 байт.
      </td>
      <td valign="top">
        <h3><a href="asm/game-of-life.asm">Игра «Жизнь»</a></h3>
        <a href="asm/game-of-life.asm"><img src="img/game-of-life.jpg" alt="Игра «Жизнь»"></a><br>
        Дисплей заполняет случайный набор пикселей, и запускается вычисление следующих поколений.<br><br>
        Программа занимает 512 байт.
      </td>
    </tr>
    <tr>
      <td valign="top" width="50%">
        <h3><a href="asm/space-fight.asm">Игра «Space Fight!»</a></h3>
        <a href="asm/space-fight.asm"><img src="img/space-fight.jpg"
            alt="Игра «Space Fight!»"></a><br>
        Внизу дисплея расположен корабль, а остальная область заполнена врагами. Нужно сбить 30
        врагов за ограниченное время. Враги приближаются с нарастающей скоростью, и, если враг
        достигнет корабля, игра проиграна. В случае победы на дисплее появится приз.<br><br>
        Программа занимает 256 байт.
      </td>
      <td valign="top">
        <h3><a href="asm/demo.asm">Demo</a></h3>
        <a href="asm/demo.asm"><img src="img/summary.jpg" alt="Demo"></a><br>
        Во время загрузки выводит на дисплей цветную бабочку. При запуске пишет в терминал
        «Привет, Онигири!», рисует изображение онигири и звонит в колокольчик.
      </td>
    </tr>
    <tr>
      <td valign="top">
        <h3><a href="asm/prime-numbers.asm">Prime Numbers</a></h3>
        <a href="asm/prime-numbers.asm"><img src="img/prime-numbers.jpg"
            alt="Prime Numbers"></a><br>
        Находит первые 16 простых чисел и выводит их на цифровой индикатор, а также на дисплей в
        двоичном формате. Выполнение занимает 3091 операцию.
      </td>
      <td valign="top">
        <h3><a href="asm/fibonacci-sequence.asm">Fibonacci Sequence</a></h3>
        <a href="asm/fibonacci-sequence.asm"><img src="img/fibonacci-sequence.jpg"
            alt="Fibonacci Sequence"></a><br>
        Находит 12 чисел Фибоначчи. Выводит их на цифровой индикатор, а также на дисплей в двоичном
        формате.
      </td>
     </tr>
    <tr>
      <td valign="top">
        <h3><a href="asm/typewriter.asm">Typewriter</a></h3>
        <a href="asm/typewriter.asm"><img src="img/typewriter.jpg" alt="Typewriter"></a><br>
        Выводит в терминал текст, набираемый на клавиатуре.
      </td>
      <td valign="top">
        <h3><a href="asm/font-test.asm">Font Test</a></h3>
        <a href="asm/font-test.asm"><img src="img/font-test.jpg" alt="Font Test"></a><br>
        Выводит в терминал все возможные символы (кодировка
        <a href="https://ru.wikipedia.org/wiki/Windows-1251">cp1251</a>).
      </td>
    </tr>
  </thead>
</table>
