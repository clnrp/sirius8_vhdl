-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Sirius8 main file

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.STD_LOGIC_ARITH.ALL;
 
entity Sirius8 is
Port(
	clk: in std_logic;
	dig: out std_logic_vector (3 downto 0);   -- saída de 4 bits, bit mais significativo a esquerda
	seg: out std_logic_vector (7 downto 0);	-- saída de 8 bits		  
	D: in std_logic_vector (3 downto 0);      -- 4 buttons
	E: out std_logic_vector (3 downto 0);     -- 4 Leds
	T: inout std_logic_vector (2 downto 0)
);
end Sirius8;

architecture Sirius8_Arch of Sirius8 is

-- Bus of 12 bits
signal Bus12b: std_logic_vector (11 downto 0);

-- System clock
signal SysClock: std_logic;

-- Hardware reset 
signal Reset   : std_logic;

-- Control word
signal PcInc   : std_logic;
signal PcOut   : std_logic;
signal Jump    : std_logic;
signal AIn     : std_logic;
signal AOut    : std_logic;
signal BIn     : std_logic;
signal CIn     : std_logic;
signal DIn     : std_logic;
signal FIn     : std_logic;
signal FOut    : std_logic;
signal AddSub  : std_logic;
signal AluSel  : std_logic_vector (1 downto 0);
signal AluOut  : std_logic;
signal MarIn   : std_logic;
signal RamWr   : std_logic;
signal RamOut  : std_logic;
signal IrIn    : std_logic;
signal IrOut   : std_logic;
signal StkCnt  : std_logic;
signal StkWr   : std_logic;
signal StkOut  : std_logic; -- put Stack value in the BUS
signal StkSen  : std_logic; -- StkSen = 0 is pop and StkSen = 1 is push 

-- Bootload signals
signal Run     : std_logic; -- program loaded
signal bPcInc  : std_logic;
signal bPcOut  : std_logic;
signal bPcReset: std_logic;
signal bMarIn  : std_logic;
signal bRamWr  : std_logic;
signal bRamOut : std_logic;
signal BootOut : std_logic;

-- Auxilar signals
signal nReset  : std_logic;
signal nPcInc  : std_logic;
signal nMarIn  : std_logic;
signal nRamWr  : std_logic;
signal Reset_bt: std_logic;
signal FlagsIn : std_logic;

-- Other signals
signal Alu_flags  : std_logic_vector (7 downto 0);
signal Mux_enc    : std_logic_vector (7 downto 0);
signal Mux_sel    : std_logic_vector (2 downto 0);
signal Mux_in     : std_logic_vector (95 downto 0); -- 12*8
signal Flags_out  : std_logic_vector (7 downto 0);
signal Stack_out  : std_logic_vector (7 downto 0);
signal Pc_out, Mar_out, Alu_out  : std_logic_vector (7 downto 0);
signal A_out, B_out, C_out       : std_logic_vector (7 downto 0);
signal Boot_out, Ir_out, Ram_out : std_logic_vector (11 downto 0);
signal Display_in: std_logic_vector (11 downto 0);

-- Clock system
component Clock
generic (div: integer := 22);
port(ClkIn: in std_logic; ClkOut: out std_logic);
end component;

-- Display component
component Dis4d_3461bs port(Clk: in std_logic; Data: in std_logic_vector (11 downto 0); DigPin : out std_logic_vector (3 downto 0); SegPin : out std_logic_vector (7 downto 0));
end component; 

-- Boot loader - Load the program to RAM
component BootLoader
port(Clk, Rst: in std_logic; Address: in std_logic_vector (7 downto 0); PcInc, PcOut, PcReset, MarIn, RamWr, RamOut, BootOut, Ready: out std_logic; Output: out std_logic_vector (11 downto 0));
end component;

-- ALU
component ALU
generic (n: integer := 8);
port(A, B: in std_logic_vector (n-1 downto 0); AddSub: in std_logic; Sel: in std_logic_vector (1 downto 0); Flags: out std_logic_vector (1 downto 0); Output: out std_logic_vector (n-1 downto 0));
end component; 

-- Generic multiplexer
component Mux
generic (sizeSel: integer := 3; sizeIn: integer := 96; sizeOut: integer := 12);	
port(Sel: in std_logic_vector (sizeSel-1 downto 0); Input: in std_logic_vector (sizeIn-1 downto 0); Output: out std_logic_vector (sizeOut-1 downto 0));	
end component;

-- 8 bits counter
component Counter_8b
port(Clk, Rst, En, Load: in std_logic; Input : in std_logic_vector (7 downto 0); Output : out std_logic_vector (7 downto 0));
end component;

-- Generic register
component gRegister
generic (size: integer := 8);
port(Clk, Rst, En: in std_logic; Input: in std_logic_vector (size-1 downto 0); Output: out std_logic_vector (size-1 downto 0));
end component;

-- Generic register with bits mask
component Register_Mask
generic (size: integer := 8);
port(Clk, Rst, En: in std_logic; Input, Mask: in std_logic_vector (size-1 downto 0); Output: out std_logic_vector (size-1 downto 0));
end component;

-- Random access memory
component Ram
generic (addrSize: integer := 8; dataSize: integer := 12);	    
port(Clk, Rst, We: in std_logic; Addr: in std_logic_vector (AddrSize-1 downto 0); Input: in std_logic_vector (DataSize-1 downto 0); Output: out std_logic_vector (DataSize-1 downto 0));	
end component;

