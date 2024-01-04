----------------------------------------------------------------------------------
-- Company			: 
-- Engineer			: Levent TURA
-- 
-- Create Date		: 07.05.2015
-- Design Name		: 
-- Module Name		: Neuron - YTU
-- Project Name	: Neuron
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Neuron is
	PORT(
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
end Neuron;

architecture YTU of Neuron is

	--
	-- Components
	--
	
	-- Sgmoid
	--
	COMPONENT Sigmoid
		PORT (
			CLK   : in  std_logic;
			RST   : in  std_logic;
			TRIG  : in  std_logic;
			INPUT : in  std_logic_vector(31 downto 0);  
			RDY	: out std_logic;
			OUTPUT: out std_logic_vector(31 downto 0)  
		);
	END COMPONENT;

	-- f32Adder
	-- 32bit floating point adder/subtracter
	COMPONENT f32_adder
    GENERIC(
      SIZE : integer := 32
    );
    PORT(
      CLK	  : in  std_logic;
      RST	  : in  std_logic;
      -- SAMPLES
      A     : in  std_logic_vector(SIZE-1 downto 0);
      B     : in  std_logic_vector(SIZE-1 downto 0);
      EN    : in  std_logic;
      -- Ouputs
      NAN   : out std_logic;
      INF   : out std_logic;
      READY : out std_logic;
      RES	  : out std_logic_vector(SIZE-1 downto 0)
    );
	END COMPONENT;

	-- Floating Point Multiplier
	--
	COMPONENT f32_multiplier
	PORT(
		CLK,RST	: in  std_logic;
		A   		: in  std_logic_vector(31 downto 0);
		B   		: in  std_logic_vector(31 downto 0);
    EN      : in  std_logic;
		NAN     : out std_logic;
		INF     : out std_logic;
    READY   : out std_logic;
		RES		  : out std_logic_vector(31 downto 0)
	);
	END COMPONENT;
    
	--
	-- Constants
	--
	
	-- General
	constant High_c 		: std_logic := '1';
	constant Low_c  		: std_logic := '0';
	-- Multiplier Counter Limit
	constant MaxMultCnt_c: integer := 3;
    
	-- 
	-- Types
	--
	type Array4x32_t is array (0 to 3) of std_logic_vector(31 downto 0);
	
	--
	-- Signals
	--

	-- Typed Signals
	signal MultResArray_s: Array4x32_t;
   
	-- General Signals
	signal Trig_s			: std_logic;
	signal bTrig_s			: std_logic;
	signal ResRdy_s		: std_logic;
	signal NeuronRes_s	: std_logic_vector(31 downto 0);
	
	-- Sigmoid
	signal CalcSigm_s		: std_logic;

	-- Floating Point Adder-1 signals
	signal AddOND_s		: std_logic;
	signal AddDone_s		: std_logic;
	signal AddIn1_s		: std_logic_vector(31 downto 0);
	signal AddIn2_s		: std_logic_vector(31 downto 0);
	signal AddRes_s		: std_logic_vector(31 downto 0);

	-- Floating Point Multiplier signals
	signal MultOND_s		: std_logic;
	signal MultDone_s		: std_logic;
	signal MultIn1_s		: std_logic_vector(31 downto 0);
	signal MultIn2_s		: std_logic_vector(31 downto 0);
	signal MultRes_s		: std_logic_vector(31 downto 0);
	signal MultCnt_s		: integer range 0 to MaxMultCnt_c;
		

begin
    
	--
	-- Primitives ---------------------------------------------
	--

	--
	-- Components ---------------------------------------------
	--

	-- Sigmoid_cmp component
	-- Sigmoid calculator
	Sigmoid_cmp : Sigmoid 
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		TRIG  => CalcSigm_s,
		INPUT => AddRes_s,
		RDY	=> ResRdy_s,
		OUTPUT=> NeuronRes_s
	);

	-- Adder_cmp component
	-- Floating Point Adder
	Adder_cmp: f32_adder
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    => AddIn1_s,
		B	    => AddIn2_s,
		EN    => AddOND_s,
		NAN   => open,
		INF   => open,
		READY => AddDone_s,
		RES   => AddRes_s
	);

	-- Mult_cmp component
	-- 
	Mult_cmp : f32_multiplier 
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    => MultIn1_s,
		B	    => MultIn2_s,
		EN    => MultOND_s,
		NAN   => open,
		INF   => open,
		READY => MultDone_s,
		RES   => MultRes_s
	);


	-- Main_p process
	-- Trig Adders and Sigmoid synchronously..
	Main_p : process( CLK, RST )
		variable Ctr_v : integer range 0 to 4;
	begin

		if(RST = High_c) then
			
			AddOND_s 	<= Low_c;
			CalcSigm_s	<= Low_c;
			AddIn1_s		<= (others=>'0');
			AddIn2_s		<= (others=>'0');
			Ctr_v			:= 0;
			
		elsif( rising_edge( CLK )) then

			AddOND_s	 	<= Low_c;
			CalcSigm_s	<= Low_c;
			
			-- Trig Adder-1 & Adder-2
			if((MultCnt_s = 3) AND (MultDone_s = High_c)) then
				AddIn1_s	<= MultResArray_s(Ctr_v)(31 downto 0);
				AddIn2_s	<= MultResArray_s(Ctr_v+1)(31 downto 0);
				AddOND_s	<= High_c;
				Ctr_v		:= Ctr_v + 2;				
			end if;
			
			if(AddDone_s = High_c) then				
				if(Ctr_v = 5) then
					CalcSigm_s<= High_c;		
					Ctr_v		 := 0;
				else
					if(Ctr_v = 4) then
						AddIn1_s	<= WGH5;
					else
						AddIn1_s	<= MultResArray_s(Ctr_v)(31 downto 0);
					end if;
					AddIn2_s	<= AddRes_s;				
					AddOND_s	<= High_c;
					Ctr_v		:= Ctr_v + 1;				
				end if;
			end if;

		end if;

	end process;

	-- MultCtrl_p process
	-- Multiplier Control process
	MultCtrl_p : process( CLK, RST )
	begin

		if(RST = High_c) then
		
			MultCnt_s 		<= 0;
			MultOND_s 		<= Low_c;
			MultResArray_s	<= (others=>(others=>'0'));
			
		elsif( rising_edge( CLK )) then

			MultOND_s <= Low_c;

			-- Trig Multiplier
			if(bTrig_s = Low_c AND Trig_s = High_c) then
				MultCnt_s 		<= 0;
				MultOND_s 		<= High_c;
				MultResArray_s	<= (others=>(others=>'0'));
			end if;

			if(MultDone_s = High_c) then
				MultResArray_s(MultCnt_s)(31 downto 0)	<= MultRes_s;
				if(MultCnt_s = MaxMultCnt_c) then
					MultCnt_s<= 0;
				else
					MultCnt_s<= MultCnt_s + 1;
					MultOND_s<= High_c;
				end if;
			end if;

		end if;

	end process;

	-- Buf_p process
	--
	Buf_p : process( CLK, RST )
	begin

		if(RST = High_c) then
			Trig_s 	<= Low_c;
			bTrig_s 	<= Low_c;
		elsif( rising_edge( CLK )) then
			Trig_s 	<= TRIG;
			bTrig_s 	<= Trig_s;
		end if;

	end process;

	--
	-- Logic --------------------------------------------------
	--
    
	-- Inputs
	--

	-- Outputs
	--
	RDY		<= ResRdy_s;
	OUTPUT	<= NeuronRes_s;

	-- InOuts
	--

	-- Internals
	--
	MultIn1_s<= INPUT1	when	MultCnt_s = 0 else
					INPUT2	when	MultCnt_s = 1 else
					INPUT3	when	MultCnt_s = 2 else
					INPUT4;

	MultIn2_s<= WGH1		when	MultCnt_s = 0 else
					WGH2		when	MultCnt_s = 1 else
					WGH3		when	MultCnt_s = 2 else
					WGH4;

end YTU;
