----------------------------------------------------------------------------------
-- Company: LvnT
-- Engineer: Levent TURA 
-- 
-- Create Date: 04.01.2024
-- Design Name: 
-- Module Name: Neuron - LvnT
-- Project Name: NN2x4x4x2_prj
-- Target Devices: -
-- Tool Versions: -
-- Description: IT computes 1 Neuron output regarding its own Weight and Input. 
-- Note : All floating points are in IEEE754 Single precision (f32).
-- 
-- Dependencies: 
-- 
-- Revision:
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
		RDY	  : out std_logic;
		OUTPUT: out std_logic_vector(31 downto 0)  
	);
end Neuron;

architecture LvnT of Neuron is

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
			RDY	  : out std_logic;
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
	constant cHigh 		  : std_logic := '1';
	constant cLow  		  : std_logic := '0';
	-- Multiplier Counter Limit
	constant cMaxMultCnt: integer := 3;
    
	-- 
	-- Types
	--
	type Array4x32_t is array (0 to 3) of std_logic_vector(31 downto 0);
	
	--
	-- Signals
	--

	-- Typed Signals
	signal sMultResArray: Array4x32_t;
   
	-- General Signals
	signal sTrig			: std_logic;
	signal sTrigDly		: std_logic;
	signal sResRdy		: std_logic;
	signal sNeuronRes	: std_logic_vector(31 downto 0);
	
	-- Sigmoid
	signal sSigmTrig	: std_logic;

	-- Floating Point Adder-1 signals
	signal sAddTrig		: std_logic;
	signal sAddRdy	  : std_logic;
	signal sAddRdyDly : std_logic;
	signal sAddDone		: std_logic;
	signal sAddIn1		: std_logic_vector(31 downto 0);
	signal sAddIn2		: std_logic_vector(31 downto 0);
	signal sAddRes		: std_logic_vector(31 downto 0);

	-- Floating Point Multiplier signals
	signal sMultTrig	: std_logic;
	signal sMultRdy	  : std_logic;
	signal sMultRdyDly: std_logic;
	signal sMultDone	: std_logic;
	signal sMultIn1		: std_logic_vector(31 downto 0);
	signal sMultIn2		: std_logic_vector(31 downto 0);
	signal sMultRes		: std_logic_vector(31 downto 0);
	signal sMultCnt		: integer range 0 to cMaxMultCnt;
		

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
		TRIG  => sSigmTrig,
		INPUT => sAddRes,
		RDY	  => sResRdy,
		OUTPUT=> sNeuronRes
	);

	-- Adder_cmp component
	-- Floating Point Adder
	Adder_cmp: f32_adder
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    => sAddIn1,
		B	    => sAddIn2,
		EN    => sAddTrig,
		NAN   => open,
		INF   => open,
		READY => sAddRdy,
		RES   => sAddRes
	);

	-- Mult_cmp component
	-- 
	Mult_cmp : f32_multiplier 
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    => sMultIn1,
		B	    => sMultIn2,
		EN    => sMultTrig,
		NAN   => open,
		INF   => open,
		READY => sMultRdy,
		RES   => sMultRes
	);


	-- Main_p process
	-- Trig Adders and Sigmoid synchronously..
	Main_p : process( CLK, RST )
		variable Ctr_v : integer range 0 to 4;
	begin
    if(rising_edge(CLK)) then
      if(RST = cHigh) then
        sAddTrig 	<= cLow;
        sSigmTrig	<= cLow;
        sAddIn1		<= (others=>'0');
        sAddIn2		<= (others=>'0');
        Ctr_v			:= 0;
      else
        sAddTrig	<= cLow;
        sSigmTrig	<= cLow;		
        -- Trig Adder-1 & Adder-2
        if((sMultCnt = 3) AND (sMultDone = cHigh)) then
          sAddIn1	<= sMultResArray(Ctr_v)(31 downto 0);
          sAddIn2	<= sMultResArray(Ctr_v+1)(31 downto 0);
          sAddTrig<= cHigh;
          Ctr_v		:= Ctr_v + 2;				
        end if;
        if(sAddDone = cHigh) then				
          if(Ctr_v = 5) then
            sSigmTrig<= cHigh;		
            Ctr_v		 := 0;
          else
            if(Ctr_v = 4) then
              sAddIn1	<= WGH5;
            else
              sAddIn1	<= sMultResArray(Ctr_v)(31 downto 0);
            end if;
            sAddIn2	<= sAddRes;				
            sAddTrig<= cHigh;
            Ctr_v		:= Ctr_v + 1;				
          end if;
        end if;
      end if;
    end if;
	end process;

	-- MultCtrl_p process
	-- Multiplier Control process
	MultCtrl_p : process( CLK, RST )
	begin
    if(rising_edge(CLK)) then
      if(RST = cHigh) then
        sMultCnt 		 <= 0;
        sMultTrig 	 <= cLow;
        sMultResArray<= (others=>(others=>'0'));
      else
        sMultTrig <= cLow;
        -- Trig Multiplier
        if(sTrigDly = cLow AND sTrig = cHigh) then
          sMultCnt 		 <= 0;
          sMultTrig 	 <= cHigh;
          sMultResArray<= (others=>(others=>'0'));
        end if;
        if(sMultDone = cHigh) then
          sMultResArray(sMultCnt)(31 downto 0)	<= sMultRes;
          if(sMultCnt = cMaxMultCnt) then
            sMultCnt  <= 0;
          else
            sMultCnt  <= sMultCnt + 1;
            sMultTrig <= cHigh;
          end if;
        end if;
      end if;
    end if;
	end process;

	-- Buf_p process
	--
	Buf_p : process( CLK, RST )
	begin
    if(rising_edge(CLK)) then
      if(RST = cHigh) then
        sTrig 	    <= cLow;
        sTrigDly    <= cLow;
        sMultRdyDly <= cLow;
        sAddRdyDly  <= cLow;
      else
        sTrig 	    <= TRIG;
        sTrigDly    <= sTrig;
        sMultRdyDly <= sMultRdy;
        sAddRdyDly  <= sAddRdy;
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
	RDY		<= sResRdy;
	OUTPUT<= sNeuronRes;

	-- InOuts
	--

	-- Internals
	--
	sMultDone<= sMultRdy AND (NOT sMultRdyDly);
	sAddDone <= sAddRdy AND (NOT sAddRdyDly);
	
	sMultIn1<= INPUT1	when	sMultCnt = 0 else
					   INPUT2	when	sMultCnt = 1 else
					   INPUT3	when	sMultCnt = 2 else
					   INPUT4;

	sMultIn2<= WGH1		when	sMultCnt = 0 else
					   WGH2		when	sMultCnt = 1 else
					   WGH3		when	sMultCnt = 2 else
					   WGH4;

end LvnT;