-- Function Stack
component Stack
generic (size: integer := 8);	
port(Clk, Rst, Count, Sen, Wr: in std_logic;	Input: in std_logic_vector (size-1 downto 0); Output: out std_logic_vector (size-1 downto 0));	
end component;

-- Instruction decoder
component InstructionDecoder
port(
Clk, Rst, Run: in std_logic; Code: in std_logic_vector (11 downto 0); Flags : in std_logic_vector (7 downto 0);
PcInc, PcOut, Jump, AIn, AOut, BIn, CIn, FIn, FOut, AddSub: out std_logic; AluSel: out std_logic_vector (1 downto 0);
AluOut, MarIn, RamWr, RamOut, IrIn, IrOut, StkCnt, StkWr, StkOut, StkSen: out std_logic
);	
end component;

-- Binary encoder of 8 bits to 3 bits
component BinaryEncoder8_3
port(Input: in std_logic_vector (7 downto 0); Output: out std_logic_vector (2 downto 0));
end component;

begin

	-- Bottons
   Reset    <= not D(0);
	Reset_bt <= not D(1);

	-- Encode mux output
	Mux_enc(0) <= (PcOut and Run) or (bPcOut and not Run);
	Mux_enc(1) <= BootOut and not Run;	
	Mux_enc(2) <= (RamOut and Run) or (bRamOut and not Run);	
	Mux_enc(3) <= AOut;
	Mux_enc(4) <= IrOut;
	Mux_enc(5) <= (AluOut and Run);
	Mux_enc(6) <= (StkOut and Run);
	Mux_enc(7) <= (FOut and Run);
	
	-- Configure clock
	Sys_clock: Clock port map(clk, SysClock);

	-- PC - program counter of 8 bits
	nReset <= Reset or bPcReset or Reset_bt;
	nPcInc <= (PcInc and Run) or (bPcInc and not Run);
	Pc_8b: Counter_8b port map(SysClock, nReset, nPcInc, Jump, Bus12b(7 downto 0), Pc_out);
	Mux_in(7 downto  0 )  <= Pc_out;
	Mux_in(11 downto 8 )  <= "0000";

	Boot: BootLoader port map(SysClock, Reset, Pc_out, bPcInc, bPcOut, bPcReset, bMarIn, bRamWr, bRamOut, BootOut, Run, Boot_out);
	Mux_in(23 downto 12)  <= Boot_out;
	
	-- MAR - memory address register
	nMarIn <= (MarIn and Run) or (bMarIn and not Run);
	Mar: gRegister port map(SysClock, Reset, nMarIn, Bus12b(7 downto 0), Mar_out);
	
	-- RAM - Random access memory of 12 bits
	nRamWr <= (RamWr and Run) or (bRamWr and not Run);
	Ram_12b: Ram port map(SysClock, Reset, nRamWr, Mar_out, Bus12b, Ram_out);
	Mux_in(35 downto 24)  <= Ram_out;	

	-- Accumalator register
	A: gRegister port map(SysClock, Reset, AIn, Bus12b(7 downto 0), A_out);
	Mux_in(43 downto 36)  <= A_out;
	Mux_in(47 downto 44)  <= "0000";
	
	-- B register
	B: gRegister port map(SysClock, Reset, BIn, Bus12b(7 downto 0), B_out);
	
	-- C register
	C: gRegister port map(SysClock, Reset, CIn, Bus12b(7 downto 0), C_out);

	-- Instruction register
	IR: gRegister generic map(12) port map(SysClock, Reset, IrIn, Bus12b, Ir_out);
	Mux_in(59 downto 48)  <= Ir_out;
	
	-- ALU 8 bits
	ALU_8b: ALU port map(A_out, B_out, AddSub, AluSel, Alu_flags(1 downto 0), Alu_out);
	Mux_in(67 downto 60)  <= Alu_out;
	Mux_in(71 downto 68)  <= "0000";

	-- Function Stack
	Func_Stack: Stack port map(SysClock, Reset, StkCnt, StkSen, StkWr, Bus12b(7 downto 0), Stack_out);
	Mux_in(79 downto 72)  <= Stack_out;
	Mux_in(83 downto 80)  <= "0000";
	
	-- Flag register
	Flag_Register: Register_Mask port map(SysClock, Reset, AluOut, Alu_flags, "00000011", Flags_out);
	Mux_in(91 downto 84)  <= Flags_out;
	Mux_in(95 downto 92)  <= "0000";
	
	Encoder: BinaryEncoder8_3 port map(Mux_enc, Mux_sel);	
	Mux_Bus12b: Mux port map (Mux_sel, Mux_in, Bus12b);
	
	-- Instruction decoder
	Inst_Dec: InstructionDecoder port map (SysClock, Reset, Run, Ir_out, Flags_out, PcInc, PcOut, Jump, AIn, AOut, BIn, CIn, FIn, FOut, AddSub, 
														AluSel, AluOut, MarIn, RamWr, RamOut, IrIn, IrOut, StkCnt, StkWr, StkOut, StkSen);
	
	-- Display of 4 digits
	Display_in(7 downto 0) <= A_out;
	Display_in(11 downto 8) <= "0000";
	Display : Dis4d_3461bs port map(clk, Display_in, dig, seg);
	
	E(0) <= not Run;
	E(1) <= not bPcReset; 
	E(2) <= '1';
	E(3) <= '1';

end Sirius8_Arch;