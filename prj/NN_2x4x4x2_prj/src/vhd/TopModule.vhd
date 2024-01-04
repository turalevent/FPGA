----------------------------------------------------------------------------------
-- Company: LvnT
-- Engineer: Levent TURA 
-- 
-- Create Date: 04.01.2024
-- Design Name: 
-- Module Name: TopModule - LvnT
-- Project Name: NN2x4x4x2_prj
-- Target Devices: -
-- Tool Versions: -
-- Description: Neural Network which has 2 Input X 4X4 Hidden x 2 Output Layers. 
--              It gets Weights and Inputs of each corresponding Neuron through UART and sends the 
--              computation result through UART. 
-- Note : All floating points are in IEEE754 Single precision (f32).
-- 
-- Dependencies: 
-- 
-- Revision:
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

architecture LvnT of TopModule is

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
			CLK, RST	: in  std_logic;
			-- Hardware Pins
			UART_RX		: in  std_logic; 							-- UART Read Pin
			UART_TX		: out std_logic;							-- UART Send Pin
			-- Status & Controls
			SEND_TRIG	: in  std_logic;							-- UART Send Trig
			SEND_DATA	: in  std_logic_vector(TX_DATA_BIT - 1 downto 0);	-- UART Send Data
			SEND_DONE	: out std_logic;							-- UART Send Done
			SEND_BUSY	: out std_logic;							-- UART Send Fail
			RCV_DONE	: out std_logic;							-- UART Received 1 byte data
			RCV_DATA 	: out std_logic_vector(7 downto 0)	-- Received data
		);
	END COMPONENT;

	-- Hidden Layer
	--
	COMPONENT NeuralNetwork
		PORT(
			CLK   		  : in  std_logic;
			RST   		  : in  std_logic;
			TRIG  		  : in  std_logic;
			WGH_SET 		: in  std_logic;
			WGH_LYR_NUM	: in  std_logic_vector(1 downto 0);  
			WGH_NUM		  : in  std_logic_vector(7 downto 0);  
			WGH			    : in  std_logic_vector(31 downto 0);  
			INPUT1		  : in  std_logic_vector(31 downto 0);
			INPUT2		  : in  std_logic_vector(31 downto 0);
			INPUT3		  : in  std_logic_vector(31 downto 0);
			INPUT4		  : in  std_logic_vector(31 downto 0);
			RDY  			  : out std_logic;
			OUTPUT1		  : out std_logic_vector(31 downto 0);
			OUTPUT2		  : out std_logic_vector(31 downto 0)
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
	constant cHigh 				  : std_logic := '1';
	constant cLow  				  : std_logic := '0';
	constant cNrlNwkStartCmd: std_logic_vector(7 downto 0):= X"65";
	constant cWghSetCmd  		: std_logic_vector(7 downto 0):= X"75";
	constant cSysPer 			  : integer 	:= 10;									     -- System CLK Period = 10 ns
	-- Test
	constant cSysAlivePer 	: integer := 250000000/cSysPer;					 -- System Alive LED's Period = 50ms
	
	--
	-- Signals
	--	
	
	-- Typed Signals
	signal sMainSt		  : MainFSM_t;
	signal sInputArry	  : Array4x32_t;
	signal sOutputArry	: Array2x32_t;
	
	-- General Signals
	signal sNrlNwkBusy	: std_logic;
	signal sSysAlvLed	  : std_logic;
	-- Uart Signals
	signal sUartSendTrig: std_logic;
	signal sUartSendDone: std_logic;
	signal sUartSendBusy: std_logic;
	signal sUartRcvDone	: std_logic;
	signal sUartSendData: std_logic_vector(7 downto 0);
	signal sUartRcvData	: std_logic_vector(7 downto 0);
	-- Inputs from UART
	signal sWghSetTrig	: std_logic;
	signal sNrlNwkTrig	: std_logic;
	signal sNrlNwkRdy	  : std_logic;
	signal sWghLyrNum	  : std_logic_vector(1 downto 0);
	signal sWghNum		  : std_logic_vector(7 downto 0);
	signal sWgh			    : std_logic_vector(31 downto 0);

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
		CLK		    => CLK,
		RST		    => RST,
		-- Hardware Pins
		UART_RX	  => UART_RX,			-- UART_RX,
		UART_TX	  => UART_TX,			-- UART_TX,
		-- Status & Controls
		SEND_TRIG => sUartSendTrig,-- Send Trig
		SEND_DATA => sUartSendData,-- Uart send data
		SEND_DONE => sUartSendDone, 
		SEND_BUSY => sUartSendBusy,
		RCV_DONE	=> sUartRcvDone,
		RCV_DATA  => sUartRcvData
	);

	-- HddenLyr1_cmp component
	-- 
	NrlNwk_cmp : NeuralNetwork 
	PORT MAP(
		CLK   		  => CLK,
		RST   		  => RST,
		TRIG  		  => sNrlNwkTrig,
		WGH_SET 		=> sWghSetTrig,
		WGH_LYR_NUM	=> sWghLyrNum,
		WGH_NUM		  => sWghNum,
		WGH			    => sWgh,
		INPUT1		  =>	sInputArry(0)(31 downto 0),
		INPUT2		  =>	sInputArry(1)(31 downto 0),
		INPUT3		  =>	sInputArry(2)(31 downto 0),
		INPUT4		  =>	sInputArry(3)(31 downto 0),
		RDY			    => sNrlNwkRdy,
		OUTPUT1		  => sOutputArry(0)(31 downto 0),
		OUTPUT2		  => sOutputArry(1)(31 downto 0)
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
	--  ______________ ______________________________________
	-- |              |              |      		   |		     |
	-- |              |              |      		   |		     |
	-- | SET_WGHT_CMD | LAYER_NUMBER | WGHT_NUMBER |  WGHT   |
	-- |              |              |      		   |		     |
	-- |______________|______________|_____________|_________|
	--	 1-byte         1-byte         1-byte        4-byte             

	-- Main_p process
	-- Remoote Control Main process
	Main_p: process(CLK, RST)
		variable OutNum_v	: integer range 0 to 1;
		variable InNum_v 	: integer range 0 to 3;
		variable BitNum_v	: integer range 0 to 40;
	begin

		if(rising_edge(CLK)) then
			if(RST = cHigh) then
				sWghSetTrig	<= cLow;
				sNrlNwkBusy	<= cLow;
				sNrlNwkTrig	<= cLow;
				sUartSendTrig	<= cLow;
				sMainSt			<= IDLE_ST;
				sWghLyrNum		<= (others=>'0');				
				sWghNum			<= (others=>'0');				
				sWgh				<= (others=>'0');				
				sInputArry		<= (others=>(others=>'0'));				
				InNum_v			:= 0;
				OutNum_v			:= 0;
				BitNum_v			:= 8;
			else

				sWghSetTrig	<= cLow;
				sNrlNwkTrig	<= cLow;
				sUartSendTrig	<= cLow;
				sMainSt			<= IDLE_ST;

				case sMainSt is

					-- IDLE_ST state
					-- Idle state
					when IDLE_ST => 					
						if(sUartRcvDone = cHigh) then
							if(sUartRcvData = cNrlNwkStartCmd) then
								sNrlNwkBusy<= cHigh;
								sMainSt		<= GET_INPUT_NUM_ST;
								BitNum_v	:= 8;
							elsif(sUartRcvData = cWghSetCmd) then
								sNrlNwkBusy<= cHigh;
								sMainSt		 <= GET_LAYER_NUM_ST;
							end if;
						elsif(sNrlNwkRdy = cHigh) then
							sMainSt			  <= SEND_OUTPUT_ST;
							sUartSendData	<= sOutputArry(OutNum_v)(BitNum_v - 1 downto BitNum_v - 8);
							sUartSendTrig	<= cHigh;
							BitNum_v			:= BitNum_v + 8;
						end if;
						
					-- GET_INPUT_NUM_ST state
					-- Get Input Number
					when GET_INPUT_NUM_ST =>
						sMainSt	<= GET_INPUT_NUM_ST;
						if(sUartRcvDone = cHigh) then
							sMainSt	<= GET_INPUT_ST;
							InNum_v	:= conv_integer(sUartRcvData);
						end if;

					-- GET_INPUT_ST state
					-- Get 4 byte Input
					when GET_INPUT_ST =>
						sMainSt	<= GET_INPUT_ST;
						if(sUartRcvDone = cHigh) then
							sInputArry(InNum_v)(BitNum_v - 1 downto BitNum_v - 8)<= sUartRcvData;
							if(BitNum_v = 32) then
								if(InNum_v = 3) then
									sMainSt		 <= IDLE_ST;
									sNrlNwkTrig<= cHigh;
								else
									sMainSt	<= GET_INPUT_NUM_ST;
								end if;
								BitNum_v	:= 8;
							else
								BitNum_v := BitNum_v + 8;
							end if;
						end if;

					-- GET_LAYER_NUM_ST state
					-- Get Layer Number to set Weight
					when GET_LAYER_NUM_ST =>
						sMainSt	<= GET_LAYER_NUM_ST;
						if(sUartRcvDone = cHigh) then
							sMainSt		<= GET_WEIGHT_NUM_ST;
							sWghLyrNum<= sUartRcvData(1 downto 0);
						end if;

					-- GET_WEIGHT_NUM_ST state
					-- Get Weight Number to set Weight
					when GET_WEIGHT_NUM_ST =>
						sMainSt	<= GET_WEIGHT_NUM_ST;
						if(sUartRcvDone = cHigh) then
							sMainSt	<= SET_WEIGHT_ST;
							sWghNum	<= sUartRcvData;
							BitNum_v:= 8;
						end if;

					-- SET_WEIGHT_ST state
					-- Get 4 byte Layer Num, Weight Num and Weight
					when SET_WEIGHT_ST =>
						sMainSt	<= SET_WEIGHT_ST;
						if(sUartRcvDone = cHigh) then
							sWgh(BitNum_v - 1 downto BitNum_v - 8)<= sUartRcvData;
							if(BitNum_v = 32) then
								sMainSt		 <= IDLE_ST;
								sWghSetTrig<= cHigh;
								BitNum_v	 := 8;
							else
								BitNum_v := BitNum_v + 8;
							end if;
						end if;

					-- SEND_OUTPUT_ST state
					-- Send Output datas
					when SEND_OUTPUT_ST =>
						sMainSt	<= SEND_OUTPUT_ST;
						if(sUartSendDone = cHigh) then
							sUartSendData	<= sOutputArry(OutNum_v)(BitNum_v - 1 downto BitNum_v - 8);
							sUartSendTrig	<= cHigh;
							if(BitNum_v = 32) then
								BitNum_v	:= 8;
								if(OutNum_v = 1) then
									sNrlNwkBusy  <= cLow;
									sMainSt		  <= IDLE_ST;
									OutNum_v 	  := 0;
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
						sMainSt	<= IDLE_ST;

				end case;
				
			end if;
		end if;
	
	end process;


	-- SysAlive_tp process
	-- ADC1XD1XXXRB->TRIGGER(LD3) ledi 500ms aralýklarla ile sürülecek.
	SysAlive_tp: process(CLK, RST)
		variable SysAlvCtr_v	: integer range 0 to cSysAlivePer;
	begin
	
		if(rising_edge(CLK)) then
			if(RST = cHigh) then
				SysAlvCtr_v	:= 0;
				sSysAlvLed	<= cLow;
			else
				if(SysAlvCtr_v = cSysAlivePer-1) then
					sSysAlvLed	<= sSysAlvLed XOR '1';	-- Toggle System Alive Led
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
	NN_RDY	 <= NOT sNrlNwkBusy;
	NN_BUSY	 <= sNrlNwkBusy;
	SYS_ALIVE<= sSysAlvLed;
	-- InOuts
	--

	-- Internals
	--

end LvnT;
