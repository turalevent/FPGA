----------------------------------------------------------------------------------
-- Company			: 
-- Engineer			: Levent TURA
-- 
-- Create Date		: 07.05.2015
-- Design Name		: 
-- Module Name		: OutputLayer - YTU
-- Project Name	: OutputLayer
-- Target Devices	: Virtex-4
-- Tool Versions	: 14.2
-- Description		: 
-- 
-- Dependencies	: 
-- 
-- Revision			:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity OutputLayer is
	GENERIC(
		INPUT_NUM	: integer;
		NEURON_NUM 	: integer
	);
	PORT(
		CLK   	: in  std_logic;
		RST   	: in  std_logic;
		TRIG  	: in  std_logic;
		WGH_SET 	: in  std_logic;
		WGH_NUM	: in  std_logic_vector(7 downto 0);  
		WGH		: in  std_logic_vector(31 downto 0);  
		INPUT1	: in  std_logic_vector(31 downto 0);  
		INPUT2	: in  std_logic_vector(31 downto 0);  
		INPUT3	: in  std_logic_vector(31 downto 0);  
		INPUT4	: in  std_logic_vector(31 downto 0);  
		RDY		: out std_logic;
		OUTPUT1	: out std_logic_vector(31 downto 0);  
		OUTPUT2	: out std_logic_vector(31 downto 0)
	);
end OutputLayer;

architecture YTU of OutputLayer is

	--
	-- Components
	--
	
	-- Neuron
	--
	COMPONENT Neuron
		PORT (
			CLK   : in  std_logic;
			RST   : in  std_logic;
			TRIG  : in  std_logic;
			INPUT1: in  std_logic_vector(31 downto 0);  
			INPUT2: in  std_logic_vector(31 downto 0);  
			INPUT3: in  std_logic_vector(31 downto 0);  
			INPUT4: in  std_logic_vector(31 downto 0);  
			WGH1	: in  std_logic_vector(31 downto 0);  
			WGH2	: in  std_logic_vector(31 downto 0);  
			WGH3	: in  std_logic_vector(31 downto 0);  
			WGH4	: in  std_logic_vector(31 downto 0);  
			WGH5	: in  std_logic_vector(31 downto 0);  
			RDY	: out std_logic;
			OUTPUT: out std_logic_vector(31 downto 0)  
		);
	END COMPONENT;

	-- 
	-- Types
	--
--	type Array10x32_t is array (0 to (NEURON_NUM*(INPUT_NUM+1))-1) of std_logic_vector(31 downto 0);
	type Array10x32_t is array (0 to 9) of std_logic_vector(31 downto 0);
	type Array2x32_t  is array (0 to NEURON_NUM-1) of std_logic_vector(31 downto 0);
    
	--
	-- Constants
	--
	
	-- General
	constant High_c 		: std_logic 	:= '1';
	constant Low_c  		: std_logic 	:= '0';
	
	--
	-- Signals
	--	
	
	-- General Signals
	signal WghSet_s		: std_logic;
	signal Trig_s			: std_logic;
	signal bTrig_s		: std_logic;
	signal ResRdy_s		: std_logic;
	signal Res_s			: std_logic_vector(31 downto 0);
	
	-- Neuron
	signal NrnTrig_s	  : std_logic;
	signal NrnResRdy_s  : std_logic;
	signal Wgh1_s			  : std_logic_vector(31 downto 0);
	signal Wgh2_s			  : std_logic_vector(31 downto 0);
	signal Wgh3_s			  : std_logic_vector(31 downto 0);
	signal Wgh4_s			  : std_logic_vector(31 downto 0);
	signal Wgh5_s			  : std_logic_vector(31 downto 0);
	signal NeuronRes_s	: std_logic_vector(31 downto 0);
	signal NrnResArry_s	: Array2x32_t;
	signal WghArry_s		: Array10x32_t;

