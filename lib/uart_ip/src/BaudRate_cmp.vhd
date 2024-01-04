library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ua_brg is
	GENERIC(
		BAUD_RATE: integer
	);
	PORT(
		CLK		   : in  std_logic;
		RST		   : in  std_logic;
		BRG_TICK : out std_logic
	);
end ua_brg;

architecture LvnT of ua_brg is

	--
	-- Constants
	--
	constant cHigh 	: std_logic := '1';
	constant cLow  	: std_logic := '0';
	constant cSysHz	: integer 	:= 100000000; 					     -- 100MHz
	constant cBrgVal: integer 	:= cSysHz/(16*BAUD_RATE)-1;	 -- 100MHz / (16*baud_rate)
	
	--
	-- Signals
	--
	signal sBrgTick : std_logic;

begin


	--
	-- Primitives ---------------------------------------------
	--


	--
	-- Components ---------------------------------------------
	--


	--
	-- Processes ----------------------------------------------
	--
	
	-- ua_brgTick_p process
	-- Baud Rate Tick Generator
	ua_brgTick_p: process(CLK, RST)
		variable vBrgCtr : integer range 0 to cBrgVal+1;
	begin
    if(rising_edge(CLK)) then
      if(RST = cHigh) then
			  vBrgCtr := 0;
        sBrgTick<= '0';
      else
        sBrgTick <= '0';
        if(vBrgCtr = cBrgVal) then
          vBrgCtr	:= 0;
          sBrgTick<= '1';
        else
          vBrgCtr := vBrgCtr + 1;
        end if;
      end if;
    end if;	
	end process;


	--
	-- Logic --------------------------------------------------
	--
	
	-- Inputs
	--
	
	-- Outputs
	--
	BRG_TICK <= sBrgTick;
	
	-- Internals
	--

end LvnT;

