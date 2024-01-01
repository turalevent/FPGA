----------------------------------------------------------------------------------
-- Company			: 
-- Engineer			: Levent TURA
-- 
-- Create Date		: 07.05.2015
-- Design Name		: 
-- Module Name		: TopModule - YTU
-- Project Name	: Neural Network
-- Target Devices	: Virtex-4
-- Tool Versions	: 14.2
-- Description		: 
-- 
-- Dependencies	: 
-- 
-- Revision			:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TopModule is
	PORT(
		CLK   	: in  std_logic;
		RST   	: in  std_logic;
		-- UART COMPONENT'S PINS
		UART_RX	: in  std_logic;							-- Uart RX pin
		UART_TX	: out std_logic;							-- Uart TX pin
		NN_BUSY	: out std_logic;
		NN_RDY	: out std_logic;
		SYS_ALIVE: out std_logic
	);
end TopModule;

architecture YTU of TopModule is

	--
	-- Components
	--
	
	--
	-- Components
	--
	-- UART COMMUNICATION
	COMPONENT UART
		GENERIC(
			BAUD_RATE	: integer;								-- UART Speed
			TX_DATA_BIT	: integer;								-- UART TX Bit Number
			RX_DATA_BIT	: integer;								-- UART RX Bit Number
			STOP_BIT		: integer								-- UART Stop Bit Number
		);
		PORT(
			CLK			: in  std_logic;
			RST			: in  std_logic;
			-- Hardware Pins
			UART_RX		: in  std_logic; 							-- UART Read Pin
			UART_TX		: out std_logic;							-- UART Send Pin
			-- Status & Controls
			SEND_TRIG	: in  std_logic;							-- UART Send Trig
			SEND_DATA	: in  std_logic_vector(TX_DATA_BIT - 1 downto 0);	-- UART Send Data
			SEND_DONE	: out std_logic;							-- UART Send Done
			SEND_BUSY	: out std_logic;							-- UART Send Fail
			RCV_DONE		: out std_logic;							-- UART Received 1 byte data
			RCV_DATA 	: out std_logic_vector(7 downto 0)	-- Received data
		);
	END COMPONENT;

	-- Hidden Layer
	--
	COMPONENT NeuralNetwork
		PORT(
			CLK   		: in  std_logic;
			RST   		: in  std_logic;
			TRIG  		: in  std_logic;
			WGH_SET 		: in  std_logic;
			WGH_LYR_NUM	: in  std_logic_vector(1 downto 0);  
			WGH_NUM		: in  std_logic_vector(7 downto 0);  
			WGH			: in  std_logic_vector(31 downto 0);  
			INPUT1		: in  std_logic_vector(31 downto 0);
			INPUT2		: in  std_logic_vector(31 downto 0);
			INPUT3		: in  std_logic_vector(31 downto 0);
			INPUT4		: in  std_logic_vector(31 downto 0);
			RDY  			: out std_logic;
			OUTPUT1		: out std_logic_vector(31 downto 0);
			OUTPUT2		: out std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	-- 
	-- Types
	--
 	type Array4x32_t  is array (0 to 3) of std_logic_vector(31 downto 0);
 	type Array2x32_t  is array (0 to 1) of std_logic_vector(31 downto 0);
   
	type MainFSM_t is(
		IDLE_ST,
		GET_INPUT_NUM_ST,
		GET_INPUT_ST,
		GET_LAYER_NUM_ST,
		GET_WEIGHT_NUM_ST,
		SET_WEIGHT_ST,
		SEND_OUTPUT_ST
	);
    
  
	--
	-- Constants
	--
	
	-- General
	constant High_c 				: std_logic := '1';
	constant Low_c  				: std_logic := '0';
	constant NrlNwkStartCmd_c  : std_logic_vector(7 downto 0):= X"65";
	constant WghSetCmd_c  		: std_logic_vector(7 downto 0):= X"75";
	constant SysPer_c 			: integer 	:= 10;									-- System CLK Period = 10 ns
	-- Test
	constant SysAlivePer_c 		: integer := 250000000/SysPer_c;					-- System Alive LED's Period = 50ms
	
	--
	-- Signals
	--	
	
	-- Typed Signals
	signal MainSt_s		: MainFSM_t;
	signal InputArry_s	: Array4x32_t;
	signal OutputArry_s	: Array2x32_t;
	
	-- General Signals
	signal NrlNwkBusy_s	: std_logic;
	signal SysAlvLed_s	: std_logic;
	-- Uart Signals
	signal UartSendTrig_s: std_logic;
	signal UartSendDone_s: std_logic;
	signal UartSendBusy_s: std_logic;
	signal UartRcvDone_s	: std_logic;
	signal UartSendData_s: std_logic_vector(7 downto 0);
	signal UartRcvData_s	: std_logic_vector(7 downto 0);
	-- Inputs from UART
	signal WghSetTrig_s	: std_logic;
	signal NrlNwkTrig_s	: std_logic;
	signal NrlNwkRdy_s	: std_logic;
	signal WghLyrNum_s	: std_logic_vector(1 downto 0);
	signal WghNum_s		: std_logic_vector(7 downto 0);
	signal Wgh_s			: std_logic_vector(31 downto 0);

begin
    
	--
	-- Primitives ---------------------------------------------
	--

	--
	-- Components ---------------------------------------------
	--

	-- UART_cmp component
	-- PC communication interface
	UART_cmp : UART 
	GENERIC MAP(
		BAUD_RATE	=> 9600,
		TX_DATA_BIT	=>	8,
		RX_DATA_BIT	=> 8,
		STOP_BIT		=> 1
	)
	PORT MAP(
		CLK		=> CLK,
		RST		=> RST,
		-- Hardware Pins
		UART_RX	=> UART_RX,			-- UART_RX,
		UART_TX	=> UART_TX,			-- UART_TX,
		-- Status & Controls
		SEND_TRIG=> UartSendTrig_s,-- Send Trig
		SEND_DATA=> UartSendData_s,-- Uart send data
		SEND_DONE=> UartSendDone_s, 
		SEND_BUSY=> UartSendBusy_s,
		RCV_DONE	=> UartRcvDone_s,
		RCV_DATA => UartRcvData_s
	);

	-- HddenLyr1_cmp component
	-- 
	NrlNwk_cmp : NeuralNetwork 
	PORT MAP(
		CLK   		=> CLK,
		RST   		=> RST,
		TRIG  		=> NrlNwkTrig_s,
		WGH_SET 		=> WghSetTrig_s,
		WGH_LYR_NUM	=> WghLyrNum_s,
		WGH_NUM		=> WghNum_s,
		WGH			=> Wgh_s,
		INPUT1		=>	InputArry_s(0)(31 downto 0),
		INPUT2		=>	InputArry_s(1)(31 downto 0),
		INPUT3		=>	InputArry_s(2)(31 downto 0),
		INPUT4		=>	InputArry_s(3)(31 downto 0),
		RDY			=> NrlNwkRdy_s,
		OUTPUT1		=> OutputArry_s(0)(31 downto 0),
		OUTPUT2		=> OutputArry_s(1)(31 downto 0)
	);


	--
	-- PC --> FPGA DATA PACKAGE	
	--  ______________ _____________________
	-- |              |              |      |
	-- |              |              |      |
	-- | NN_START_CMD | INPUT_NUMBER | DATA |
	-- |              |              |      |
	-- |______________|______________|______|
	--	 1-byte         1-byte         4-byte             
	--
	--  ______________ _____________________________________
	-- |              |              |      		  |		  |
	-- |              |              |      		  |		  |
	-- | SET_WGHT_CMD | LAYER_NUMBER | WGHT_NUMBER |  WGHT  |
	-- |              |              |      		  |		  |
	-- |______________|______________|_____________|________|
	--	 1-byte         1-byte         1-byte        4-byte             

	-- Main_p process
	-- Remoote Control Main process
	Main_p: process(CLK, RST)
		variable OutNum_v	: integer range 0 to 1;
		variable InNum_v 	: integer range 0 to 3;
		variable BitNum_v	: integer range 0 to 40;
	begin
	
		if(rising_edge(CLK)) then
			if(RST = High_c) then
				WghSetTrig_s	<= Low_c;
				NrlNwkBusy_s	<= Low_c;
				NrlNwkTrig_s	<= Low_c;
				UartSendTrig_s	<= Low_c;
				MainSt_s			<= IDLE_ST;
				WghLyrNum_s		<= (others=>'0');				
				WghNum_s			<= (others=>'0');				
				Wgh_s				<= (others=>'0');				
				InputArry_s		<= (others=>(others=>'0'));				
				InNum_v			:= 0;
				OutNum_v			:= 0;
				BitNum_v			:= 8;
			else

				WghSetTrig_s	<= Low_c;
				NrlNwkTrig_s	<= Low_c;
				UartSendTrig_s	<= Low_c;
				MainSt_s			<= IDLE_ST;

				case MainSt_s is

					-- IDLE_ST state
					-- Idle state
					when IDLE_ST => 					
						if(UartRcvDone_s = High_c) then
							if(UartRcvData_s = NrlNwkStartCmd_c) then
								NrlNwkBusy_s<= High_c;
								MainSt_s		<= GET_INPUT_NUM_ST;
								BitNum_v		:= 8;
							elsif(UartRcvData_s = WghSetCmd_c) then
								NrlNwkBusy_s<= High_c;
								MainSt_s		<= GET_LAYER_NUM_ST;
							end if;
						elsif(NrlNwkRdy_s = High_c) then
							MainSt_s			<= SEND_OUTPUT_ST;
							UartSendData_s	<= OutputArry_s(OutNum_v)(BitNum_v - 1 downto BitNum_v - 8);
							UartSendTrig_s	<= High_c;
							BitNum_v			:= BitNum_v + 8;
						end if;
						
					-- GET_INPUT_NUM_ST state
					-- Get Input Number
					when GET_INPUT_NUM_ST =>
						MainSt_s	<= GET_INPUT_NUM_ST;
						if(UartRcvDone_s = High_c) then
							MainSt_s	<= GET_INPUT_ST;
							InNum_v	:= conv_integer(UartRcvData_s);
						end if;

					-- GET_INPUT_ST state
					-- Get 4 byte Input
					when GET_INPUT_ST =>
						MainSt_s	<= GET_INPUT_ST;
						if(UartRcvDone_s = High_c) then
							InputArry_s(InNum_v)(BitNum_v - 1 downto BitNum_v - 8)<= UartRcvData_s;
							if(BitNum_v = 32) then
								if(InNum_v = 3) then
									MainSt_s		<= IDLE_ST;
									NrlNwkTrig_s<= High_c;
								else
									MainSt_s	<= GET_INPUT_NUM_ST;
								end if;
								BitNum_v	:= 8;
							else
								BitNum_v := BitNum_v + 8;
							end if;
						end if;

					-- GET_LAYER_NUM_ST state
					-- Get Layer Number to set Weight
					when GET_LAYER_NUM_ST =>
						MainSt_s	<= GET_LAYER_NUM_ST;
						if(UartRcvDone_s = High_c) then
							MainSt_s		<= GET_WEIGHT_NUM_ST;
							WghLyrNum_s	<= UartRcvData_s(1 downto 0);
						end if;

					-- GET_WEIGHT_NUM_ST state
					-- Get Weight Number to set Weight
					when GET_WEIGHT_NUM_ST =>
						MainSt_s	<= GET_WEIGHT_NUM_ST;
						if(UartRcvDone_s = High_c) then
							MainSt_s	<= SET_WEIGHT_ST;
							WghNum_s	<= UartRcvData_s;
							BitNum_v	:= 8;
						end if;

					-- SET_WEIGHT_ST state
					-- Get 4 byte Layer Num, Weight Num and Weight
					when SET_WEIGHT_ST =>
						MainSt_s	<= SET_WEIGHT_ST;
						if(UartRcvDone_s = High_c) then
							Wgh_s(BitNum_v - 1 downto BitNum_v - 8)<= UartRcvData_s;
							if(BitNum_v = 32) then
								MainSt_s		<= IDLE_ST;
								WghSetTrig_s<= High_c;
								BitNum_v		:= 8;
							else
								BitNum_v := BitNum_v + 8;
							end if;
						end if;

					-- SEND_OUTPUT_ST state
					-- Send Output datas
					when SEND_OUTPUT_ST =>
						MainSt_s	<= SEND_OUTPUT_ST;
						if(UartSendDone_s = High_c) then
							UartSendData_s	<= OutputArry_s(OutNum_v)(BitNum_v - 1 downto BitNum_v - 8);
							UartSendTrig_s	<= High_c;
							if(BitNum_v = 32) then
								BitNum_v	:= 8;
								if(OutNum_v = 1) then
									NrlNwkBusy_s<= Low_c;
									MainSt_s		<= IDLE_ST;
									OutNum_v 	:= 0;
								else
									OutNum_v := OutNum_v + 1;
								end if;
							else
								BitNum_v := BitNum_v + 8;
							end if;
						end if;
					
					-- others state
					-- go to RC_IDLE_ST state..
					when others => 					
						MainSt_s	<= IDLE_ST;

				end case;
				
			end if;
		end if;
	
	end process;


	-- SysAlive_tp process
	-- ADC1XD1XXXRB->TRIGGER(LD3) ledi 500ms aralýklarla ile sürülecek.
	SysAlive_tp: process(CLK, RST)
		variable SysAlvCtr_v	: integer range 0 to SysAlivePer_c;
	begin
	
		if(rising_edge(CLK)) then
			if(RST = High_c) then
				SysAlvCtr_v	:= 0;
				SysAlvLed_s	<= Low_c;
			else
				if(SysAlvCtr_v = SysAlivePer_c-1) then
					SysAlvLed_s	<= SysAlvLed_s XOR '1';	-- Toggle System Alive Led
					SysAlvCtr_v	:= 0;
				else
					SysAlvCtr_v	:= SysAlvCtr_v + 1;
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
	NN_RDY	<= NOT NrlNwkBusy_s;
	NN_BUSY	<= NrlNwkBusy_s;
	SYS_ALIVE<= SysAlvLed_s;
	-- InOuts
	--

	-- Internals
	--

end YTU;
