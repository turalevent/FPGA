----------------------------------------------------------------------------------
-- Company: LvnT
-- Engineer: Levent TURA 
-- 
-- Create Date: 04.01.2024
-- Design Name: 
-- Module Name: Sigmoid - LvnT
-- Project Name: NN2x4x4x2_prj
-- Target Devices: -
-- Tool Versions: -
-- Description: IT computes 1 Neuron's Sigmoid result regarding its Input and Weight. 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Sigmoid is
	PORT(
		CLK   : in  std_logic;
		RST   : in  std_logic;
		TRIG  : in  std_logic;
		INPUT : in  std_logic_vector(31 downto 0);  
		RDY	  : out std_logic;
		OUTPUT: out std_logic_vector(31 downto 0)  
	);
end Sigmoid;

architecture LvnT of Sigmoid is


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

	constant cHigh : std_logic := '1';
	constant cLow  : std_logic := '0';
	constant cOneFp: std_logic_vector(31 downto 0) := X"3f800000";
	constant cTwoFp: std_logic_vector(31 downto 0) := X"40000000";
    
	-- 
	-- Types
	--

	type SigFSM_t is(
	  IDLE_ST,
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
	signal sMainSt			: SigFSM_t;
	
	-- General Signals
	signal sTrig		  : std_logic;
	signal sTrigDly	  : std_logic;
	signal sEnRise    : std_logic;
	signal sIn			  : std_logic_vector(31 downto 0);
	signal sAbsIn		  : std_logic_vector(31 downto 0);
	signal sResRdy	  : std_logic;
	signal sSigRes	  : std_logic_vector(31 downto 0);

	-- Floating Point Adder signals
	signal sAddTrig	  : std_logic;
	signal sAddDone	  : std_logic;
	signal sAddRdy	  : std_logic;
	signal sAddRdyDly	: std_logic;
	signal sAddIn1	  : std_logic_vector(31 downto 0);
	signal sAddIn2	  : std_logic_vector(31 downto 0);
	signal sAddRes	  : std_logic_vector(31 downto 0);

	-- Floating Point Divider signals
	signal sDivTrig	  : std_logic;
	signal sDivDone	  : std_logic;
	signal sDivRdy	  : std_logic;
	signal sDivRdyDly	: std_logic;
	signal sDivIn1	  : std_logic_vector(31 downto 0);
	signal sDivIn2	  : std_logic_vector(31 downto 0);
	signal sDivRes	  : std_logic_vector(31 downto 0);
		
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
		A	    => sAddIn1,
		B	    => sAddIn2,
		EN    => sAddTrig,
		NAN   => open,
		INF   => open,
		READY => sAddRdy,
		RES   => sAddRes
	);

	-- Divider_cmp component
	-- Floating Point Divider
	Divider_cmp : f32_divider 
	PORT MAP(
		CLK	  => CLK,
		RST	  => RST,
		A		  => sDivIn1,
		B		  => sDivIn2,
		EN    => sDivTrig,
		NAN   => open,
		INF   => open,
		READY => sDivRdy,
		RES	  => sDivRes
	);

	-- Sigmoid calculation
	--
	--        1          In
	-- Out = --- * [ ---------- + 1 ]
	--        2       1 + |In|
	--
	-- Step-1 : Calc. Abs(In)
	-- Step-2 : Calc. 1 + Abs(In)	-> ADD1_ST
	-- Step-3 : Calc. /				    -> DIV1_ST
	-- Step-4 : Calc. + 1 			  -> ADD2_ST
	-- Step-5 : Calc. / 2 			  -> DIV2_ST
    
	-- Main_p process
	--
	Main_p : process( CLK, RST )
	begin
    if(rising_edge(CLK)) then
      if(RST = cHigh) then
        sResRdy	<= cLow;
        sAddTrig<= cLow;
        sDivTrig<= cLow;
        sMainSt	<= IDLE_ST;
        sAddIn1	<= (others=>'0');
        sAddIn2	<= (others=>'0');
        sSigRes	<= (others=>'0');
      else
        sAddTrig<= cLow;
        sDivTrig<= cLow;       
        case sMainSt is

          -- ADD1_ST state
          -- 
          when IDLE_ST =>
            if(sEnRise = cHigh) then
              sMainSt	<= ADD1_ST;
              sResRdy	<= cLow;
              sSigRes	<= (others=>'0');
            end if;
            
          -- ADD1_ST state
          -- 
          when ADD1_ST =>
            sAddIn1	<= cOneFp;
            sAddIn2	<= sAbsIn;
            sAddTrig<= cHigh;
            sMainSt	<= DIV1_ST;
            
          -- DIV1_ST state
          -- 
          when DIV1_ST =>
            if(sAddDone = cHigh) then
              sDivIn1	<= sIn;
              sDivIn2	<= sAddRes;
              sDivTrig<= cHigh;
              sMainSt	<= ADD2_ST;
            else
              sMainSt	<= DIV1_ST;
            end if;
            
          -- ADD2_ST state
          -- 
          when ADD2_ST =>
            if(sDivDone = cHigh) then
              sAddIn1	<= sDivRes;
              sAddIn2	<= cOneFp;
              sAddTrig<= cHigh;
              sMainSt	<= DIV2_ST;
            else
              sMainSt	<= ADD2_ST;
            end if;
            
          -- DIV2_ST state
          -- 
          when DIV2_ST =>
            if(sAddDone = cHigh) then
              sDivIn1	<= sAddRes;
              sDivIn2	<= cTwoFp;
              sDivTrig<= cHigh;
              sMainSt	<= FINAL_ST;
            else
              sMainSt	<= DIV2_ST;
            end if;
            
          -- FINAL_ST state
          -- 
          when FINAL_ST =>
            if(sDivDone = cHigh) then
              sMainSt	<= IDLE_ST;
              sResRdy	<= cHigh;
              sSigRes	<= sDivRes;
            else
              sMainSt	<= FINAL_ST;
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
    if(rising_edge(CLK)) then
      if(RST = cHigh) then
        sTrig 	   <= cLow;
        sTrigDly   <= cLow;
        sIn		     <= (others=>'0');
        sAbsIn	   <= (others=>'0');
        sDivRdyDly <= cLow;
        sAddRdyDly <= cLow;
      else
        sTrig 	   <= TRIG;
        sTrigDly   <= sTrig;
        sIn		     <= INPUT;
        sAbsIn	   <= '0' & INPUT(30 downto 0);
        sDivRdyDly <= sDivRdy;
        sAddRdyDly <= sAddRdy;
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
    OUTPUT<= sSigRes;
    
    -- InOuts
    --
    
    -- Internals
    --
	sEnRise  <= sTrig AND (NOT sTrigDly);
	sDivDone <= sDivRdy AND (NOT sDivRdyDly);
	sAddDone <= sAddRdy AND (NOT sAddRdyDly);


end LvnT;
