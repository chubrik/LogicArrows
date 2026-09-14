# Компьютер v1
🌐 [English](../../computer-v1/README.md) | Русский
<br><br>

<table>
  <thead>
    <tr>
      <td valign="top" width="50%">
        Полноценный компьютер, целиком собранный из стрелочек: 8-битный процессор, 256 байт памяти,
        клавиатура, дисплей, терминал, цифровой индикатор и набор дискет с программами и играми.
        Предшественник более совершенного
        <a href="../computer-v2/README.md">компьютера v2</a>.<br><br>
        <a href="https://logic-arrows.io/map-lVeJ9jtX"><b>Карта с компьютером</b></a><br><br>
        <a href="specification.md">Устройство и характеристики</a><br><br>
        <a href="programming.md">Программирование</a><br><br>
        <a href="#examples">Готовые программы</a>
      </td>
      <td valign="top">
        <a href="https://logic-arrows.io/map-lVeJ9jtX"><img src="../../computer-v1/img/summary.jpg"
          alt="Компьютер v1"></a>
      </td>
    </tr>
  </thead>
</table>
<br>


## Демонстрация работы
Зайдите на [карту с компьютером](https://logic-arrows.io/map-lVeJ9jtX). В нижнем ползунке установите
максимальную скорость. Нажмите на кнопку `Hello world` и дождитесь загрузки программы в память
компьютера. Далее нажмите на кнопку `RUN` и наблюдайте, как программа выведет на дисплей котика и
надпись «Hello world». По окончании загорится лампочка `DONE`.

Чтобы запустить на компьютере вашу собственную программу, см. [Программирование](programming.md).
<br><br><br>


## <a name="examples"></a>Готовые программы
<table>
  <thead>
    <tr>
      <td valign="top" width="33%">
        <a href="asm/space-fight.asm">
          <img src="../../computer-v1/img/space-fight.jpg" alt="Игра «Бой в космосе»"><br>
          <b>Игра «Бой в космосе»</b>
        </a><br>
        К вам приближаются вражеские корабли, которые нужно сбить за ограниченное время. В случае
        победы вы получите приз.<br><br>
        Игра занимает весь доступный объём памяти 256 байт и в целях производительности выложена на
        <a href="https://logic-arrows.io/map-space-fight">отдельной карте</a>.<br><br>
      </td>
      <td valign="top" width="33%">
        <a href="asm/hello-world.asm">
          <img src="../../computer-v1/img/summary.jpg" alt="Hello World"><br>
          <b>Hello World</b>
        </a><br>
        Выводит на дисплей котика и надпись «Hello world»<br><br>
      </td>
      <td valign="top" width="33%">
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20Langton%27s%20ant.asm">
          <img src="../../computer-v1/img/langton-ant.jpg" alt="Муравей Лэнгтона"><br>
          <b>Муравей Лэнгтона</b>
        </a><br>
        Муравей ползает по дисплею, перекрашивает клетки и поворачивает по простому правилу,
        порождая сложный узор. Автор —
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows">
        Михаил Мосеев</a>.<br><br>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <a href="asm/prime-numbers.asm">
          <img src="../../computer-v1/img/prime-numbers.jpg" alt="Простые числа"><br>
          <b>Простые числа</b>
        </a><br>
        Находит первые 16 простых чисел и выводит их на дисплей в двоичном формате<br><br>
      </td>
      <td valign="top">
        <a href="asm/fibonacci-sequence.asm">
          <img src="../../computer-v1/img/fibonacci-sequence.jpg" alt="Числа Фибоначчи"><br>
          <b>Числа Фибоначчи</b>
        </a><br>
        Находит 10 чисел Фибоначчи и выводит их на дисплей в двоичном формате<br><br>
      </td>
      <td valign="top">
        <a href="asm/typewriter.asm">
          <img src="../../computer-v1/img/terminal.jpg" alt="Пишущая машинка"><br>
          <b>Пишущая машинка</b>
        </a><br>
        Выводит в терминал текст, набираемый на клавиатуре<br><br>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <a href="asm/font-test.asm">
          <img src="../../computer-v1/img/font-test.jpg" alt="Тест шрифта"><br>
          <b>Тест шрифта</b>
        </a><br>
        Выводит в терминал все возможные символы (кодировка
        <a href="https://ru.wikipedia.org/wiki/Windows-1251">cp1251</a>)<br><br>
      </td>
    </tr>
  </thead>
</table>
