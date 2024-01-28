using ComputerEmulator;

Console.Utils.MaximizeWindow();
var ram = new Ram();
Console.Pin(ram.Display);
ram.Load(SpaceFight.Bytes());
var cpu = new Cpu(ram);
cpu.Run();
