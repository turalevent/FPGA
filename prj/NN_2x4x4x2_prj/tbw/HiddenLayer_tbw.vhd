--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:14:42 05/10/2015
-- Design Name:   
-- Module Name:   C:/prj/fpga/layer/tb/HiddenLayer_tbw.vhd
-- Project Name:  layer
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: HiddenLayer
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
 
ENTITY HiddenLayer_tbw IS
END HiddenLayer_tbw;
 
ARCHITECTURE behavior OF HiddenLayer_tbw IS 
 
    -- Component Declaration for the Unit Under Test (UUT)

	COMPONENT HiddenLayer
		GENERIC(
			NEURON_NUM : integer
		);
		PORT(
			CLK 		: IN  std_logic;
			RST 		: IN  std_logic;
			TRIG 		: IN  std_logic;
			WGH_SET 	: IN  std_logic;
			WGH_NUM	: IN  std_logic_vector(7 downto 0);  
			WGH		: IN  std_logic_vector(31 downto 0);  
			INPUT1 	: IN  std_logic_vector(31 downto 0);
			INPUT2 	: IN  std_logic_vector(31 downto 0);
			INPUT3 	: IN  std_logic_vector(31 downto 0);
			INPUT4 	: IN  std_logic_vector(31 downto 0);
			RDY 		: OUT std_logic;
			OUTPUT1 	: OUT std_logic_vector(31 downto 0);
			OUTPUT2 	: OUT std_logic_vector(31 downto 0);
			OUTPUT3 	: OUT std_logic_vector(31 downto 0);
			OUTPUT4 	: OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
    

   --Inputs
   signal CLK 		: std_logic := '0';
   signal RST 		: std_logic := '0';
   signal TRIG 	: std_logic := '0';
   signal WGH_SET	: std_logic := '0';
   signal WGH_NUM	: std_logic_vector(7 downto 0)  := X"00";
   signal WGH	 	: std_logic_vector(31 downto 0) := X"00000000"; -- 0.2
   signal INPUT1 	: std_logic_vector(31 downto 0) := X"3dcccccd"; -- 0.1
   signal INPUT2 	: std_logic_vector(31 downto 0) := X"3e4ccccd"; -- 0.2
   signal INPUT3 	: std_logic_vector(31 downto 0) := X"3e99999a"; -- 0.3
   signal INPUT4 	: std_logic_vector(31 downto 0) := X"3ecccccd"; -- 0.4

 	--Outputs
   signal RDY 		: std_logic;
   signal OUTPUT1 : std_logic_vector(31 downto 0);
   signal OUTPUT2 : std_logic_vector(31 downto 0);
   signal OUTPUT3 : std_logic_vector(31 downto 0);
   signal OUTPUT4 : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut: HiddenLayer 
	GENERIC MAP(
		NEURON_NUM => 4
	)
	PORT MAP (
		CLK 		=> CLK,
		RST 		=> RST,
		TRIG 		=> TRIG,
		WGH_SET 	=> WGH_SET,
		WGH_NUM 	=> WGH_NUM,
		WGH 		=> WGH,
		INPUT1 	=> INPUT1,
		INPUT2 	=> INPUT2,
		INPUT3 	=> INPUT3,
		INPUT4 	=> INPUT4,
		RDY 		=> RDY,
		OUTPUT1 	=> OUTPUT1,
		OUTPUT2 	=> OUTPUT2,
		OUTPUT3 	=> OUTPUT3,
		OUTPUT4 	=> OUTPUT4
	);

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		
		-- Weight-0 Set : 0.1
		WGH_NUM	<= X"00";
		WGH		<= X"3dcccccd";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-1 Set : 0.2
		WGH_NUM	<= X"01";
		WGH		<= X"3e4ccccd";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-2 Set : 0.3
		WGH_NUM	<= X"02";
		WGH		<= X"3e99999a";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-3 Set : 0.4
		WGH_NUM	<= X"03";
		WGH		<= X"3ecccccd";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-4 Set : 0.5
		WGH_NUM	<= X"04";
		WGH		<= X"3f000000";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-5 Set : 0.1
		WGH_NUM	<= X"05";
		WGH		<= X"3dcccccd";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-6 Set : 0.2
		WGH_NUM	<= X"06";
		WGH		<= X"3e4ccccd";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-7 Set : 0.3
		WGH_NUM	<= X"07";
		WGH		<= X"3e99999a";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-8 Set : 0.4
		WGH_NUM	<= X"08";
		WGH		<= X"3ecccccd";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-9 Set : 0.5
		WGH_NUM	<= X"09";
		WGH		<= X"3f000000";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;

		-- Weight-10 Set : 0.1
		WGH_NUM	<= X"0a";
		WGH		<= X"3dcccccd";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-11 Set : 0.2
		WGH_NUM	<= X"0b";
		WGH		<= X"3e4ccccd";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-12 Set : 0.3
		WGH_NUM	<= X"0c";
		WGH		<= X"3e99999a";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-13 Set : 0.4
		WGH_NUM	<= X"0d";
		WGH		<= X"3ecccccd";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-14 Set : 0.5
		WGH_NUM	<= X"0e";
		WGH		<= X"3f000000";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-15 Set : 0.1
		WGH_NUM	<= X"0f";
		WGH		<= X"3dcccccd";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-16 Set : 0.2
		WGH_NUM	<= X"10";
		WGH		<= X"3e4ccccd";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-17 Set : 0.3
		WGH_NUM	<= X"11";
		WGH		<= X"3e99999a";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-18 Set : 0.4
		WGH_NUM	<= X"12";
		WGH		<= X"3ecccccd";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;
		
		-- Weight-19 Set : 0.5
		WGH_NUM	<= X"13";
		WGH		<= X"3f000000";
		WGH_SET	<= '1';
      wait for CLK_period;
		WGH_SET	<= '0';
      wait for CLK_period;

		TRIG	<= '1';
      wait for CLK_period;
		TRIG	<= '0';
		
      wait for 500 us;	
		
		assert false
		report "Sim Finished"
		severity failure;
		
      -- insert stimulus here 

      wait;
   end process;

END;
