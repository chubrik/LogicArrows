# Computer v1
🌐 English | [Русский](../ru/computer-v1/README.md)
<br><br>

<table>
  <thead>
    <tr>
      <td valign="top" width="50%">
        A full-fledged computer assembled entirely of logic arrows: an 8-bit processor, 256 bytes
        of memory, a keyboard, a display, a terminal, a digital indicator, and a set of disks with
        programs and games. The predecessor of the more advanced
        <a href="../computer-v2/README.md">Computer v2</a>.<br><br>
        <a href="https://logic-arrows.io/map-lVeJ9jtX"><b>Map with the computer</b></a><br><br>
        <a href="specification.md">Structure and Specifications</a><br><br>
        <a href="programming.md">Programming</a><br><br>
        <a href="#examples">Ready-made programs</a>
      </td>
      <td valign="top">
        <a href="https://logic-arrows.io/map-lVeJ9jtX"><img src="img/summary.jpg"
          alt="Computer v1"></a>
      </td>
    </tr>
  </thead>
</table>
<br>


## Demonstration
Go to the [map with the computer](https://logic-arrows.io/map-lVeJ9jtX). On the bottom slider, set
the maximum speed. Press the `Hello world` button and wait for the program to load into the
computer’s memory. Next, press the `RUN` button and watch as the program displays a cat and the text
“Hello world”. When finished, the `DONE` light will turn on.

To run your own program on the computer, see [Programming](programming.md).
<br><br><br>


## <a name="examples"></a>Ready-made programs
<table>
  <thead>
    <tr>
      <td valign="top" width="50%">
        <h3><a href="asm/space-fight.asm">Space Fight Game</a></h3>
        <a href="asm/space-fight.asm"><img src="img/space-fight.jpg"
          alt="Space Fight Game"></a><br>
        Enemy ships are approaching you, which you need to shoot down within a limited time. If you
        win, you will receive a prize.<br><br>
        The game occupies the entire available memory of 256 bytes and for performance purposes is
        available on a <a href="https://logic-arrows.io/map-space-fight">separate map</a>.
      </td>
      <td valign="top">
        <h3><a href="asm/hello-world.asm">Hello World</a></h3>
        <a href="asm/hello-world.asm"><img src="img/summary.jpg" alt="Hello World"></a><br>
        Displays a cat and the text “Hello world” on the screen
      </td>
    </tr>
    <tr>
      <td valign="top">
        <h3><a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20Langton%27s%20ant.asm">
          Langton's Ant</a></h3>
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20Langton%27s%20ant.asm">
          <img src="img/langton-ant.jpg" alt="Langton's Ant"></a><br>
        The ant crawls across the display, repainting the cells and turning by a simple rule that
        produces a complex pattern. Author:
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows">
        Mikhail Moseev</a>.
      </td>
      <td valign="top">
        <h3><a href="asm/prime-numbers.asm">Prime Numbers</a></h3>
        <a href="asm/prime-numbers.asm"><img src="img/prime-numbers.jpg"
          alt="Prime Numbers"></a><br>
        Finds the first 16 prime numbers and displays them on the screen in binary format
      </td>
    </tr>
    <tr>
      <td valign="top">
        <h3><a href="asm/fibonacci-sequence.asm">Fibonacci Sequence</a></h3>
        <a href="asm/fibonacci-sequence.asm"><img src="img/fibonacci-sequence.jpg"
          alt="Fibonacci Sequence"></a><br>
        Finds 10 Fibonacci numbers and displays them on the screen in binary format
      </td>
      <td valign="top">
        <h3><a href="asm/typewriter.asm">Typewriter</a></h3>
        <a href="asm/typewriter.asm"><img src="img/terminal.jpg" alt="Typewriter"></a><br>
        Outputs text typed on the keyboard to the terminal
      </td>
    </tr>
    <tr>
      <td valign="top">
        <h3><a href="asm/font-test.asm">Font Test</a></h3>
        <a href="asm/font-test.asm"><img src="img/font-test.jpg" alt="Font Test"></a><br>
        Outputs all possible characters to the terminal (encoding
        <a href="https://en.wikipedia.org/wiki/Windows-1251">cp1251</a>)
      </td>
    </tr>
  </thead>
</table>
