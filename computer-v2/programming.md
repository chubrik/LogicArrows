# Programming
<br>

To run your own program on the computer, follow these steps:
- Learn the assembly language on this page.
- Open the [online compiler](https://chubrik.github.io/arrows-compiler/) and write your program in
  the left panel.
- Copy the compiled code from the right panel.
- Go to the [computer map](https://logic-arrows.io/map-computer) and press `Ctrl+V` to paste the
  disk with the program.
- Connect the wire from the disk to the common wire from the other disks.
- Press the button on the disk and wait for the program to load into the computer’s memory.
- Press the `RUN` button on the computer and watch your program execute.
<br><br><br>


## General Principles
A program consists of a sequence of instructions and a set of data. Each instruction occupies 1 byte
in memory. Some instructions require an additional operand, which also occupies 1 byte and is
located in memory immediately after the instruction. The processor executes instructions one after
another, starting from address `00`. According to the program, the processor can also make jumps to
different parts of the code, thus creating loops, subroutines, etc.

While executing a program, the processor interacts with registers `A` `B` `C` `D` and flags `Z` `S`
`C` `O`. Each register stores 1 byte and is general-purpose. The flags represent the result of
computational operations and can be used as conditions for jumps:
- **Z flag (zero)** indicates that the result is zero.
- **S flag (sign)** indicates that the most significant bit of the result is active. In signed
  arithmetic, this means a negative number.
- **C flag (carry)** indicates that during an operation, one of the bits went beyond the byte limit.
- **O flag (overflow)** indicates that in signed arithmetic, the result went out of the range
  `−128...+127`.
<br><br><br>


## Syntax
For the best understanding of the assembly language and its syntax, please review the
[program examples](asm) created by the computer’s author. Here we will cover the main points:
```asm
MY_CONST equ 100                ; Declare a constant MY_CONST with the value 100 using the "equ"
                                ; keyword. As values, you can use numbers from 0 to 255 anywhere in
                                ; the code in decimal (100), hexadecimal (0x64), octal (0144), or
                                ; binary (0b01100100) form. You can also use a character in quotes
                                ; ("d"), which is equivalent to a number in the cp1251 encoding.

ldi a, MY_CONST                 ; When the code is assembled, "MY_CONST" is replaced with its final
                                ; value, so the program will actually execute "ldi a, 100"

my_label:                       ; Declare a label, it denotes the current address in the code
  inc a
  jnz my_label                  ; The program will jump to the my_label label, creating a loop

my_data db 1, 2, 3, 0x4, "abc"  ; Declare a data area using the "db" keyword. The my_data label
                                ; denotes the starting address of this area. As data, you can
                                ; specify numbers, constants, labels, and strings, separated by
                                ; commas.

my_data_size equ $ - my_data    ; "$" denotes the current address in the code. By subtracting the
                                ; my_data address, we get the size of the data area, which we assign
                                ; to the my_data_size constant.
```
<br><br>


## Instructions

### Control Instructions
The instructions in this set are responsible for memory operations and jumps. In the table below,
the conventional ***X*** and ***Y*** are used to denote any registers, and ***F*** is used to denote
any flag.

Instruction | Description
---|---
nop | Does nothing, proceeds to the next instruction
ld ***X*** | Loads into ***X*** a value from memory, using the operand as an address
ld ***X***, ***Y*** | Loads into ***X*** a value from memory, using ***Y*** as an address
ldi ***X*** | Loads the operand directly into ***X***
st ***X*** | Stores the value of ***X*** in memory at the address from the operand
st ***X***, ***Y*** | Stores the value of ***X*** in memory at the address from ***Y***
jmp | Unconditional jump to the address from the operand
jmp ***X*** | Unconditional jump to the address from ***X***
j***F*** | Jump to the address from the operand, if ***F*** = 1
jn***F*** | Jump to the address from the operand, if ***F*** = 0
j***F*** ***X*** | Jump to the address from ***X***, if ***F*** = 1
jn***F*** ***X*** | Jump to the address from ***X***, if ***F*** = 0
hlt | Halts the program execution

<br>


### Computational Instructions
The instructions in this set perform calculations based on registers and affect the flags. In the
table below, the conventional ***X*** and ***Y*** are used to denote any registers.

Instruction | Description | Effect<br> on flags
---|---|---
clr ***X*** | Clears ***X*** | –
mov ***X***, ***Y*** | Copies from ***Y*** to ***X*** | –
and ***X***, ***Y*** | Bitwise AND between ***X*** and ***Y***, result is written to ***X*** | Z, S
or ***X***, ***Y*** | Bitwise OR between ***X*** and ***Y***, result is written to ***X*** | Z, S
xor ***X***, ***Y*** | Exclusive OR between ***X*** and ***Y***, result is written to ***X*** | Z, S
add ***X***, ***Y*** | Adds ***X*** and ***Y***, result is written to ***X*** | Z, S, C, O
adc ***X***, ***Y*** | Adds ***X***, ***Y*** and the `C` flag, result is written to ***X*** | Z, S, C, O
sub ***X***, ***Y*** | Subtracts ***Y*** from ***X***, result is written to ***X*** | Z, S, C, O
sbb ***X***, ***Y*** | Subtracts ***Y*** and the `C` flag from ***X***, result is written to ***X*** | Z, S, C, O
test ***X*** | Updates flags based on the value of ***X*** | Z, S
inc ***X*** | Adds 1 | Z, S
dec ***X*** | Subtracts 1 | Z, S
not ***X*** | Inverts each bit | Z, S
neg ***X*** | Changes the sign (treats the value as a signed number) | Z, S
rnd ***X*** | Generates a random value | Z, S
shl ***X*** | Shifts all bits one position to the left, the rightmost bit is cleared | Z, S, C
shr ***X*** | Shifts all bits one position to the right, the leftmost bit is cleared | Z, S, C
sar ***X*** | Shifts all bits one position to the right, the leftmost bit is unchanged | Z, S, C
rcl ***X*** | Shifts all bits one position to the left, the rightmost bit is taken from the `C` flag | Z, S, C
rcr ***X*** | Shifts all bits one position to the right, the leftmost bit is taken from the `C` flag | Z, S, C

<br>


### Instruction Table
Each instruction has its own code (opcode). For example, `st a, d` has the code `3C` (row, then
column).
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
