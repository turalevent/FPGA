--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:16:36 05/15/2015
-- Design Name:   
-- Module Name:   C:/prj/fpga/NeuralNetwork/tb/TopModule_tbw.vhd
-- Project Name:  NeuralNetwork
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TopModule
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TopModule_tbw IS
END TopModule_tbw;
 
ARCHITECTURE behavior OF TopModule_tbw IS 
 
	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT TopModule
		PORT(
			CLK 		: IN  std_logic;
			RST 		: IN  std_logic;
			UART_RX 	: IN  std_logic;
			UART_TX 	: OUT std_logic;
			NN_BUSY 	: OUT std_logic;
			NN_RDY 	: OUT std_logic
		);
	END COMPONENT;
    
	-- 
	-- Types
	--

	type uart_st is (
							IDLE_ST, 
							START_ST, 
							DATA_ST, 
							STOP_ST
						);
						

   --Inputs
   signal CLK 		: std_logic := '0';
   signal RST 		: std_logic := '0';
   signal PC_TX	: std_logic := '0';

 	--Outputs
   signal PC_RX 	: std_logic;
   signal NN_BUSY : std_logic;
   signal NN_RDY 	: std_logic;

	-- General
	constant High_c 		: std_logic := '1';
	constant Low_c  		: std_logic := '0';
	
   -- Clock period definitions
   constant CLK100MHz 	: time := 10 ns;
   constant UartBaudTime: time := 540 ns;

	constant TxDataStopTickCnt_c	: integer := 16;
	constant TxStartTickCnt_c		: integer := 7;
	constant TxDB_c					: integer := 16;
	constant RxDB_c					: integer := 8;

	constant NnStartCmd_c: std_logic_vector(7 downto 0) := X"65";
	constant Input1_c		: std_logic_vector(31 downto 0):= X"3dcccccd"; -- 0.1
	constant Input2_c		: std_logic_vector(31 downto 0):= X"3e4ccccd"; -- 0.2
	constant Input3_c		: std_logic_vector(31 downto 0):= X"3e99999a"; -- 0.3
	constant Input4_c		: std_logic_vector(31 downto 0):= X"3ecccccd"; -- 0.4

	-- Internal Signals
	signal NnStartCmd_s	: std_logic_vector(7 downto 0)	:= NnStartCmd_c;
	signal Input1_s	 	: std_logic_vector(31 downto 0)	:= Input1_c;
	signal Input2_s	 	: std_logic_vector(31 downto 0)	:= Input2_c;
	signal Input3_s	 	: std_logic_vector(31 downto 0)	:= Input3_c;
	signal Input4_s	 	: std_logic_vector(31 downto 0)	:= Input4_c;
	signal PcRxData_s		: std_logic_vector(15 downto 0)	:= (others=>'0');
	signal PcTxData_s		: std_logic_vector(7 downto 0)	:= (others=>'0');
	signal PcSendTrig_s	: std_logic								:= '0';
	signal PcSendDone_s	: std_logic								:= '0';
	signal PcRcvdTrig_s	: std_logic								:= '0';
	signal StartShow_s	: std_logic								:= '0';
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut: TopModule PORT MAP (
		CLK 		=> CLK,
		RST 		=> RST,
		UART_RX 	=> PC_TX,
		UART_TX 	=> PC_RX,
		NN_BUSY 	=> NN_BUSY,
		NN_RDY 	=> NN_RDY
	);

	-- Reset system
	RST <= '1','0' after CLK100MHz;
	
   -- CLK_p process definitions
	-- 100MHz Main CLK
   CLK_p: process
   begin
		CLK <= '0';
		wait for CLK100MHz/2;
		CLK <= '1';
		wait for CLK100MHz/2;
   end process;

	-- PcRx_p process
	-- Receive UART Data as PC
	PcRx_p: process
	begin
		
		-- PC Received UART value..
		PcRcvdTrig_s<= High_c;
		wait for CLK100MHz;
		PcRcvdTrig_s<= Low_c;
		
	end process;

	-- PcTx_p process
	-- Send UART Data as a PC
	PcTx_p: process
	begin
		
		wait until PcSendTrig_s = High_c;

		-- START BIT generation state 				
		PC_TX	  	<= '0';
		wait for (UartBaudTime * TxStartTickCnt_c);
		
		-- Send First Bit
		PC_TX  	<= PcTxData_s(0);
		wait for (UartBaudTime * TxDataStopTickCnt_c);

		PC_TX  	<= PcTxData_s(1);	-- send 1 bit
		wait for (UartBaudTime * TxDataStopTickCnt_c);

		PC_TX  	<= PcTxData_s(2);	-- send 1 bit
		wait for (UartBaudTime * TxDataStopTickCnt_c);

		PC_TX  	<= PcTxData_s(3);	-- send 1 bit
		wait for (UartBaudTime * TxDataStopTickCnt_c);

		PC_TX  	<= PcTxData_s(4);	-- send 1 bit
		wait for (UartBaudTime * TxDataStopTickCnt_c);

		PC_TX  	<= PcTxData_s(5);	-- send 1 bit
		wait for (UartBaudTime * TxDataStopTickCnt_c);

		PC_TX  	<= PcTxData_s(6);	-- send 1 bit
		wait for (UartBaudTime * TxDataStopTickCnt_c);
		
		PC_TX  	<= PcTxData_s(7);	-- send 1 bit
		wait for (UartBaudTime * TxDataStopTickCnt_c);

		
		-- STOP BIT generation state 				
		PC_TX		<= '1';
		wait for (UartBaudTime * TxDataStopTickCnt_c);
		
		PcSendDone_s<= High_c;
		wait for CLK100MHz/2;
		PcSendDone_s<= Low_c;

	end process;

	--
	-- 											PC --> FPGA DATA PACKAGE	
	--  __________________________________________________________________________________
	-- |               |                  |             |         |           |           |
	-- |               |                  |             |         |           |           |
	-- | NQR_START_CMD | PA & T/R TX TIME | T/R RX TIME | QD TIME | NEW FREQ. | NEW PHASE |
	-- |               |                  |             |         |           |           |
	-- |_______________|__________________|_____________|_________|___________|___________|
	--	 1-byte          3-byte             4-byte        3-byte    4-byte      1-byte
	--
	
	-- UrxTest_p process
	-- UART RX Test: Send Command to System Command Package :
	UrxTest_p: process
	begin
		
		wait until StartShow_s = High_c;
		
		-- Send NEURAL NETWORK START COMMAND 
		PcTxData_s	<= NnStartCmd_s;
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
				
		-- Send INPUT-1
			-- Send Input number : 0
		PcTxData_s	<= X"00";
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;

			-- 1.byte
		PcTxData_s	<= Input1_s(7 downto 0);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
			-- 2.byte
		PcTxData_s	<= Input1_s(15 downto 8);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
			-- 3.byte
		PcTxData_s	<= Input1_s(23 downto 16);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
			-- 4.byte
		PcTxData_s	<= Input1_s(31 downto 24);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
		-- Send INPUT-2  
			-- Send Input number : 1
		PcTxData_s	<= X"01";
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;

			-- 1.byte
		PcTxData_s	<= Input2_s(7 downto 0);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
			-- 2.byte
		PcTxData_s	<= Input2_s(15 downto 8);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
			-- 3.byte
		PcTxData_s	<= Input2_s(23 downto 16);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
			-- 4.byte
		PcTxData_s	<= Input2_s(31 downto 24);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
		-- Send INPUT-3  
			-- Send Input number : 2
		PcTxData_s	<= X"02";
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;

			-- 1.byte
		PcTxData_s	<= Input3_s(7 downto 0);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
			-- 2.byte
		PcTxData_s	<= Input3_s(15 downto 8);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
			-- 3.byte
		PcTxData_s	<= Input3_s(23 downto 16);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
			-- 4.byte
		PcTxData_s	<= Input3_s(31 downto 24);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
		-- Send INPUT-4  
			-- Send Input number : 3
		PcTxData_s	<= X"03";
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;

			-- 1.byte
		PcTxData_s	<= Input4_s(7 downto 0);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
			-- 2.byte
		PcTxData_s	<= Input4_s(15 downto 8);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
			-- 3.byte
		PcTxData_s	<= Input4_s(23 downto 16);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
			-- 4.byte
		PcTxData_s	<= Input4_s(31 downto 24);
		
		PcSendTrig_s<= High_c;
		wait for CLK100MHz/2;
		PcSendTrig_s<= Low_c;
		
		wait until PcSendDone_s = High_c;
		wait for CLK100MHz*1;
		
				
		-- End Of Command Sending process..
		wait;


	end process;

--	-- UtxTest_p process
--	-- UART TX Test : Collect Send Data Array from System..
--	UtxTest_p: process
--		variable RdCtr_v : integer range 0 to RamSize_c := 0;
--	begin
--		
--		wait until PcRcvdTrig_s = High_c;
--		PcRamBlock_s(RdCtr_v) 	<= PcRxData_s;
--		RdCtr_v	:= RdCtr_v + 1;
--		
--	end process;

	-- MainTest_p process
	-- Main Test
	MainTest_p: process
	begin
		
		wait for CLK100MHz*5;
		
		StartShow_s	<= High_c;
		wait for CLK100MHz/2;
		StartShow_s	<= Low_c;
		
		wait for 2 ms;
		
		assert false
		report "Sim Ok"
		severity failure;
		
	end process;


END;
