using System.Drawing;

namespace ComputerEmulator;

internal class Cpu(Ram ram)
{
    private static readonly Random _random = new();
    private static readonly MyByte _inAddr = new("BE");

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
    private bool _fcoSetted;
    private bool _jumped;
    private MyByte _inQueued;

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

            if (key != ConsoleKey.Enter)
                _inQueued = (int)key;

            var instruction = _instructions[_ir];
            instruction.Action(this);

            if (!_jumped)
                _ip++;
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

    private void SetFlagsCO(bool fc, bool fo)
    {
        _fc = fc;
        _fo = fo;
        _fcoSetted = true;
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
        var fcColor = _fcoSetted ? "W" : _fc ? "G" : "d";
        var fsColor = _fzsSetted ? "W" : _fs ? "G" : "d";
        var foColor = _fcoSetted ? "W" : _fo ? "G" : "d";

        Console.WriteLine(
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
           $"d`BB:{_ram.Read("BB").Hex}  ",
           $"d`BC:{_ram.Read("BC").Hex}  ",
           $"d`BD:{_ram.Read("BD").Hex}  ",
           $"d`BE:{_ram.Read("BE").Hex}  ",
           $"d`BF:{_ram.Read("BF").Hex}"
        );

        _raSetted = _rbSetted = _rcSetted = _rdSetted = _fzsSetted = _fcoSetted = _jumped = false;
    }

