----------------------------------------------------------------------------------
-- Company: LvnT
-- Engineer: Levent TURA 
-- 
-- Create Date: 31.12.2023
-- Design Name: 
-- Module Name: f32_divider - LvnT
-- Project Name: f32_divider
-- Target Devices: -
-- Tool Versions: -
-- Description: IEEE754 Single precision (f32) Divider
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

entity f32_divider is
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
end f32_divider;

architecture LvnT of f32_divider is

	--
	-- COMPONENT DECLERATIONS
	--
  COMPONENT bin_divider
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
  end COMPONENT;
	
	--
	-- Constants
	--
	
	-- General
	constant cHigh: std_logic := '1';
	constant cLow	: std_logic := '0';

	constant cOnes	: std_logic_vector(31 downto 0):= (others=>'1');
	constant cZeros	: std_logic_vector(31 downto 0):= (others=>'0');
	constant cExpMax: std_logic_vector(7 downto 0) := "11111111";  -- Biased: 255, Unbiased: 128
	
	--
	-- Typed
	--	
  type div_stage_t is (
    DIV_STAGE_IDLE, 
    DIV_STAGE_CHECK_INPUTS, 
    DIV_STAGE_COMP_EXP, 
    DIV_STAGE_COMP_MANT, 
    DIV_STAGE_COMB_RES
  );
	
	--
	-- Signals
	--
	signal sDivStage     : div_stage_t;
	signal sSignA, sSignB: std_logic;
	signal sExpA, sExpB	 : std_logic_vector(8 downto 0);
	signal sMantA,sMantB : std_logic_vector(31 downto 0);	
	signal sReady        : std_logic;
	signal sNAN          : std_logic;
	signal sInf          : std_logic;
	signal sRes          : std_logic_vector(31 downto 0);
	signal sEN           : std_logic;
	signal sEnDly        : std_logic;
	signal sEnRise       : std_logic;
	signal sSignRes			 : std_logic := '0';
	signal sExpRes			 : std_logic_vector(8 downto 0);
	signal sMantRes			 : std_logic_vector(23 downto 0);	
	signal sBinDivQRes   : std_logic_vector(31 downto 0);	
	signal sBinDivFRes   : std_logic_vector(31 downto 0);	
	signal sBinDivNAN    : std_logic;
	signal sBinDivInf    : std_logic;
	signal sBinDivReady  : std_logic;
	signal sBinDivEn     : std_logic;
  
