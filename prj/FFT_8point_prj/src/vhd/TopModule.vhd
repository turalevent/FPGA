----------------------------------------------------------------------------------
-- Company: LvnT
-- Engineer: Levent TURA 
-- 
-- Create Date: 31.12.2023
-- Design Name: 
-- Module Name: TopModule - LvnT
-- Project Name: FFT-8points
-- Target Devices: -
-- Tool Versions: -
-- Description: 8 points FFT implementation
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
use IEEE.NUMERIC_STD.ALL;

entity f32_FFT8 is
	PORT(
    CLK  : in  std_logic;
    RST  : in  std_logic;
    EN   : in  std_logic;
    -- SAMPLES
    x0   : in  std_logic_vector(31 downto 0);
    x1   : in  std_logic_vector(31 downto 0);
    x2   : in  std_logic_vector(31 downto 0);
    x3   : in  std_logic_vector(31 downto 0);
    x4   : in  std_logic_vector(31 downto 0);
    x5   : in  std_logic_vector(31 downto 0);
    x6   : in  std_logic_vector(31 downto 0);
    x7   : in  std_logic_vector(31 downto 0);
    -- Ouputs
    X0R  : out std_logic_vector(31 downto 0);
    X0I  : out std_logic_vector(31 downto 0);
    X1R  : out std_logic_vector(31 downto 0);
    X1I  : out std_logic_vector(31 downto 0);
    X2R  : out std_logic_vector(31 downto 0);
    X2I  : out std_logic_vector(31 downto 0);
    X3R  : out std_logic_vector(31 downto 0);
    X3I  : out std_logic_vector(31 downto 0);
    X4R  : out std_logic_vector(31 downto 0);
    X4I  : out std_logic_vector(31 downto 0);
    X5R  : out std_logic_vector(31 downto 0);
    X5I  : out std_logic_vector(31 downto 0);
    X6R  : out std_logic_vector(31 downto 0);
    X6I  : out std_logic_vector(31 downto 0);
    X7R  : out std_logic_vector(31 downto 0);
    X7I  : out std_logic_vector(31 downto 0);      
    READY: out std_logic;
    NAN  : out std_logic;
    INF  : out std_logic
  );
end f32_FFT8;

