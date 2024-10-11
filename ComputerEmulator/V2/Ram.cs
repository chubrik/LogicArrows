namespace ComputerEmulator.V2;

using ComputerEmulator;

internal class Ram
{
    private const int Size = 1024;
    private readonly IList<MyByte> _main = new MyByte[Size];
    private readonly IList<MyByte> _screen = new MyByte[32];
    private MyByte _number = default;
    private bool _numberSetted = false;
    private static readonly MyByte _bankAddr = new("3D");
    private static readonly MyByte _inAddr = new("3E");
    private static readonly MyByte _outAddr = new("3F");
    private static readonly MyByte _outNumber = new("10");
    private static readonly MyByte _outScreen = new("80");
    private static readonly MyByte _screenMinAddr = new("40");
    private static readonly MyByte _screenMaxAddr = new("5F");
    private static readonly MyByte _numberAddr = new("60");
    private int _bankShift = 0;

    public MyByte Read(MyByte rawAddr)
    {
        var value = Get(rawAddr);

        if (rawAddr == _inAddr)
            SetIn(0);

        return value;
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
        if (addr != _inAddr)
            _main[addr] = value;

        if (_main[_outAddr] == _outNumber && addr == _numberAddr)
        {
            _number = value;
            _numberSetted = true;
            Console.UpdatePin();
        }

        if (_main[_outAddr] == _outScreen && addr >= _screenMinAddr && addr <= _screenMaxAddr)
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

    public void SetIn(MyByte value) => _main[_inAddr] = value;

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

            if (i < _screenMaxAddr - 2)
                items.Add("\n");
        }

        items.Add("    Num: ");

        if (_numberSetted)
            items.Add($"G`{_number.Value}");

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
