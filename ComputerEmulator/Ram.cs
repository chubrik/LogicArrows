using ComputerEmulator;

internal class Ram
{
    private readonly IList<MyByte> _main = new MyByte[256];
    private readonly IList<MyByte> _screen = new MyByte[256];
    private MyByte _number = default;
    private bool _numberSetted = false;
    private static readonly MyByte _outAddr = new("3F");
    private static readonly MyByte _outNumber = new("10");
    private static readonly MyByte _outScreen = new("80");
    private static readonly MyByte _screenMinAddr = new("40");
    private static readonly MyByte _screenMaxAddr = new("5F");

    public MyByte Read(MyByte addr)
    {
        return _main[addr];
    }

    public MyByte Read(string addr)
    {
        return _main[new MyByte(addr)];
    }

    public void Write(MyByte addr, MyByte value)
    {
        _main[addr] = value;

        if (_main[_outAddr] == _outNumber && addr == _screenMinAddr)
        {
            _number = value;
            _numberSetted = true;
            Console.UpdatePin();
        }

        if (_main[_outAddr] == _outScreen && addr >= _screenMinAddr && addr <= _screenMaxAddr)
        {
            _screen[addr] = value;
            Console.UpdatePin();
        }
    }

    public void Load(IReadOnlyList<MyByte> bytes)
    {
        if (bytes.Count > 256)
            throw new InvalidOperationException();

        for (var i = 0; i < bytes.Count; i++)
            Write(i, bytes[i]);
    }

    public IReadOnlyList<string> Display()
    {
        var items = new List<string>();

        for (var i = _screenMinAddr; i < _screenMaxAddr; i += 2)
        {
            var row = "rw`";
            row += Pixels(_screen[i]);
            row += Pixels(_screen[i + 1]);
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
