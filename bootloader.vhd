-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Boot Loader

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.textio.all;                     -- basic I/O
use IEEE.std_logic_textio.all;          -- I/O for logic type

entity BootLoader is
port
(
	Clk     : in std_logic;
	Rst     : in std_logic;
	Bl      : in std_logic_vector (11 downto 0);
	Blw     : in std_logic;
	Run     : in std_logic;
	Address : in std_logic_vector (7 downto 0);
	PcInc   : out std_logic;
	PcOut   : out std_logic;
	PcReset : out std_logic;
	MarIn   : out std_logic;
	RamWr   : out std_logic;
	RamOut  : out std_logic;
	BootOut : out std_logic;
	Ready   : out std_logic;
	Output  : out std_logic_vector (11 downto 0)
);
end BootLoader;

architecture Sirius8_Arch of BootLoader is
signal Cycle: std_logic_vector (15 downto 0);
signal CountEn: std_logic;
signal Count: std_logic_vector (3 downto 0);
signal RamEn: std_logic;
signal CountRam: std_logic_vector (3 downto 0);
signal Reg_out: std_logic_vector (11 downto 0);
signal RegIn: std_logic;
signal Check: std_logic;
signal Check_aux : std_logic_vector (11 downto 0);
signal Start: std_logic;

-- Binary Decoder
component BinaryDecoder 
generic(sizeIn : integer := 3; sizeOut : integer := 8);
port(Input : in std_logic_vector (sizeIn-1 downto 0); Output : out std_logic_vector (sizeOut-1 downto 0));
end component;

-- 4 bits counter
component Counter_4b
port(Clk, Rst, En, Sen, Load: in std_logic; Input : in std_logic_vector (3 downto 0); Output : out std_logic_vector (3 downto 0));
end component;

-- Generic register
component gRegister
generic (size: integer := 12);
port(Clk, Rst, En: in std_logic; Input: in std_logic_vector (size-1 downto 0); Output: out std_logic_vector (size-1 downto 0));
end component;

component FlipFlop_D
port(Clk, Rst, D: in std_logic; Q, Q_bar: out std_logic);
end component;

begin

	CountEn <= Blw and not Count(3); -- enable count if you have instruction and have not reached count limit
	cnt_bl : Counter_4b port map(Clk, Rst or not Check or not Blw, CountEn, '1', '0', "0000", Count); -- reset if check=false or Blw=false 
	
	-- enable count of CountRam if check=true and if Count reaches limit
	cnt_ram : Counter_4b port map(Clk, Rst or not Check or not Blw, RamEn and not Cycle(3), '1', '0', "0000", CountRam); -- reset if check=false or Blw=false 
	RegIn <= Blw;
	bl_reg: gRegister port map(Clk, Rst, RegIn, Bl, Reg_out);

	-- checks if the value of the register is equal to the input
	Check_aux(0) <= not (Reg_out(0) xor Bl(0));
	check_loop: for i in 1 to 11 generate
		Check_aux(i) <= Check_aux(i-1) and not (Reg_out(i) xor BL(i));
	end generate check_loop; 
	Check <= Check_aux(11); 
   RamEn <= Check and Count(3);
	
	dec_cycle : BinaryDecoder generic map(4, 16) port map(CountRam, Cycle);
	
	-- Cycle 0, PcOut, MarIn => BUS = MAR = 0, 1, 2, 3 
   -- Cycle 1, PcInc, RamWR, BootOut => PC = 1, MAR = 0, BUS = BootOut = RAM = 10, 5, 7, 13
   -- Cycle 2, PcOut = 0, 1, 2, 3 
   -- Cycle 3, RamOut = 10, 5, 7, 13

	PcOut <= RamEn and (Cycle(0) or Cycle(2));
	MarIn <= RamEn and Cycle(0);
	PcInc <= RamEn and Cycle(1);
	RamWr <= RamEn and Cycle(1);
	BootOut <= RamEn and Cycle(1);
	RamOut <= RamEn and Cycle(3);
	
	ff_run: FlipFlop_D port map(Clk, Rst, Run or Start, Start);
	
	--Output(3 downto 0) <= CountRam;
	Output <= Reg_out;
	PcReset <= Run;
	Ready <= Start; --Cycle(3);
end Sirius8_Arch;