namespace ComputerEmulator.V2;

internal class Cpu(Ram ram)
{
    private static readonly Random _random = new();

    private readonly Ram _ram = ram;
    private int counter;
    private MyByte _ip;
    private MyByte _ir;
    private MyByte _ra;
    private MyByte _rb;
    private MyByte _rc;
    private MyByte _rd;
    private bool _fz;
    private bool _fs;
    private bool _fc;
    private bool _fo;
    private bool _raSetted;
    private bool _rbSetted;
    private bool _rcSetted;
    private bool _rdSetted;
    private bool _fzsSetted;
    private bool _fcSetted;
    private bool _foSetted;
    private MyByte? _jumpAddr;
    private bool _jumped;
    private bool _halted;
    private bool _wasArgument;

    public void Run()
    {
        for (; ; )
        {
            counter++;

            if (_jumpAddr != null)
            {
                _ip = _jumpAddr.Value;
                _jumpAddr = null;
                _jumped = true;
            }

            _ir = _ram.Read(_ip);
            var key = Console.ReadKey(intercept: true).Key;

            if (key == ConsoleKey.Escape)
                return;

            if (key != ConsoleKey.NumPad0)
                _ram.SetIn((int)key);

            var instruction = _instructions[_ir];
            instruction.Action(this);
            State();
            _ip++;

            if (_halted)
                return;
        }
    }

    private MyByte GetArgument()
    {
        State();
        counter++;
        var argument = _ram.Read(++_ip);
        _ir = _ram.Read(_ip);
        Console.ReadKey(intercept: true);
        _wasArgument = true;
        return argument;
    }

    private void SetRegA(MyByte value)
    {
        _ra = value;
        _raSetted = true;
    }

    private void SetRegB(MyByte value)
    {
        _rb = value;
        _rbSetted = true;
    }

    private void SetRegC(MyByte value)
    {
        _rc = value;
        _rcSetted = true;
    }

    private void SetRegD(MyByte value)
    {
        _rd = value;
        _rdSetted = true;
    }

    private void SetFlagsZS(MyByte value)
    {
        _fz = value == 0;
        _fs = value.IsSigned;
        _fzsSetted = true;
    }

    private void SetFlagsC(bool fc)
    {
        _fc = fc;
        _fcSetted = true;
    }

    private void SetFlagsO(bool fo)
    {
        _fo = fo;
        _foSetted = true;
    }

    private void State()
    {
        var ipColor = _jumped ? "W" : "G";
        var irDescrColor = _wasArgument ? "d" : "G";
        var irDescr = _wasArgument ? "argument" : _instructions[_ir].Name;
        var raColor = _raSetted ? "W" : _ra != 0 ? "G" : "d";
        var rbColor = _rbSetted ? "W" : _rb != 0 ? "G" : "d";
        var rcColor = _rcSetted ? "W" : _rc != 0 ? "G" : "d";
        var rdColor = _rdSetted ? "W" : _rd != 0 ? "G" : "d";
        var fzColor = _fzsSetted ? "W" : _fz ? "G" : "d";
        var fcColor = _fcSetted ? "W" : _fc ? "G" : "d";
        var fsColor = _fzsSetted ? "W" : _fs ? "G" : "d";
        var foColor = _foSetted ? "W" : _fo ? "G" : "d";

        var caches = "";

        for (var i = 0; i < 48; i++)
        {
            if (i == 16 || i == 32)
                caches += " ";

            caches += new MyByte(_ram.Get(i) + 2).Hex[1];
        }

        Console.WriteLine([
           $"d`{counter,5}  ",
           "d`IP:", $"{ipColor}`{_ip.Hex}  ",
           "d`IR:", $"G`{_ir.Hex}  ", $"{irDescrColor}`{irDescr,-10}  ",
           "d`A:", $"{raColor}`{_ra.Hex}  ",
           "d`B:", $"{rbColor}`{_rb.Hex}  ",
           "d`C:", $"{rcColor}`{_rc.Hex}  ",
           "d`D:", $"{rdColor}`{_rd.Hex}    ",
           "d`Z:", $"{fzColor}`{(_fz ? "1" : "0")}  ",
           "d`S:", $"{fsColor}`{(_fs ? "1" : "0")}  ",
           "d`C:", $"{fcColor}`{(_fc ? "1" : "0")}  ",
           "d`O:", $"{foColor}`{(_fo ? "1" : "0")}    ",
           $"d`35:{_ram.Get("35").Hex}  ",
           $"d`36:{_ram.Get("36").Hex}  ",
           $"d`37:{_ram.Get("37").Hex}  ",
           $"d`38:{_ram.Get("38").Hex}  ",
           $"d`39:{_ram.Get("39").Hex}  ",
           $"d`3A:{_ram.Get("3A").Hex}  ",
           $"d`3B:{_ram.Get("3B").Hex}  ",
           $"d`3C:{_ram.Get("3C").Hex}    ",
           $"d`3D:{_ram.Get("3D").Hex}  ",
           $"d`3E:{_ram.Get("3E").Hex}  ",
           $"d`3F:{_ram.Get("3F").Hex}    ",
           $"d`30:{_ram.Get("30").Hex}    ",
           $"d`{caches}"
        ]);

        _raSetted = _rbSetted = _rcSetted = _rdSetted = _fzsSetted = _fcSetted = _foSetted = _jumped = _wasArgument = false;
    }

    [Obsolete]
    private static void Command(Cpu cpu) => throw new NotImplementedException();

    #region Commands

    #region Nop / Hlt

    private static void Nop(Cpu cpu)
    {
    }

    private static void Hlt(Cpu cpu)
    {
        cpu._halted = true;
    }

    #endregion

    #region Jmp / Jmp X

