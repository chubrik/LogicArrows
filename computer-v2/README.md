# Computer v2
🌐 English | [Русский](../ru/computer-v2/README.md)
<br><br>

<table>
  <thead>
    <tr>
      <td valign="top" width="50%">
        A full-fledged computer assembled entirely of logic arrows: an 8-bit processor, up to 32 KB
        of memory, a keyboard, a color display, a terminal, a digital indicator, and a set of
        diskettes with programs and games, some of them created by members of the community.<br><br>
        <ul>
          <li><a href="https://logic-arrows.io/map-computer"><b>Map with the computer ⇾</b></a></li>
        </ul>
        <ul>
          <li><a href="specification.md">Structure and Specifications</a></li>
          <li><a href="programming.md">Programming</a></li>
          <li><a href="#examples">Ready-made programs</a></li>
          <li><a href="#links">Links</a></li>
        </ul>
      </td>
      <td valign="top">
        <a href="https://logic-arrows.io/map-computer"><img src="img/summary.jpg"
          alt="Computer v2"></a>
      </td>
    </tr>
  </thead>
</table>
<br>


## Demonstration
Go to the [map with the computer](https://logic-arrows.io/map-computer). On the bottom slider, set
the maximum speed. Press the `Demo` button and wait for the program to load into the computer’s
memory. During loading, a colored butterfly will be displayed. Next, press the `RUN` button and
watch as the program writes “Hello, Onigiri!” in the terminal, draws an onigiri image, and rings the
bell. When finished, the `DONE` light will turn on.

To run your own program on the computer, see [Programming](programming.md).
<br><br><br>


## <a name="examples"></a>Ready-made programs
<table>
  <thead>
    <tr>
      <td valign="top" width="33%">
        <a href="asm/tetris.asm">
          <img src="img/tetris.jpg" alt="Tetris Game"><br>
          <b>Tetris Game</b>
        </a><br>
        Fill the rows and increase your score. A classic puzzle game with color graphics.<br><br>
      </td>
      <td valign="top" width="33%">
        <a href="asm/game-of-life.asm">
          <img src="img/game-of-life.jpg" alt="Game of Life"><br>
          <b>Game of Life</b>
        </a><br>
        Fills the display with random pixels and calculates subsequent generations<br><br>
      </td>
      <td valign="top" width="33%">
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%203d%20maze.asm">
          <img src="img/3d-maze.jpg" alt="3D Maze Game"><br>
          <b>3D Maze Game</b>
        </a><br>
        Find the way out of the maze in first-person view. The 3D graphics are rendered by ray
        casting. Author: <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows">
        Mikhail Moseev</a>.<br><br>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <a href="asm/community/arkanoid.asm">
          <img src="img/arkanoid.jpg" alt="Arkanoid Game"><br>
          <b>Arkanoid Game</b>
        </a><br>
        Bounce the ball with the paddle to break all the bricks on the screen. Author:
        <a href="https://github.com/farmer2010">Farmer_2010</a>.<br><br>
      </td>
      <td valign="top">
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20snake.asm">
          <img src="img/snake.jpg" alt="Snake Game"><br>
          <b>Snake Game</b>
        </a><br>
        Control the snake, collect apples, and don’t run into your own tail. Author:
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows">
        Mikhail Moseev</a>.<br><br>
      </td>
      <td valign="top">
        <a href="asm/space-fight.asm">
          <img src="img/space-fight.jpg" alt="Space Fight Game"><br>
          <b>Space Fight Game</b>
        </a><br>
        Enemy ships are approaching you, which you need to shoot down within a limited time. If you
        win, you will receive a prize.<br><br>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20minesweeper.asm">
          <img src="img/minesweeper.jpg" alt="Minesweeper Game"><br>
          <b>Minesweeper Game</b>
        </a><br>
        Open the cells, following the number clues, and don’t step on a mine. Author:
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows">
        Mikhail Moseev</a>.<br><br>
      </td>
      <td valign="top">
        <a href="asm/guess-number.asm">
          <img src="img/guess-number.jpg" alt="Guess the Number Game"><br>
          <b>Guess the Number Game</b>
        </a><br>
        Guess the numbers using the “higher/lower” rule and increase your overall winning
        score<br><br>
      </td>
      <td valign="top">
        <a href="asm/community/maze-generator.asm">
          <img src="img/maze-generator.jpg" alt="Maze Generator"><br>
          <b>Maze Generator</b>
        </a><br>
        Generates a random maze on the display using the backtracking algorithm. Author:
        <a href="https://github.com/farmer2010">Farmer_2010</a>.<br><br>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <a href="asm/community/1d-cellular-automaton.asm">
          <img src="img/1d-cellular-automaton.jpg" alt="1D Cellular Automaton"><br>
          <b>1D Cellular Automaton</b>
        </a><br>
        Enter a rule in binary and watch the cells evolve on the display. Author:
        <a href="https://github.com/farmer2010">Farmer_2010</a>.<br><br>
      </td>
      <td valign="top">
        <a href="asm/community/langton-ant.asm">
          <img src="img/langton-ant.jpg" alt="Langton's Ant"><br>
          <b>Langton's Ant</b>
        </a><br>
        The ant crawls across the display, repainting the cells and turning by a simple rule that
        produces a complex pattern. Author:
        <a href="https://github.com/farmer2010">Farmer_2010</a>.<br><br>
      </td>
      <td valign="top">
        <a href="asm/demo.asm">
          <img src="img/summary.jpg" alt="Demo"><br>
          <b>Demo</b>
        </a><br>
        Displays a colored butterfly, writes “Hello, Onigiri!” in the terminal, draws an onigiri
        image, and rings the bell<br><br>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows/blob/main/code%20tennis.asm">
          <img src="img/tennis.jpg" alt="Tennis Game"><br>
          <b>Tennis Game</b>
        </a><br>
        Bounce the ball with the paddle and don’t let it fall. Author:
        <a href="https://github.com/mihail-moseev/program_for_computer_in_logic-arrows">
        Mikhail Moseev</a>.<br><br>
      </td>
      <td valign="top">
        <a href="asm/prime-numbers.asm">
          <img src="img/prime-numbers.jpg" alt="Prime Numbers"><br>
          <b>Prime Numbers</b>
        </a><br>
        Finds 16 prime numbers and outputs them to the digital indicator, as well as to the display
        in binary format<br><br>
      </td>
      <td valign="top">
        <a href="asm/fibonacci-sequence.asm">
          <img src="img/fibonacci-sequence.jpg" alt="Fibonacci Sequence"><br>
          <b>Fibonacci Sequence</b>
        </a><br>
        Finds 12 Fibonacci numbers. Outputs them to the digital indicator, as well as to the display
        in binary format<br><br>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <a href="asm/terminal-art.asm">
          <img src="img/terminal-art.jpg" alt="Terminal Art"><br>
          <b>Terminal Art</b>
        </a><br>
        Uses the terminal’s graphics mode to display an image<br><br>
      </td>
      <td valign="top">
        <a href="asm/ram-art.asm">
          <img src="img/ram-art.jpg" alt="RAM Art"><br>
          <b>RAM Art</b>
        </a><br>
        A joke program that uses RAM as a canvas to display an image (“Where are the arrows?!” in
        Russian)<br><br>
      </td>
      <td valign="top">
        <a href="asm/typewriter.asm">
          <img src="img/typewriter.jpg" alt="Typewriter"><br>
          <b>Typewriter</b>
        </a><br>
        Outputs text typed on the keyboard to the terminal<br><br>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <a href="asm/font-test.asm">
          <img src="img/font-test.jpg" alt="Font Test"><br>
          <b>Font Test</b>
        </a><br>
        Outputs all possible characters to the terminal (encoding
        <a href="https://en.wikipedia.org/wiki/Windows-1251">cp1251</a>)<br><br>
      </td>
    </tr>
  </thead>
</table>
<br>


## <a name="links"></a>Links

- [Online compiler](https://chubrik.github.io/arrows-compiler/) – write a program and get a diskette
  to paste into the game
- [GraphDLC](https://github.com/MerinPrime/GraphDLC) – essential browser extension that speeds up
  Logic Arrows by 5000 times
- [Programs by Mikhail Moseev](https://github.com/mihail-moseev/program_for_computer_in_logic-arrows)
  – repository by the author of several programs listed above
- [Python emulator](https://github.com/farmer2010/Chubrik-processor-emulator) – written by
  community member Farmer_2010, the author of several programs listed above
- [Discord server](https://discord.gg/8FMuQuMFCN) and [Telegram channel](https://t.me/logic_arrows)
  – where people discuss the computer and share ideas and new programs
- [Computer v1](../computer-v1/README.md) – early version of the computer, based on a physical
  prototype
