using ComputerEmulator;

Console.Extras.WindowMaximize();
var ram = new Ram();
Console.Pin(ram.Display);
ram.Load(SpaceFight.Bytes());
var cpu = new Cpu(ram);
cpu.Run();
