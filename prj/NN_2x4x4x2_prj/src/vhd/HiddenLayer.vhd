----------------------------------------------------------------------------------
-- Company: LvnT
-- Engineer: Levent TURA 
-- 
-- Create Date: 04.01.2024
-- Design Name: 
-- Module Name: HiddenLayer - LvnT
-- Project Name: NN2x4x4x2_prj
-- Target Devices: -
-- Tool Versions: -
-- Description: Neural Network Hidden Layer which has 4 Neurons. 
-- Note : All floating points are in IEEE754 Single precision (f32).
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity HiddenLayer is
	GENERIC(
		NEURON_NUM : integer
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
		OUTPUT2	: out std_logic_vector(31 downto 0); 
		OUTPUT3	: out std_logic_vector(31 downto 0);  
		OUTPUT4	: out std_logic_vector(31 downto 0)  
	);
end HiddenLayer;

architecture LvnT of HiddenLayer is

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
--	type Array20x32_t is array (0 to (NEURON_NUM*(NEURON_NUM+1))-1) of std_logic_vector(31 downto 0);
	type Array20x32_t is array (0 to 19) of std_logic_vector(31 downto 0);
	type Array4x32_t  is array (0 to NEURON_NUM-1) of std_logic_vector(31 downto 0);
    
	--
	-- Constants
	--
	
	-- General
	constant cHigh 		: std_logic 	:= '1';
	constant cLow  		: std_logic 	:= '0';
	
	--
	-- Signals
	--	
	
	-- General Signals
	signal sWghSet		: std_logic;
	signal sTrig			: std_logic;
	signal sTrigDly			: std_logic;
	signal sResRdy		: std_logic;
	signal sRes			: std_logic_vector(31 downto 0);
	
	-- Neuron
	signal sNrnsTrig	: std_logic;
	signal sNrnsResRdy: std_logic;
	signal sWgh1			: std_logic_vector(31 downto 0);
	signal sWgh2			: std_logic_vector(31 downto 0);
	signal sWgh3			: std_logic_vector(31 downto 0);
	signal sWgh4			: std_logic_vector(31 downto 0);
	signal sWgh5			: std_logic_vector(31 downto 0);
	signal sNeuronsRes: std_logic_vector(31 downto 0);
	signal sNrnResArry: Array4x32_t;
	signal sWghArry		: Array20x32_t;

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
		TRIG  => sNrnsTrig,
		INPUT1=> INPUT1,
		INPUT2=> INPUT2,
		INPUT3=> INPUT3,
		INPUT4=> INPUT4,
		WGH1 	=> sWgh1,
		WGH2 	=> sWgh2,
		WGH3 	=> sWgh3,
		WGH4 	=> sWgh4,
		WGH5 	=> sWgh5,
		RDY	=> sNrnsResRdy,
		OUTPUT=> sNeuronsRes
	);

	-- Main_p process
	-- Trig Adders and Sigmoid synchronously..
	Main_p : process( CLK, RST )
		variable Ctr_v : integer range 0 to NEURON_NUM-1;
	begin

    if(rising_edge(CLK)) then
      if(RST = cHigh) then
        sResRdy		<= cLow;
        sNrnsTrig	  <= cLow;
        sWgh1		  <= (others=>'0');
        sWgh2		  <= (others=>'0');
        sWgh3		  <= (others=>'0');
        sWgh4		  <= (others=>'0');
        sWgh5		  <= (others=>'0');
        sNrnResArry<= (others=>(others=>'0'));
        Ctr_v			  := 0;
      else
        sResRdy	<= cLow;
        sNrnsTrig<= cLow;
  
        -- Trig Multiplier
        if(sTrigDly = cLow AND sTrig = cHigh) then
          sNrnsTrig<= cHigh;
          Ctr_v	 	:= 0;
        end if;
  
        if(sNrnsResRdy = cHigh) then
          sNrnResArry(Ctr_v)(31 downto 0)	<= sNeuronsRes;
          if(Ctr_v = NEURON_NUM-1) then
            sResRdy	<= cHigh;
          else
            sNrnsTrig<= cHigh;
            Ctr_v		:= Ctr_v + 1;
          end if;
        end if;
          
        sWgh1	<= sWghArry(Ctr_v*5)(31 downto 0);
        sWgh2	<= sWghArry((Ctr_v*5)+1)(31 downto 0);
        sWgh3	<= sWghArry((Ctr_v*5)+2)(31 downto 0);
        sWgh4	<= sWghArry((Ctr_v*5)+3)(31 downto 0);
        sWgh5	<= sWghArry((Ctr_v*5)+4)(31 downto 0);
      end if;
    end if;	

	end process;

	-- SetWgh_p process
	-- Set Weights
	SetWgh_p : process( CLK, RST )
		variable WghNum_v : integer range 0 to 20;
	begin
    if(rising_edge(CLK)) then
      if(RST = cHigh) then
        sWghArry <= (others=>(others=>'0'));
        WghNum_v := 0;
      else
        if(sWghSet = cHigh) then
          WghNum_v	:= conv_integer(WGH_NUM);
          sWghArry(WghNum_v)(31 downto 0)	<= WGH;
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
        sWghSet <= cLow;
        sTrig 	<= cLow;
        sTrigDly<= cLow;
      else
        sWghSet <= WGH_SET;
        sTrig 	<= TRIG;
        sTrigDly<= sTrig;
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
	OUTPUT1	<= sNrnResArry(0)(31 downto 0);
	OUTPUT2	<= sNrnResArry(1)(31 downto 0);
	OUTPUT3	<= sNrnResArry(2)(31 downto 0);
	OUTPUT4	<= sNrnResArry(3)(31 downto 0);
	
	-- InOuts
	--

	-- Internals
	--

end LvnT;