architecture LvnT of f32_FFT8 is

	--
	-- COMPONENT DECLERATIONS
	--
	COMPONENT f32_butterfly
	PORT(
	  CLK, RST		: in  std_logic;
	  Ar, Ai			: in  std_logic_vector(31 downto 0);
	  Br, Bi			: in  std_logic_vector(31 downto 0);
	  TWDr, TWDi	: in  std_logic_vector(31 downto 0);
    READY       : out std_logic;
    EN	        : in  std_logic;
    NAN, INF    : out std_logic;
	  RESUr,RESUi	: out std_logic_vector(31 downto 0);
	  RESDr,RESDi	: out std_logic_vector(31 downto 0)
	);
	END COMPONENT;
	
	--
	-- Types
	--
	type tTwdArr is ARRAY(0 to 8) of std_logic_vector(31 downto 0);	-- Twiddle Array 
	type tBtfArr is ARRAY(0 to 3) of std_logic_vector(31 downto 0);	-- Butterfly Array
	 
	 
	--
	-- Constants
	--
	 
	-- General
	constant cHigh: std_logic := '1';
	constant cLow : std_logic := '0';
	
	-- k
	-- W
	-- N
	-- Twiddle Factors (in IEEE754 single precision 32-bit floating point format)
	constant cTwd	: tTwdArr := (
		-- W2.0: 1+j0
		X"3F800000",	-- Re{W2.0}		:  1
		-- W4.0: 1+j0
		X"3F800000",	-- Re{W4.0}		:  1
		-- W4.1: 0-j
		X"BF800000",	-- Im{W4.1}		: -j
		-- W8.0: 1+j0
		X"3F800000",	-- Re{W8.0}		:  1
		-- W8.1: 0.707106-j0.707106
		X"3F3504E6",	-- Re{W8.1}		:  0.707106
		X"BF3504E6",	-- Im(W8.1}		: -0.707106
		-- W8.2: 0-j
		X"BF800000",	-- Im{W8.2}		: -j
		-- W8.3: -0.707106-j0.707106
		X"BF3504E6",	-- Re{W8.3}		: -0.707106
		X"BF3504E6"		-- Im{W8.3}		: -0.707106
	);
	constant cZeros: std_logic_vector(31 downto 0):= (others=>'0');

	--
	-- Signals
	--	
	signal sReady    : std_logic;
	signal sNAN, sInf: std_logic;
	
	-- Butterflies 
		-- Stage0
	signal sStg0Ur   : tBtfArr;	   -- Stage0 Butterfly Up wings {Re}
	signal sStg0Ui   : tBtfArr; 	 -- Stage0 Butterfly Up wings {Im}
	signal sStg0Dr   : tBtfArr;	   -- Stage0 Butterfly Down wings {Re}
	signal sStg0Di   : tBtfArr; 	 -- Stage0 Butterfly Down wings {Im}
	signal sEnStg0   : std_logic;
	signal sRdyStg00 : std_logic;
	signal sNANStg00 : std_logic;
	signal sInfStg00 : std_logic;
	signal sRdyStg01 : std_logic;
	signal sNANStg01 : std_logic;
	signal sInfStg01 : std_logic;
	signal sRdyStg02 : std_logic;
	signal sNANStg02 : std_logic;
	signal sInfStg02 : std_logic;
	signal sRdyStg03 : std_logic;
	signal sNANStg03 : std_logic;
	signal sInfStg03 : std_logic;
		-- Stage1
	signal sStg1Ur   : tBtfArr;	   -- Stage1 Butterfly Up wings {Re}
	signal sStg1Ui   : tBtfArr; 	 -- Stage1 Butterfly Up wings {Im}
	signal sStg1Dr   : tBtfArr;	   -- Stage1 Butterfly Down wings {Re}
	signal sStg1Di   : tBtfArr; 	 -- Stage1 Butterfly Down wings {Im}
	signal sEnStg1   : std_logic;
	signal sRdyStg10 : std_logic;
	signal sNANStg10 : std_logic;
	signal sInfStg10 : std_logic;
	signal sRdyStg11 : std_logic;
	signal sNANStg11 : std_logic;
	signal sInfStg11 : std_logic;
	signal sRdyStg12 : std_logic;
	signal sNANStg12 : std_logic;
	signal sInfStg12 : std_logic;
	signal sRdyStg13 : std_logic;
	signal sNANStg13 : std_logic;
	signal sInfStg13 : std_logic;
		-- Stage2
	signal sEnStg2   : std_logic;
	signal sRdyStg20 : std_logic;
	signal sNANStg20 : std_logic;
	signal sInfStg20 : std_logic;
	signal sRdyStg21 : std_logic;
	signal sNANStg21 : std_logic;
	signal sInfStg21 : std_logic;
	signal sRdyStg22 : std_logic;
	signal sNANStg22 : std_logic;
	signal sInfStg22 : std_logic;
	signal sRdyStg23 : std_logic;
	signal sNANStg23 : std_logic;
	signal sInfStg23 : std_logic;
