library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity UART is
	GENERIC(
		BAUD_RATE	  : integer := 115200;
		TX_DATA_BIT	: integer := 8;										-- UART TX Bit Number
		RX_DATA_BIT	: integer := 8;										-- UART RX Bit Number
		STOP_BIT		: integer := 1
	);
	PORT(
		CLK		: in  std_logic;
		RST		: in  std_logic;
		SEND_TRIG: in  std_logic;
		SEND_DATA: in  std_logic_vector(TX_DATA_BIT - 1 downto 0);
		UART_RX	: in  std_logic;
		UART_TX	: out std_logic;
		SEND_DONE: out std_logic;
		SEND_BUSY: out std_logic;
		RCV_DONE	: out std_logic;
		RCV_DATA : out std_logic_vector(7 downto 0)
	);
end UART;

architecture LvnT of UART is

	--
	-- COMPONENT DECLERATIONS
	--
	
	-- BAUD RATE GENERATOR
	COMPONENT ua_brg
		GENERIC(
			BAUD_RATE: integer
		);
		PORT(
			CLK		: in  std_logic;
			RST		: in  std_logic;
			BRG_TICK	: out std_logic
		);
	END COMPONENT;

	-- UART TX
	COMPONENT ua_tx
		GENERIC(
			DATA_BIT		: integer;
			STOP_BIT		: integer
		);
		PORT(
			CLK		: in  std_logic;
			RST		: in  std_logic;
			BRG_TICK	: in  std_logic; 
			-- Hardware Pins
			UART_TX	: out std_logic;
			-- Status & Controls
			SEND_TRIG: in  std_logic;
			SEND_DATA: in  std_logic_vector(DATA_BIT - 1 downto 0);
			SEND_DONE: out std_logic;
			SEND_BUSY: out std_logic
		);
	END COMPONENT;

	-- UART RX
	COMPONENT ua_rx
		GENERIC(
			DATA_BIT		: integer;
			STOP_BIT		: integer
		);
		PORT(
			CLK		: in  std_logic;
			RST		: in  std_logic;
			BRG_TICK	: in  std_logic; 
			-- Hardware Pins
			UART_RX	: in std_logic;
			-- Status & Controls
			RCV_DATA	: out std_logic_vector(DATA_BIT - 1 downto 0);
			RCV_DONE : out std_logic
		);
	END COMPONENT;

	--
	-- Constants
	--
	constant High_c : std_logic := '1';
	constant Low_c  : std_logic := '0';

	--
	-- Signals
	--
	-- UART Signals
	signal BrgTick_s: std_logic;

begin


	--
	-- Primitives ---------------------------------------------
	--


	--
	-- Components ---------------------------------------------
	--

	-- ua_brg_cmp component
	-- Baud Rate Tick Generator
	ua_brg_cmp : ua_brg 
	GENERIC MAP(
		BAUD_RATE=> BAUD_RATE
	)
	PORT MAP(
		CLK		=> CLK,
		RST		=> RST,
		BRG_TICK	=> BrgTick_s
	);

	-- ua_tx_cmp component
	-- UART Send 
	ua_tx_cmp : ua_tx 
	GENERIC MAP(
		DATA_BIT	=> TX_DATA_BIT,
		STOP_BIT	=> STOP_BIT
	)
	PORT MAP(
		CLK		=> CLK,
		RST		=> RST,
		BRG_TICK	=> BrgTick_s,
		-- Hardware Pins
		UART_TX	=> UART_TX,
		-- Status & Controls
		SEND_TRIG=> SEND_TRIG,
		SEND_DATA=> SEND_DATA,
		SEND_DONE=> SEND_DONE,
		SEND_BUSY=> SEND_BUSY
	);

	-- ua_rx_cmp component
	-- UART Receive 
	ua_rx_cmp : ua_rx 
	GENERIC MAP(
		DATA_BIT	=> RX_DATA_BIT,
		STOP_BIT	=> STOP_BIT
	)
	PORT MAP(
		CLK		=> CLK,
		RST		=> RST,
		BRG_TICK	=> BrgTick_s,
		-- Hardware Pins
		UART_RX	=> UART_RX,
		-- Status & Controls
		RCV_DONE => RCV_DONE,
		RCV_DATA	=> RCV_DATA 
	);

	--
	-- Processes ----------------------------------------------
	--


	--
	-- Logic --------------------------------------------------
	--
	
	-- Inputs
	--
	
	-- Outputs
	--
	
	-- Internals
	--
	
end LvnT;

