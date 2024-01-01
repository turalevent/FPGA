----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.11.2016 10:56:58
-- Design Name: 
-- Module Name: TopModule - SENSODEV
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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

entity f32_cpx_negate is
	PORT(
		CLK,RST	: in  std_logic;
		Ar, Ai	: in  std_logic_vector(31 downto 0);
		EN      : in  std_logic;
		READY   : out std_logic;
		Rr, Ri	: out std_logic_vector(31 downto 0)
	);
end f32_cpx_negate;

architecture SENSODEV of f32_cpx_negate is

	--
	-- COMPONENT DECLERATIONS
	--
	
	-- f32_negate
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
	
	
	--
	-- Constants
	--
	
	--
	-- Typed
	--	
	
	--
	-- Signals
	--
	signal sReady1 : std_logic;	
	signal sReady2 : std_logic;	
   
begin


	--
	-- Primitives ---------------------------------------------
	--

	--
	-- Components ---------------------------------------------
	--
	
	-- cmpNr
	cmpNr: f32_negate
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    =>	Ar,
		EN    => EN,
		READY => sReady1,
		RES   => Rr
	);

	-- cmpNi
	cmpNi: f32_negate
	PORT MAP(
		CLK   => CLK,
		RST   => RST,
		A	    =>	Ai,
		EN    => EN,
		READY => sReady2,
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
	READY <= sReady1 AND sReady2;
	
	-- InOuts
	--

	-- Internals
	--


end SENSODEV;
