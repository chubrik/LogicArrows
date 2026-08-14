# Компьютер v2
🌐 [English](../../computer-v2/README.md) | Русский
<br><br>

<table>
  <thead>
    <tr>
      <td valign="top" width="50%">
        Полноценный компьютер, целиком собранный из стрелочек: 8-битный процессор, до 32 КБ памяти,
        клавиатура, цветной дисплей, терминал, цифровой индикатор и набор дискет с программами и
        играми, созданными в том числе участниками сообщества.<br><br>
        <a href="https://logic-arrows.io/map-computer"><b>Карта с компьютером</b></a><br><br>
        <a href="specification.md">Устройство и характеристики</a><br><br>
        <a href="programming.md">Программирование</a><br><br>
        <a href="#examples">Готовые программы</a>
      </td>
      <td valign="top">
        <a href="https://logic-arrows.io/map-computer"><img src="../../computer-v2/img/summary.jpg"
          alt="Компьютер v2"></a>
      </td>
    </tr>
  </thead>
</table>
<br>


## Демонстрация работы
Зайдите на [карту с компьютером](https://logic-arrows.io/map-computer). В нижнем ползунке установите
максимальную скорость. Нажмите на кнопку `Demo` и дождитесь загрузки программы в память компьютера.
Во время загрузки на дисплей будет выведена цветная бабочка. Далее нажмите на кнопку `RUN` и
наблюдайте, как программа в терминале напишет «Hello, Onigiri!», нарисует изображение онигири и
позвонит в колокольчик. По окончании загорится лампочка `DONE`.

Чтобы запустить на компьютере вашу собственную программу, см. [Программирование](programming.md).
<br><br><br>


## <a name="examples"></a>Готовые программы
<table>
  <thead>
    <tr>
      <td valign="top" width="50%">
        <h3><a href="asm/tetris.asm">Игра «Тетрис»</a></h3>
        <a href="asm/tetris.asm"><img src="../../computer-v2/img/tetris.jpg"
          alt="Игра «Тетрис»"></a><br>
        Заполняйте ряды и повышайте счёт. Классическая игра-головоломка с цветной графикой.
      </td>
      <td valign="top">
        <h3><a href="asm/game-of-life.asm">Игра «Жизнь»</a></h3>
        <a href="asm/game-of-life.asm"><img src="../../computer-v2/img/game-of-life.jpg"
          alt="Игра «Жизнь»"></a><br>
        Заполняет дисплей случайными пикселями и вычисляет последующие поколения
      </td>
    </tr>
    <tr>
      <td valign="top">
        <h3><a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20snake.asm">
          Игра «Змейка»</a></h3>
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20snake.asm">
          <img src="../../computer-v2/img/snake.jpg" alt="Игра «Змейка»"></a><br>
        Собирайте яблоки и не врезайтесь в собственный хвост. Автор —
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows">
        Михаил Мосеев</a>.
      </td>
      <td valign="top">
        <h3><a href="asm/space-fight.asm">Игра «Space Fight»</a></h3>
        <a href="asm/space-fight.asm"><img src="../../computer-v2/img/space-fight.jpg"
          alt="Игра «Space Fight»"></a><br>
        К вам приближаются вражеские корабли, которые нужно сбить за ограниченное время. В случае
        победы вы получите приз.
      </td>
    </tr>
    <tr>
      <td valign="top">
        <h3><a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20minesweeper.asm">
          Игра «Сапёр»</a></h3>
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20minesweeper.asm">
          <img src="../../computer-v2/img/minesweeper.jpg" alt="Игра «Сапёр»"></a><br>
        Открывайте клетки, ориентируясь по цифрам, и не подорвитесь на мине. Автор —
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows">
        Михаил Мосеев</a>.
      </td>
      <td valign="top">
        <h3><a href="asm/guess-number.asm">Игра «Угадай число»</a></h3>
        <a href="asm/guess-number.asm"><img src="../../computer-v2/img/guess-number.jpg"
          alt="Игра «Угадай число»"></a><br>
        Угадывайте числа по правилу «больше/меньше» и повышайте общий счёт побед
      </td>
    </tr>
    <tr>
      <td valign="top">
        <h3><a href="../../computer-v2/asm/community/maze-generator.asm">Maze Generator</a></h3>
        <a href="../../computer-v2/asm/community/maze-generator.asm">
          <img src="../../computer-v2/img/maze-generator.jpg" alt="Maze Generator"></a><br>
        Генерирует на дисплее случайный лабиринт методом поиска с возвратом. Автор —
        <a href="https://t.me/farmer_2010">Farmer_2010</a>.
      </td>
      <td valign="top">
        <h3><a href="../../computer-v2/asm/community/1d-cellular-automaton.asm">
          1D Cellular Automaton</a></h3>
        <a href="../../computer-v2/asm/community/1d-cellular-automaton.asm">
          <img src="../../computer-v2/img/1d-cellular-automaton.jpg"
            alt="1D Cellular Automaton"></a><br>
        Введите правило в двоичном виде и наблюдайте за эволюцией клеток на дисплее. Автор —
        <a href="https://t.me/farmer_2010">Farmer_2010</a>.
      </td>
    </tr>
    <tr>
      <td valign="top">
        <h3><a href="asm/demo.asm">Demo</a></h3>
        <a href="asm/demo.asm"><img src="../../computer-v2/img/summary.jpg" alt="Demo"></a><br>
        Выводит на дисплей цветную бабочку, пишет в терминал «Hello, Onigiri!», рисует изображение
        онигири и звонит в колокольчик
      </td>
      <td valign="top">
        <h3><a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20tennis.asm">
          Игра «Теннис»</a></h3>
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20tennis.asm">
          <img src="../../computer-v2/img/tennis.jpg" alt="Игра «Теннис»"></a><br>
        Отбивайте мяч платформой, не давая ему упасть. Автор —
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows">
        Михаил Мосеев</a>.
      </td>
    </tr>
    <tr>
      <td valign="top">
        <h3><a href="asm/prime-numbers.asm">Prime Numbers</a></h3>
        <a href="asm/prime-numbers.asm"><img src="../../computer-v2/img/prime-numbers.jpg"
          alt="Prime Numbers"></a><br>
        Находит 16 простых чисел и выводит их на цифровой индикатор, а также на дисплей в двоичном
        формате
      </td>
      <td valign="top">
        <h3><a href="asm/fibonacci-sequence.asm">Fibonacci Sequence</a></h3>
        <a href="asm/fibonacci-sequence.asm"><img src="../../computer-v2/img/fibonacci-sequence.jpg"
          alt="Fibonacci Sequence"></a><br>
        Находит 12 чисел Фибоначчи. Выводит их на цифровой индикатор, а также на дисплей в двоичном
        формате
      </td>
    </tr>
    <tr>
      <td valign="top">
        <h3><a href="asm/terminal-art.asm">Terminal Art</a></h3>
        <a href="asm/terminal-art.asm"><img src="../../computer-v2/img/terminal-art.jpg"
          alt="Terminal Art"></a><br>
        Использует графический режим терминала для вывода изображения
      </td>
      <td valign="top">
        <h3><a href="asm/ram-art.asm">RAM Art</a></h3>
        <a href="asm/ram-art.asm"><img src="../../computer-v2/img/ram-art.jpg"
          alt="RAM Art"></a><br>
        Программа-шутка, использует RAM как холст для вывода изображения
      </td>
    </tr>
    <tr>
      <td valign="top">
        <h3><a href="asm/typewriter.asm">Typewriter</a></h3>
        <a href="asm/typewriter.asm"><img src="../../computer-v2/img/typewriter.jpg"
          alt="Typewriter"></a><br>
        Выводит в терминал текст, набираемый на клавиатуре
      </td>
      <td valign="top">
        <h3><a href="asm/font-test.asm">Font Test</a></h3>
        <a href="asm/font-test.asm"><img src="../../computer-v2/img/font-test.jpg"
          alt="Font Test"></a><br>
        Выводит в терминал все возможные символы (кодировка
        <a href="https://ru.wikipedia.org/wiki/Windows-1251">cp1251</a>)
      </td>
    </tr>
  </thead>
</table>