    private static void Jmp(Cpu cpu) => cpu._jumpAddr = cpu.GetArgument();
    private static void JmpA(Cpu cpu) => cpu._jumpAddr = cpu._ra;
    private static void JmpB(Cpu cpu) => cpu._jumpAddr = cpu._rb;
    private static void JmpC(Cpu cpu) => cpu._jumpAddr = cpu._rc;
    private static void JmpD(Cpu cpu) => cpu._jumpAddr = cpu._rd;

    #endregion

    #region JF / JnF

    private static void Jz(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (cpu._fz)
            cpu._jumpAddr = arg;
    }

    private static void Js(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (cpu._fs)
            cpu._jumpAddr = arg;
    }

    private static void Jc(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (cpu._fc)
            cpu._jumpAddr = arg;
    }

    private static void Jo(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (cpu._fo)
            cpu._jumpAddr = arg;
    }

    private static void Jnz(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (!cpu._fz)
            cpu._jumpAddr = arg;
    }

    private static void Jns(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (!cpu._fs)
            cpu._jumpAddr = arg;
    }

    private static void Jnc(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (!cpu._fc)
            cpu._jumpAddr = arg;
    }

    private static void Jno(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (!cpu._fo)
            cpu._jumpAddr = arg;
    }

    #endregion

    #region JF X

    private static void JzA(Cpu cpu)
    {
        if (cpu._fz)
            cpu._jumpAddr = cpu._ra;
    }

    private static void JsA(Cpu cpu)
    {
        if (cpu._fs)
            cpu._jumpAddr = cpu._ra;
    }

    private static void JcA(Cpu cpu)
    {
        if (cpu._fc)
            cpu._jumpAddr = cpu._ra;
    }

    private static void JoA(Cpu cpu)
    {
        if (cpu._fo)
            cpu._jumpAddr = cpu._ra;
    }

    private static void JzB(Cpu cpu)
    {
        if (cpu._fz)
            cpu._jumpAddr = cpu._rb;
    }

    private static void JsB(Cpu cpu)
    {
        if (cpu._fs)
            cpu._jumpAddr = cpu._rb;
    }

    private static void JcB(Cpu cpu)
    {
        if (cpu._fc)
            cpu._jumpAddr = cpu._rb;
    }

    private static void JoB(Cpu cpu)
    {
        if (cpu._fo)
            cpu._jumpAddr = cpu._rb;
    }

    private static void JzC(Cpu cpu)
    {
        if (cpu._fz)
            cpu._jumpAddr = cpu._rc;
    }

    private static void JsC(Cpu cpu)
    {
        if (cpu._fs)
            cpu._jumpAddr = cpu._rc;
    }

    private static void JcC(Cpu cpu)
    {
        if (cpu._fc)
            cpu._jumpAddr = cpu._rc;
    }

    private static void JoC(Cpu cpu)
    {
        if (cpu._fo)
            cpu._jumpAddr = cpu._rc;
    }

    private static void JzD(Cpu cpu)
    {
        if (cpu._fz)
            cpu._jumpAddr = cpu._rd;
    }

    private static void JsD(Cpu cpu)
    {
        if (cpu._fs)
            cpu._jumpAddr = cpu._rd;
    }

    private static void JcD(Cpu cpu)
    {
        if (cpu._fc)
            cpu._jumpAddr = cpu._rd;
    }

    private static void JoD(Cpu cpu)
    {
        if (cpu._fo)
            cpu._jumpAddr = cpu._rd;
    }

    #endregion

    #region JnF X

    private static void JnzA(Cpu cpu)
    {
        if (!cpu._fz)
            cpu._jumpAddr = cpu._ra;
    }

    private static void JnsA(Cpu cpu)
    {
        if (!cpu._fs)
            cpu._jumpAddr = cpu._ra;
    }

    private static void JncA(Cpu cpu)
    {
        if (!cpu._fc)
            cpu._jumpAddr = cpu._ra;
    }

    private static void JnoA(Cpu cpu)
    {
        if (!cpu._fo)
            cpu._jumpAddr = cpu._ra;
    }

    private static void JnzB(Cpu cpu)
    {
        if (!cpu._fz)
            cpu._jumpAddr = cpu._rb;
    }

    private static void JnsB(Cpu cpu)
    {
        if (!cpu._fs)
            cpu._jumpAddr = cpu._rb;
    }

    private static void JncB(Cpu cpu)
    {
        if (!cpu._fc)
            cpu._jumpAddr = cpu._rb;
    }

    private static void JnoB(Cpu cpu)
    {
        if (!cpu._fo)
            cpu._jumpAddr = cpu._rb;
    }

    private static void JnzC(Cpu cpu)
    {
        if (!cpu._fz)
            cpu._jumpAddr = cpu._rc;
    }

    private static void JnsC(Cpu cpu)
    {
        if (!cpu._fs)
            cpu._jumpAddr = cpu._rc;
    }

    private static void JncC(Cpu cpu)
    {
        if (!cpu._fc)
            cpu._jumpAddr = cpu._rc;
    }

    private static void JnoC(Cpu cpu)
    {
        if (!cpu._fo)
            cpu._jumpAddr = cpu._rc;
    }

    private static void JnzD(Cpu cpu)
    {
        if (!cpu._fz)
            cpu._jumpAddr = cpu._rd;
    }

    private static void JnsD(Cpu cpu)
    {
        if (!cpu._fs)
            cpu._jumpAddr = cpu._rd;
    }

    private static void JncD(Cpu cpu)
    {
        if (!cpu._fc)
            cpu._jumpAddr = cpu._rd;
    }

    private static void JnoD(Cpu cpu)
    {
        if (!cpu._fo)
            cpu._jumpAddr = cpu._rd;
    }

    #endregion

    #region St X

    private static void StA(Cpu cpu) => cpu._ram.Write(cpu.GetArgument(), cpu._ra);
    private static void StB(Cpu cpu) => cpu._ram.Write(cpu.GetArgument(), cpu._rb);
    private static void StC(Cpu cpu) => cpu._ram.Write(cpu.GetArgument(), cpu._rc);
    private static void StD(Cpu cpu) => cpu._ram.Write(cpu.GetArgument(), cpu._rd);

