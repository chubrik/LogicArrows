using ComputerEmulator;

Console.Utils.MaximizeWindow();
var ram = new Ram();
Console.Pin(ram.Display);
var game = new Game();
ram.Load(game.Bytes());
var cpu = new Cpu(ram);
cpu.Run();
