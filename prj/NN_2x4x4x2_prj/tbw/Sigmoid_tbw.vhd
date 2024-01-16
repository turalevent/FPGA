--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:10:50 05/05/2015
-- Design Name:   
-- Module Name:   C:/prj/fpga/sigmoid/tb/Sigmoid_tbw.vhd
-- Project Name:  sigmoid
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Sigmoid
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
 
ENTITY Sigmoid_tbw IS
END Sigmoid_tbw;
 
ARCHITECTURE behavior OF Sigmoid_tbw IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Sigmoid
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         TRIG : IN  std_logic;
         INPUT : IN  std_logic_vector(31 downto 0);
         RDY : OUT  std_logic;
         OUTPUT : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal TRIG : std_logic := '0';
   signal INPUT : std_logic_vector(31 downto 0) := X"c0200000";	-- floating point : -2.5

	-- Sigmoid calculation
	--
	--        1          In
	-- Out = --- * [ ---------- + 1 ]
	--        2       1 + |In|
	--
	-- TEST RESULTS
	-- In = -2.5 ------------------
	-- Expec. Out = 0.142
	-- Calc.  Out = 0.1428
	-- In = 5.6 -------------------
	-- Expec. Out = 0.92
	-- Calc.  Out = 0.9242
	-- In = 0.1 -------------------
	-- Expec. Out = 0.54
	-- Calc.  Out = 0.5454
	-- In = 0.5 -------------------
	-- Expec. Out = 0.66
	-- Calc.  Out = 0.6666667
	
 	--Outputs
   signal RDY : std_logic;
   signal OUTPUT : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Sigmoid PORT MAP (
          CLK => CLK,
          RST => RST,
          TRIG => TRIG,
          INPUT => INPUT,
          RDY => RDY,
          OUTPUT => OUTPUT
        );

	RST <= '1', '0' after CLK_period*2;
	TRIG<= '0', '1' after CLK_period*5, '0' after CLK_period*6;

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
		
      wait for 5 us;	
		
		assert false
		report "Sim Finished"
		severity failure;
		
      -- insert stimulus here 

      wait;
   end process;

END;
