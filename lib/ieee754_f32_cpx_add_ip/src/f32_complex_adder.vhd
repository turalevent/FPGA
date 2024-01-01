----------------------------------------------------------------------------------
-- Company: LvnT
-- Engineer: Levent TURA 
-- 
-- Create Date: 31.12.2023
-- Design Name: 
-- Module Name: f32_complex_multiplier - LvnT
-- Project Name: f32_complex_multiplier
-- Target Devices: -
-- Tool Versions: -
-- Description: IEEE754 Single precision (f32) Complex Multiplier
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.NUMERIC_STD.ALL;

entity f32_cpx_adder is
	PORT(
    CLK, RST: in  std_logic;
    Ar, Ai  : in  std_logic_vector(31 downto 0);
    Br, Bi  : in  std_logic_vector(31 downto 0);
    EN      : in  std_logic;
    READY   : out std_logic;
		NAN     : out std_logic;
		INF     : out std_logic;
    Rr, Ri  : out std_logic_vector(31 downto 0)
  );
end f32_cpx_adder;

architecture LvnT of f32_cpx_adder is

	--
	-- COMPONENT DECLERATIONS
	--
	
	--
	-- Constants
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
	
	--
	-- Typed
	--	
	
	--
	-- Signals
	--	
  signal sReadyAdder1 : std_logic;
  signal sReadyAdder2 : std_logic;
  signal sNAN, sInf   : std_logic;
  -- Adder-1
  signal sNANA1,sInfA1: std_logic;  
  -- Adder-2
  signal sNANA2,sInfA2: std_logic;  
  
begin


	--
	-- Primitives ---------------------------------------------
	--

	--
	-- Components ---------------------------------------------
	--

	-- cmpA1 
	cmpA1: f32_adder
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    => Ar,
		B	    => Br,
		EN    => EN,
		NAN   => sNANA1,
		INF   => sInfA1,
		READY => sReadyAdder1,
		RES   => Rr
	);

	-- cmpA1 
	cmpA2: f32_adder
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    => Ai,
		B	    => Bi,
		EN    => EN,
		NAN   => sNANA2,
		INF   => sInfA2,
		READY => sReadyAdder2,
		RES   => Ri
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
	READY <= sReadyAdder1 AND sReadyAdder2;
	NAN   <= sNAN;
	INF   <= sInf;

	
	-- InOuts
	--

	-- Internals
	--
	sNAN   <= sNANA1 OR sNANA2;
	sInf   <= sInfA1 OR sInfA2;


end LvnT;