    #endregion

    #region St X,Y

    private static void StBA(Cpu cpu) => cpu._ram.Write(cpu._ra, cpu._rb);
    private static void StCA(Cpu cpu) => cpu._ram.Write(cpu._ra, cpu._rc);
    private static void StDA(Cpu cpu) => cpu._ram.Write(cpu._ra, cpu._rd);
    private static void StAB(Cpu cpu) => cpu._ram.Write(cpu._rb, cpu._ra);
    private static void StCB(Cpu cpu) => cpu._ram.Write(cpu._rb, cpu._rc);
    private static void StDB(Cpu cpu) => cpu._ram.Write(cpu._rb, cpu._rd);
    private static void StAC(Cpu cpu) => cpu._ram.Write(cpu._rc, cpu._ra);
    private static void StBC(Cpu cpu) => cpu._ram.Write(cpu._rc, cpu._rb);
    private static void StDC(Cpu cpu) => cpu._ram.Write(cpu._rc, cpu._rd);
    private static void StAD(Cpu cpu) => cpu._ram.Write(cpu._rd, cpu._ra);
    private static void StBD(Cpu cpu) => cpu._ram.Write(cpu._rd, cpu._rb);
    private static void StCD(Cpu cpu) => cpu._ram.Write(cpu._rd, cpu._rc);

    #endregion

    #region Ld X,Y

    private static void LdAA(Cpu cpu) => cpu.SetRegA(cpu._ram.Read(cpu._ra));
    private static void LdBA(Cpu cpu) => cpu.SetRegB(cpu._ram.Read(cpu._ra));
    private static void LdCA(Cpu cpu) => cpu.SetRegC(cpu._ram.Read(cpu._ra));
    private static void LdDA(Cpu cpu) => cpu.SetRegD(cpu._ram.Read(cpu._ra));
    private static void LdAB(Cpu cpu) => cpu.SetRegA(cpu._ram.Read(cpu._rb));
    private static void LdBB(Cpu cpu) => cpu.SetRegB(cpu._ram.Read(cpu._rb));
    private static void LdCB(Cpu cpu) => cpu.SetRegC(cpu._ram.Read(cpu._rb));
    private static void LdDB(Cpu cpu) => cpu.SetRegD(cpu._ram.Read(cpu._rb));
    private static void LdAC(Cpu cpu) => cpu.SetRegA(cpu._ram.Read(cpu._rc));
    private static void LdBC(Cpu cpu) => cpu.SetRegB(cpu._ram.Read(cpu._rc));
    private static void LdCC(Cpu cpu) => cpu.SetRegC(cpu._ram.Read(cpu._rc));
    private static void LdDC(Cpu cpu) => cpu.SetRegD(cpu._ram.Read(cpu._rc));
    private static void LdAD(Cpu cpu) => cpu.SetRegA(cpu._ram.Read(cpu._rd));
    private static void LdBD(Cpu cpu) => cpu.SetRegB(cpu._ram.Read(cpu._rd));
    private static void LdCD(Cpu cpu) => cpu.SetRegC(cpu._ram.Read(cpu._rd));
    private static void LdDD(Cpu cpu) => cpu.SetRegD(cpu._ram.Read(cpu._rd));

    #endregion

    #region Ld X / Ldi X

    private static void LdA(Cpu cpu) => cpu.SetRegA(cpu._ram.Read(cpu.GetArgument()));
    private static void LdB(Cpu cpu) => cpu.SetRegB(cpu._ram.Read(cpu.GetArgument()));
    private static void LdC(Cpu cpu) => cpu.SetRegC(cpu._ram.Read(cpu.GetArgument()));
    private static void LdD(Cpu cpu) => cpu.SetRegD(cpu._ram.Read(cpu.GetArgument()));

    private static void LdiA(Cpu cpu) => cpu.SetRegA(cpu.GetArgument());
    private static void LdiB(Cpu cpu) => cpu.SetRegB(cpu.GetArgument());
    private static void LdiC(Cpu cpu) => cpu.SetRegC(cpu.GetArgument());
    private static void LdiD(Cpu cpu) => cpu.SetRegD(cpu.GetArgument());

    #endregion

    #region Clr / Test

    private static void ClrA(Cpu cpu) => cpu.SetRegA(0);
    private static void ClrB(Cpu cpu) => cpu.SetRegB(0);
    private static void ClrC(Cpu cpu) => cpu.SetRegC(0);
    private static void ClrD(Cpu cpu) => cpu.SetRegD(0);

    private static void TestA(Cpu cpu) => cpu.SetFlagsZS(cpu._ra);
    private static void TestB(Cpu cpu) => cpu.SetFlagsZS(cpu._rb);
    private static void TestC(Cpu cpu) => cpu.SetFlagsZS(cpu._rc);
    private static void TestD(Cpu cpu) => cpu.SetFlagsZS(cpu._rd);

    #endregion

    #region Mov

    private static void MovBA(Cpu cpu) => cpu.SetRegB(cpu._ra);
    private static void MovCA(Cpu cpu) => cpu.SetRegC(cpu._ra);
    private static void MovDA(Cpu cpu) => cpu.SetRegD(cpu._ra);
    private static void MovAB(Cpu cpu) => cpu.SetRegA(cpu._rb);
    private static void MovCB(Cpu cpu) => cpu.SetRegC(cpu._rb);
    private static void MovDB(Cpu cpu) => cpu.SetRegD(cpu._rb);
    private static void MovAC(Cpu cpu) => cpu.SetRegA(cpu._rc);
    private static void MovBC(Cpu cpu) => cpu.SetRegB(cpu._rc);
    private static void MovDC(Cpu cpu) => cpu.SetRegD(cpu._rc);
    private static void MovAD(Cpu cpu) => cpu.SetRegA(cpu._rd);
    private static void MovBD(Cpu cpu) => cpu.SetRegB(cpu._rd);
    private static void MovCD(Cpu cpu) => cpu.SetRegC(cpu._rd);

