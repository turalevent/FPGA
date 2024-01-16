----------------------------------------------------------------------------------
-- Company: LvnT
-- Engineer: Levent TURA 
-- 
-- Create Date: 31.12.2023
-- Design Name: 
-- Module Name: f32_adder - LvnT
-- Project Name: f32_adder
-- Target Devices: -
-- Tool Versions: -
-- Description: IEEE754 Single precision (f32) Adder
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

entity f32_adder is
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
end f32_adder;

architecture LvnT of f32_adder is

	--
	-- COMPONENT DECLERATIONS
	--
	
	--
	-- Constants
	--
	
	-- General
	constant cHigh     : std_logic := '1';
	constant cLow	     : std_logic := '0';
	
	constant cZeros	   : std_logic_vector(SIZE-1 downto 0) := (others=>'0');
	constant cOnes     : std_logic_vector(SIZE-1 downto 0) := (others=>'1');
	--
	-- Typed
	--	
  type adder_stage_t is (
    ADDER_STAGE_IDLE, 
    ADDER_STAGE_CHECK_INPUTS, 
    ADDER_STAGE_2, 
    ADDER_STAGE_3, 
    ADDER_STAGE_4, 
    ADDER_STAGE_5, 
    ADDER_STAGE_6, 
    ADDER_STAGE_7,
    ADDER_STAGE_8
  );
	
	--
	-- Signals
	--	
	signal sAdderStage    : adder_stage_t;
  signal sNAN, sInf			: std_logic;
  signal sSignRes				: std_logic;
  signal sExpA, sExpB		: std_logic_vector(7 downto 0);
  signal sExpRes				: std_logic_vector(7 downto 0);
  signal sMantA, sMantB	: std_logic_vector(SIZE-1 downto 0);		
  signal sMantRes				: std_logic_vector(SIZE-1 downto 0);
  signal sReady 				: std_logic;
	signal sEN            : std_logic;
	signal sEnDly        : std_logic;
	signal sEnRise        : std_logic;

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
	
	-- pFloatAdder process
	-- Float Adder
	--
	pFloatAdderPipe: process(CLK, RST) 
    variable vIndxH	: integer range 0 to SIZE := 0;
    variable vIndxN	: integer range 0 to SIZE := 0;
	  variable vTemp : std_logic_vector(SIZE-1 downto 0);		
	begin
		
		if(rising_edge(CLK)) then
		  
		  if(RST = cHigh) then
		    sAdderStage <= ADDER_STAGE_IDLE;
        RES         <= (others=>'0');
        sSignRes    <= '0';
        sSignRes    <= cLow;
        sExpA       <= (others=>'0');
        sExpB       <= (others=>'0');
        sExpRes     <= (others=>'0');
        sMantA      <= (others=>'0');
        sMantB      <= (others=>'0');		
        sMantRes    <= (others=>'0');
        sReady      <= cLow;
        sNAN        <= cLow;
        sInf        <= cLow;
		    vTemp       := (others=>'0');
        vIndxH      := 0;
        vIndxN      := 0;
		  else
        case sAdderStage is
        
          -- 0. Wait for Enable signal
          when ADDER_STAGE_IDLE =>
            if(sEnRise = cHigh) then
             sReady <= cLow;
             sAdderStage <= ADDER_STAGE_CHECK_INPUTS;
           end if;
            
          -- 1. Decompose Exponent and Mantissa
          when ADDER_STAGE_CHECK_INPUTS =>
            sAdderStage <= ADDER_STAGE_IDLE;
            sReady <= cHigh;  
            sNAN   <= cLow;
            sInf   <= cLow;
            if(A = 0) then              
              RES<= B;
            elsif((A(30 downto 23) = X"FF") AND (A(23 downto 0) = 0)) then              
              RES <= A;
              sInf<= cHigh;
            elsif((A(30 downto 23) = X"FF") AND (A(23 downto 0) > 0)) then              
              RES   <= B;
              sNAN  <= cHigh;
              sReady<= cLow;  
            elsif(B = 0) then              
              RES<= A;
            elsif((B(30 downto 23) = X"FF") AND (B(23 downto 0) = 0)) then              
              RES <= B;
              sInf<= cHigh;
            elsif((B(30 downto 23) = X"FF") AND (B(23 downto 0) > 0)) then              
              RES   <= B;
              sNAN  <= cHigh;
              sReady<= cLow;  
            elsif((A(30 downto 0) = B(30 downto 0)) AND ((A(31) XOR B(31)) = cHigh)) then
              RES<= (others=>'0');
            else
              sReady  <= cLow;
              sAdderStage <= ADDER_STAGE_2;
            end if;
            
          -- 1. Decompose Exponent and Mantissa
          when ADDER_STAGE_2 =>
            sExpA	<= A(30 downto 23);
            sExpB	<= B(30 downto 23);
            sMantA<= X"00" & '1' & A(22 downto 0);	-- Strech Mantissa for extra resolution and add implicit 1
            sMantB<= X"00" & '1' & B(22 downto 0);	-- Strech Mantissa for extra resolution and add implicit 1 
            sAdderStage <= ADDER_STAGE_3;
            
          -- 2. Equalize Exponents,
          -- find Sign and Exponent parts of the Result
          when ADDER_STAGE_3 =>
            if(sExpA < sExpB) then			-- A < B
              vIndxH	:= to_integer(unsigned(sExpB - sExpA));
              if(vIndxH > 30) then
                sMantA<= (others=>'0');
              else
                -- This for loop used to make vIndxH variable Real
                -- to be able to use as a index of the concat operation..
                for i in 0 to SIZE loop
                  if(i = vIndxH) then
                    sMantA <= cZeros(i-1 downto 0) & sMantA(31 downto i);
                  end if;
                end loop;
              end if;
              sExpRes	<= sExpB;
              sSignRes<= B(31);
            elsif(sExpA > sExpB ) then		-- A > B
              vIndxH	:= to_integer(unsigned(sExpA - sExpB));
              if(vIndxH > 30) then
                sMantB<= (others=>'0');
              else
                -- This for loop used to make vIndxH variable Real
                -- to be able to use as a index of the concat operation..
                for i in 0 to SIZE loop
                  if(i = vIndxH) then
                    sMantB<= cZeros(i-1 downto 0) & sMantB(31 downto i);
                  end if;
                end loop;
              end if;					
              sExpRes	<= sExpA;
              sSignRes<= A(31);
            else
              sExpRes	<= sExpA;
              if(sMantA > sMantB) then
                sSignRes<= A(31);
              elsif(sMantA < sMantB) then
                sSignRes<= B(31);
              else
                if((A(31) = cHigh) AND (B(31) = cHigh)) then
                  sSignRes<= cHigh;
                else
                  sSignRes<= cLow;
                end if;
              end if;
            end if;
            sAdderStage <= ADDER_STAGE_4;
                  
          -- 3. 2's complement of negative value
          when ADDER_STAGE_4 =>
            if(A(31) = cHigh) then
              vTemp:= sMantA XOR cOnes;
              sMantA<= vTemp + 1;
            end if;
            if(B(31) = cHigh) then
              vTemp:= sMantB XOR cOnes;
              sMantB<= vTemp + 1;
            end if;
            sAdderStage <= ADDER_STAGE_5;
                      
          -- 4. Add Mantissa
          when ADDER_STAGE_5 =>
            sMantRes<= sMantA + sMantB;
            sAdderStage <= ADDER_STAGE_6;

          -- 5. 2's complement of result
          when ADDER_STAGE_6 =>
            if(sSignRes = cHigh) then
              vTemp	:= sMantRes XOR cOnes;
              sMantRes<= vTemp + 1;
            end if;
            sAdderStage <= ADDER_STAGE_7;
  
          -- 6. Normalize
          when ADDER_STAGE_7 =>
            for i in 0 to sMantRes'high loop
              vIndxN:= sMantRes'high-i;
              exit when (sMantRes(sMantRes'high-i) = cHigh);
            end loop;
            if(vIndxN = 23) 	then	-- Don't
            elsif(vIndxN < 23)then	-- Shift to Left 
              vIndxN	:= 23 - vIndxN;
              for i in 0 to SIZE loop
                if(i=vIndxN) then
                  sMantRes<= sMantRes(31-i downto 0) & cZeros(i-1 downto 0);
                end if;
              end loop;
              sExpRes	<= sExpRes - std_logic_vector(to_unsigned(vIndxN, 8));
            elsif(vIndxN > 23)then	-- Shift to Right
              vIndxN	:= vIndxN - 23;
              for i in 0 to SIZE loop
                if(i=vIndxN) then
                  sMantRes<= cZeros(i-1 downto 0) & sMantRes(31 downto i);
                end if;
              end loop;
              sExpRes	<= sExpRes + std_logic_vector(to_unsigned(vIndxN, 8));
            end if;
            sAdderStage <= ADDER_STAGE_8;
  
          -- 7. Compose Result and remove implicit 1
          when ADDER_STAGE_8 =>
            RES<= sSignRes & sExpRes & sMantRes(22 downto 0);
            sReady <= cHigh;
            sAdderStage <= ADDER_STAGE_IDLE;
  
          -- 8. Serve the Result
          when others =>
            sReady <= cLow;
            sAdderStage <= ADDER_STAGE_IDLE;
                  
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
	-- Logic --------------------------------------------------
	--
    
	-- Inputs
	--

	-- Outputs
	--
	INF  <= sInf;
	NAN  <= sNAN;
	READY<= sReady;
	
	-- InOuts
	--

	-- Internals
	--
  sEnRise <= sEN AND (NOT sEnDly);


end LvnT;
