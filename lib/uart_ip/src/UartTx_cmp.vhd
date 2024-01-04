library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ua_tx is
	GENERIC(
		DATA_BIT	: integer;
		STOP_BIT	: integer
	);
	PORT(
		CLK, RST  : in  std_logic;
		BRG_TICK	: in  std_logic; 
		-- Hardware Pins
		UART_TX	  : out std_logic;
		-- Status & Controls
		SEND_TRIG : in  std_logic;
		SEND_DATA : in  std_logic_vector(DATA_BIT - 1 downto 0);
		SEND_DONE : out std_logic;
		SEND_BUSY : out std_logic
	);
end ua_tx;

architecture LvnT of ua_tx is

	--
	-- Constants
	--
	constant cHigh : std_logic := '1';
	constant cLow  : std_logic := '0';

	constant cStrTick : integer := 15;	-- Number of Start Tick count
	constant cTickCnt : integer := 15;	-- Number of Data/Stop Tick count
	
	-- 
	-- Types
	--
	type utx_st is (
							IDLE_ST, 
							START_ST, 
							DATA_ST, 
							STOP_ST
						);
	--
	-- Signals
	--
	signal sMainSt  : utx_st;
	signal sTxData  : std_logic_vector(DATA_BIT-1 downto 0);
	signal sTxBit		: std_logic;
	signal sTxDone	: std_logic;
	signal sTxTrig	: std_logic;
	signal sBrgTick	: std_logic;
	signal sTxBusy	: std_logic;
	
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

	-- UartTransmit_p process
	-- Uart Transmit
	UartTransmit_p: process(CLK, RST)
		variable vTxSendCnt : integer range 0 to DATA_BIT := 0;
		variable vTickCtr	  : integer range 0 to 50;
	begin
  
    if(rising_edge(CLK)) then
      if(RST = cHigh) then
        sMainSt   <= IDLE_ST;
        sTxData	  <= (others => '0');
        sTxDone		<='0';
        vTickCtr	:= 0;
        vTxSendCnt:= 1;
        sTxBusy		<= '0';
      else
        sTxDone <= '0';
  
        -- UART TRANSMIT procedure
        case sMainSt is
  
          -- IDLE state 				
          when IDLE_ST  =>
            sTxBit	  <= '1';
            if(sTxTrig = '1') then
              sTxBusy	<= '1';
              sTxData	<= SEND_DATA;
              sMainSt <= START_ST;
              sTxBit	<= '0';
              vTickCtr:= 0;
            else
              sMainSt <= IDLE_ST;
              sTxBusy	<= '0';
            end if;
            
          -- START BIT generation state 				
          when START_ST =>
            if(sBrgTick = '1') then
              if(vTickCtr = cStrTick) then
                vTickCtr	:= 0;
                sMainSt   <= DATA_ST;
                vTxSendCnt:= 1;
                sTxBit  	<= sTxData(0);	-- send 1 bit
              else
                vTickCtr  := vTickCtr + 1;
              end if;
            end if;
          
          -- DATA TRANSMIT state 				
          when DATA_ST  =>
            if(sBrgTick = '1') then
              if(vTickCtr = cTickCnt) then
                vTickCtr := 0;
                if(vTxSendCnt = DATA_BIT) then				-- N bit data sent
                  sMainSt <= STOP_ST;
                  sTxBit	<= '1';
                else
                  sTxBit  	<= sTxData(vTxSendCnt);	-- send 1 bit
                  vTxSendCnt := vTxSendCnt + 1;								
                end if;
              else
                vTickCtr := vTickCtr + 1;
              end if;
            end if;
          
          -- STOP BIT generation state 				
          when STOP_ST  =>
            if(sBrgTick = '1') then
              if(vTickCtr = cTickCnt) then
                vTickCtr	:= 0;
                sTxDone 	<= '1';
                sTxBusy		<= '0';
                sMainSt   <= IDLE_ST;
              else
                vTickCtr  := vTickCtr + 1;
              end if;
            end if;
          
          -- Other state 
          when others =>
            sMainSt <= IDLE_ST;
        end case;		
      end if;
    end if;	
			
	end process;


	--
	-- Logic --------------------------------------------------
	--
	
	-- Inputs
	--
	sBrgTick<= BRG_TICK;
	sTxTrig	<= SEND_TRIG;
	
	-- Outputs
	--
	SEND_BUSY<= sTxBusy;
	UART_TX	 <= sTxBit;
	SEND_DONE<= sTxDone;
	
	-- Internals
	--

end LvnT;

