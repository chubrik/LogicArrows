namespace ComputerEmulator.V1;

internal class Cpu(Ram ram)
{
    private static readonly Random _random = new();
    private static readonly MyByte _inAddr = new("3E");

    private readonly Ram _ram = ram;
    private int counter;
    private MyByte _ip;
    private MyByte _ir;
    private MyByte _ra;
    private MyByte _rb;
    private MyByte _rc;
    private MyByte _rd;
    private bool _fz;
    private bool _fc;
    private bool _fs;
    private bool _fo;
    private bool _raSetted;
    private bool _rbSetted;
    private bool _rcSetted;
    private bool _rdSetted;
    private bool _fzsSetted;
    private bool _fcSetted;
    private bool _foSetted;
    private bool _jumped;
    private bool _halted;
    private MyByte? _inQueued;

    public void Run()
    {
        for (; ; )
        {
            counter++;
            _ir = _ram.Read(_ip);
            State();
            var key = Console.ReadKey(intercept: true).Key;

            if (key == ConsoleKey.Escape)
                return;

            if (key != ConsoleKey.NumPad0)
            {
                var keyCode = key switch
                {
                    ConsoleKey.LeftArrow => 0x11,
                    ConsoleKey.UpArrow => 0x12,
                    ConsoleKey.RightArrow => 0x13,
                    ConsoleKey.DownArrow => 0x14,
                    ConsoleKey.Enter => 0x0A,
                    _ => (int)key
                };

                _inQueued = keyCode;
            }

            var instruction = _instructions[_ir];
            instruction.Action(this);

            if (!_jumped)
                _ip++;

            if (_halted)
                return;
        }
    }