    #endregion

    #region And

    private static void AndBA(Cpu cpu)
    {
        cpu.SetRegB(cpu._rb & cpu._ra);
        cpu.SetFlagsZS(cpu._rb);
    }

    private static void AndCA(Cpu cpu)
    {
        cpu.SetRegC(cpu._rc & cpu._ra);
        cpu.SetFlagsZS(cpu._rc);
    }

    private static void AndDA(Cpu cpu)
    {
        cpu.SetRegD(cpu._rd & cpu._ra);
        cpu.SetFlagsZS(cpu._rd);
    }

    private static void AndAB(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra & cpu._rb);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void AndCB(Cpu cpu)
    {
        cpu.SetRegC(cpu._rc & cpu._rb);
        cpu.SetFlagsZS(cpu._rc);
    }

    private static void AndDB(Cpu cpu)
    {
        cpu.SetRegD(cpu._rd & cpu._rb);
        cpu.SetFlagsZS(cpu._rd);
    }

    private static void AndBC(Cpu cpu)
    {
        cpu.SetRegB(cpu._rb & cpu._rc);
        cpu.SetFlagsZS(cpu._rb);
    }

    private static void AndAC(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra & cpu._rc);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void AndDC(Cpu cpu)
    {
        cpu.SetRegD(cpu._rd & cpu._rc);
        cpu.SetFlagsZS(cpu._rd);
    }

    private static void AndAD(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra & cpu._rd);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void AndBD(Cpu cpu)
    {
        cpu.SetRegB(cpu._rb & cpu._rd);
        cpu.SetFlagsZS(cpu._rb);
    }

    private static void AndCD(Cpu cpu)
    {
        cpu.SetRegC(cpu._rc & cpu._rd);
        cpu.SetFlagsZS(cpu._rc);
    }

    #endregion

    #region Or

    private static void OrBA(Cpu cpu)
    {
        cpu.SetRegB(cpu._rb | cpu._ra);
        cpu.SetFlagsZS(cpu._rb);
    }

    private static void OrCA(Cpu cpu)
    {
        cpu.SetRegC(cpu._rc | cpu._ra);
        cpu.SetFlagsZS(cpu._rc);
    }

    private static void OrDA(Cpu cpu)
    {
        cpu.SetRegD(cpu._rd | cpu._ra);
        cpu.SetFlagsZS(cpu._rd);
    }

    private static void OrAB(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra | cpu._rb);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void OrCB(Cpu cpu)
    {
        cpu.SetRegC(cpu._rc | cpu._rb);
        cpu.SetFlagsZS(cpu._rc);
    }

    private static void OrDB(Cpu cpu)
    {
        cpu.SetRegD(cpu._rd | cpu._rb);
        cpu.SetFlagsZS(cpu._rd);
    }

    private static void OrBC(Cpu cpu)
    {
        cpu.SetRegB(cpu._rb | cpu._rc);
        cpu.SetFlagsZS(cpu._rb);
    }

    private static void OrAC(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra | cpu._rc);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void OrDC(Cpu cpu)
    {
        cpu.SetRegD(cpu._rd | cpu._rc);
        cpu.SetFlagsZS(cpu._rd);
    }

    private static void OrAD(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra | cpu._rd);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void OrBD(Cpu cpu)
    {
        cpu.SetRegB(cpu._rb | cpu._rd);
        cpu.SetFlagsZS(cpu._rb);
    }

    private static void OrCD(Cpu cpu)
    {
        cpu.SetRegC(cpu._rc | cpu._rd);
        cpu.SetFlagsZS(cpu._rc);
    }

    #endregion

    #region Xor

    private static void XorBA(Cpu cpu)
    {
        cpu.SetRegB(cpu._rb ^ cpu._ra);
        cpu.SetFlagsZS(cpu._rb);
    }

    private static void XorCA(Cpu cpu)
    {
        cpu.SetRegC(cpu._rc ^ cpu._ra);
        cpu.SetFlagsZS(cpu._rc);
    }

    private static void XorDA(Cpu cpu)
    {
        cpu.SetRegD(cpu._rd ^ cpu._ra);
        cpu.SetFlagsZS(cpu._rd);
    }

    private static void XorAB(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra ^ cpu._rb);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void XorCB(Cpu cpu)
    {
        cpu.SetRegC(cpu._rc ^ cpu._rb);
        cpu.SetFlagsZS(cpu._rc);
    }

    private static void XorDB(Cpu cpu)
    {
        cpu.SetRegD(cpu._rd ^ cpu._rb);
        cpu.SetFlagsZS(cpu._rd);
    }

    private static void XorBC(Cpu cpu)
    {
        cpu.SetRegB(cpu._rb ^ cpu._rc);
        cpu.SetFlagsZS(cpu._rb);
    }

    private static void XorAC(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra ^ cpu._rc);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void XorDC(Cpu cpu)
    {
        cpu.SetRegD(cpu._rd ^ cpu._rc);
        cpu.SetFlagsZS(cpu._rd);
    }

    private static void XorAD(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra ^ cpu._rd);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void XorBD(Cpu cpu)
    {
        cpu.SetRegB(cpu._rb ^ cpu._rd);
        cpu.SetFlagsZS(cpu._rb);
    }

    private static void XorCD(Cpu cpu)
    {
        cpu.SetRegC(cpu._rc ^ cpu._rd);
        cpu.SetFlagsZS(cpu._rc);
    }

    #endregion

    #region Inc / Dec

    private static void IncA(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra + 1);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void IncB(Cpu cpu)
    {
        cpu.SetRegB(cpu._rb + 1);
        cpu.SetFlagsZS(cpu._rb);
    }