begin


	--
	-- Primitives ---------------------------------------------
	--

	--
	-- Components ---------------------------------------------
	--
  BinDiv: bin_divider
    PORT MAP(
      CLK	  => CLK,
      RST	  => RST,
      A     => sMantA,
      B     => sMantB,
      EN    => sBinDivEn,
      INF   => sBinDivInf,
      NAN   => sBinDivNAN,
      READY => sBinDivReady,
      Q_RES	=> sBinDivQRes,
      F_RES	=> sBinDivFRes
    );

	--
	-- Processes ----------------------------------------------
	--
	
	-- pFloatMult process
	-- Float multiplier
	--
	pFloatMult: process(CLK, RST) 
	begin
	
		if(rising_edge(CLK)) then
		  if(RST = cHigh) then
        sDivStage<= DIV_STAGE_IDLE;
        sExpA		 <= (others=>'0');
        sExpB		 <= (others=>'0');
        sMantA	 <= (others=>'0');
        sMantB	 <= (others=>'0');
        sExpRes	 <= (others=>'0');
        sMantRes <= (others=>'0');
        sSignRes <= '0';
        sBinDivEn<= '0';
        sRes     <= (others=>'0');
        sNAN     <= cLow;
        sInf     <= cLow;
        sReady   <= cLow;
		  else
        case sDivStage is
        
          -- 1. Wait for Enable signal,
          -- Decompose into Sign Exponent and Mantissa
          when DIV_STAGE_IDLE =>
            if(sEnRise = cHigh) then
              sNAN     <= cLow;
              sInf     <= cLow;
			  sReady <= cLow;
              sDivStage<= DIV_STAGE_CHECK_INPUTS;
              sExpA		 <= '0' & A(30 downto 23); -- Include carry bit for addition
              sExpB		 <= '0' & B(30 downto 23); -- Include carry bit for addition
              sMantA	 <= "000000001" & A(22 downto 0);  -- 1.M (32bits for binary divider)
              sMantB	 <= "000000001" & B(22 downto 0);  -- 1.M (32bits for binary divider)
              sSignA	 <= A(31);
              sSignB	 <= B(31);
           end if;
            
          -- 2. Check Inputs
          when DIV_STAGE_CHECK_INPUTS =>
            sReady<= cHigh;        
            sDivStage <= DIV_STAGE_IDLE;
            -- Both operands are Zero ?
            if((A = 0) AND (B = 0)) then
              sRes	<= (others=>'0');
              sNAN  <= cHigh;
              sReady<= cLow;        
            -- Divider is Zero?
            elsif(B = 0) then
              sRes	<= (sSignA XOR sSignB) & cOnes(7 downto 0) & cZeros(22 downto 0);
              sInf  <= cHigh;
            -- Division is Zero?
            elsif(A = 0) then
              sRes	<= (others=>'0');
            else
              sReady<= cLow;        
              sDivStage <= DIV_STAGE_COMP_EXP;
            end if;
            
          -- 3. Compute Exponent
          when DIV_STAGE_COMP_EXP =>
            sSignRes  <= sSignA XOR sSignB;
            sExpRes	  <= (sExpA - sExpB) + 127;
            -- If both operands' Mantissas are Zero?
            if((A(22 downto 0) = 0) AND (B(22 downto 0) = 0)) then
              sMantRes  <= (others=>'0');
              sDivStage <= DIV_STAGE_COMB_RES;
            else 
              sBinDivEn <= cHigh;
              sDivStage <= DIV_STAGE_COMP_MANT;
            end if;
            
          -- 4. Compute Mantissa
          -- sMantRes = sMantA / sMantB;
          when DIV_STAGE_COMP_MANT =>
            sBinDivEn <= cLow;
            if(sBinDivReady = cHigh) then
              if(sBinDivQRes = 0) then
                sMantRes <= sBinDivFRes(31 downto 8);
                sExpRes	 <= sExpRes - 1;
              else
                sMantRes <= '0' & sBinDivFRes(31 downto 9);
              end if;
              sDivStage <= DIV_STAGE_COMB_RES;
            elsif(sBinDivInf = cHigh) then
              sRes	<= (sSignA XOR sSignB) & cOnes(7 downto 0) & cZeros(22 downto 0);
              sInf  <= cHigh;
              sReady<= cHigh;        
              sDivStage <= DIV_STAGE_IDLE;
            elsif(sBinDivNAN = cHigh) then
              sRes	<= (others=>'0');
              sNAN  <= cHigh;
              sDivStage <= DIV_STAGE_IDLE;
            end if;
                      
          -- 5. Compose Result
          when DIV_STAGE_COMB_RES =>
            if(sExpRes = cExpMax) then
              sRes	<= sSignRes & cOnes(7 downto 0) & cZeros(22 downto 0);
              sInf <= cHigh;
            else 
              sRes  <= sSignRes & sExpRes(7 downto 0) & sMantRes(22 downto 0);
              sReady<= cHigh;
            end if;
            sDivStage <= DIV_STAGE_IDLE;
                  
          when others =>
            sDivStage <= DIV_STAGE_IDLE;
        end case;
		  end if;
		end if;
		
	end process;
 
	-- pRiseDedection process
	-- Rising Edge detection of any required signal
	pRiseDetection: process(CLK, RST) 
	begin
		
    if(rising_edge(CLK)) then
      if(RST = cHigh) then
        sEN	    <= cLow;
        sEnDly	<= cLow;
      else
        sEN     <= EN;
        sEnDly <= sEN;
      end if;
    end if;
	end process;
	
	--
	--
    
	-- Inputs
	--

	-- Outputs
	--
	RES  <= sRes;
	INF  <= sInf;
	NAN  <= sNAN;
	READY<= sReady;
	
	-- InOuts
	--

	-- Internals
	--
	sEnRise <= sEN AND (NOT sEnDly);


end LvnT;
