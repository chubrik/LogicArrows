using System.Text.RegularExpressions;

namespace ComputerEmulator;

internal readonly struct MyByte
{
    public readonly byte Value;

    public MyByte(int @byte)
    {
        Value = unchecked((byte)@byte);
    }

    public MyByte(string hex)
    {
        if (!Regex.IsMatch(hex, @"^[0-9A-F]{2}$"))
            throw new InvalidOperationException();

        Value = (byte)(_toNumberMap[hex[0]] * 16 + _toNumberMap[hex[1]]);
    }

    public string Hex
    {
        get {
            var major = _toCharMap[Value / 16];
            var minor = _toCharMap[Value % 16];
            return $"{major}{minor}";
        }
    }

    public bool IsSigned => Value >= 128;

    public override string ToString()
    {
        return $"{Hex} {Value}";
    }

    private static readonly Dictionary<int, char> _toCharMap = new()
    {
        { 0, '0'},
        { 1, '1'},
        { 2, '2'},
        { 3, '3'},
        { 4, '4'},
        { 5, '5'},
        { 6, '6'},
        { 7, '7'},
        { 8, '8'},
        { 9, '9'},
        { 10, 'A'},
        { 11, 'B'},
        { 12, 'C'},
        { 13, 'D'},
        { 14, 'E'},
        { 15, 'F'},
    };

    private static readonly Dictionary<char, int> _toNumberMap = new()
    {
        { '0', 0},
        { '1', 1},
        { '2', 2},
        { '3', 3},
        { '4', 4},
        { '5', 5},
        { '6', 6},
        { '7', 7},
        { '8', 8},
        { '9', 9},
        { 'A', 10},
        { 'B', 11},
        { 'C', 12},
        { 'D', 13},
        { 'E', 14},
        { 'F', 15},
    };

    public static implicit operator MyByte(int value) => new(value);
    public static implicit operator byte(MyByte value) => value.Value;
}
