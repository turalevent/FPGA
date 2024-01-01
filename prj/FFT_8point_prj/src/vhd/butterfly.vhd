----------------------------------------------------------------------------------
-- Company: LvnT
-- Engineer: Levent TURA 
-- 
-- Create Date: 31.12.2023
-- Design Name: 
-- Module Name: Butterfly - LvnT
-- Project Name: butterfly
-- Target Devices: -
-- Tool Versions: -
-- Description: Butterfly implementation
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
USE IEEE.STD_LOGIC_ARITH.all;

entity f32_butterfly is
	PORT(
    CLK, RST	  : in  std_logic;
    EN	        : in  std_logic;
    -- SAMPLES
    Ar, Ai		  : in  std_logic_vector(31 downto 0);
    Br, Bi		  : in  std_logic_vector(31 downto 0);
    TWDr, TWDi  : in  std_logic_vector(31 downto 0);
    -- Ouputs
    READY       : out std_logic;
    NAN, INF    : out std_logic;
    RESUr,RESUi : out std_logic_vector(31 downto 0);
    RESDr,RESDi : out std_logic_vector(31 downto 0)
  );
end f32_butterfly;

architecture LvnT of f32_butterfly is

	--
	-- COMPONENT DECLERATIONS
	--
	
	-- f32_cpx_multiplier
	-- 32bit floating point complex multiplier
	COMPONENT f32_cpx_multiplier
	PORT(
    CLK,RST : in  std_logic;
    Ar, Ai	: in  std_logic_vector(31 downto 0);
    Br, Bi  : in  std_logic_vector(31 downto 0);
    EN      : in  std_logic;
    -- Ouputs
		NAN     : out std_logic;
		INF     : out std_logic;
    READY   : out std_logic;
    Rr, Ri  : out std_logic_vector(31 downto 0)
  );
	END COMPONENT;

	-- f32_cpx_adder
	-- 32bit floating point adder/subtracter
	COMPONENT f32_cpx_adder
	PORT(
    CLK,RST : in  std_logic;
    Ar, Ai  : in  std_logic_vector(31 downto 0);
    Br, Bi  : in  std_logic_vector(31 downto 0);
		EN      : in  std_logic;
		NAN     : out std_logic;
		INF     : out std_logic;
		READY   : out std_logic;
    Rr, Ri	: out std_logic_vector(31 downto 0)
  );
	END COMPONENT;

	-- f32CpxNegate
	-- 32bit Negate
	COMPONENT f32_cpx_negate
	PORT(
		CLK,RST	: in  std_logic;
		Ar, Ai	: in  std_logic_vector(31 downto 0);
		EN      : in  std_logic;
		READY   : out std_logic;
		Rr, Ri	: out std_logic_vector(31 downto 0)
	);
	END COMPONENT;
	
	--
	-- Constants
	--
	
	-- General
	constant cHigh : std_logic := '1';
	constant cLow  : std_logic := '0';
	
	--
	-- Typed
	--	
	
	--
	-- Signals
	--	
	signal sReady   : std_logic;
  signal sNAN,sInf: std_logic;
  signal sMultUr	: std_logic_vector(31 downto 0);
  signal sMultUi	: std_logic_vector(31 downto 0);
  signal sMultDr	: std_logic_vector(31 downto 0);
  signal sMultDi	: std_logic_vector(31 downto 0);
  signal sTWDr_n	: std_logic_vector(31 downto 0);
  signal sTWDi_n	: std_logic_vector(31 downto 0);
  -- Complex Multiplier-1
  signal sNANCM1  : std_logic;
  signal sInfCM1  : std_logic;
  signal sRdyCM1  : std_logic;
  signal sEnCM1   : std_logic;
  -- Complex Multiplier-2
  signal sNANCM2  : std_logic;
  signal sInfCM2  : std_logic;
  signal sRdyCM2  : std_logic;
  signal sEnCM2   : std_logic;
  -- Complex Adder-1
  signal sNANCA1  : std_logic;
  signal sInfCA1  : std_logic;
  signal sRdyCA1  : std_logic;
  signal sEnCA1   : std_logic;
  -- Complex Adder-2
  signal sNANCA2  : std_logic;
  signal sInfCA2  : std_logic;
  signal sRdyCA2  : std_logic;
  signal sEnCA2   : std_logic;
  -- Complex Negate
  signal sEnCN    : std_logic;
  signal sRdyCN   : std_logic;
  
