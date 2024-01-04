----------------------------------------------------------------------------------
-- Company			: 
-- Engineer			: Levent TURA
-- 
-- Create Date		: 07.05.2015
-- Design Name		: 
-- Module Name		: Sigmoid - YTU
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Sigmoid is
	PORT(
		CLK   : in  std_logic;
		RST   : in  std_logic;
		TRIG  : in  std_logic;
		INPUT : in  std_logic_vector(31 downto 0);  
		RDY	: out std_logic;
		OUTPUT: out std_logic_vector(31 downto 0)  
	);
end Sigmoid;

architecture YTU of Sigmoid is


	--
	-- Components
	--
	
	-- Floating Point Adder
	--
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

	-- Floating Point Divider
	--
	COMPONENT f32_divider
	PORT(
		CLK	  : in  std_logic;
		RST	  : in  std_logic;
		A		  : in  std_logic_vector(31 downto 0);
		B		  : in  std_logic_vector(31 downto 0);
		EN    : in  std_logic;
		NAN   : out std_logic;
		INF   : out std_logic;
		READY : out std_logic;
		RES	  : out std_logic_vector(31 downto 0)
	);
	END COMPONENT;
    
	--
	-- Constants
	--

	constant High_c : std_logic := '1';
	constant Low_c  : std_logic := '0';
	constant OneFp_c: std_logic_vector(31 downto 0) := X"3f800000";
	constant TwoFp_c: std_logic_vector(31 downto 0) := X"40000000";
    
	-- 
	-- Types
	--

	type SigFSM_t is(
		ADD1_ST,
		DIV1_ST,
		ADD2_ST,
		DIV2_ST,
		FINAL_ST
	);
    
    
	--
	-- Signals
	--
    
	--Typed Signals
	signal SigSt_s			: SigFSM_t;
	
	-- General Signals
	signal Trig_s		: std_logic;
	signal bTrig_s		: std_logic;
	signal In_s			: std_logic_vector(31 downto 0);
	signal AbsIn_s		: std_logic_vector(31 downto 0);
	signal ResRdy_s	: std_logic;

	-- Floating Point Adder signals
	signal AddOND_s	: std_logic;
	signal AddDone_s	: std_logic;
	signal AddIn1_s	: std_logic_vector(31 downto 0);
	signal AddIn2_s	: std_logic_vector(31 downto 0);
	signal AddRes_s	: std_logic_vector(31 downto 0);

	-- Floating Point Divider signals
	signal DivOND_s	: std_logic;
	signal DivDone_s	: std_logic;
	signal DivIn1_s	: std_logic_vector(31 downto 0);
	signal DivIn2_s	: std_logic_vector(31 downto 0);
	signal DivRes_s	: std_logic_vector(31 downto 0);
		
begin
    
	--
	-- Components ---------------------------------------------
	--

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

	-- Divider_cmp component
	-- Floating Point Divider
	Divider_cmp : f32_divider 
	PORT MAP(
		CLK	  => CLK,
		RST	  => RST,
		A		  =>	DivIn1_s,
		B		  =>	DivIn2_s,
		EN    => DivOND_s,
		NAN   => open,
		INF   => open,
		READY => DivDone_s,
		RES	  =>	DivRes_s
	);

	-- Sigmoid calculation
	--
	--        1          In
	-- Out = --- * [ ---------- + 1 ]
	--        2       1 + |In|
	--
	-- Step-1 : Calc. Abs(In)
	-- Step-2 : Calc. 1 + Abs(In)	-> ADD1_ST
	-- Step-3 : Calc. /				->	DIV1_ST
	-- Step-4 : Calc. + 1 			-> ADD2_ST
	-- Step-5 : Calc. / 2 			-> DIV2_ST
    
	-- Main_p process
	--
	Main_p : process( CLK, RST )
		variable CalcRun_v : std_logic;
	begin

		if(RST = High_c) then
		
			ResRdy_s	<= Low_c;
			AddOND_s	<= Low_c;
			DivOND_s	<= Low_c;
			SigSt_s	<= ADD1_ST;
			SigSt_s	<= ADD1_ST;
			AddIn1_s	<= (others=>'0');
			AddIn2_s	<= (others=>'0');
			CalcRun_v:= Low_c;

		elsif( rising_edge( CLK )) then
			
			ResRdy_s	<= Low_c;
			AddOND_s	<= Low_c;
			DivOND_s	<= Low_c;
			
			if(bTrig_s = Low_c AND Trig_s = High_c) then
				CalcRun_v:= High_c;
			end if;
			
			if(CalcRun_v = High_c) then
			
				case SigSt_s is

					-- ADD1_ST state
					-- 
					when ADD1_ST =>
						AddIn1_s	<= OneFp_c;
						AddIn2_s	<= AbsIn_s;
						AddOND_s	<= High_c;
						SigSt_s	<= DIV1_ST;
						
					-- DIV1_ST state
					-- 
					when DIV1_ST =>
						if(AddDone_s = High_c) then
							DivIn1_s	<= In_s;
							DivIn2_s	<= AddRes_s;
							DivOND_s	<= High_c;
							SigSt_s	<= ADD2_ST;
						else
							SigSt_s	<= DIV1_ST;
						end if;
						
					-- ADD2_ST state
					-- 
					when ADD2_ST =>
						if(DivDone_s = High_c) then
							AddIn1_s	<= DivRes_s;
							AddIn2_s	<= OneFp_c;
							AddOND_s	<= High_c;
							SigSt_s	<= DIV2_ST;
						else
							SigSt_s	<= ADD2_ST;
						end if;
						
					-- DIV2_ST state
					-- 
					when DIV2_ST =>
						if(AddDone_s = High_c) then
							DivIn1_s	<= AddRes_s;
							DivIn2_s	<= TwoFp_c;
							DivOND_s	<= High_c;
							SigSt_s	<= FINAL_ST;
						else
							SigSt_s	<= DIV2_ST;
						end if;
						
					-- FINAL_ST state
					-- 
					when FINAL_ST =>
						if(DivDone_s = High_c) then
							SigSt_s	<= ADD1_ST;
							ResRdy_s	<= High_c;
							CalcRun_v:= Low_c;
						else
							SigSt_s	<= FINAL_ST;
						end if;

					-- others state
					-- 
					when others => 					

				end case;
				
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
			In_s		<= (others=>'0');
			AbsIn_s	<= (others=>'0');
		elsif( rising_edge( CLK )) then
			Trig_s 	<= TRIG;
			bTrig_s 	<= Trig_s;
			In_s		<= INPUT;
			AbsIn_s	<= '0' & INPUT(30 downto 0);
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
    OUTPUT	<= DivRes_s;
    
    -- InOuts
    --
    
    -- Internals
    --


end YTU;