    [Obsolete]
    private static void Command(Cpu cpu) => throw new NotImplementedException();

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
        cpu.SetFlagsCO(fc: false, fo: false);
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
        cpu.SetFlagsCO(fc: cpu._ra.IsSigned, fo: cpu._ra.IsSigned != shifted.IsSigned);
        cpu.SetRegA(shifted);
    }

    private static void ShlB(Cpu cpu)
    {
        MyByte shifted = cpu._rb << 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsCO(fc: cpu._rb.IsSigned, fo: cpu._rb.IsSigned != shifted.IsSigned);
        cpu.SetRegB(shifted);
    }

    private static void ShlC(Cpu cpu)
    {
        MyByte shifted = cpu._rc << 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsCO(fc: cpu._rc.IsSigned, fo: cpu._rc.IsSigned != shifted.IsSigned);
        cpu.SetRegC(shifted);
    }

    private static void ShlD(Cpu cpu)
    {
        MyByte shifted = cpu._rd << 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsCO(fc: cpu._rd.IsSigned, fo: cpu._rd.IsSigned != shifted.IsSigned);
        cpu.SetRegD(shifted);
    }

    private static void ShrA(Cpu cpu)
    {
        MyByte shifted = cpu._ra >> 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsCO(fc: (cpu._ra & 1) != 0, fo: cpu._ra.IsSigned != shifted.IsSigned);
        cpu.SetRegA(shifted);
    }

    private static void ShrB(Cpu cpu)
    {
        MyByte shifted = cpu._rb >> 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsCO(fc: (cpu._rb & 1) != 0, fo: cpu._rb.IsSigned != shifted.IsSigned);
        cpu.SetRegB(shifted);
    }

    private static void ShrC(Cpu cpu)
    {
        MyByte shifted = cpu._rc >> 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsCO(fc: (cpu._rc & 1) != 0, fo: cpu._rc.IsSigned != shifted.IsSigned);
        cpu.SetRegC(shifted);
    }

    private static void ShrD(Cpu cpu)
    {
        MyByte shifted = cpu._rd >> 1;
        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsCO(fc: (cpu._rd & 1) != 0, fo: cpu._rd.IsSigned != shifted.IsSigned);
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
        cpu.SetFlagsCO(fc: cpu._ra.IsSigned, fo: cpu._ra.IsSigned != shifted.IsSigned);
        cpu.SetRegA(shifted);
    }

    private static void RclB(Cpu cpu)
    {
        MyByte shifted = cpu._rb << 1;

        if (cpu._fc)
            shifted |= 1;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsCO(fc: cpu._rb.IsSigned, fo: cpu._rb.IsSigned != shifted.IsSigned);
        cpu.SetRegB(shifted);
    }

    private static void RclC(Cpu cpu)
    {
        MyByte shifted = cpu._rc << 1;

        if (cpu._fc)
            shifted |= 1;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsCO(fc: cpu._rc.IsSigned, fo: cpu._rc.IsSigned != shifted.IsSigned);
        cpu.SetRegC(shifted);
    }

    private static void RclD(Cpu cpu)
    {
        MyByte shifted = cpu._rd << 1;

        if (cpu._fc)
            shifted |= 1;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsCO(fc: cpu._rd.IsSigned, fo: cpu._rd.IsSigned != shifted.IsSigned);
        cpu.SetRegD(shifted);
    }

    private static void RcrA(Cpu cpu)
    {
        MyByte shifted = cpu._ra >> 1;

        if (cpu._fc)
            shifted |= 128;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsCO(fc: (cpu._ra & 1) != 0, fo: cpu._ra.IsSigned != shifted.IsSigned);
        cpu.SetRegA(shifted);
    }

    private static void RcrB(Cpu cpu)
    {
        MyByte shifted = cpu._rb >> 1;

        if (cpu._fc)
            shifted |= 128;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsCO(fc: (cpu._rb & 1) != 0, fo: cpu._rb.IsSigned != shifted.IsSigned);
        cpu.SetRegB(shifted);
    }

    private static void RcrC(Cpu cpu)
    {
        MyByte shifted = cpu._rc >> 1;

        if (cpu._fc)
            shifted |= 128;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsCO(fc: (cpu._rc & 1) != 0, fo: cpu._rc.IsSigned != shifted.IsSigned);
        cpu.SetRegC(shifted);
    }

    private static void RcrD(Cpu cpu)
    {
        MyByte shifted = cpu._rd >> 1;

        if (cpu._fc)
            shifted |= 128;

        cpu.SetFlagsZS(shifted);
        cpu.SetFlagsCO(fc: (cpu._rd & 1) != 0, fo: cpu._rd.IsSigned != shifted.IsSigned);
        cpu.SetRegD(shifted);
    }

    #endregion

    #region Ld / Ldi

    private static void LdA(Cpu cpu) => cpu.SetRegA(cpu._ram.Read(cpu.GetArgument()));
    private static void LdB(Cpu cpu) => cpu.SetRegB(cpu._ram.Read(cpu.GetArgument()));
    private static void LdC(Cpu cpu) => cpu.SetRegC(cpu._ram.Read(cpu.GetArgument()));
    private static void LdD(Cpu cpu) => cpu.SetRegD(cpu._ram.Read(cpu.GetArgument()));

    private static void LdiA(Cpu cpu) => cpu.SetRegA(cpu.GetArgument());
    private static void LdiB(Cpu cpu) => cpu.SetRegB(cpu.GetArgument());
    private static void LdiC(Cpu cpu) => cpu.SetRegC(cpu.GetArgument());
    private static void LdiD(Cpu cpu) => cpu.SetRegD(cpu.GetArgument());

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

    #region Rnd

    private static void RndA(Cpu cpu) => cpu.SetRegA(_random.Next(0, 255));
    private static void RndB(Cpu cpu) => cpu.SetRegB(_random.Next(0, 255));
    private static void RndC(Cpu cpu) => cpu.SetRegC(_random.Next(0, 255));
    private static void RndD(Cpu cpu) => cpu.SetRegD(_random.Next(0, 255));

    #endregion

    #region St

    private static void StA(Cpu cpu)
    {
        cpu._ram.Write(cpu.GetArgument(), cpu._ra);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StB(Cpu cpu)
    {
        cpu._ram.Write(cpu.GetArgument(), cpu._rb);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StC(Cpu cpu)
    {
        cpu._ram.Write(cpu.GetArgument(), cpu._rc);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StD(Cpu cpu)
    {
        cpu._ram.Write(cpu.GetArgument(), cpu._rd);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    #endregion

    #region St X,Y

    private static void StAA(Cpu cpu)
    {
        cpu._ram.Write(cpu._ra, cpu._ra);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StBA(Cpu cpu)
    {
        cpu._ram.Write(cpu._ra, cpu._rb);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StCA(Cpu cpu)
    {
        cpu._ram.Write(cpu._ra, cpu._rc);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StDA(Cpu cpu)
    {
        cpu._ram.Write(cpu._ra, cpu._rd);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StAB(Cpu cpu)
    {
        cpu._ram.Write(cpu._rb, cpu._ra);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StBB(Cpu cpu)
    {
        cpu._ram.Write(cpu._rb, cpu._rb);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StCB(Cpu cpu)
    {
        cpu._ram.Write(cpu._rb, cpu._rc);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StDB(Cpu cpu)
    {
        cpu._ram.Write(cpu._rb, cpu._rd);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StAC(Cpu cpu)
    {
        cpu._ram.Write(cpu._rc, cpu._ra);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StBC(Cpu cpu)
    {
        cpu._ram.Write(cpu._rc, cpu._rb);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StCC(Cpu cpu)
    {
        cpu._ram.Write(cpu._rc, cpu._rc);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StDC(Cpu cpu)
    {
        cpu._ram.Write(cpu._rc, cpu._rd);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StAD(Cpu cpu)
    {
        cpu._ram.Write(cpu._rd, cpu._ra);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StBD(Cpu cpu)
    {
        cpu._ram.Write(cpu._rd, cpu._rb);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StCD(Cpu cpu)
    {
        cpu._ram.Write(cpu._rd, cpu._rc);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    private static void StDD(Cpu cpu)
    {
        cpu._ram.Write(cpu._rd, cpu._rd);
        cpu._ram.Write(_inAddr, cpu._inQueued);
    }

    #endregion

    #region JX / JnX

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

    #region Jmp / Nop

    private static void Jmp(Cpu cpu)
    {
        cpu._ip = cpu.GetArgument();
        cpu._jumped = true;
    }

    private static void Nop(Cpu _) { }

    #endregion

    private readonly IReadOnlyList<Instruction> _instructions =
    [
        new Instruction("mov a,0", MovA0), // 00
        new Instruction("mov a,b", MovAB),
        new Instruction("mov a,c", MovAC),
        new Instruction("mov a,d", MovAD),
        new Instruction("mov a,0*", MovA0),
        new Instruction("mov b,a", MovBA),
        new Instruction("mov c,a", MovCA),
        new Instruction("mov d,a", MovDA),
        new Instruction("and a,0", AndA0),
        new Instruction("and a,b", AndAB),
        new Instruction("and a,c", AndAC),
        new Instruction("and a,d", AndAD),
        new Instruction("and a,0*", AndA0),
        new Instruction("and b,a", AndBA),
        new Instruction("and c,a", AndCA),
        new Instruction("and d,a", AndDA),
        new Instruction("or a,0", OrA0), // 10
        new Instruction("or a,b", OrAB),
        new Instruction("or a,c", OrAC),
        new Instruction("or a,d", OrAD),
        new Instruction("or a,0*", OrA0),
        new Instruction("or b,a", OrBA),
        new Instruction("or c,a", OrCA),
        new Instruction("or d,a", OrDA),
        new Instruction("xor a,0", XorA0),
        new Instruction("xor a,b", XorAB),
        new Instruction("xor a,c", XorAC),
        new Instruction("xor a,d", XorAD),
        new Instruction("xor a,0*", XorA0),
        new Instruction("xor b,a", XorBA),
        new Instruction("xor c,a", XorCA),
        new Instruction("xor d,a", XorDA),
        new Instruction("add a,0", AddA0), // 20
        new Instruction("add a,b", Command),
        new Instruction("add a,c", Command),
        new Instruction("add a,d", Command),
        new Instruction("add a,0*", Command),
        new Instruction("add b,a", Command),
        new Instruction("add c,a", Command),
        new Instruction("add d,a", Command),
        new Instruction("adc a,0", Command),
        new Instruction("adc a,b", Command),
        new Instruction("adc a,c", Command),
        new Instruction("adc a,d", Command),
        new Instruction("adc a,0*", Command),
        new Instruction("adc b,a", Command),
        new Instruction("adc c,a", Command),
        new Instruction("adc d,a", Command),
        new Instruction("sub a,0", Command), // 30
        new Instruction("sub a,b", Command),
        new Instruction("sub a,c", Command),
        new Instruction("sub a,d", Command),
        new Instruction("sub a,0*", Command),
        new Instruction("sub b,a", Command),
        new Instruction("sub c,a", Command),
        new Instruction("sub d,a", Command),
        new Instruction("sbb a,0", Command),
        new Instruction("sbb a,b", Command),
        new Instruction("sbb a,c", Command),
        new Instruction("sbb a,d", Command),
        new Instruction("sbb a,0*", Command),
        new Instruction("sbb b,a", Command),
        new Instruction("sbb c,a", Command),
        new Instruction("sbb d,a", Command),
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
        new Instruction("ld a,a", LdAA), // 90
        new Instruction("ld b,a", LdBA),
        new Instruction("ld c,a", LdCA),
        new Instruction("ld d,a", LdDA),
        new Instruction("ld a,b", LdAB),
        new Instruction("ld b,b", LdBB),
        new Instruction("ld c,b", LdCB),
        new Instruction("ld d,b", LdDB),
        new Instruction("ld a,c", LdAC),
        new Instruction("ld b,c", LdBC),
        new Instruction("ld c,c", LdCC),
        new Instruction("ld d,c", LdDC),
        new Instruction("ld a,d", LdAD),
        new Instruction("ld b,d", LdBD),
        new Instruction("ld c,d", LdCD),
        new Instruction("ld d,d", LdDD),
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
        new Instruction("st a,a", StAA), // B0
        new Instruction("st b,a", StBA),
        new Instruction("st c,a", StCA),
        new Instruction("st d,a", StDA),
        new Instruction("st a,b", StAB),
        new Instruction("st b,b", StBB),
        new Instruction("st c,b", StCB),
        new Instruction("st d,b", StDB),
        new Instruction("st a,c", StAC),
        new Instruction("st b,c", StBC),
        new Instruction("st c,c", StCC),
        new Instruction("st d,c", StDC),
        new Instruction("st a,d", StAD),
        new Instruction("st b,d", StBD),
        new Instruction("st c,d", StCD),
        new Instruction("st d,d", StDD),
        new Instruction("jz a", Command), // C0
        new Instruction("jc a", Command),
        new Instruction("js a", Command),
        new Instruction("jo a", Command),
        new Instruction("jz b", Command),
        new Instruction("jc b", Command),
        new Instruction("js b", Command),
        new Instruction("jo b", Command),
        new Instruction("jz c", Command),
        new Instruction("jc c", Command),
        new Instruction("js c", Command),
        new Instruction("jo c", Command),
        new Instruction("jz d", Command),
        new Instruction("jc d", Command),
        new Instruction("js d", Command),
        new Instruction("jo d", Command),
        new Instruction("jnz a", Command), // D0
        new Instruction("jnc a", Command),
        new Instruction("jns a", Command),
        new Instruction("jno a", Command),
        new Instruction("jnz b", Command),
        new Instruction("jnc b", Command),
        new Instruction("jns b", Command),
        new Instruction("jno b", Command),
        new Instruction("jnz c", Command),
        new Instruction("jnc c", Command),
        new Instruction("jns c", Command),
        new Instruction("jno c", Command),
        new Instruction("jnz d", Command),
        new Instruction("jnc d", Command),
        new Instruction("jns d", Command),
        new Instruction("jno d", Command),
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
        new Instruction("nop", Nop),
        new Instruction("nop*", Nop),
        new Instruction("nop*", Nop),
        new Instruction("nop*", Nop),
        new Instruction("jmp a", Command), // F0
        new Instruction("jmp a*", Command),
        new Instruction("jmp a*", Command),
        new Instruction("jmp a*", Command),
        new Instruction("jmp b", Command),
        new Instruction("jmp b*", Command),
        new Instruction("jmp b*", Command),
        new Instruction("jmp b*", Command),
        new Instruction("jmp c", Command),
        new Instruction("jmp c*", Command),
        new Instruction("jmp c*", Command),
        new Instruction("jmp c*", Command),
        new Instruction("jmp d", Command),
        new Instruction("jmp d*", Command),
        new Instruction("jmp d*", Command),
        new Instruction("jmp d*", Command)
    ];

    private class Instruction(string name, Action<Cpu> action)
    {
        public readonly string Name = name;
        public readonly Action<Cpu> Action = action;
    }
}
