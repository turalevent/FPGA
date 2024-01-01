----------------------------------------------------------------------------------
-- Company: LvnT
-- Engineer: Levent TURA 
-- 
-- Create Date: 31.12.2023
-- Design Name: 
-- Module Name: f32_negate - LvnT
-- Project Name: f32_negate
-- Target Devices: -
-- Tool Versions: -
-- Description: IEEE754 Single precision (f32) Negate
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

entity f32_negate is
	PORT(
		CLK,RST	: in  std_logic;
		A   		: in  std_logic_vector(31 downto 0);
		EN      : in  std_logic;
		READY   : out std_logic;
		RES		  : out std_logic_vector(31 downto 0)
	);
end f32_negate;

architecture LvnT of f32_negate is

	--
	-- COMPONENT DECLERATIONS
	--
	
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
	signal sReady: std_logic;
	signal sEnB  : std_logic;
   
begin


	--
	-- Primitives --------------------------------------------
	--

	--
	-- Components ---------------------------------------------
	--

	--
	-- Processes ----------------------------------------------
	--
	
	-- pFloatMult process
	-- Float multiplier
	--
	pFloatNeg: process(CLK, RST) 
		variable vSign	: std_logic := '0';
	begin
		
    if(rising_edge(CLK)) then
      if(RST = cHigh) then
        RES		<= (others=>'0');
        sReady<= cLow;
      else
        sEnB  <= EN;
        sReady<= cLow;
        if((sEnB = cHigh) AND (EN = cLow)) then
          if(A = 0) then
            RES	<= (others=>'0');
          else
            RES	<= (A(31) XOR cHigh) & A(30 downto 0);
          end if;
          sReady<= cHigh;
        end if;
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
	READY <= sReady;
	
	-- InOuts
	--

	-- Internals
	--


end LvnT;
