----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/14/2023 09:21:07 PM
-- Design Name: 
-- Module Name: IEEE754_Adder_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bin_divider_tb is
--  Port ( );
end bin_divider_tb;
  
architecture Behavioral of bin_divider_tb is

  COMPONENT bin_divider
    PORT(
      CLK	  : in  std_logic;
      RST	  : in  std_logic;
      A		  : in  std_logic_vector(31 downto 0);
      B		  : in  std_logic_vector(31 downto 0);
      EN    : in  std_logic;
      NAN   : out std_logic;
      INF   : out std_logic;
      READY : out std_logic;
      Q_RES : out std_logic_vector(31 downto 0);
      F_RES : out std_logic_vector(31 downto 0)
    );
  end COMPONENT;
  
   --Inputs
   signal CLK   : std_logic := '0';
   signal RST   : std_logic := '0';
   signal EN    : std_logic := '0';

 	--Outputs
   signal INF   : std_logic := '0';
   signal NAN   : std_logic := '0';
   signal READY : std_logic := '0';
   signal Q_RES : std_logic_vector(31 downto 0);
   signal F_RES : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;

   constant cTestInA : std_logic_vector(31 downto 0) := X"008CCCCD";
   constant cTestInB : std_logic_vector(31 downto 0) := X"00866666";
  
begin

  UUT: bin_divider
    PORT MAP(
      CLK	  => CLK,
      RST	  => RST,
      A     => cTestInA,
      B     => cTestInB,
      EN    => EN,
      INF   => INF,
      NAN   => NAN,
      READY => READY,
      Q_RES	=> Q_RES,
      F_RES	=> F_RES
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
 
end Behavioral;