begin
    
	--
	-- Primitives ---------------------------------------------
	--

	--
	-- Components ---------------------------------------------
	--

	-- Neuron_cmp component
	-- 
	Neuron_cmp : Neuron 
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		TRIG  => NrnTrig_s,
		INPUT1=> INPUT1,
		INPUT2=> INPUT2,
		INPUT3=> INPUT3,
		INPUT4=> INPUT4,
		WGH1 	=> Wgh1_s,
		WGH2 	=> Wgh2_s,
		WGH3 	=> Wgh3_s,
		WGH4 	=> Wgh4_s,
		WGH5 	=> Wgh5_s,
		RDY	  => NrnResRdy_s,
		OUTPUT=> NeuronRes_s
	);

	-- Main_p process
	-- Trig Adders and Sigmoid synchronously..
	Main_p : process( CLK, RST )
		variable Ctr_v : integer range 0 to NEURON_NUM-1;
	begin

		if(RST = High_c) then
			
			ResRdy_s		<= Low_c;
			NrnTrig_s	  <= Low_c;
			Wgh1_s		  <= (others=>'0');
			Wgh2_s		  <= (others=>'0');
			Wgh3_s		  <= (others=>'0');
			Wgh4_s		  <= (others=>'0');
			Wgh5_s		  <= (others=>'0');
			NrnResArry_s<= (others=>(others=>'0'));
			Ctr_v			  := 0;
			
		elsif( rising_edge( CLK )) then

			ResRdy_s <= Low_c;
			NrnTrig_s<= Low_c;

			-- Trig Multiplier
			if(bTrig_s = Low_c AND Trig_s = High_c) then
				NrnTrig_s <= High_c;
				Ctr_v	 	  := 0;
			end if;

			if(NrnResRdy_s = High_c) then
				NrnResArry_s(Ctr_v)(31 downto 0)	<= NeuronRes_s;
				if(Ctr_v = NEURON_NUM-1) then
					ResRdy_s	<= High_c;
				else
					NrnTrig_s <= High_c;
					Ctr_v		  := Ctr_v + 1;
				end if;
			end if;
				
			Wgh1_s	<= WghArry_s(Ctr_v*5)(31 downto 0);
			Wgh2_s	<= WghArry_s((Ctr_v*5)+1)(31 downto 0);
			Wgh3_s	<= WghArry_s((Ctr_v*5)+2)(31 downto 0);
			Wgh4_s	<= WghArry_s((Ctr_v*5)+3)(31 downto 0);
			Wgh5_s	<= WghArry_s((Ctr_v*5)+4)(31 downto 0);

		end if;

	end process;

	-- SetWgh_p process
	-- Set Weights
	SetWgh_p : process( CLK, RST )
		variable WghNum_v : integer range 0 to 9;
	begin

		if(RST = High_c) then
			WghArry_s<= (others=>(others=>'0'));
			WghNum_v	:= 0;
		elsif( rising_edge( CLK )) then
			
			if(WghSet_s = High_c) then
				WghNum_v	:= conv_integer(WGH_NUM);
				WghArry_s(WghNum_v)(31 downto 0)	<= WGH;
			end if;
			
		end if;

	end process;

	-- Buf_p process
	--
	Buf_p : process( CLK, RST )
	begin

		if(RST = High_c) then
			WghSet_s<= Low_c;
			Trig_s 	<= Low_c;
			bTrig_s <= Low_c;
		elsif( rising_edge( CLK )) then
			WghSet_s<= WGH_SET;
			Trig_s 	<= TRIG;
			bTrig_s <= Trig_s;
		end if;

	end process;

	--
	-- Logic --------------------------------------------------
	--
    
	-- Inputs
	--

	-- Outputs
	--
	RDY		  <= ResRdy_s;
	OUTPUT1	<= NrnResArry_s(0)(31 downto 0);
	OUTPUT2	<= NrnResArry_s(1)(31 downto 0);
	
	-- InOuts
	--

	-- Internals
	--

end YTU;
