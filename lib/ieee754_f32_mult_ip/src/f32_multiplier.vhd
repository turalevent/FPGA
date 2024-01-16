----------------------------------------------------------------------------------
-- Company: LvnT
-- Engineer: Levent TURA 
-- 
-- Create Date: 31.12.2023
-- Design Name: 
-- Module Name: f32_multiplier - LvnT
-- Project Name: f32_multiplier
-- Target Devices: -
-- Tool Versions: -
-- Description: IEEE754 Single precision (f32) Multiplier
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

entity f32_multiplier is
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
end f32_multiplier;

architecture LvnT of f32_multiplier is

	--
	-- COMPONENT DECLERATIONS
	--
	
	--
	-- Constants
	--
	
	-- General
	constant cHigh: std_logic := '1';
	constant cLow	: std_logic := '0';

	constant cZeros	: std_logic_vector(31 downto 0):= (others=>'0');
	constant cExpMax: std_logic_vector(7 downto 0) := "11111111";  -- Biased: 255, Unbiased: 128
	
	--
	-- Typed
	--	
  type mult_stage_t is (
    MULT_STAGE_IDLE, 
    MULT_STAGE_CHECK_INPUTS, 
    MULT_STAGE_COMP_EXP_MANT, 
    MULT_STAGE_COMP_NORMALIZE,
    MULT_STAGE_COMB_RES
  );
	
	--
	-- Signals
	--
	signal sMultStage    : mult_stage_t;
	signal sSignA, sSignB: std_logic;
	signal sExpA, sExpB	 : std_logic_vector(8 downto 0);
	signal sMantA,sMantB : std_logic_vector(23 downto 0);	
	signal sReady        : std_logic;
	signal sNAN          : std_logic;
	signal sInf          : std_logic;
	signal sRes          : std_logic_vector(31 downto 0);
	signal sEN           : std_logic;
	signal sEnDly1       : std_logic;
	signal sEnRise       : std_logic;
	signal sSignRes			 : std_logic := '0';
	signal sExpRes			 : std_logic_vector(8 downto 0);
	signal sMantRes			 : std_logic_vector(47 downto 0);	
   
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
		variable vIndxH	  : integer range 0 to 48 := 0;
	begin
	
		if(rising_edge(CLK)) then
		  if(RST = cHigh) then
        sExpA		<= (others=>'0');
        sExpB		<= (others=>'0');
        sMantA	<= (others=>'0');
        sMantB	<= (others=>'0');
        sExpRes	<= (others=>'0');
        sMantRes<= (others=>'0');
        sSignRes<= '0';
        sRes    <= (others=>'0');
        sNAN    <= cLow;
        sInf    <= cLow;
        sReady  <= cLow;
						
        vIndxH	:= 0;
		  else
				  
							
        case sMultStage is
        
          -- 0. Wait for Enable signal,
          -- Decompose into Sign Exponent and Mantissa
          when MULT_STAGE_IDLE =>
            if(sEnRise = cHigh) then
              sNAN      <= cLow;
              sInf      <= cLow;
              sReady    <= cLow; 
              sMultStage<= MULT_STAGE_CHECK_INPUTS;
              sExpA		  <= '0' & A(30 downto 23); -- Include carry bit for addition
              sExpB		  <= '0' & B(30 downto 23); -- Include carry bit for addition
              sMantA	  <= '1' & A(22 downto 0);  -- 1.M
              sMantB	  <= '1' & B(22 downto 0);  -- 1.M
              sSignA	  <= A(31);
              sSignB	  <= B(31);
           end if;
            
          -- 1. Decompose Exponent and Mantissa
          -- we must extract the mantissas, adding an 1 as most significant bit, for normalization
          when MULT_STAGE_CHECK_INPUTS =>
            sReady<= cHigh;        
            sMultStage <= MULT_STAGE_IDLE;
            -- Zero ?
            if((A = 0) OR (B = 0)) then
              sRes	<= (others=>'0');
            -- Infinity because of Input-A ? 
            elsif((sExpA(7 downto 0) = 255) AND (sMantA(22 downto 0) = 0)) then
              sRes	<= (sSignA XOR sSignB) & A(30 downto 0);
              sInf <= cHigh;
            -- NaN because of Input-A ? 
            elsif((sExpA(7 downto 0) = 255) AND (sMantA(22 downto 0) > 0)) then
              sRes	<= (others => '0');
              sNAN <= cHigh;
              sReady<= cLow;        
            -- Infinity because of Input-B ? 
            elsif((sExpB(7 downto 0) = 255) AND (sMantB(22 downto 0) = 0)) then
              sRes	<= (sSignA XOR sSignB) & B(30 downto 0);
              sInf  <= cHigh;
            -- NaN because of Input-B ? 
            elsif((sExpB(7 downto 0) = 255) AND (sMantB(22 downto 0) > 0)) then
              sRes	<= (others => '0');
              sNAN  <= cHigh;
              sReady<= cLow;        
            else
              sReady<= cLow;        
              sMultStage <= MULT_STAGE_COMP_EXP_MANT;
            end if;
            
          -- 2. Compute Exponent and Mantissa
          when MULT_STAGE_COMP_EXP_MANT =>
            sSignRes<= sSignA XOR sSignB;
            sMantRes<= sMantA * sMantB;
            sExpRes	<= (sExpA + sExpB) - 127;
            sMultStage <= MULT_STAGE_COMP_NORMALIZE;
          
          -- 3. Multiply Mantissas & Exponents
          when MULT_STAGE_COMP_NORMALIZE =>
            -- Find MSB '1' in the Mantissa
            for i in 0 to sMantRes'high loop
              vIndxH:= sMantRes'high-i;
              exit when (sMantRes(vIndxH) = '1');
            end loop;
            -- Increase Exponent if sMantRes[47] = '1'
            if(vIndxH = sMantRes'high) then
              sExpRes <= sExpRes + 1;
            end if;
            sMultStage <= MULT_STAGE_COMB_RES;
                      
          -- 4. Compose Result
          -- only the most significant bits are useful: after normalization (elimination of
          -- the most significant 1), we get the 23-bit mantissa of the result.
          when MULT_STAGE_COMB_RES =>
            if(sExpRes = cExpMax) then
              sRes	<= sSignRes & "11111111" & cZeros(22 downto 0);
              sInf <= cHigh;
            else 
              if(vIndxH < 25) then
                sRes  <= sSignRes & sExpRes(7 downto 0) & cZeros(22 downto 0);
                sReady<= cHigh;
              else
                sRes  <= sSignRes & sExpRes(7 downto 0) & sMantRes(vIndxH-1 downto vIndxH-23);
                sReady<= cHigh;
              end if;
            end if;
            sMultStage <= MULT_STAGE_IDLE;
                  
          when others =>
            sMultStage <= MULT_STAGE_IDLE;
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
        sEnDly1	<= cLow;
      else
        sEN     <= EN;
        sEnDly1 <= sEN;
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
	RES  <= sRes;
	INF  <= sInf;
	NAN  <= sNAN;
	READY<= sReady;
	
	-- InOuts
	--

	-- Internals
	--
  sEnRise <= sEN AND (NOT sEnDly1);


end LvnT;