begin

	--  (Ar+jAi) >------------(+)----- (ResUr+jResUi) 
	--                  \    /
	--                   \  /(TWDr+jTWDi)
	--                    \/
	--                    /\
	--                   /  \
	--                  /    \
	--  (Br+jBi) >--------->--(+)----- (ResDr+jResDi) 
	--                  -(TWDr+jTWDi)
	
	
	--
	-- Primitives ---------------------------------------------
	--

	--
	-- Components ---------------------------------------------
	--
	
	-------------------------------------
	-- Butterfly Up  Wing Computation  --
	-------------------------------------
	-- cmpCM1 
	-- Complex multiplication of B and TWD
	cmpCM1: f32_cpx_multiplier
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		Ar	  => Br,
		Ai	  => Bi,
		Br	  => TWDr,
		Bi	  => TWDi,
		EN    => sEnCM1,
		NAN   => sNANCM1,
		INF   => sInfCM1,
    READY => sRdyCM1,
		Rr	  => sMultUr,
		Ri	  => sMultUi
	);

	-- cmpCA1 
	cmpCA1: f32_cpx_adder
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		Ar	  =>	Ar,
		Ai	  =>	Ai,
		Br	  => sMultUr,
		Bi	  => sMultUi,
		EN    => sEnCA1,
		NAN   => sNANCA1,
		INF   => sInfCA1,
    READY => sRdyCA1,
		Rr	  => RESUr,
		Ri	  => RESUi
	);
	

	-------------------------------------
	-- Butterfly Down Wing Computation --
	-------------------------------------
	
	-- cmpCN
	-- Complex negate
	cmpCN: f32_cpx_negate
	PORT MAP(
		CLK  => CLK,
		RST  => RST,
		Ar	 => TWDr,
		Ai	 => TWDi,
		EN   => sEnCN,
		READY=> sRdyCN,
		Rr	 => sTWDr_n,
		Ri	 => sTWDi_n
	);
	
	-- cmpCM2 
	-- Complex multiplication of B and -TWD
	cmpCM2: f32_cpx_multiplier
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		Ar	  =>	Br,
		Ai	  => Bi,
		Br	  => sTWDr_n,
		Bi	  => sTWDi_n,
		EN    => sEnCM2,
		NAN   => sNANCM2,
		INF   => sInfCM2,
    READY => sRdyCM2,
		Rr	  => sMultDr,
		Ri	  => sMultDi
	);

	-- cmpCA2
	cmpCA2: f32_cpx_adder
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		Ar	  => Ar,
		Ai	  => Ai,
		Br	  => sMultDr,
		Bi	  => sMultDi,
		EN    => sEnCA2,
		NAN   => sNANCA2,
		INF   => sInfCA2,
    READY => sRdyCA2,
		Rr	  => RESDr,
		Ri	  => RESDi
	);

	--
	-- Processes ----------------------------------------------
	--
	
	--
	-- Logic --------------------------------------------------
	--
    
	-- Inputs
	--

	-- Outputs
	--
	READY  <= sReady;
	NAN    <= sNAN;
	INF    <= sInf;
	
	-- InOuts
	--

	-- Internals
	--
  sEnCM1  <= EN;
  sEnCM2  <= EN;
  sEnCA1  <= sRdyCM1;
  sEnCN   <= sRdyCM2;
  sEnCA2  <= sRdyCN;
  
  sReady  <= sRdyCA1 AND sRdyCA2;
  
  sNAN    <= sNANCM1 OR sNANCA1 OR
             sNANCM2 OR sNANCA2;
  sInf    <= sInfCM1 OR sInfCA1 OR
             sInfCM2 OR sInfCA2;
  
end LvnT;
