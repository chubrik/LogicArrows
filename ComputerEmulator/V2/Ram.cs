namespace ComputerEmulator.V2;

using ComputerEmulator;

internal class Ram
{
    private const int Size = 1024;
    private readonly IList<MyByte> _main = new MyByte[Size];
    private readonly IList<MyByte> _screen = new MyByte[32];
    private MyByte _bcd = default;
    private bool _bcdSetted = false;
    private MyByte _in = new(0);
    private static readonly MyByte _bcdAddr = new("3A");
    private static readonly MyByte _ioAddr = new("3E");
    private static readonly MyByte _bankAddr = new("3F");
    private static readonly MyByte _screenMinAddr = new("40");
    private static readonly MyByte _screenMaxAddr = new("5F");
    private int _bankShift = 0;

    private const byte Mode_Terminal = 1;
    private const byte Mode_Bcd = 2;
    private const byte Mode_Screen = 4;
    private const byte Mode_ScreenColor = 8;

    public MyByte Read(MyByte rawAddr)
    {
        if (rawAddr == _ioAddr)
        {
            var value = _in;
            _in = 0;
            return value;
        }

        return Get(rawAddr);
    }

    public MyByte Get(string rawAddr) => Get(new MyByte(rawAddr));

    public MyByte Get(MyByte rawAddr) => _main[GetFullAddr(rawAddr)];

    public void Write(MyByte rawAddr, MyByte value)
    {
        var addr = GetFullAddr(rawAddr);
        WriteInternal(addr, value);
    }

    private void WriteInternal(int addr, MyByte value)
    {
        _main[addr] = value;

        if ((_main[_ioAddr] & Mode_Bcd) != 0 && addr == _bcdAddr)
        {
            _bcd = value;
            _bcdSetted = true;
            Console.UpdatePin();
        }

        if ((_main[_ioAddr] & Mode_Screen) != 0 && addr >= _screenMinAddr && addr <= _screenMaxAddr)
        {
            _screen[addr - 64] = value;
            Console.UpdatePin();
        }

        if (addr == _bankAddr)
        {
            var maskedValue = Math.Max(1, value & 0b00000111);
            _bankShift = (maskedValue - 1) * 128;
        }
    }

    public void SetIn(MyByte value) => _in = value;

    private int GetFullAddr(MyByte rawAddr) => rawAddr < 128 ? rawAddr : rawAddr + _bankShift;

    public void Load(IReadOnlyList<MyByte> bytes)
    {
        if (bytes.Count > Size)
            throw new InvalidOperationException();

        for (var i = 0; i < bytes.Count; i++)
            if (i != _bankAddr)
                WriteInternal(i, bytes[i]);
    }

    public IReadOnlyList<string> Display()
    {
        var items = new List<string>();

        for (var i = _screenMinAddr; i < _screenMaxAddr; i += 2)
        {
            var row = "rw`";
            row += Pixels(_screen[i - 64]);
            row += Pixels(_screen[i - 63]);
            items.Add(row);

            items.Add("   ");
            items.Add("rw`" + Pixels(_main[i + 32]) + Pixels(_main[i + 33]));

            if (i < _screenMaxAddr - 2)
                items.Add("\n");
        }

        items.Add("    BCD: ");

        if (_bcdSetted)
            items.Add($"G`{_bcd.Value}");

        return items;
    }

    private static string Pixels(MyByte value)
    {
        var hex = value.Hex;
        return $"{_pixelMap[hex[0]]}{_pixelMap[hex[1]]}";
    }

    private static readonly Dictionary<char, string> _pixelMap = new()
    {
        { '0', "        "},
        { '1', "      ▓▓"},
        { '2', "    ▓▓  "},
        { '3', "    ▓▓▓▓"},
        { '4', "  ▓▓    "},
        { '5', "  ▓▓  ▓▓"},
        { '6', "  ▓▓▓▓  "},
        { '7', "  ▓▓▓▓▓▓"},
        { '8', "▓▓      "},
        { '9', "▓▓    ▓▓"},
        { 'A', "▓▓  ▓▓  "},
        { 'B', "▓▓  ▓▓▓▓"},
        { 'C', "▓▓▓▓    "},
        { 'D', "▓▓▓▓  ▓▓"},
        { 'E', "▓▓▓▓▓▓  "},
        { 'F', "▓▓▓▓▓▓▓▓"},
    };
}