    private static void IncC(Cpu cpu)
    {
        cpu.SetRegC(cpu._rc + 1);
        cpu.SetFlagsZS(cpu._rc);
    }

    private static void IncD(Cpu cpu)
    {
        cpu.SetRegD(cpu._rd + 1);
        cpu.SetFlagsZS(cpu._rd);
    }

    private static void DecA(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra - 1);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void DecB(Cpu cpu)
    {
        cpu.SetRegB(cpu._rb - 1);
        cpu.SetFlagsZS(cpu._rb);
    }

    private static void DecC(Cpu cpu)
    {
        cpu.SetRegC(cpu._rc - 1);
        cpu.SetFlagsZS(cpu._rc);
    }

    private static void DecD(Cpu cpu)
    {
        cpu.SetRegD(cpu._rd - 1);
        cpu.SetFlagsZS(cpu._rd);
    }

    #endregion

    #region Add

    private static void AddBA(Cpu cpu)
    {
        MyByte result = cpu._rb + cpu._ra;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rb.IsSigned && cpu._ra.IsSigned);
        cpu.SetFlagsO(cpu._rb.IsSigned == cpu._ra.IsSigned && cpu._ra.IsSigned != result.IsSigned);
        cpu.SetRegB(result);
    }

    private static void AddCA(Cpu cpu)
    {
        MyByte result = cpu._rc + cpu._ra;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rc.IsSigned && cpu._ra.IsSigned);
        cpu.SetFlagsO(cpu._rc.IsSigned == cpu._ra.IsSigned && cpu._ra.IsSigned != result.IsSigned);
        cpu.SetRegC(result);
    }

    private static void AddDA(Cpu cpu)
    {
        MyByte result = cpu._rd + cpu._ra;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rd.IsSigned && cpu._ra.IsSigned);
        cpu.SetFlagsO(cpu._rd.IsSigned == cpu._ra.IsSigned && cpu._ra.IsSigned != result.IsSigned);
        cpu.SetRegD(result);
    }

    private static void AddAB(Cpu cpu)
    {
        MyByte result = cpu._ra + cpu._rb;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._ra.IsSigned && cpu._rb.IsSigned);
        cpu.SetFlagsO(cpu._ra.IsSigned == cpu._rb.IsSigned && cpu._rb.IsSigned != result.IsSigned);
        cpu.SetRegA(result);
    }

    private static void AddCB(Cpu cpu)
    {
        MyByte result = cpu._rc + cpu._rb;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rc.IsSigned && cpu._rb.IsSigned);
        cpu.SetFlagsO(cpu._rc.IsSigned == cpu._rb.IsSigned && cpu._rb.IsSigned != result.IsSigned);
        cpu.SetRegC(result);
    }

    private static void AddDB(Cpu cpu)
    {
        MyByte result = cpu._rd + cpu._rb;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rd.IsSigned && cpu._rb.IsSigned);
        cpu.SetFlagsO(cpu._rd.IsSigned == cpu._rb.IsSigned && cpu._rb.IsSigned != result.IsSigned);
        cpu.SetRegD(result);
    }

    private static void AddAC(Cpu cpu)
    {
        MyByte result = cpu._ra + cpu._rc;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._ra.IsSigned && cpu._rc.IsSigned);
        cpu.SetFlagsO(cpu._ra.IsSigned == cpu._rc.IsSigned && cpu._rb.IsSigned != result.IsSigned);
        cpu.SetRegA(result);
    }

    private static void AddBC(Cpu cpu)
    {
        MyByte result = cpu._rb + cpu._rc;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rb.IsSigned && cpu._rc.IsSigned);
        cpu.SetFlagsO(cpu._rb.IsSigned == cpu._rc.IsSigned && cpu._rc.IsSigned != result.IsSigned);
        cpu.SetRegB(result);
    }

    private static void AddDC(Cpu cpu)
    {
        MyByte result = cpu._rd + cpu._rc;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rd.IsSigned && cpu._rc.IsSigned);
        cpu.SetFlagsO(cpu._rd.IsSigned == cpu._rc.IsSigned && cpu._rc.IsSigned != result.IsSigned);
        cpu.SetRegD(result);
    }

    private static void AddAD(Cpu cpu)
    {
        MyByte result = cpu._ra + cpu._rd;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._ra.IsSigned && cpu._rd.IsSigned);
        cpu.SetFlagsO(cpu._ra.IsSigned == cpu._rd.IsSigned && cpu._rb.IsSigned != result.IsSigned);
        cpu.SetRegA(result);
    }

    private static void AddBD(Cpu cpu)
    {
        MyByte result = cpu._rb + cpu._rd;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rb.IsSigned && cpu._rd.IsSigned);
        cpu.SetFlagsO(cpu._rb.IsSigned == cpu._rd.IsSigned && cpu._rd.IsSigned != result.IsSigned);
        cpu.SetRegB(result);
    }

    private static void AddCD(Cpu cpu)
    {
        MyByte result = cpu._rc + cpu._rd;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rc.IsSigned && cpu._rd.IsSigned);
        cpu.SetFlagsO(cpu._rc.IsSigned == cpu._rd.IsSigned && cpu._rd.IsSigned != result.IsSigned);
        cpu.SetRegC(result);
    }

    #endregion

    #region Rcl / Rcr

    private static void RclA(Cpu cpu)
    {
        MyByte shifted = cpu._ra << 1;

        if (cpu._fc)
            shifted |= 1;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC(cpu._ra.IsSigned);
        cpu.SetRegA(shifted);
    }

    private static void RclB(Cpu cpu)
    {
        MyByte shifted = cpu._rb << 1;

        if (cpu._fc)
            shifted |= 1;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC(cpu._rb.IsSigned);
        cpu.SetRegB(shifted);
    }

    private static void RclC(Cpu cpu)
    {
        MyByte shifted = cpu._rc << 1;

        if (cpu._fc)
            shifted |= 1;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC(cpu._rc.IsSigned);
        cpu.SetRegC(shifted);
    }

    private static void RclD(Cpu cpu)
    {
        MyByte shifted = cpu._rd << 1;

        if (cpu._fc)
            shifted |= 1;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC(cpu._rd.IsSigned);
        cpu.SetRegD(shifted);
    }

    private static void RcrA(Cpu cpu)
    {
        MyByte shifted = cpu._ra >> 1;

        if (cpu._fc)
            shifted |= 128;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC((cpu._ra & 1) != 0);
        cpu.SetRegA(shifted);
    }

    private static void RcrB(Cpu cpu)
    {
        MyByte shifted = cpu._rb >> 1;

        if (cpu._fc)
            shifted |= 128;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC((cpu._rb & 1) != 0);
        cpu.SetRegB(shifted);
    }

    private static void RcrC(Cpu cpu)
    {
        MyByte shifted = cpu._rc >> 1;

        if (cpu._fc)
            shifted |= 128;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC((cpu._rc & 1) != 0);
        cpu.SetRegC(shifted);
    }

    private static void RcrD(Cpu cpu)
    {
        MyByte shifted = cpu._rd >> 1;

        if (cpu._fc)
            shifted |= 128;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC((cpu._rd & 1) != 0);
        cpu.SetRegD(shifted);
    }

    #endregion

    #region Sub

    private static void SubBA(Cpu cpu)
    {
        MyByte result = cpu._rb - cpu._ra;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rb < cpu._ra);
        cpu.SetFlagsO(cpu._rb.IsSigned != cpu._ra.IsSigned && cpu._ra.IsSigned == result.IsSigned);
        cpu.SetRegB(result);
    }

    private static void SubCA(Cpu cpu)
    {
        MyByte result = cpu._rc - cpu._ra;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rc < cpu._ra);
        cpu.SetFlagsO(cpu._rc.IsSigned != cpu._ra.IsSigned && cpu._ra.IsSigned == result.IsSigned);
        cpu.SetRegC(result);
    }

    private static void SubDA(Cpu cpu)
    {
        MyByte result = cpu._rd - cpu._ra;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rd < cpu._ra);
        cpu.SetFlagsO(cpu._rd.IsSigned != cpu._ra.IsSigned && cpu._ra.IsSigned == result.IsSigned);
        cpu.SetRegD(result);
    }

    private static void SubAB(Cpu cpu)
    {
        MyByte result = cpu._ra - cpu._rb;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._ra < cpu._rb);
        cpu.SetFlagsO(cpu._ra.IsSigned != cpu._rb.IsSigned && cpu._rb.IsSigned == result.IsSigned);
        cpu.SetRegA(result);
    }

    private static void SubCB(Cpu cpu)
    {
        MyByte result = cpu._rc - cpu._rb;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rc < cpu._rb);
        cpu.SetFlagsO(cpu._rc.IsSigned != cpu._rb.IsSigned && cpu._rb.IsSigned == result.IsSigned);
        cpu.SetRegC(result);
    }

    private static void SubDB(Cpu cpu)
    {
        MyByte result = cpu._rd - cpu._rb;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rd < cpu._rb);
        cpu.SetFlagsO(cpu._rd.IsSigned != cpu._rb.IsSigned && cpu._rb.IsSigned == result.IsSigned);
        cpu.SetRegD(result);
    }

    private static void SubAC(Cpu cpu)
    {
        MyByte result = cpu._ra - cpu._rc;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._ra < cpu._rb);
        cpu.SetFlagsO(cpu._ra.IsSigned != cpu._rb.IsSigned && cpu._rb.IsSigned == result.IsSigned);
        cpu.SetRegA(result);
    }

    private static void SubBC(Cpu cpu)
    {
        MyByte result = cpu._rb - cpu._rc;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rb < cpu._rc);
        cpu.SetFlagsO(cpu._rb.IsSigned != cpu._rc.IsSigned && cpu._rc.IsSigned == result.IsSigned);
        cpu.SetRegB(result);
    }

    private static void SubDC(Cpu cpu)
    {
        MyByte result = cpu._rd - cpu._rc;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rd < cpu._rc);
        cpu.SetFlagsO(cpu._rd.IsSigned != cpu._rc.IsSigned && cpu._rc.IsSigned == result.IsSigned);
        cpu.SetRegD(result);
    }

    private static void SubAD(Cpu cpu)
    {
        MyByte result = cpu._ra - cpu._rd;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._ra < cpu._rb);
        cpu.SetFlagsO(cpu._ra.IsSigned != cpu._rb.IsSigned && cpu._rb.IsSigned == result.IsSigned);
        cpu.SetRegA(result);
    }

    private static void SubBD(Cpu cpu)
    {
        MyByte result = cpu._rb - cpu._rd;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rb < cpu._rd);
        cpu.SetFlagsO(cpu._rb.IsSigned != cpu._rd.IsSigned && cpu._rd.IsSigned == result.IsSigned);
        cpu.SetRegB(result);
    }

    private static void SubCD(Cpu cpu)
    {
        MyByte result = cpu._rc - cpu._rd;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._rc < cpu._rd);
        cpu.SetFlagsO(cpu._rc.IsSigned != cpu._rd.IsSigned && cpu._rd.IsSigned == result.IsSigned);
        cpu.SetRegC(result);
    }

    #endregion

    #region Shl / Shr

    private static void ShlA(Cpu cpu)
    {
        MyByte shifted = cpu._ra << 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC(cpu._ra.IsSigned);
        cpu.SetRegA(shifted);
    }

    private static void ShlB(Cpu cpu)
    {
        MyByte shifted = cpu._rb << 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC(cpu._rb.IsSigned);
        cpu.SetRegB(shifted);
    }

    private static void ShlC(Cpu cpu)
    {
        MyByte shifted = cpu._rc << 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC(cpu._rc.IsSigned);
        cpu.SetRegC(shifted);
    }

    private static void ShlD(Cpu cpu)
    {
        MyByte shifted = cpu._rd << 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC(cpu._rd.IsSigned);
        cpu.SetRegD(shifted);
    }

    private static void ShrA(Cpu cpu)
    {
        MyByte shifted = cpu._ra >> 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC((cpu._ra & 1) != 0);
        cpu.SetRegA(shifted);
    }

    private static void ShrB(Cpu cpu)
    {
        MyByte shifted = cpu._rb >> 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC((cpu._rb & 1) != 0);
        cpu.SetRegB(shifted);
    }

    private static void ShrC(Cpu cpu)
    {
        MyByte shifted = cpu._rc >> 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC((cpu._rc & 1) != 0);
        cpu.SetRegC(shifted);
    }

    private static void ShrD(Cpu cpu)
    {
        MyByte shifted = cpu._rd >> 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsC((cpu._rd & 1) != 0);
        cpu.SetRegD(shifted);
    }

    #endregion

    #region Rnd

    private static void RndA(Cpu cpu) => cpu.SetRegA(_random.Next(0, 256));
    private static void RndB(Cpu cpu) => cpu.SetRegB(_random.Next(0, 256));
    private static void RndC(Cpu cpu) => cpu.SetRegC(_random.Next(0, 256));
    private static void RndD(Cpu cpu) => cpu.SetRegD(_random.Next(0, 256));

    #endregion

    private readonly IReadOnlyList<Instruction> _instructions =
    [
        new Instruction("nop", Nop), // 00
        new Instruction("hlt", Hlt),
        new Instruction("(reserved)", Command),
        new Instruction("jmp", Jmp),
        new Instruction("jmp a", JmpA),
        new Instruction("jmp b", JmpB),
        new Instruction("jmp c", JmpC),
        new Instruction("jmp d", JmpD),
        new Instruction("jz", Jz),
        new Instruction("js", Js),
        new Instruction("jc", Jc),
        new Instruction("jo", Jo),
        new Instruction("jnz", Jnz),
        new Instruction("jns", Jns),
        new Instruction("jnc", Jnc),
        new Instruction("jno", Jno),
        new Instruction("jz a", JzA), // 10
        new Instruction("js a", JsA),
        new Instruction("jc a", JcA),
        new Instruction("jo a", JoA),
        new Instruction("jz b", JzB),
        new Instruction("js b", JsB),
        new Instruction("jc b", JcB),
        new Instruction("jo b", JoB),
        new Instruction("jz c", JzC),
        new Instruction("js c", JsC),
        new Instruction("jc c", JcC),
        new Instruction("jo c", JoC),
        new Instruction("jz d", JzD),
        new Instruction("js d", JsD),
        new Instruction("jc d", JcD),
        new Instruction("jo d", JoD),
        new Instruction("jnz a", JnzA), // 20
        new Instruction("jns a", JnsA),
        new Instruction("jnc a", JncA),
        new Instruction("jno a", JnoA),
        new Instruction("jnz b", JnzB),
        new Instruction("jns b", JnsB),
        new Instruction("jnc b", JncB),
        new Instruction("jno b", JnoB),
        new Instruction("jnz c", JnzC),
        new Instruction("jns c", JnsC),
        new Instruction("jnc c", JncC),
        new Instruction("jno c", JnoC),
        new Instruction("jnz d", JnzD),
        new Instruction("jns d", JnsD),
        new Instruction("jnc d", JncD),
        new Instruction("jno d", JnoD),
        new Instruction("st a", StA), // 30
        new Instruction("st b, a", StBA),
        new Instruction("st c, a", StCA),
        new Instruction("st d, a", StDA),
        new Instruction("st a, b", StAB),
        new Instruction("st b", StB),
        new Instruction("st c, b", StCB),
        new Instruction("st d, b", StDB),
        new Instruction("st a, c", StAC),
        new Instruction("st b, c", StBC),
        new Instruction("st c", StC),
        new Instruction("st d, c", StDC),
        new Instruction("st a, d", StAD),
        new Instruction("st b, d", StBD),
        new Instruction("st c, d", StCD),
        new Instruction("st d", StD),
        new Instruction("ld a, a", LdAA), // 40
        new Instruction("ld b, a", LdBA),
        new Instruction("ld c, a", LdCA),
        new Instruction("ld d, a", LdDA),
        new Instruction("ld a, b", LdAB),
        new Instruction("ld b, b", LdBB),
        new Instruction("ld c, b", LdCB),
        new Instruction("ld d, b", LdDB),
        new Instruction("ld a, c", LdAC),
        new Instruction("ld b, c", LdBC),
        new Instruction("ld c, c", LdCC),
        new Instruction("ld d, c", LdDC),
        new Instruction("ld a, d", LdAD),
        new Instruction("ld b, d", LdBD),
        new Instruction("ld c, d", LdCD),
        new Instruction("ld d, d", LdDD),
        new Instruction("ld a", LdA), // 50
        new Instruction("ld b", LdB),
        new Instruction("ld c", LdC),
        new Instruction("ld d", LdD),
        new Instruction("ldi a", LdiA),
        new Instruction("ldi b", LdiB),
        new Instruction("ldi c", LdiC),
        new Instruction("ldi d", LdiD),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("clr a", ClrA), // 60
        new Instruction("mov b, a", MovBA),
        new Instruction("mov c, a", MovCA),
        new Instruction("mov d, a", MovDA),
        new Instruction("mov a, b", MovAB),
        new Instruction("clr b", ClrB),
        new Instruction("mov c, b", MovCB),
        new Instruction("mov d, b", MovDB),
        new Instruction("mov a, c", MovAC),
        new Instruction("mov b, c", MovBC),
        new Instruction("clr c", ClrC),
        new Instruction("mov d, c", MovDC),
        new Instruction("mov a, d", MovAD),
        new Instruction("mov b, d", MovBD),
        new Instruction("mov c, d", MovCD),
        new Instruction("clr d", ClrD),
        new Instruction("test a", TestA), // 70
        new Instruction("and b, a", AndBA),
        new Instruction("and c, a", AndCA),
        new Instruction("and d, a", AndDA),
        new Instruction("and a, b", AndAB),
        new Instruction("test b", TestB),
        new Instruction("and c, b", AndCB),
        new Instruction("and d, b", AndDB),
        new Instruction("and a, c", AndAC),
        new Instruction("and b, c", AndBC),
        new Instruction("test c", TestC),
        new Instruction("and d, c", AndDC),
        new Instruction("and a, d", AndAD),
        new Instruction("and b, d", AndBD),
        new Instruction("and c, d", AndCD),
        new Instruction("test d", TestD),
        new Instruction("not a", Command), // 80
        new Instruction("or b, a", OrBA),
        new Instruction("or c, a", OrCA),
        new Instruction("or d, a", OrDA),
        new Instruction("or a, b", OrAB),
        new Instruction("not b", Command),
        new Instruction("or c, b", OrCB),
        new Instruction("or d, b", OrDB),
        new Instruction("or a, c", OrAC),
        new Instruction("or b, c", OrBC),
        new Instruction("not c", Command),
        new Instruction("or d, c", OrDC),
        new Instruction("or a, d", OrAD),
        new Instruction("or b, d", OrBD),
        new Instruction("or c, d", OrCD),
        new Instruction("not d", Command),
        new Instruction("neg a", Command), // 90
        new Instruction("xor b, a", XorBA),
        new Instruction("xor c, a", XorCA),
        new Instruction("xor d, a", XorDA),
        new Instruction("xor a, b", XorAB),
        new Instruction("neg b", Command),
        new Instruction("xor c, b", XorCB),
        new Instruction("xor d, b", XorDB),
        new Instruction("xor a, c", XorAC),
        new Instruction("xor b, c", XorBC),
        new Instruction("neg c", Command),
        new Instruction("xor d, c", XorDC),
        new Instruction("xor a, d", XorAD),
        new Instruction("xor b, d", XorBD),
        new Instruction("xor c, d", XorCD),
        new Instruction("neg d", Command),
        new Instruction("inc a", IncA), // A0
        new Instruction("add b, a", AddBA),
        new Instruction("add c, a", AddCA),
        new Instruction("add d, a", AddDA),
        new Instruction("add a, b", AddAB),
        new Instruction("inc b", IncB),
        new Instruction("add c, b", AddCB),
        new Instruction("add d, b", AddDB),
        new Instruction("add a, c", AddAC),
        new Instruction("add b, c", AddBC),
        new Instruction("inc c", IncC),
        new Instruction("add d, c", AddDC),
        new Instruction("add a, d", AddAD),
        new Instruction("add b, d", AddBD),
        new Instruction("add c, d", AddCD),
        new Instruction("inc d", IncD),
        new Instruction("dec a", DecA), // B0
        new Instruction("adc b, a", Command),
        new Instruction("adc c, a", Command),
        new Instruction("adc d, a", Command),
        new Instruction("adc a, b", Command),
        new Instruction("dec b", DecB),
        new Instruction("adc c, b", Command),
        new Instruction("adc d, b", Command),
        new Instruction("adc a, c", Command),
        new Instruction("adc b, c", Command),
        new Instruction("dec c", DecC),
        new Instruction("adc d, c", Command),
        new Instruction("adc a, d", Command),
        new Instruction("adc b, d", Command),
        new Instruction("adc c, d", Command),
        new Instruction("dec d", DecD),
        new Instruction("rcl a", RclA), // C0
        new Instruction("sub b, a", SubBA),
        new Instruction("sub c, a", SubCA),
        new Instruction("sub d, a", SubDA),
        new Instruction("sub a, b", SubAB),
        new Instruction("rcl b", RclB),
        new Instruction("sub c, b", SubCB),
        new Instruction("sub d, b", SubDB),
        new Instruction("sub a, c", SubAC),
        new Instruction("sub b, c", SubBC),
        new Instruction("rcl c", RclC),
        new Instruction("sub d, c", SubDC),
        new Instruction("sub a, d", SubAD),
        new Instruction("sub b, d", SubBD),
        new Instruction("sub c, d", SubCD),
        new Instruction("rcl d", RclD),
        new Instruction("rcr a", RcrA), // D0
        new Instruction("sbb b, a", Command),
        new Instruction("sbb c, a", Command),
        new Instruction("sbb d, a", Command),
        new Instruction("sbb a, b", Command),
        new Instruction("rcr b", RcrB),
        new Instruction("sbb c, b", Command),
        new Instruction("sbb d, b", Command),
        new Instruction("sbb a, c", Command),
        new Instruction("sbb b, c", Command),
        new Instruction("rcr c", RcrC),
        new Instruction("sbb d, c", Command),
        new Instruction("sbb a, d", Command),
        new Instruction("sbb b, d", Command),
        new Instruction("sbb c, d", Command),
        new Instruction("rcr d", RcrD),
        new Instruction("shl a", ShlA), // E0
        new Instruction("shl b", ShlB),
        new Instruction("shl c", ShlC),
        new Instruction("shl d", ShlD),
        new Instruction("shr a", ShrA),
        new Instruction("shr b", ShrB),
        new Instruction("shr c", ShrC),
        new Instruction("shr d", ShrD),
        new Instruction("sar a", Command),
        new Instruction("sar b", Command),
        new Instruction("sar c", Command),
        new Instruction("sar d", Command),
        new Instruction("rnd a", RndA),
        new Instruction("rnd b", RndB),
        new Instruction("rnd c", RndC),
        new Instruction("rnd d", RndD),
        new Instruction("(reserved)", Command), // F0
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
    ];

    private class Instruction(string name, Action<Cpu> action)
    {
        public readonly string Name = name;
        public readonly Action<Cpu> Action = action;
    }

    #endregion
}
