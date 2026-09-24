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
        <ul>
          <li><a href="https://logic-arrows.io/map-computer"><b>Карта с компьютером ⇾</b></a></li>
        </ul>
        <ul>
          <li><a href="specification.md">Устройство и характеристики</a></li>
          <li><a href="programming.md">Программирование</a></li>
          <li><a href="#examples">Готовые программы</a></li>
          <li><a href="#links">Ссылки</a></li>
        </ul>
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
      <td valign="top" width="33%">
        <a href="asm/tetris.asm">
          <img src="../../computer-v2/img/tetris.jpg" alt="Игра «Тетрис»"><br>
          <b>Игра «Тетрис»</b>
        </a><br>
        Заполняйте ряды и повышайте счёт. Классическая игра-головоломка с цветной графикой.<br><br>
      </td>
      <td valign="top" width="33%">
        <a href="asm/game-of-life.asm">
          <img src="../../computer-v2/img/game-of-life.jpg" alt="Игра «Жизнь»"><br>
          <b>Игра «Жизнь»</b>
        </a><br>
        Заполняет дисплей случайными пикселями и вычисляет последующие поколения<br><br>
      </td>
      <td valign="top" width="33%">
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%203d%20maze.asm">
          <img src="../../computer-v2/img/3d-maze.jpg" alt="Игра «3D-лабиринт»"><br>
          <b>Игра «3D-лабиринт»</b>
        </a><br>
        Найдите выход из лабиринта, глядя от первого лица. Трёхмерная графика строится через
        рейкастинг. Автор — <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows">
        Михаил Мосеев</a>.<br><br>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <a href="asm/community/arkanoid.asm">
          <img src="../../computer-v2/img/arkanoid.jpg" alt="Игра «Арканоид»"><br>
          <b>Игра «Арканоид»</b>
        </a><br>
        Отбивайте мяч платформой, чтобы разбить все блоки на экране. Автор —
        <a href="https://github.com/farmer2010">Farmer_2010</a>.<br><br>
      </td>
      <td valign="top">
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20snake.asm">
          <img src="../../computer-v2/img/snake.jpg" alt="Игра «Змейка»"><br>
          <b>Игра «Змейка»</b>
        </a><br>
        Собирайте яблоки и не врезайтесь в собственный хвост. Автор —
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows">
        Михаил Мосеев</a>.<br><br>
      </td>
      <td valign="top">
        <a href="asm/space-fight.asm">
          <img src="../../computer-v2/img/space-fight.jpg" alt="Игра «Бой в космосе»"><br>
          <b>Игра «Бой в космосе»</b>
        </a><br>
        К вам приближаются вражеские корабли, которые нужно сбить за ограниченное время. В случае
        победы вы получите приз.<br><br>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20minesweeper.asm">
          <img src="../../computer-v2/img/minesweeper.jpg" alt="Игра «Сапёр»"><br>
          <b>Игра «Сапёр»</b>
        </a><br>
        Открывайте клетки, ориентируясь по цифрам, и не подорвитесь на мине. Автор —
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows">
        Михаил Мосеев</a>.<br><br>
      </td>
      <td valign="top">
        <a href="asm/guess-number.asm">
          <img src="../../computer-v2/img/guess-number.jpg" alt="Игра «Угадай число»"><br>
          <b>Игра «Угадай число»</b>
        </a><br>
        Угадывайте числа по правилу «больше/меньше» и повышайте общий счёт побед<br><br>
      </td>
      <td valign="top">
        <a href="asm/community/maze-generator.asm">
          <img src="../../computer-v2/img/maze-generator.jpg" alt="Генератор лабиринтов"><br>
          <b>Генератор лабиринтов</b>
        </a><br>
        Генерирует на дисплее случайный лабиринт методом поиска с возвратом. Автор —
        <a href="https://github.com/farmer2010">Farmer_2010</a>.<br><br>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <a href="asm/community/1d-cellular-automaton.asm">
          <img src="../../computer-v2/img/1d-cellular-automaton.jpg" alt="1D клеточный автомат"><br>
          <b>1D клеточный автомат</b>
        </a><br>
        Введите правило в двоичном виде и наблюдайте за эволюцией клеток на дисплее. Автор —
        <a href="https://github.com/farmer2010">Farmer_2010</a>.<br><br>
      </td>
      <td valign="top">
        <a href="asm/community/langton-ant.asm">
          <img src="../../computer-v2/img/langton-ant.jpg" alt="Муравей Лэнгтона"><br>
          <b>Муравей Лэнгтона</b>
        </a><br>
        Муравей ползает по дисплею, перекрашивает клетки и поворачивает по простому правилу,
        порождая сложный узор. Автор —
        <a href="https://github.com/farmer2010">Farmer_2010</a>.<br><br>
      </td>
      <td valign="top">
        <a href="asm/demo.asm">
          <img src="../../computer-v2/img/summary.jpg" alt="Демо"><br>
          <b>Демо</b>
        </a><br>
        Выводит на дисплей цветную бабочку, пишет в терминал «Hello, Onigiri!», рисует изображение
        онигири и звонит в колокольчик<br><br>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20tennis.asm">
          <img src="../../computer-v2/img/tennis.jpg" alt="Игра «Теннис»"><br>
          <b>Игра «Теннис»</b>
        </a><br>
        Отбивайте мяч платформой, не давая ему упасть и зарабатывая очки. Автор —
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows">
        Михаил Мосеев</a>.<br><br>
      </td>
      <td valign="top">
        <a href="asm/prime-numbers.asm">
          <img src="../../computer-v2/img/prime-numbers.jpg" alt="Простые числа"><br>
          <b>Простые числа</b>
        </a><br>
        Находит 16 простых чисел и выводит их на цифровой индикатор, а также на дисплей в двоичном
        формате<br><br>
      </td>
      <td valign="top">
        <a href="asm/fibonacci-sequence.asm">
          <img src="../../computer-v2/img/fibonacci-sequence.jpg" alt="Числа Фибоначчи"><br>
          <b>Числа Фибоначчи</b>
        </a><br>
        Находит 12 чисел Фибоначчи. Выводит их на цифровой индикатор, а также на дисплей в двоичном
        формате<br><br>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <a href="asm/terminal-art.asm">
          <img src="../../computer-v2/img/terminal-art.jpg" alt="Арт в терминале"><br>
          <b>Арт в терминале</b>
        </a><br>
        Использует графический режим терминала для вывода изображения<br><br>
      </td>
      <td valign="top">
        <a href="asm/ram-art.asm">
          <img src="../../computer-v2/img/ram-art.jpg" alt="Арт в RAM"><br>
          <b>Арт в RAM</b>
        </a><br>
        Программа-шутка, использует RAM как холст для вывода изображения<br><br>
      </td>
      <td valign="top">
        <a href="asm/typewriter.asm">
          <img src="../../computer-v2/img/typewriter.jpg" alt="Пишущая машинка"><br>
          <b>Пишущая машинка</b>
        </a><br>
        Выводит в терминал текст, набираемый на клавиатуре<br><br>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <a href="asm/font-test.asm">
          <img src="../../computer-v2/img/font-test.jpg" alt="Тест шрифта"><br>
          <b>Тест шрифта</b>
        </a><br>
        Выводит в терминал все возможные символы (кодировка
        <a href="https://ru.wikipedia.org/wiki/Windows-1251">cp1251</a>)<br><br>
      </td>
    </tr>
  </thead>
</table>
<br>


## <a name="links"></a>Ссылки

- [Онлайн-компилятор](https://chubrik.github.io/arrows-compiler/) – напишите программу и получите
  дискету для вставки в игру
- [GraphDLC](https://github.com/MerinPrime/GraphDLC) – необходимое расширение для браузера,
  ускоряющее Стрелочки в 5000 раз
- [Программы Михаила Мосеева](https://github.com/mihail-moseev/program_for_computer_in_logic-arrows)
  – репозиторий автора нескольких программ из списка выше
- [Эмулятор на Python](https://github.com/farmer2010/Chubrik-processor-emulator) – написан
  участником сообщества Farmer_2010, автором нескольких программ из списка выше
- [Эмулятор на C](https://github.com/KittenAmogus/ACPUEmulator) – написан участником сообщества
  KittenAmogus, проект в разработке
- [Дискорд-сервер](https://discord.gg/8FMuQuMFCN) и [Телеграм-канал](https://t.me/logic_arrows) –
  здесь обсуждают компьютер, делятся идеями и новыми программами
- [Компьютер v1](../computer-v1/README.md) – ранняя версия компьютера, созданная по физическому
  прототипу
