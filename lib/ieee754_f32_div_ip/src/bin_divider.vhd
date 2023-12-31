----------------------------------------------------------------------------------
-- Company: LvnT
-- Engineer: Levent TURA 
-- 
-- Create Date: 31.12.2023
-- Design Name: 
-- Module Name: bin_divider - LvnT
-- Project Name: bin_divider
-- Target Devices: -
-- Tool Versions: -
-- Description: Binary Divider
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

entity bin_divider is
	PORT(
		CLK	  : in  std_logic;
		RST	  : in  std_logic;
		A		  : in  std_logic_vector(31 downto 0);
		B		  : in  std_logic_vector(31 downto 0);
		EN    : in  std_logic;
		NAN   : out std_logic;
		INF   : out std_logic;
		READY : out std_logic;
		Q_RES : out std_logic_vector(31 downto 0);
		F_RES : out std_logic_vector(31 downto 0)
	);
end bin_divider;

architecture LvnT of bin_divider is

	--
	-- COMPONENT DECLERATIONS
	--
	
	--
	-- Constants
	--
	
	-- General
	constant cHigh: std_logic := '1';
	constant cLow	: std_logic := '0';
	
	--
	-- Typed
	--	
  type div_stage_t is (
    DIV_STAGE_IDLE, 
    DIV_STAGE_CHECK_INPUTS, 
    DIV_STAGE_COMPUTATION,
    DIV_STAGE_RESULT
  );
	
	--
	-- Signals
	--
	signal sDivStage     : div_stage_t;
	signal sReady        : std_logic;
	signal sFracComp     : std_logic;
	signal sNAN          : std_logic;
	signal sInf          : std_logic;
	signal sQRes, sFRes  : std_logic_vector(31 downto 0);
	signal sA, sB        : std_logic_vector(31 downto 0);
	signal sEnB          : std_logic;
   
begin


	--
	-- Primitives ---------------------------------------------
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
	pFloatMult: process(CLK, RST) 
		variable vCompCtr	: integer range 0 to 48 := 0;
	  variable vA       : std_logic_vector(31 downto 0);
	begin
	
		if(rising_edge(CLK)) then
		  if(RST = cHigh) then
        sDivStage<= DIV_STAGE_IDLE;
        sQRes    <= (others=>'0');
        sFRes    <= (others=>'0');
        sFracComp<= cLow;
        sNAN     <= cLow;
        sInf     <= cLow;
        sReady   <= cLow;
        sEnB     <= cLow;
        vCompCtr := 31;
        sA	     <= (others=>'0');
        sB	     <= (others=>'0');
        vA	     := (others=>'0');
		  else
		    sEnB  <= EN;
		    sReady<= cLow;        
        case sDivStage is
        
          -- 0. Wait for Enable signal,
          -- Decompose into Sign Exponent and Mantissa
          when DIV_STAGE_IDLE =>
            if((sEnB = cHigh) AND (EN = cLow)) then
              sNAN     <= cLow;
              sInf     <= cLow;
              sDivStage<= DIV_STAGE_CHECK_INPUTS;
              sFracComp<= cLow;
              sQRes    <= (others=>'0');
              sFRes    <= (others=>'0');
              sA	     <= A;
              sB	     <= B;
              vCompCtr := 31;
           end if;
            
          -- 1. Check Iputs
          when DIV_STAGE_CHECK_INPUTS =>
            sReady<= cHigh;        
            sDivStage <= DIV_STAGE_IDLE;
            -- Both operands are Zero ?
            if((sA = 0) AND (sB = 0)) then
              sQRes	<= (others=>'0');
              sFRes	<= (others=>'0');
              sNAN  <= cHigh;
              sReady<= cLow;        
            -- Divider is Zero?
            elsif(sB = 0) then
              sQRes	<= (others=>'0');
              sFRes	<= (others=>'0');
              sInf  <= cHigh;
            -- Division is Zero?
            elsif(sA = 0) then
              sQRes	<= (others=>'0');
              sFRes	<= (others=>'0');
            else
              sReady<= cLow;        
              sDivStage <= DIV_STAGE_COMPUTATION;
            end if;
          
          -- 2. Compute the result
          when DIV_STAGE_COMPUTATION =>
            if(sA > sB) then
              sA <= sA - sB;
              if(sFracComp = cHigh) then
                sFRes(vCompCtr) <= '1';
                if(vCompCtr = 0) then
                  sDivStage <= DIV_STAGE_RESULT;
                else
                  vCompCtr := vCompCtr - 1;
                end if;
              else
                sQRes <= sQRes + 1;
              end if;
            elsif(sA = sB) then
              if(sFracComp = cHigh) then
                sFRes(vCompCtr) <= '1';
              else
                sQRes <= sQRes + 1;
              end if;
              sDivStage <= DIV_STAGE_RESULT;
            else
              sFracComp <= cHigh;
              vA := sA(30 downto 0) & '0';
              if(vA < sB) then
                if(vCompCtr = 0) then
                  sDivStage <= DIV_STAGE_RESULT;
                else
                  vCompCtr := vCompCtr - 1;
                end if;
              end if;
             sA <= vA;
            end if;
                  
          -- 3. Serve the result
          when DIV_STAGE_RESULT =>
            sReady<= cHigh;
            sDivStage <= DIV_STAGE_IDLE;
          
          when others =>
            sDivStage <= DIV_STAGE_IDLE;
            
        end case;
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
	Q_RES<= sQRes;
	F_RES<= sFRes;
	INF  <= sInf;
	NAN  <= sNAN;
	READY<= sReady;
	
	-- InOuts
	--

	-- Internals
	--


end LvnT;
