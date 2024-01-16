--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:14:03 05/07/2015
-- Design Name:   
-- Module Name:   C:/prj/fpga/neuron/tb/Neuron_tbw.vhd
-- Project Name:  neuron
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Neuron
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
 
ENTITY Neuron_tbw IS
END Neuron_tbw;
 
ARCHITECTURE behavior OF Neuron_tbw IS 
 
  -- Component Declaration for the Unit Under Test (UUT)
  
  COMPONENT Neuron
  PORT(
    CLK 	: IN   std_logic;
    RST 	: IN   std_logic;
    TRIG 	: IN   std_logic;
    INPUT1: IN   std_logic_vector(31 downto 0);
    INPUT2: IN   std_logic_vector(31 downto 0);
    INPUT3: IN   std_logic_vector(31 downto 0);
    INPUT4: IN   std_logic_vector(31 downto 0);
    WGH1	: IN   std_logic_vector(31 downto 0);  
    WGH2	: IN   std_logic_vector(31 downto 0);  
    WGH3	: IN   std_logic_vector(31 downto 0);  
    WGH4	: IN   std_logic_vector(31 downto 0);  
    WGH5	: IN   std_logic_vector(31 downto 0);  
    RDY 	: OUT  std_logic;
    OUTPUT: OUT  std_logic_vector(31 downto 0)
  );
  END COMPONENT;
  
 --Inputs
 signal CLK 		: std_logic := '0';
 signal RST 		: std_logic := '0';
 signal TRIG 	  : std_logic := '0';
 signal INPUT1 	: std_logic_vector(31 downto 0) := X"3dcccccd"; -- 0.1
 signal INPUT2 	: std_logic_vector(31 downto 0) := X"3e4ccccd"; -- 0.2
 signal INPUT3 	: std_logic_vector(31 downto 0) := X"3e99999a"; -- 0.3
 signal INPUT4 	: std_logic_vector(31 downto 0) := X"3ecccccd"; -- 0.4
 signal WGH1 	  : std_logic_vector(31 downto 0) := X"3dcccccd"; -- 0.1
 signal WGH2 	  : std_logic_vector(31 downto 0) := X"3e4ccccd"; -- 0.2
 signal WGH3 	  : std_logic_vector(31 downto 0) := X"3e99999a"; -- 0.3
 signal WGH4 	  : std_logic_vector(31 downto 0) := X"3ecccccd"; -- 0.4
 signal WGH5 	  : std_logic_vector(31 downto 0) := X"3f000000"; -- 0.5

--Outputs
 signal RDY 		: std_logic;
 signal OUTPUT 	: std_logic_vector(31 downto 0);

 -- Clock period definitions
 constant CLK_period : time := 10 ns;

BEGIN
 
  -- Instantiate the Unit Under Test (UUT)
  uut: Neuron PORT MAP (
    CLK 		=> CLK,
    RST 		=> RST,
    TRIG 	  => TRIG,
    INPUT1 	=> INPUT1,
    INPUT2 	=> INPUT2,
    INPUT3 	=> INPUT3,
    INPUT4 	=> INPUT4,
    WGH1 	  => WGH1,
    WGH2 	  => WGH2,
    WGH3 	  => WGH3,
    WGH4 	  => WGH4,
    WGH5 	  => WGH5,
    RDY 		=> RDY,
    OUTPUT 	=> OUTPUT
  );
  
   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 
	RST <= '1', '0' after CLK_period*2;
	TRIG<= '0', '1' after CLK_period*5, '0' after CLK_period*6;

   -- Stimulus process
 stim_proc: process
 begin		
		
  wait for 100 us;	
		
  assert false
  report "Sim Finished"
  severity failure;
		
  -- insert stimulus here 

  wait;
 end process;

END;
