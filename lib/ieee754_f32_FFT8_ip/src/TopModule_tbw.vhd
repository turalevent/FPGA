--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:20:06 11/24/2017
-- Design Name:   
-- Module Name:   D:/Projects/FPGA/ise/prj/FFT/exam1/FFTexam1/sim/TopModule_tbw.vhd
-- Project Name:  FFTexam1
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

  COMPONENT f32_FFT8
  PORT(
     CLK	: IN  std_logic;
     RST 	: IN  std_logic;
     EN   : in  std_logic;
     x0 	: IN  std_logic_vector(31 downto 0);
     x1 	: IN  std_logic_vector(31 downto 0);
     x2 	: IN  std_logic_vector(31 downto 0);
     x3 	: IN  std_logic_vector(31 downto 0);
     x4 	: IN  std_logic_vector(31 downto 0);
     x5 	: IN  std_logic_vector(31 downto 0);
     x6 	: IN  std_logic_vector(31 downto 0);
     x7 	: IN  std_logic_vector(31 downto 0);
     X0R 	: OUT  std_logic_vector(31 downto 0);
     X0I 	: OUT  std_logic_vector(31 downto 0);
     X1R 	: OUT  std_logic_vector(31 downto 0);
     X1I 	: OUT  std_logic_vector(31 downto 0);
     X2R 	: OUT  std_logic_vector(31 downto 0);
     X2I 	: OUT  std_logic_vector(31 downto 0);
     X3R 	: OUT  std_logic_vector(31 downto 0);
     X3I 	: OUT  std_logic_vector(31 downto 0);
     X4R 	: OUT  std_logic_vector(31 downto 0);
     X4I 	: OUT  std_logic_vector(31 downto 0);
     X5R 	: OUT  std_logic_vector(31 downto 0);
     X5I 	: OUT  std_logic_vector(31 downto 0);
     X6R 	: OUT  std_logic_vector(31 downto 0);
     X6I 	: OUT  std_logic_vector(31 downto 0);
     X7R 	: OUT  std_logic_vector(31 downto 0);
     X7I 	: OUT  std_logic_vector(31 downto 0);
    READY  : out std_logic;
    NAN    : out std_logic;
    INF    : out std_logic
  );
  END COMPONENT;
  
  --Inputs
  signal CLK 	: std_logic := '0';
  signal RST 	: std_logic := '0';
  signal EN 	  : std_logic;
  signal READY : std_logic;
  signal NAN 	: std_logic;
  signal INF 	: std_logic;
  signal x0 	  : std_logic_vector(31 downto 0) :=  X"bfa00000";		-- -1.25
  signal x1 	  : std_logic_vector(31 downto 0) :=  X"3f8f5c29";		-- 1.12
  signal x2 	  : std_logic_vector(31 downto 0) :=  X"402ccccd";		-- 2.7
  signal x3 	  : std_logic_vector(31 downto 0) :=  X"c0000000";		-- -2
  signal x4 	  : std_logic_vector(31 downto 0) :=  X"3fc00000";		-- 1.5
  signal x5 	  : std_logic_vector(31 downto 0) :=  X"3f75c28f";		-- 0.96
  signal x6 	  : std_logic_vector(31 downto 0) :=  X"3f4ccccd";		-- 0.8
  signal x7 	  : std_logic_vector(31 downto 0) :=  X"3e800000";		-- 0.25
  
  --Outputs
  signal X0R 	: std_logic_vector(31 downto 0);
  signal X0I 	: std_logic_vector(31 downto 0);
  signal X1R 	: std_logic_vector(31 downto 0);
  signal X1I 	: std_logic_vector(31 downto 0);
  signal X2R 	: std_logic_vector(31 downto 0);
  signal X2I 	: std_logic_vector(31 downto 0);
  signal X3R 	: std_logic_vector(31 downto 0);
  signal X3I 	: std_logic_vector(31 downto 0);
  signal X4R 	: std_logic_vector(31 downto 0);
  signal X4I 	: std_logic_vector(31 downto 0);
  signal X5R 	: std_logic_vector(31 downto 0);
  signal X5I 	: std_logic_vector(31 downto 0);
  signal X6R 	: std_logic_vector(31 downto 0);
  signal X6I 	: std_logic_vector(31 downto 0);
  signal X7R 	: std_logic_vector(31 downto 0);
  signal X7I 	: std_logic_vector(31 downto 0);
  
  -- Clock period definitions
  constant CLK_period : time := 10 ns;
  
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
  uut: f32_FFT8 
  PORT MAP (
    CLK 	=> CLK,
    RST 	=> RST,
    EN    => EN,
    x0 	  => x0,
    x1 	  => x1,
    x2 	  => x2,
    x3 	  => x3,
    x4 	  => x4,
    x5 	  => x5,
    x6 	  => x6,
    x7 	  => x7,
    X0R 	=> X0R,
    X0I 	=> X0I,
    X1R 	=> X1R,
    X1I 	=> X1I,
    X2R 	=> X2R,
    X2I 	=> X2I,
    X3R 	=> X3R,
    X3I 	=> X3I,
    X4R 	=> X4R,
    X4I 	=> X4I,
    X5R 	=> X5R,
    X5I 	=> X5I,
    X6R 	=> X6R,
    X6I 	=> X6I,
    X7R 	=> X7R,
    X7I 	=> X7I,
    READY => READY,
    NAN   => NAN,
    INF   => INF
  );
	
	RST <= '1', '0' after CLK_period*2;
	EN  <= '0', '1' after CLK_period*5, '0' after CLK_period*6;
	
  -- Clock process definitions
  CLK_process :process
  begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
  end process;
 
END;