    private MyByte GetArgument()
    {
        counter++;
        var argument = _ram.Read(++_ip);
        _ir = _ram.Read(_ip);
        State(isArgument: true);
        Console.ReadKey(intercept: true);
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

    private void State(bool isArgument = false)
    {
        var ipColor = _jumped ? "W" : "G";
        var irDescrColor = isArgument ? "d" : "G";
        var irDescr = isArgument ? "argument" : _instructions[_ir].Name;
        var raColor = _raSetted ? "W" : _ra != 0 ? "G" : "d";
        var rbColor = _rbSetted ? "W" : _rb != 0 ? "G" : "d";
        var rcColor = _rcSetted ? "W" : _rc != 0 ? "G" : "d";
        var rdColor = _rdSetted ? "W" : _rd != 0 ? "G" : "d";
        var fzColor = _fzsSetted ? "W" : _fz ? "G" : "d";
        var fcColor = _fcSetted ? "W" : _fc ? "G" : "d";
        var fsColor = _fzsSetted ? "W" : _fs ? "G" : "d";
        var foColor = _foSetted ? "W" : _fo ? "G" : "d";

        Console.WriteLine([
           $"d`{counter,5}  ",
           "d`IP:", $"{ipColor}`{_ip.Hex}  ",
           "d`IR:", $"G`{_ir.Hex}  ", $"{irDescrColor}`{irDescr,-10}  ",
           "d`A:", $"{raColor}`{_ra.Hex}  ",
           "d`B:", $"{rbColor}`{_rb.Hex}  ",
           "d`C:", $"{rcColor}`{_rc.Hex}  ",
           "d`D:", $"{rdColor}`{_rd.Hex}    ",
           "d`Z:", $"{fzColor}`{(_fz ? "1" : "0")}  ",
           "d`C:", $"{fcColor}`{(_fc ? "1" : "0")}  ",
           "d`S:", $"{fsColor}`{(_fs ? "1" : "0")}  ",
           "d`O:", $"{foColor}`{(_fo ? "1" : "0")}    ",
           $"d`3A:{_ram.Read("3A").Hex}  ",
           $"d`3B:{_ram.Read("3B").Hex}  ",
           $"d`3C:{_ram.Read("3C").Hex}  ",
           $"d`3E:{_ram.Read("3E").Hex}  ",
           $"d`3F:{_ram.Read("3F").Hex}"
        ]);

        _raSetted = _rbSetted = _rcSetted = _rdSetted = _fzsSetted = _fcSetted = _foSetted = _jumped = false;
    }

    [Obsolete]
    private static void Command(Cpu cpu) => throw new NotImplementedException();

    private static void CheckIn(Cpu cpu, MyByte addr)
    {
        if (addr == _inAddr && cpu._inQueued != null)
        {
            cpu._ram.Write(_inAddr, cpu._inQueued.Value);
            cpu._inQueued = null;
        }
    }

    #region Commands

    #region Mov

    private static void MovA0(Cpu cpu) => cpu.SetRegA(0);
    private static void MovAB(Cpu cpu) => cpu.SetRegA(cpu._rb);
    private static void MovAC(Cpu cpu) => cpu.SetRegA(cpu._rc);
    private static void MovAD(Cpu cpu) => cpu.SetRegA(cpu._rd);
    private static void MovBA(Cpu cpu) => cpu.SetRegB(cpu._ra);
    private static void MovCA(Cpu cpu) => cpu.SetRegC(cpu._ra);
    private static void MovDA(Cpu cpu) => cpu.SetRegD(cpu._ra);

    #endregion

    #region And

    private static void AndA0(Cpu cpu)
    {
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void AndAB(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra & cpu._rb);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void AndAC(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra & cpu._rc);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void AndAD(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra & cpu._rd);
        cpu.SetFlagsZS(cpu._ra);
    }

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

    #endregion

    #region Or

    private static void OrA0(Cpu cpu)
    {
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void OrAB(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra | cpu._rb);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void OrAC(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra | cpu._rc);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void OrAD(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra | cpu._rd);
        cpu.SetFlagsZS(cpu._ra);
    }

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

    #endregion

    #region Xor

    private static void XorA0(Cpu cpu)
    {
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void XorAB(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra ^ cpu._rb);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void XorAC(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra ^ cpu._rc);
        cpu.SetFlagsZS(cpu._ra);
    }

    private static void XorAD(Cpu cpu)
    {
        cpu.SetRegA(cpu._ra ^ cpu._rd);
        cpu.SetFlagsZS(cpu._ra);
    }

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

    #endregion

    #region Add

    private static void AddA0(Cpu cpu)
    {
        cpu.SetFlagsZS(cpu._ra);
        cpu.SetFlagsC(false);
        cpu.SetFlagsO(false);
    }

    private static void AddAB(Cpu cpu)
    {
        MyByte result = cpu._ra + cpu._rb;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._ra.IsSigned && cpu._rb.IsSigned);
        cpu.SetFlagsO(cpu._ra.IsSigned == cpu._rb.IsSigned && cpu._rb.IsSigned != result.IsSigned);
        cpu.SetRegA(result);
    }

