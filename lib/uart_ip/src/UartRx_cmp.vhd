library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ua_rx is
	GENERIC(
		DATA_BIT	: integer;
		STOP_BIT	: integer
	);
	PORT(
		CLK, RST	: in  std_logic;
		BRG_TICK	: in  std_logic; 
		-- Hardware Pins
		UART_RX	  : in std_logic;
		-- Status & Controls
		RCV_DATA	: out std_logic_vector(7 downto 0);
		RCV_DONE  : out std_logic
	);
end ua_rx;

architecture LvnT of ua_rx is

	--
	-- Constants
	--
	constant cHigh   : std_logic := '1';
	constant cLow    : std_logic := '0';

	constant cStrTick: integer := 7;	-- Number of Start Tick count
	constant cTickCnt: integer := 15;	-- Number of Data/Stop Tick count
	
	-- 
	-- Types
	--
	type urx_st is (
							IDLE_ST, 
							START_ST,
							DATA_ST, 
							STOP_ST
						);
	--
	-- Signals
	--
	signal sMainSt  : urx_st;
	signal sRxData  : std_logic_vector(DATA_BIT-1 downto 0);
	signal sRxBit		: std_logic;
	signal sRxDone	: std_logic;
	signal sBrgTick	: std_logic;
	
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

	-- UartReceive_p process
	-- Uart Receive
	UartReceive_p: process(CLK, RST)
		variable vRxRcvCnt: integer range 0 to 50 := 0;
		variable vTickCtr	: integer range 0 to 50;
		variable vStpCtr	: integer range 0 to 3;
	begin

    if(rising_edge(CLK)) then
      if(RST = cHigh) then
        sMainSt   <= IDLE_ST;
        sRxData	  <= (others => '0');
        sRxDone		<='0';
        vStpCtr		:= 0;
        vTickCtr	:= 0;
        vRxRcvCnt	:= 0;
      else
        sRxDone <= '0';
  
        -- UART RECEIVE procedure
        case sMainSt is
          -- IDLE state 				
          when IDLE_ST  =>
            if(sRxBit = '0') then
              sMainSt <= START_ST;
              vTickCtr	:= 0;
              vRxRcvCnt	:= 0;
            else
              sMainSt <= IDLE_ST;
            end if;
            
          -- START BIT Getting state 				
          when START_ST =>
            if(sBrgTick = '1') then
              if(vTickCtr = cStrTick) then
                vStpCtr		:= 0;
                vTickCtr	:= 0;
                vRxRcvCnt := 0;								
                sRxData	  <= (others => '0');
                sMainSt   <= DATA_ST;
              else
                vTickCtr := vTickCtr + 1;
              end if;
            end if;
          
          -- DATA RECEIVING state 				
          when DATA_ST  =>
            if(sBrgTick = '1') then
              if(vTickCtr = cTickCnt) then
                vTickCtr := 0;
                sRxData(vRxRcvCnt)	<= sRxBit;			-- receive 1 bit
                if(vRxRcvCnt = DATA_BIT - 1) then		-- N bit data received
                  sMainSt <= STOP_ST;
                else
                  vRxRcvCnt := vRxRcvCnt + 1;								
                end if;
              else
                vTickCtr := vTickCtr + 1;
              end if;
            end if;
          
          -- STOP BIT Getting state 				
          when STOP_ST  =>
            if(sBrgTick = '1') then
              if(vTickCtr = cTickCnt) then
                vTickCtr	:= 0;
                if(vStpCtr = STOP_BIT - 1) then
                  sRxDone <= '1';
                  sMainSt <= IDLE_ST;
                else
                  vStpCtr := vStpCtr + 1;
                end if;
              else
                vTickCtr := vTickCtr + 1;
              end if;
            end if;
          
          -- Other state 
          when others =>
            sMainSt <= IDLE_ST;
            
        end case;		
      end if;
    end if;	




		
		if(RST = cHigh) then
		elsif(rising_edge(CLK)) then
		end if;
			
	end process;


	--
	-- Logic --------------------------------------------------
	--

	-- Inputs
	--
	sBrgTick<= BRG_TICK;
	sRxBit	<= UART_RX;
	
	-- Outputs
	--
	RCV_DATA<= sRxData;
	RCV_DONE<= sRxDone;
	
	-- Internals
	--

end LvnT;

