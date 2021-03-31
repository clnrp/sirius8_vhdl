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
signal Done: std_logic;
signal Cycle: std_logic_vector (1 downto 0);
signal Count: std_logic_vector (2 downto 0);

component FlipFlop_D 
port(Clk,Rst,D: in std_logic; Q: out std_logic);
end component;

begin

	load : process(Clk, Rst) -- sensível ao clock e reset 
	variable LineDebug: line;
	variable Loaded: BIT := '0';
	variable Reset: BIT := '0';
	variable ResetCnt: integer := 0;
	begin
		 if(Rst = '1') then Cycle <= "00";	-- estado inicial
		 elsif(Clk'event and Clk = '1') then  
		   case Cycle is
			  when "00" => Cycle <= "01";
			  when "01" => Cycle <= "10";
			  when "10" => Cycle <= "11";
			  when "11" => Cycle <= "00";
			end case;
		 end if;

		 if (Clk'event and Clk = '0') then
			if (Loaded = '0') then 
				if (Address = "00000000")    then -- 00
					Output <= "001011111100";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00000001") then -- 01
					Output <= "001100000001";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00000010") then -- 02
					Output <= "100100000001";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00000011") then -- 03
					Output <= "000100000001";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00000100") then -- 04
					Output <= "101000001000";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00000101") then -- 05
					Output <= "001100000010";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00000110") then -- 06
					Output <= "101000001101";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00000111") then -- 07
					Output <= "000100000000";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00001000") then -- 08
					Output <= "001100000100";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00001001") then -- 09
					Output <= "101000001011";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00001010") then -- 10
					Output <= "101100000000";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00001011") then -- 11
					Output <= "001100000101";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00001100") then -- 12
					Output <= "101100000000";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00001101") then -- 13
					Output <= "010000000011";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00001110") then -- 14
					Output <= "100000000000";
					Loaded := '0';
					Reset := '0';
				elsif (Address = "00001111") then -- 15
					Output <= "101100000000";
					Loaded := '0';
					Reset := '0';
				else
					Output <= "000000000000";
					Loaded := '1';
					Reset := '1';
				end if;
				 
				 --write(LineDebug, Cycle);
				if (Cycle = "00")    then -- PcOut, MarIn => BUS = MAR = 0, 1, 2, 3 
					PcInc <= '0';
					PcOut <= '1';
					MarIn <= '1';
					RamWr <= '0';
					RamOut <= '0';
					BootOut <= '0';
				elsif (Cycle = "01") then -- PcInc, RamIn, RamWR, BootOut => PC = 1, MAR = 0, BUS = BootOut = RAM = 10, 5, 7, 13
					PcInc <= '1';
					PcOut <= '0';
					MarIn <= '0';
					RamWr <= '1';
					RamOut <= '0';
					BootOut <= '1';
				elsif (Cycle = "10") then -- PcOut = 0, 1, 2, 3 
					PcInc <= '0';
					PcOut <= '1';
					MarIn <= '0';
					RamWr <= '0';
					RamOut <= '0';
					BootOut <= '0';
				elsif (Cycle = "11") then -- RamOut = 10, 5, 7, 13
					PcInc <= '0';
					PcOut <= '0';
					MarIn <= '0';
					RamWr <= '0';
					RamOut <= '1';
					BootOut <= '0';
				end if;
			else
				if ResetCnt < 2 then
					ResetCnt := ResetCnt + 1;
				end if;
			end if;
		end if;
		
		if (Loaded = '1') then
			Ready <= '1';
		else
			Ready <= '0';
		end if;

		if (Reset = '1' and ResetCnt < 2) then
			PcReset <= '1';
		else
			PcReset <= '0';
		end if;
		
	end process load;

	--ff: FlipFlop_D port map(Clk, Rst, Done or Loaded, Loaded);
	--done_g: if Done = '1' generate
	--		Loaded <= '1';
	--end generate done_g;
	--Ready <= Loaded;
	--PcReset <= '0';

end Sirius8_Arch;