    private static void AddAC(Cpu cpu)
    {
        MyByte result = cpu._ra + cpu._rc;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._ra.IsSigned && cpu._rc.IsSigned);
        cpu.SetFlagsO(cpu._ra.IsSigned == cpu._rc.IsSigned && cpu._rb.IsSigned != result.IsSigned);
        cpu.SetRegA(result);
    }

    private static void AddAD(Cpu cpu)
    {
        MyByte result = cpu._ra + cpu._rd;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._ra.IsSigned && cpu._rd.IsSigned);
        cpu.SetFlagsO(cpu._ra.IsSigned == cpu._rd.IsSigned && cpu._rb.IsSigned != result.IsSigned);
        cpu.SetRegA(result);
    }

    #endregion

    #region Sub

    private static void SubA0(Cpu cpu)
    {
        cpu.SetFlagsZS(cpu._ra);
        cpu.SetFlagsC(false);
        cpu.SetFlagsO(false);
    }

    private static void SubAB(Cpu cpu)
    {
        MyByte result = cpu._ra - cpu._rb;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._ra < cpu._rb);
        cpu.SetFlagsO(cpu._ra.IsSigned != cpu._rb.IsSigned && cpu._rb.IsSigned == result.IsSigned);
        cpu.SetRegA(result);
    }

    private static void SubAC(Cpu cpu)
    {
        MyByte result = cpu._ra - cpu._rc;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._ra < cpu._rb);
        cpu.SetFlagsO(cpu._ra.IsSigned != cpu._rb.IsSigned && cpu._rb.IsSigned == result.IsSigned);
        cpu.SetRegA(result);
    }

    private static void SubAD(Cpu cpu)
    {
        MyByte result = cpu._ra - cpu._rd;
        cpu.SetFlagsZS(result);
        cpu.SetFlagsC(cpu._ra < cpu._rb);
        cpu.SetFlagsO(cpu._ra.IsSigned != cpu._rb.IsSigned && cpu._rb.IsSigned == result.IsSigned);
        cpu.SetRegA(result);
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

    #region Ld X / Ldi X

    private static void LdA(Cpu cpu)
    {
        var addr = cpu.GetArgument();
        CheckIn(cpu, addr);
        cpu.SetRegA(cpu._ram.Read(addr));
    }

    private static void LdB(Cpu cpu)
    {
        var addr = cpu.GetArgument();
        CheckIn(cpu, addr);
        cpu.SetRegB(cpu._ram.Read(addr));
    }

    private static void LdC(Cpu cpu)
    {
        var addr = cpu.GetArgument();
        CheckIn(cpu, addr);
        cpu.SetRegC(cpu._ram.Read(addr));
    }

    private static void LdD(Cpu cpu)
    {
        var addr = cpu.GetArgument();
        CheckIn(cpu, addr);
        cpu.SetRegD(cpu._ram.Read(addr));
    }

    private static void LdiA(Cpu cpu) => cpu.SetRegA(cpu.GetArgument());
    private static void LdiB(Cpu cpu) => cpu.SetRegB(cpu.GetArgument());
    private static void LdiC(Cpu cpu) => cpu.SetRegC(cpu.GetArgument());
    private static void LdiD(Cpu cpu) => cpu.SetRegD(cpu.GetArgument());

    #endregion

    #region Ld X,Y

    private static void LdAA(Cpu cpu)
    {
        CheckIn(cpu, cpu._ra);
        cpu.SetRegA(cpu._ram.Read(cpu._ra));
    }

    private static void LdBA(Cpu cpu)
    {
        CheckIn(cpu, cpu._ra);
        cpu.SetRegB(cpu._ram.Read(cpu._ra));
    }

    private static void LdCA(Cpu cpu)
    {
        CheckIn(cpu, cpu._ra);
        cpu.SetRegC(cpu._ram.Read(cpu._ra));
    }

    private static void LdDA(Cpu cpu)
    {
        CheckIn(cpu, cpu._ra);
        cpu.SetRegD(cpu._ram.Read(cpu._ra));
    }

    private static void LdAB(Cpu cpu)
    {
        CheckIn(cpu, cpu._rb);
        cpu.SetRegA(cpu._ram.Read(cpu._rb));
    }

    private static void LdBB(Cpu cpu)
    {
        CheckIn(cpu, cpu._rb);
        cpu.SetRegB(cpu._ram.Read(cpu._rb));
    }

    private static void LdCB(Cpu cpu)
    {
        CheckIn(cpu, cpu._rb);
        cpu.SetRegC(cpu._ram.Read(cpu._rb));
    }

    private static void LdDB(Cpu cpu)
    {
        CheckIn(cpu, cpu._rb);
        cpu.SetRegD(cpu._ram.Read(cpu._rb));
    }

    private static void LdAC(Cpu cpu)
    {
        CheckIn(cpu, cpu._rc);
        cpu.SetRegA(cpu._ram.Read(cpu._rc));
    }

    private static void LdBC(Cpu cpu)
    {
        CheckIn(cpu, cpu._rc);
        cpu.SetRegB(cpu._ram.Read(cpu._rc));
    }

    private static void LdCC(Cpu cpu)
    {
        CheckIn(cpu, cpu._rc);
        cpu.SetRegC(cpu._ram.Read(cpu._rc));
    }

    private static void LdDC(Cpu cpu)
    {
        CheckIn(cpu, cpu._rc);
        cpu.SetRegD(cpu._ram.Read(cpu._rc));
    }

    private static void LdAD(Cpu cpu)
    {
        CheckIn(cpu, cpu._rd);
        cpu.SetRegA(cpu._ram.Read(cpu._rd));
    }

    private static void LdBD(Cpu cpu)
    {
        CheckIn(cpu, cpu._rd);
        cpu.SetRegB(cpu._ram.Read(cpu._rd));
    }

    private static void LdCD(Cpu cpu)
    {
        CheckIn(cpu, cpu._rd);
        cpu.SetRegC(cpu._ram.Read(cpu._rd));
    }

    private static void LdDD(Cpu cpu)
    {
        CheckIn(cpu, cpu._rd);
        cpu.SetRegD(cpu._ram.Read(cpu._rd));
    }

    #endregion

    #region Rnd

    private static void RndA(Cpu cpu) => cpu.SetRegA(_random.Next(0, 256));
    private static void RndB(Cpu cpu) => cpu.SetRegB(_random.Next(0, 256));
    private static void RndC(Cpu cpu) => cpu.SetRegC(_random.Next(0, 256));
    private static void RndD(Cpu cpu) => cpu.SetRegD(_random.Next(0, 256));

    #endregion

    #region St X

    private static void StA(Cpu cpu) => cpu._ram.Write(cpu.GetArgument(), cpu._ra);
    private static void StB(Cpu cpu) => cpu._ram.Write(cpu.GetArgument(), cpu._rb);
    private static void StC(Cpu cpu) => cpu._ram.Write(cpu.GetArgument(), cpu._rc);
    private static void StD(Cpu cpu) => cpu._ram.Write(cpu.GetArgument(), cpu._rd);

    #endregion

    #region St X,Y

    private static void StAA(Cpu cpu) => cpu._ram.Write(cpu._ra, cpu._ra);
    private static void StBA(Cpu cpu) => cpu._ram.Write(cpu._ra, cpu._rb);
    private static void StCA(Cpu cpu) => cpu._ram.Write(cpu._ra, cpu._rc);
    private static void StDA(Cpu cpu) => cpu._ram.Write(cpu._ra, cpu._rd);
    private static void StAB(Cpu cpu) => cpu._ram.Write(cpu._rb, cpu._ra);
    private static void StBB(Cpu cpu) => cpu._ram.Write(cpu._rb, cpu._rb);
    private static void StCB(Cpu cpu) => cpu._ram.Write(cpu._rb, cpu._rc);
    private static void StDB(Cpu cpu) => cpu._ram.Write(cpu._rb, cpu._rd);
    private static void StAC(Cpu cpu) => cpu._ram.Write(cpu._rc, cpu._ra);
    private static void StBC(Cpu cpu) => cpu._ram.Write(cpu._rc, cpu._rb);
    private static void StCC(Cpu cpu) => cpu._ram.Write(cpu._rc, cpu._rc);
    private static void StDC(Cpu cpu) => cpu._ram.Write(cpu._rc, cpu._rd);
    private static void StAD(Cpu cpu) => cpu._ram.Write(cpu._rd, cpu._ra);
    private static void StBD(Cpu cpu) => cpu._ram.Write(cpu._rd, cpu._rb);
    private static void StCD(Cpu cpu) => cpu._ram.Write(cpu._rd, cpu._rc);
    private static void StDD(Cpu cpu) => cpu._ram.Write(cpu._rd, cpu._rd);

    #endregion

    #region JF / JnF

    private static void Jz(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (cpu._fz)
        {
            cpu._ip = arg;
            cpu._jumped = true;
        }
    }

    private static void Jc(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (cpu._fc)
        {
            cpu._ip = arg;
            cpu._jumped = true;
        }
    }

    private static void Js(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (cpu._fs)
        {
            cpu._ip = arg;
            cpu._jumped = true;
        }
    }

    private static void Jo(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (cpu._fo)
        {
            cpu._ip = arg;
            cpu._jumped = true;
        }
    }

    private static void Jnz(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (!cpu._fz)
        {
            cpu._ip = arg;
            cpu._jumped = true;
        }
    }

    private static void Jnc(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (!cpu._fc)
        {
            cpu._ip = arg;
            cpu._jumped = true;
        }
    }

    private static void Jns(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (!cpu._fs)
        {
            cpu._ip = arg;
            cpu._jumped = true;
        }
    }

    private static void Jno(Cpu cpu)
    {
        var arg = cpu.GetArgument();

        if (!cpu._fo)
        {
            cpu._ip = arg;
            cpu._jumped = true;
        }
    }

    #endregion

    #region JF X

    private static void JzA(Cpu cpu)
    {
        if (cpu._fz)
        {
            cpu._ip = cpu._ra;
            cpu._jumped = true;
        }
    }

    private static void JcA(Cpu cpu)
    {
        if (cpu._fc)
        {
            cpu._ip = cpu._ra;
            cpu._jumped = true;
        }
    }

    private static void JsA(Cpu cpu)
    {
        if (cpu._fs)
        {
            cpu._ip = cpu._ra;
            cpu._jumped = true;
        }
    }

    private static void JoA(Cpu cpu)
    {
        if (cpu._fo)
        {
            cpu._ip = cpu._ra;
            cpu._jumped = true;
        }
    }

    private static void JzB(Cpu cpu)
    {
        if (cpu._fz)
        {
            cpu._ip = cpu._rb;
            cpu._jumped = true;
        }
    }

    private static void JcB(Cpu cpu)
    {
        if (cpu._fc)
        {
            cpu._ip = cpu._rb;
            cpu._jumped = true;
        }
    }

    private static void JsB(Cpu cpu)
    {
        if (cpu._fs)
        {
            cpu._ip = cpu._rb;
            cpu._jumped = true;
        }
    }

    private static void JoB(Cpu cpu)
    {
        if (cpu._fo)
        {
            cpu._ip = cpu._rb;
            cpu._jumped = true;
        }
    }

    private static void JzC(Cpu cpu)
    {
        if (cpu._fz)
        {
            cpu._ip = cpu._rc;
            cpu._jumped = true;
        }
    }

    private static void JcC(Cpu cpu)
    {
        if (cpu._fc)
        {
            cpu._ip = cpu._rc;
            cpu._jumped = true;
        }
    }

    private static void JsC(Cpu cpu)
    {
        if (cpu._fs)
        {
            cpu._ip = cpu._rc;
            cpu._jumped = true;
        }
    }

    private static void JoC(Cpu cpu)
    {
        if (cpu._fo)
        {
            cpu._ip = cpu._rc;
            cpu._jumped = true;
        }
    }

    private static void JzD(Cpu cpu)
    {
        if (cpu._fz)
        {
            cpu._ip = cpu._rd;
            cpu._jumped = true;
        }
    }

    private static void JcD(Cpu cpu)
    {
        if (cpu._fc)
        {
            cpu._ip = cpu._rd;
            cpu._jumped = true;
        }
    }

    private static void JsD(Cpu cpu)
    {
        if (cpu._fs)
        {
            cpu._ip = cpu._rd;
            cpu._jumped = true;
        }
    }

    private static void JoD(Cpu cpu)
    {
        if (cpu._fo)
        {
            cpu._ip = cpu._rd;
            cpu._jumped = true;
        }
    }

    #endregion

    #region JnF X

    private static void JnzA(Cpu cpu)
    {
        if (!cpu._fz)
        {
            cpu._ip = cpu._ra;
            cpu._jumped = true;
        }
    }

    private static void JncA(Cpu cpu)
    {
        if (!cpu._fc)
        {
            cpu._ip = cpu._ra;
            cpu._jumped = true;
        }
    }

    private static void JnsA(Cpu cpu)
    {
        if (!cpu._fs)
        {
            cpu._ip = cpu._ra;
            cpu._jumped = true;
        }
    }

    private static void JnoA(Cpu cpu)
    {
        if (!cpu._fo)
        {
            cpu._ip = cpu._ra;
            cpu._jumped = true;
        }
    }

    private static void JnzB(Cpu cpu)
    {
        if (!cpu._fz)
        {
            cpu._ip = cpu._rb;
            cpu._jumped = true;
        }
    }

    private static void JncB(Cpu cpu)
    {
        if (!cpu._fc)
        {
            cpu._ip = cpu._rb;
            cpu._jumped = true;
        }
    }

    private static void JnsB(Cpu cpu)
    {
        if (!cpu._fs)
        {
            cpu._ip = cpu._rb;
            cpu._jumped = true;
        }
    }

    private static void JnoB(Cpu cpu)
    {
        if (!cpu._fo)
        {
            cpu._ip = cpu._rb;
            cpu._jumped = true;
        }
    }

    private static void JnzC(Cpu cpu)
    {
        if (!cpu._fz)
        {
            cpu._ip = cpu._rc;
            cpu._jumped = true;
        }
    }

    private static void JncC(Cpu cpu)
    {
        if (!cpu._fc)
        {
            cpu._ip = cpu._rc;
            cpu._jumped = true;
        }
    }

    private static void JnsC(Cpu cpu)
    {
        if (!cpu._fs)
        {
            cpu._ip = cpu._rc;
            cpu._jumped = true;
        }
    }

    private static void JnoC(Cpu cpu)
    {
        if (!cpu._fo)
        {
            cpu._ip = cpu._rc;
            cpu._jumped = true;
        }
    }

    private static void JnzD(Cpu cpu)
    {
        if (!cpu._fz)
        {
            cpu._ip = cpu._rd;
            cpu._jumped = true;
        }
    }

    private static void JncD(Cpu cpu)
    {
        if (!cpu._fc)
        {
            cpu._ip = cpu._rd;
            cpu._jumped = true;
        }
    }

    private static void JnsD(Cpu cpu)
    {
        if (!cpu._fs)
        {
            cpu._ip = cpu._rd;
            cpu._jumped = true;
        }
    }

    private static void JnoD(Cpu cpu)
    {
        if (!cpu._fo)
        {
            cpu._ip = cpu._rd;
            cpu._jumped = true;
        }
    }

    #endregion

    #region Jmp / Jmp X / Hlt

    private static void Jmp(Cpu cpu)
    {
        cpu._ip = cpu.GetArgument();
        cpu._jumped = true;
    }

    private static void JmpA(Cpu cpu)
    {
        cpu._ip = cpu._ra;
        cpu._jumped = true;
    }

    private static void JmpB(Cpu cpu)
    {
        cpu._ip = cpu._rb;
        cpu._jumped = true;
    }

    private static void JmpC(Cpu cpu)
    {
        cpu._ip = cpu._rc;
        cpu._jumped = true;
    }

    private static void JmpD(Cpu cpu)
    {
        cpu._ip = cpu._rd;
        cpu._jumped = true;
    }

    private static void Hlt(Cpu cpu)
    {
        cpu._halted = true;
    }

    #endregion

    private readonly IReadOnlyList<Instruction> _instructions =
    [
        new Instruction("mov a, 0", MovA0), // 00
        new Instruction("mov a, b", MovAB),
        new Instruction("mov a, c", MovAC),
        new Instruction("mov a, d", MovAD),
        new Instruction("mov a, 0*", MovA0),
        new Instruction("mov b, a", MovBA),
        new Instruction("mov c, a", MovCA),
        new Instruction("mov d, a", MovDA),
        new Instruction("and a, 0", AndA0),
        new Instruction("and a, b", AndAB),
        new Instruction("and a, c", AndAC),
        new Instruction("and a, d", AndAD),
        new Instruction("and a, 0*", AndA0),
        new Instruction("and b, a", AndBA),
        new Instruction("and c, a", AndCA),
        new Instruction("and d, a", AndDA),
        new Instruction("or a, 0", OrA0), // 10
        new Instruction("or a, b", OrAB),
        new Instruction("or a, c", OrAC),
        new Instruction("or a, d", OrAD),
        new Instruction("or a, 0*", OrA0),
        new Instruction("or b, a", OrBA),
        new Instruction("or c, a", OrCA),
        new Instruction("or d, a", OrDA),
        new Instruction("xor a, 0", XorA0),
        new Instruction("xor a, b", XorAB),
        new Instruction("xor a, c", XorAC),
        new Instruction("xor a, d", XorAD),
        new Instruction("xor a, 0*", XorA0),
        new Instruction("xor b, a", XorBA),
        new Instruction("xor c, a", XorCA),
        new Instruction("xor d, a", XorDA),
        new Instruction("add a, 0", AddA0), // 20
        new Instruction("add a, b", AddAB),
        new Instruction("add a, c", AddAC),
        new Instruction("add a, d", AddAD),
        new Instruction("add a, 0*", AddA0),
        new Instruction("add b, a", Command),
        new Instruction("add c, a", Command),
        new Instruction("add d, a", Command),
        new Instruction("adc a, 0", Command),
        new Instruction("adc a, b", Command),
        new Instruction("adc a, c", Command),
        new Instruction("adc a, d", Command),
        new Instruction("adc a, 0*", Command),
        new Instruction("adc b, a", Command),
        new Instruction("adc c, a", Command),
        new Instruction("adc d, a", Command),
        new Instruction("sub a, 0", SubA0), // 30
        new Instruction("sub a, b", SubAB),
        new Instruction("sub a, c", SubAC),
        new Instruction("sub a, d", SubAD),
        new Instruction("sub a, 0*", SubA0),
        new Instruction("sub b, a", Command),
        new Instruction("sub c, a", Command),
        new Instruction("sub d, a", Command),
        new Instruction("sbb a, 0", Command),
        new Instruction("sbb a, b", Command),
        new Instruction("sbb a, c", Command),
        new Instruction("sbb a, d", Command),
        new Instruction("sbb a, 0*", Command),
        new Instruction("sbb b, a", Command),
        new Instruction("sbb c, a", Command),
        new Instruction("sbb d, a", Command),
        new Instruction("not a", Command), // 40
        new Instruction("not b", Command),
        new Instruction("not c", Command),
        new Instruction("not d", Command),
        new Instruction("neg a", Command),
        new Instruction("neg b", Command),
        new Instruction("neg c", Command),
        new Instruction("neg d", Command),
        new Instruction("inc a", IncA),
        new Instruction("inc b", IncB),
        new Instruction("inc c", IncC),
        new Instruction("inc d", IncD),
        new Instruction("dec a", DecA),
        new Instruction("dec b", DecB),
        new Instruction("dec c", DecC),
        new Instruction("dec d", DecD),
        new Instruction("shl a", ShlA), // 50
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
        new Instruction("exp a", Command),
        new Instruction("exp b", Command),
        new Instruction("exp c", Command),
        new Instruction("exp d", Command),
        new Instruction("rcl a", RclA), // 60
        new Instruction("rcl b", RclB),
        new Instruction("rcl c", RclC),
        new Instruction("rcl d", RclD),
        new Instruction("rcr a", RcrA),
        new Instruction("rcr b", RcrB),
        new Instruction("rcr c", RcrC),
        new Instruction("rcr d", RcrD),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command),
        new Instruction("(reserved)", Command), // 70
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
        new Instruction("ld a", LdA), // 80
        new Instruction("ld b", LdB),
        new Instruction("ld c", LdC),
        new Instruction("ld d", LdD),
        new Instruction("ld a*", LdA),
        new Instruction("ld b*", LdB),
        new Instruction("ld c*", LdC),
        new Instruction("ld d*", LdD),
        new Instruction("ldi a", LdiA),
        new Instruction("ldi b", LdiB),
        new Instruction("ldi c", LdiC),
        new Instruction("ldi d", LdiD),
        new Instruction("ldi a*", LdiA),
        new Instruction("ldi b*", LdiB),
        new Instruction("ldi c*", LdiC),
        new Instruction("ldi d*", LdiD),
        new Instruction("ld a, a", LdAA), // 90
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
        new Instruction("st a", StA), // A0
        new Instruction("st b", StB),
        new Instruction("st c", StC),
        new Instruction("st d", StD),
        new Instruction("st a*", StA),
        new Instruction("st b*", StB),
        new Instruction("st c*", StC),
        new Instruction("st d*", StD),
        new Instruction("rnd a", RndA),
        new Instruction("rnd b", RndB),
        new Instruction("rnd c", RndC),
        new Instruction("rnd d", RndD),
        new Instruction("rnd a*", RndA),
        new Instruction("rnd b*", RndB),
        new Instruction("rnd c*", RndC),
        new Instruction("rnd d*", RndD),
        new Instruction("st a, a", StAA), // B0
        new Instruction("st b, a", StBA),
        new Instruction("st c, a", StCA),
        new Instruction("st d, a", StDA),
        new Instruction("st a, b", StAB),
        new Instruction("st b, b", StBB),
        new Instruction("st c, b", StCB),
        new Instruction("st d, b", StDB),
        new Instruction("st a, c", StAC),
        new Instruction("st b, c", StBC),
        new Instruction("st c, c", StCC),
        new Instruction("st d, c", StDC),
        new Instruction("st a, d", StAD),
        new Instruction("st b, d", StBD),
        new Instruction("st c, d", StCD),
        new Instruction("st d, d", StDD),
        new Instruction("jz a", JzA), // C0
        new Instruction("jc a", JcA),
        new Instruction("js a", JsA),
        new Instruction("jo a", JoA),
        new Instruction("jz b", JzB),
        new Instruction("jc b", JcB),
        new Instruction("js b", JsB),
        new Instruction("jo b", JoB),
        new Instruction("jz c", JzC),
        new Instruction("jc c", JcC),
        new Instruction("js c", JsC),
        new Instruction("jo c", JoC),
        new Instruction("jz d", JzD),
        new Instruction("jc d", JcD),
        new Instruction("js d", JsD),
        new Instruction("jo d", JoD),
        new Instruction("jnz a", JnzA), // D0
        new Instruction("jnc a", JncA),
        new Instruction("jns a", JnsA),
        new Instruction("jno a", JnoA),
        new Instruction("jnz b", JnzB),
        new Instruction("jnc b", JncB),
        new Instruction("jns b", JnsB),
        new Instruction("jno b", JnoB),
        new Instruction("jnz c", JnzC),
        new Instruction("jnc c", JncC),
        new Instruction("jns c", JnsC),
        new Instruction("jno c", JnoC),
        new Instruction("jnz d", JnzD),
        new Instruction("jnc d", JncD),
        new Instruction("jns d", JnsD),
        new Instruction("jno d", JnoD),
        new Instruction("jz", Jz), // E0
        new Instruction("jc", Jc),
        new Instruction("js", Js),
        new Instruction("jo", Jo),
        new Instruction("jnz", Jnz),
        new Instruction("jnc", Jnc),
        new Instruction("jns", Jns),
        new Instruction("jno", Jno),
        new Instruction("jmp", Jmp),
        new Instruction("jmp*", Jmp),
        new Instruction("jmp*", Jmp),
        new Instruction("jmp*", Jmp),
        new Instruction("hlt", Hlt),
        new Instruction("hlt*", Hlt),
        new Instruction("hlt*", Hlt),
        new Instruction("hlt*", Hlt),
        new Instruction("jmp a", JmpA), // F0
        new Instruction("jmp a*", JmpA),
        new Instruction("jmp a*", JmpA),
        new Instruction("jmp a*", JmpA),
        new Instruction("jmp b", JmpB),
        new Instruction("jmp b*", JmpB),
        new Instruction("jmp b*", JmpB),
        new Instruction("jmp b*", JmpB),
        new Instruction("jmp c", JmpC),
        new Instruction("jmp c*", JmpC),
        new Instruction("jmp c*", JmpC),
        new Instruction("jmp c*", JmpC),
        new Instruction("jmp d", JmpD),
        new Instruction("jmp d*", JmpD),
        new Instruction("jmp d*", JmpD),
        new Instruction("jmp d*", JmpD),
    ];

    private class Instruction(string name, Action<Cpu> action)
    {
        public readonly string Name = name;
        public readonly Action<Cpu> Action = action;
    }

    #endregion
}
