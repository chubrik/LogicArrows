﻿Console.Extras.WindowMaximize();

// V1 - Space Fight!
{
    var ram = new ComputerEmulator.V1.Ram();
    Console.Pin(ram.Display);
    ram.Load(ComputerEmulator.V1.SpaceFight.Bytes());
    var cpu = new ComputerEmulator.V1.Cpu(ram);
    cpu.Run();
}

// V2 - Game
//{
//    var ram = new ComputerEmulator.V2.Ram();
//    Console.Pin(ram.Display);
//    ram.Load(ComputerEmulator.V2.Game.Bytes());
//    var cpu = new ComputerEmulator.V2.Cpu(ram);
//    cpu.Run();
//}