begin

    
	--
	-- Primitives ---------------------------------------------
	--

	--
	-- Components ---------------------------------------------
	--
	
	-------------------------------------
	--     FFT Stage0 Computation      --
	-------------------------------------
	-- cmpB1 32bit floating point butterfly
	cmpB1: f32_butterfly
	PORT MAP(
		CLK	=> CLK,
		RST	=> RST,
		Ar		=> x0, 			    -- Re{x0}	: Sample-0
		Ai		=> cZeros,		  -- Im{x0}	: 0
		Br		=> x4, 			    -- Re{x4}	: Sample-4
		Bi		=> cZeros,		  -- Im{x4}	: 0
		TWDr	=> cTwd(0),		  -- Re{W2.0} : 1
		TWDi	=> cZeros,		  -- Im{W2.0} : 0
		EN    => sEnStg0,
		READY => sRdyStg00,
		NAN   => sNANStg00,
		INF   => sInfStg00,
		RESUr	=> sStg0Ur(0),	-- Stage-0 0th Up  Wing result (Re)
		RESUi	=> sStg0Ui(0),	-- Stage-0 0th Up  Wing result (Im)
		RESDr	=> sStg0Dr(0),	-- Stage-0 0th Dwn Wing result (Re)
		RESDi	=> sStg0Di(0)	  -- Stage-0 0th Dwn Wing result (Im)
	);
	-- cmpB2 32bit floating point butterfly
	cmpB2: f32_butterfly
	PORT MAP(
		CLK	=> CLK,
		RST	=> RST,
		Ar		=> x2, 			    -- Re{x0}	: Sample-2
		Ai		=> cZeros,		  -- Im{x0}	: 0
		Br		=> x6, 			    -- Re{x4}	: Sample-6
		Bi		=> cZeros,		  -- Im{x4}	: 0
		TWDr	=> cTwd(0),		  -- Re{W2.0} : 1
		TWDi	=> cZeros,		  -- Im{W2.0} : 0
		EN    => sEnStg0,
		READY => sRdyStg01,
		NAN   => sNANStg01,
		INF   => sInfStg01,
		RESUr	=> sStg0Ur(1),	-- Stage-0 1st Up  Wing result (Re)
		RESUi	=> sStg0Ui(1),	-- Stage-0 1st Up  Wing result (Im)
		RESDr	=> sStg0Dr(1),	-- Stage-0 1st Dwn Wing result (Re)
		RESDi	=> sStg0Di(1)	  -- Stage-0 1st Dwn Wing result (Im)
	);
	-- cmpB3 32bit floating point butterfly
	cmpB3: f32_butterfly
	PORT MAP(
		CLK	=> CLK,
		RST	=> RST,
		Ar		=> x1, 			    -- Re{x0}	: Sample-1
		Ai		=> cZeros,		  -- Im{x0}	: 0
		Br		=> x5, 			    -- Re{x4}	: Sample-5
		Bi		=> cZeros,		  -- Im{x4}	: 0
		TWDr	=> cTwd(0),		  -- Re{W2.0} : 1
		TWDi	=> cZeros,		  -- Im{W2.0} : 0
		EN    => sEnStg0,
		READY => sRdyStg02,
		NAN   => sNANStg02,
		INF   => sInfStg02,
		RESUr	=> sStg0Ur(2),	-- Stage-0 2nd Up  Wing result (Re)
		RESUi	=> sStg0Ui(2),	-- Stage-0 2nd Up  Wing result (Im)
		RESDr	=> sStg0Dr(2),	-- Stage-0 2nd Dwn Wing result (Re)
		RESDi	=> sStg0Di(2)	  -- Stage-0 2nd Dwn Wing result (Im)
	);
	-- cmpB4 32bit floating point butterfly
	cmpB4: f32_butterfly
	PORT MAP(
		CLK	=> CLK,
		RST	=> RST,
		Ar		=> x3, 			    -- Re{x0}	: Sample-3
		Ai		=> cZeros,		  -- Im{x0}	: 0
		Br		=> x7, 			    -- Re{x4}	: Sample-7
		Bi		=> cZeros,		  -- Im{x4}	: 0
		TWDr	=> cTwd(0),		  -- Re{W2.0} : 1
		TWDi	=> cZeros,		  -- Im{W2.0} : 0
		EN    => sEnStg0,
		READY => sRdyStg03,
		NAN   => sNANStg03,
		INF   => sInfStg03,
		RESUr	=> sStg0Ur(3),	-- Stage-0 3rd Up  Wing result (Re)
		RESUi	=> sStg0Ui(3),	-- Stage-0 3rd Up  Wing result (Im)
		RESDr	=> sStg0Dr(3),	-- Stage-0 3rd Dwn Wing result (Re)
		RESDi	=> sStg0Di(3)	  -- Stage-0 3rd Dwn Wing result (Im)
	);
	
	-------------------------------------
	--     FFT Stage-1 Computation      --
	-------------------------------------
	-- cmpB5 32bit floating point butterfly
	cmpB5: f32_butterfly
	PORT MAP(
		CLK	=> CLK,
		RST	=> RST,
		Ar		=> sStg0Ur(0),	-- Re{sStg0.0U}
		Ai		=> sStg0Ui(0),	-- Im{sStg0.0U}
		Br		=> sStg0Ur(1),	-- Re{sStg0.1U}
		Bi		=> sStg0Ui(1),	-- Im{sStg0.1U}
		TWDr	=> cTwd(1),		  -- Re{W4.0} : 1
		TWDi	=> cZeros,		  -- Im{W4.0} : 0
		EN    => sEnStg1,
		READY => sRdyStg10,
		NAN   => sNANStg10,
		INF   => sInfStg10,
		RESUr	=> sStg1Ur(0),	-- Stage-1 0th Up  Wing result (Re)
		RESUi	=> sStg1Ui(0),	-- Stage-1 0th Up  Wing result (Im)
		RESDr	=> sStg1Dr(0),	-- Stage-1 0th Dwn Wing result (Re)
		RESDi	=> sStg1Di(0)	  -- Stage-1 0th Dwn Wing result (Im)
	);
	-- cmpB6 32bit floating point butterfly
	cmpB6: f32_butterfly
	PORT MAP(
		CLK	=> CLK,
		RST	=> RST,
		Ar		=> sStg0Dr(0),	-- Re{sStg0.0D}
		Ai		=> sStg0Di(0),	-- Im{sStg0.0D}
		Br		=> sStg0Dr(1),	-- Re{sStg0.1D}
		Bi		=> sStg0Di(1),	-- Im{sStg0.1D}
		TWDr	=> cZeros,		  -- Re{W4.1} : 0
		TWDi	=> cTwd(2),		  -- Im{W4.1} : -j
		EN    => sEnStg1,
		READY => sRdyStg11,
		NAN   => sNANStg11,
		INF   => sInfStg11,
		RESUr	=> sStg1Ur(1),	-- Stage-1 1st Up  Wing result (Re)
		RESUi	=> sStg1Ui(1),	-- Stage-1 1st Up  Wing result (Im)
		RESDr	=> sStg1Dr(1),	-- Stage-1 1st Dwn Wing result (Re)
		RESDi	=> sStg1Di(1)	  -- Stage-1 1st Dwn Wing result (Im)
	);
	-- cmpB7 32bit floating point butterfly
	cmpB7: f32_butterfly
	PORT MAP(
		CLK	=> CLK,
		RST	=> RST,
		Ar		=> sStg0Ur(2),	-- Re{sStg0.2U}
		Ai		=> sStg0Ui(2),	-- Im{sStg0.2U}
		Br		=> sStg0Ur(3),	-- Re{sStg0.3U}
		Bi		=> sStg0Ui(3),	-- Im{sStg0.3U}
		TWDr	=> cTwd(1),		  -- Re{W4.0} : 1
		TWDi	=> cZeros,		  -- Im{W4.1} : 0
		EN    => sEnStg1,
		READY => sRdyStg12,
		NAN   => sNANStg12,
		INF   => sInfStg12,
		RESUr	=> sStg1Ur(2),	-- Stage-1 2nd Up  Wing result (Re)
		RESUi	=> sStg1Ui(2),	-- Stage-1 2nd Up  Wing result (Im)
		RESDr	=> sStg1Dr(2),	-- Stage-1 2nd Dwn Wing result (Re)
		RESDi	=> sStg1Di(2)	  -- Stage-1 2nd Dwn Wing result (Im)
	);
	-- cmpB8 32bit floating point butterfly
	cmpB8: f32_butterfly
	PORT MAP(
		CLK	=> CLK,
		RST	=> RST,
		Ar		=> sStg0Dr(2),	-- Re{sStg0.2D}
		Ai		=> sStg0Di(2),	-- Im{sStg0.2D}
		Br		=> sStg0Dr(3),	-- Re{sStg0.3D}
		Bi		=> sStg0Di(3),	-- Im{sStg0.3D}
		TWDr	=> cZeros,		  -- Re{W4.1} : 0
		TWDi	=> cTwd(2),		  -- Im{W4.1} : -j
		EN    => sEnStg1,
		READY => sRdyStg13,
		NAN   => sNANStg13,
		INF   => sInfStg13,
		RESUr	=> sStg1Ur(3),	-- Stage-1 1st Up  Wing result (Re)
		RESUi	=> sStg1Ui(3),	-- Stage-1 1st Up  Wing result (Im)
		RESDr	=> sStg1Dr(3),	-- Stage-1 1st Dwn Wing result (Re)
		RESDi	=> sStg1Di(3)	  -- Stage-1 1st Dwn Wing result (Im)
	);

	-------------------------------------
	--     FFT Stage-2 Computation      --
	-------------------------------------
	-- cmpB9 32bit floating point butterfly
	cmpB9: f32_butterfly
	PORT MAP(
		CLK	=> CLK,
		RST	=> RST,
		Ar		=> sStg1Ur(0),	-- Re{sStg1.0U}
		Ai		=> sStg1Ui(0),	-- Im{sStg1.0U}
		Br		=> sStg1Ur(2),	-- Re{sStg1.2U}
		Bi		=> sStg1Ui(2),	-- Im{sStg1.2U}
		TWDr	=> cTwd(3),		  -- Re{W8.0} : 1
		TWDi	=> cZeros,		  -- Im{W8.0} : 0
		EN    => sEnStg2,
		READY => sRdyStg20,
		NAN   => sNANStg20,
		INF   => sInfStg20,
		RESUr	=> X0R,			    -- Re{X0}
		RESUi	=> X0I,			    -- Im{X0}
		RESDr	=> X4R,			    -- Re{X4}
		RESDi	=> X4I			    -- Im{X4}
	);
	-- cmpB10 32bit floating point butterfly
	cmpB10: f32_butterfly
	PORT MAP(
		CLK	=> CLK,
		RST	=> RST,
		Ar		=> sStg1Ur(1),	-- Re{sStg1.1U}
		Ai		=> sStg1Ui(1),	-- Im{sStg1.1U}
		Br		=> sStg1Ur(3),	-- Re{sStg1.3U}
		Bi		=> sStg1Ui(3),	-- Im{sStg1.3U}
		TWDr	=> cTwd(4),		  -- Re{W8.1} : 0.707
		TWDi	=> cTwd(5),		  -- Im{W8.1} : -j0.707
		EN    => sEnStg2,
		READY => sRdyStg21,
		NAN   => sNANStg21,
		INF   => sInfStg21,
		RESUr	=> X1R,			    -- Re{X1}
		RESUi	=> X1I,			    -- Im{X1}
		RESDr	=> X5R,			    -- Re{X5}
		RESDi	=> X5I			    -- Im{X5}
	);
	-- cmpB11 32bit floating point butterfly
	cmpB11: f32_butterfly
	PORT MAP(
		CLK	=> CLK,
		RST	=> RST,
		Ar		=> sStg1Dr(0),	-- Re{sStg1.0D}
		Ai		=> sStg1Di(0),	-- Im{sStg1.0D}
		Br		=> sStg1Dr(2),	-- Re{sStg1.2D}
		Bi		=> sStg1Di(2),	-- Im{sStg1.2D}
		TWDr	=> cZeros,		  -- Re{W8.2} : 0
		TWDi	=> cTwd(6),		  -- Im{W8.2} : -j
		EN    => sEnStg2,
		READY => sRdyStg22,
		NAN   => sNANStg22,
		INF   => sInfStg22,
		RESUr	=> X2R,			    -- Re{X2}
		RESUi	=> X2I,			    -- Im{X2}
		RESDr	=> X6R,			    -- Re{X6}
		RESDi	=> X6I			    -- Im{X6}
	);
	-- cmpB12 32bit floating point butterfly
	cmpB12: f32_butterfly
	PORT MAP(
		CLK	  => CLK,
		RST	  => RST,
		Ar		=> sStg1Dr(1),	-- Re{sStg1.1D}
		Ai		=> sStg1Di(1),	-- Im{sStg1.1D}
		Br		=> sStg1Dr(3),	-- Re{sStg1.3D}
		Bi		=> sStg1Di(3),	-- Im{sStg1.3D}
		TWDr	=> cTwd(7),		  -- Re{W8.3} : -0.707
		TWDi	=> cTwd(8),		  -- Im{W8.3} : -j0.707
		EN    => sEnStg2,
		READY => sRdyStg23,
		NAN   => sNANStg23,
		INF   => sInfStg23,
		RESUr	=> X3R,			    -- Re{X3}
		RESUi	=> X3I,			    -- Im{X3}
		RESDr	=> X7R,			    -- Re{X7}
		RESDi	=> X7I			    -- Im{X7}
	);

	--
	-- Logic --------------------------------------------------
	--
    
	-- Inputs
	--

	-- Outputs
	--
	READY  <= sReady;
	NAN    <= sNAN;
	INF    <= sINF;
	
	-- InOuts
	--

	-- Internals
	--
	sEnStg0 <=  EN;
  sEnStg1 <=  sRdyStg00 AND sRdyStg01 AND sRdyStg02 AND sRdyStg03;
  sEnStg2 <=  sRdyStg10 AND sRdyStg11 AND sRdyStg12 AND sRdyStg13;
  
  sReady  <=  sRdyStg20 AND sRdyStg21 AND sRdyStg22 AND sRdyStg23;
  
  sInf    <=  sInfStg00 OR sInfStg01 OR sInfStg02 OR sInfStg03 OR 
              sInfStg10 OR sInfStg11 OR sInfStg12 OR sInfStg13 OR 
              sInfStg20 OR sInfStg21 OR sInfStg22 OR sInfStg23;

  sNAN    <=  sNANStg00 OR sNANStg01 OR sNANStg02 OR sNANStg03 OR 
              sNANStg10 OR sNANStg11 OR sNANStg12 OR sNANStg13 OR 
              sNANStg20 OR sNANStg21 OR sNANStg22 OR sNANStg23;
  
end LvnT;
