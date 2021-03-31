-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Instruction Decoder

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity InstructionDecoder is
port
(
	Clk   : in std_logic;
	Rst   : in std_logic;
	Run   : in std_logic;
	Code  : in std_logic_vector (11 downto 0);
	Flags : in std_logic_vector (7 downto 0);
	PcInc : out std_logic;
	PcOut : out std_logic;
	Jump  : out std_logic;
	AIn   : out std_logic;
	AOut  : out std_logic;
	BIn   : out std_logic;
	CIn   : out std_logic;
	FIn   : out std_logic;
	FOut  : out std_logic;
	AddSub: out std_logic;
	AluSel: out std_logic_vector (1 downto 0);
	AluOut: out std_logic;
	MarIn : out std_logic;
	RamWr : out std_logic;
	RamOut: out std_logic;
	IrIn  : out std_logic;
	IrOut : out std_logic;
	StkCnt: out std_logic;
   StkWr : out std_logic;
   StkOut: out std_logic;
   StkSen: out std_logic
);
end InstructionDecoder;

architecture Sirius8_Arch of InstructionDecoder is

signal NOP,O_JUMP,LDA,SUM,SUB,O_AND,O_OR,O_XOR,LDC,BTR,CALL,RET: std_logic;
signal EndCycle: std_logic;
signal OpCode: std_logic_vector (3 downto 0);
signal CountBits: std_logic_vector (3 downto 0);
signal Cycle: std_logic_vector (15 downto 0);
signal Operation: std_logic_vector (15 downto 0);

-- Binary Decoder
component BinaryDecoder 
generic(sizeIn : integer := 3; sizeOut : integer := 8);
port(Input : in std_logic_vector (sizeIn-1 downto 0); Output : out std_logic_vector (sizeOut-1 downto 0));
end component;

-- 4 bits counter
component Counter_4b
port(Clk, Rst, En, Sen, Load: in std_logic; Input : in std_logic_vector (3 downto 0); Output : out std_logic_vector (3 downto 0));
end component;

begin

	OpCode <= Code(11 downto 8);

	cnt_cycle : Counter_4b port map(Clk, Rst, Run, '1', EndCycle, "0000", CountBits);
	dec_cycle : BinaryDecoder generic map(4, 16) port map(CountBits, Cycle);
	dec_inst  : BinaryDecoder generic map(4, 16) port map(OpCode, Operation);
	
	NOP       <= Operation(0);
	O_JUMP    <= Operation(1);
	LDA       <= Operation(2);
	SUM       <= Operation(3);
	SUB       <= Operation(4);
	O_AND     <= Operation(5);
	O_OR      <= Operation(6);
	O_XOR     <= Operation(7);
	LDC       <= Operation(8);
	BTR       <= Operation(9);
	CALL      <= Operation(10);
	RET       <= Operation(11);
		
	EndCycle  <= (Cycle(5) or (Cycle(3) and (O_JUMP or LDA or LDC or BTR)));  -- Reset 4 bits counter
   PcOut     <= (Cycle(0) or (Cycle(2) and CALL));
   IrOut     <= (Cycle(2) and (O_JUMP or LDA or SUM or SUB)) or (Cycle(4) and CALL);
   MarIn     <= (Cycle(0));
   Jump      <= (Cycle(2) and O_JUMP) or (Cycle(3) and RET) or (Cycle(4) and CALL);
   RamOut    <= (Cycle(1));
   IrIn      <= (Cycle(1));
   PcInc     <= (Cycle(1) or (Cycle(2) and O_JUMP) or (Cycle(3) and RET) or (Cycle(4) and CALL) or 
                (Cycle(2) and BTR and ((Code(0) and Flags(0)) or (Code(1) and Flags(1)) or (Code(2) and Flags(2)) or (Code(3) and Flags(3)) or (Code(4) and Flags(4)) or (Code(5) and Flags(5)) or (Code(6) and Flags(6)) or (Code(7) and Flags(7)))));
   AIn       <= (Cycle(2) and LDA) or (Cycle(4) and (SUM or SUB));
   AOut      <= (Cycle(2) and LDC);
   BIn       <= (Cycle(2) and (SUM or SUB));
   CIn       <= (Cycle(2) and LDC);
   FIn       <= (Cycle(3) and (SUM or SUB or O_AND or O_OR or O_XOR));
   AluOut    <= (Cycle(4) and (SUM or SUB));
   AddSub    <= ((Cycle(3) or Cycle(4)) and (not SUM or SUB));
   AluSel(0) <= ((Cycle(3) or Cycle(4)) and (O_AND or O_XOR));
   AluSel(1) <= ((Cycle(3) or Cycle(4)) and (O_OR or O_XOR));
   StkCnt    <= (Cycle(2) and RET) or (Cycle(3) and CALL);
   StkWr     <= (Cycle(2) and CALL);
   StkOut    <= (Cycle(3) and RET);
   StkSen    <= (Cycle(3) and CALL);

	--	Cycle 0 -> PcOut e MarIn
	--	Cycle 1 -> RamOut, IrIn e PcInc.
	--	The control bits will be triggered on the falling edge of the clock.
	--	NOP  0000
	--	JUMP 0001, 2 -> IrOut, PcInc, Jump;
	--	LDA  0010, 2 -> IrOut, AIn;
	--	SUM  0011, 2 -> IrOut, BIn;         3 -> AddSub=0, FIn;         4 -> AddSub=0, AluOut, AIn
	--	SUB  0100, 2 -> IrOut, BIn;         3 -> AddSub=1, FIn;         4 -> AddSub=1, AluOut, AIn;
	--	AND  0101, 2 -> IrOut, BIn;         3 -> AluSel[0]=1, AluSel[1]=0, FIn;   4 -> AluSel[0]=1, AluSel[1]=0, AluOut, AIn
	--	OR   0110, 2 -> IrOut, BIn;         3 -> AluSel[0]=0, AluSel[1]=1, FIn;   4 -> AluSel[0]=0, AluSel[1]=1, AluOut, AIn
	--	XOR  0111, 2 -> IrOut, BIn;         3 -> AluSel[0]=1, AluSel[1]=1, FIn;   4 -> AluSel[0]=1, AluSel[1]=1, AluOut, AIn
	--	LDC  1000, 2 -> AOut, CIn;
	--	BTR  1001, 2 -> PcInc # Opcode = 4bits, Register=4bits, Bit=3bits, SetClear=1  Max 16 register
	--	CALL 1010, 2 -> PcOut, StkWr;       3 -> StkCnt, StkSen;        4 -> IrOut, PcInc, Jump
	--	RET  1011, 2 -> StkCnt, 'StkSen;    3 -> StkOut, PcInc, Jump

end Sirius8_Arch;