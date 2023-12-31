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
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.all;
use ieee.std_logic_unsigned.all;

entity f32_cpx_multiplier is
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
end f32_cpx_multiplier;

architecture LvnT of f32_cpx_multiplier is

	--
	-- COMPONENT DECLERATIONS
	--
	
	--
	-- Constants
	--

	-- f32-Multiplier
	-- 32bit floating point multiplier
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

	-- f32Adder
	-- 32bit floating point adder/subtracter
	COMPONENT f32_adder
	PORT(
		CLK,RST	: in  std_logic;
		A   	 	: in  std_logic_vector(31 downto 0);
		B   	 	: in  std_logic_vector(31 downto 0);
    EN      : in  std_logic;
		NAN     : out std_logic;
		INF     : out std_logic;
    READY   : out std_logic;
		RES	 	  : out std_logic_vector(31 downto 0)
	);
	END COMPONENT;

	-- f32Negate
	-- 32bit Negate
	COMPONENT f32_negate
	PORT(
		CLK,RST	: in  std_logic;
		A			  : in  std_logic_vector(31 downto 0);
    EN      : in  std_logic;
    READY   : out std_logic;
		RES		  : out std_logic_vector(31 downto 0)
	);
	END COMPONENT;
	
	-- General
	constant cHigh	: std_logic := '1';
	constant cLow  : std_logic := '0';
	
	--
	-- Typed
	--	
	
	--
	-- Signals
	--	
   signal sAiBi_n	  : std_logic_vector(31 downto 0);
   signal sArBr	    : std_logic_vector(31 downto 0);
   signal sAiBi	    : std_logic_vector(31 downto 0);
   signal sArBi	    : std_logic_vector(31 downto 0);
   signal sAiBr	    : std_logic_vector(31 downto 0);
   signal sResr	    : std_logic_vector(31 downto 0);
   signal sResi	    : std_logic_vector(31 downto 0);
   signal sNAN, sInf: std_logic;
   signal sEnNeg    : std_logic;
   signal sReadyA1  : std_logic;  
   signal sReadyA2  : std_logic;  
   signal sReadyN   : std_logic;  
   -- Multiplier-1
   signal sReadyM1  : std_logic;  
   signal sNANM1    : std_logic;  
   signal sInfM1    : std_logic;  
   -- Multiplier-2
   signal sReadyM2  : std_logic;  
   signal sNANM2    : std_logic;  
   signal sInfM2    : std_logic;  
   -- Multiplier-3
   signal sReadyM3  : std_logic;  
   signal sNANM3    : std_logic;  
   signal sInfM3    : std_logic;  
   -- Multiplier-4
   signal sReadyM4  : std_logic;  
   signal sNANM4    : std_logic;  
   signal sInfM4    : std_logic;  
   -- Adder-1
   signal sNANA1    : std_logic;  
   signal sInfA1    : std_logic;  
   -- Adder-2
   signal sNANA2    : std_logic;  
   signal sInfA2    : std_logic;  
   signal sEnAdd    : std_logic;  
begin


	--
	-- Primitives ---------------------------------------------
	--

	--
	-- Components ---------------------------------------------
	--
	
	
	--
	--
	-- (Ar + Ai)x(Br + Bi) = [ArBr - AiBi] + j[ArBi + AiBr]
	--
	--
	
	
	-- cmpM1 
	cmpM1: f32_multiplier
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    => Ar,
		B	    => Br,
		EN    => EN,
		NAN   => sNANM1,
		INF   => sInfM1,
		READY => sReadyM1,
		RES   => sArBr
	);
	
	-- cmpM2 
	cmpM2: f32_multiplier
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    => Ai,
		B	    => Bi,
		EN    => EN,
		NAN   => sNANM2,
		INF   => sInfM2,
		READY => sReadyM2,
		RES   => sAiBi
	);

	-- cmpM3 
	cmpM3: f32_multiplier
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    => Ar,
		B	    => Bi,
		EN    => EN,
		NAN   => sNANM3,
		INF   => sInfM3,
		READY => sReadyM3,
		RES   => sArBi
	);

	-- cmpM4
	cmpM4: f32_multiplier
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    => Ai,
		B	    => Br,
		EN    => EN,
		NAN   => sNANM4,
		INF   => sInfM4,
		READY => sReadyM4,
		RES   => sAiBr
	);

	-- cmpNeg
	cmpNeg: f32_negate
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    => sAiBi,
		EN    => sEnNeg,
		READY => sReadyN,
		RES   => sAiBi_n
	);

	-- cmpA1 
	cmpA1: f32_adder
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    => sAiBi_n,
		B	    => sArBr,
		EN    => sEnAdd,
		NAN   => sNANA1,
		INF   => sInfA1,
		READY => sReadyA1,
		RES   => Rr
	);

	-- cmpA2
	cmpA2: f32_adder
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    => sArBi,
		B	    => sAiBr,
		EN    => sEnAdd,
		NAN   => sNANA2,
		INF   => sInfA2,
		READY => sReadyA2,
		RES   => Ri
	);
	
	
	--
	-- Processes ----------------------------------------------
	--

	-- pFloatMult process
	-- Float multiplier
	--
	pEnMultDelay: process(CLK, RST) 
	begin
	
		if(rising_edge(CLK)) then
		  if(RST = cHigh) then
        sEnAdd  <= cLow;
		  else
        sEnAdd  <= sReadyN;
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
	READY <= sReadyA1 AND sReadyA2;
	NAN   <= sNAN;
	-- InOuts
	--

	-- Internals
	--
	sEnNeg <= sReadyM1 AND sReadyM2 AND sReadyM3 AND sReadyM4;
	sNAN   <= sNANM1 OR sNANM2 OR sNANM3 OR sNANM4 OR sNANA1 OR sNANA2;
	sInf   <= sInfM1 OR sInfM2 OR sInfM3 OR sInfM4 OR sInfA1 OR sInfA2;
  

end LvnT;
