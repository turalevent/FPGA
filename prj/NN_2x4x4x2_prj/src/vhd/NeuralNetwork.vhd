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
--              It takes Inputs Weights for each Neuron and computes the resultand Output. 
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

entity NeuralNetwork is
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
end NeuralNetwork;

architecture LvnT of NeuralNetwork is

	--
	-- Components
	--
	
	--
	-- Components
	--

	-- Hidden Layer
	--
	COMPONENT HiddenLayer
		GENERIC(
			NEURON_NUM : integer
		);
		PORT(
			CLK   	: in  std_logic;
			RST   	: in  std_logic;
			TRIG  	: in  std_logic;
			WGH_SET 	: in  std_logic;
			WGH_NUM	: in  std_logic_vector(7 downto 0);  
			WGH		: in  std_logic_vector(31 downto 0);  
			INPUT1	: in  std_logic_vector(31 downto 0);  
			INPUT2	: in  std_logic_vector(31 downto 0);  
			INPUT3	: in  std_logic_vector(31 downto 0);  
			INPUT4	: in  std_logic_vector(31 downto 0);  
			RDY		: out std_logic;
			OUTPUT1	: out std_logic_vector(31 downto 0);  
			OUTPUT2	: out std_logic_vector(31 downto 0); 
			OUTPUT3	: out std_logic_vector(31 downto 0);  
			OUTPUT4	: out std_logic_vector(31 downto 0)  
		);
	END COMPONENT;

	-- Output Layer
	--
	COMPONENT OutputLayer
		GENERIC(
			INPUT_NUM 	: integer;
			NEURON_NUM 	: integer
		);
		PORT(
			CLK   	: in  std_logic;
			RST   	: in  std_logic;
			TRIG  	: in  std_logic;
			WGH_SET 	: in  std_logic;
			WGH_NUM	: in  std_logic_vector(7 downto 0);  
			WGH		: in  std_logic_vector(31 downto 0);  
			INPUT1	: in  std_logic_vector(31 downto 0);  
			INPUT2	: in  std_logic_vector(31 downto 0);  
			INPUT3	: in  std_logic_vector(31 downto 0);  
			INPUT4	: in  std_logic_vector(31 downto 0);  
			RDY		: out std_logic;
			OUTPUT1	: out std_logic_vector(31 downto 0);  
			OUTPUT2	: out std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	-- 
	-- Types
	--
   
  
	--
	-- Constants
	--
	
	-- General
	constant High_c 				: std_logic := '1';
	constant Low_c  				: std_logic := '0';
	
	--
	-- Signals
	--	
	
	signal WghNum_s			: std_logic_vector(7 downto 0);
	signal Wgh_s				: std_logic_vector(31 downto 0);
	-- Hidden Layer-1
	signal HiddLyr1WghSet_s	: std_logic;
	signal HiddLyr1Rdy_s		: std_logic;
	signal HiddLyr1Out1_s	: std_logic_vector(31 downto 0);
	signal HiddLyr1Out2_s	: std_logic_vector(31 downto 0);
	signal HiddLyr1Out3_s	: std_logic_vector(31 downto 0);
	signal HiddLyr1Out4_s	: std_logic_vector(31 downto 0);
	-- Hidden Layer-1
	signal HiddLyr2WghSet_s	: std_logic;
	signal HiddLyr2Rdy_s		: std_logic;
	signal HiddLyr2Out1_s	: std_logic_vector(31 downto 0);
	signal HiddLyr2Out2_s	: std_logic_vector(31 downto 0);
	signal HiddLyr2Out3_s	: std_logic_vector(31 downto 0);
	signal HiddLyr2Out4_s	: std_logic_vector(31 downto 0);
	-- Output Layer
	signal OutLyrWghSet_s	: std_logic;
	
begin
    
	--
	-- Primitives ---------------------------------------------
	--

	--
	-- Components ---------------------------------------------
	--

	-- HddenLyr1_cmp component
	-- 
	HddenLyr1_cmp : HiddenLayer 
	GENERIC MAP(
		NEURON_NUM => 4
	)
	PORT MAP(
		CLK   	=> CLK,
		RST   	=> RST,
		TRIG  	=> TRIG,
		WGH_SET 	=> HiddLyr1WghSet_s,
		WGH_NUM	=> WGH_NUM,
		WGH		=> WGH,
		INPUT1	=>	INPUT1,
		INPUT2	=>	INPUT2,
		INPUT3	=>	INPUT3,
		INPUT4	=>	INPUT4,
		RDY		=> HiddLyr1Rdy_s,
		OUTPUT1	=> HiddLyr1Out1_s,
		OUTPUT2	=> HiddLyr1Out2_s,
		OUTPUT3	=> HiddLyr1Out3_s,
		OUTPUT4	=> HiddLyr1Out4_s
	);

	-- HddenLyr2_cmp component
	-- 
	HddenLyr2_cmp : HiddenLayer 
	GENERIC MAP(
		NEURON_NUM => 4
	)
	PORT MAP(
		CLK   	=> CLK,
		RST   	=> RST,
		TRIG  	=> HiddLyr1Rdy_s,
		WGH_SET 	=> HiddLyr2WghSet_s,
		WGH_NUM	=> WGH_NUM,
		WGH		=> WGH,
		INPUT1	=>	HiddLyr1Out1_s,
		INPUT2	=>	HiddLyr1Out2_s,
		INPUT3	=>	HiddLyr1Out3_s,
		INPUT4	=>	HiddLyr1Out4_s,
		RDY		=> HiddLyr2Rdy_s,
		OUTPUT1	=> HiddLyr2Out1_s,
		OUTPUT2	=> HiddLyr2Out2_s,
		OUTPUT3	=> HiddLyr2Out3_s,
		OUTPUT4	=> HiddLyr2Out4_s
	);

	-- OutLyr_cmp component
	-- 
	OutLyr_cmp : OutputLayer 
	GENERIC MAP(
		INPUT_NUM 	=> 4,
		NEURON_NUM 	=> 2
	)
	PORT MAP(
		CLK   	=> CLK,
		RST   	=> RST,
		TRIG  	=> HiddLyr2Rdy_s,
		WGH_SET 	=> OutLyrWghSet_s,
		WGH_NUM	=> WGH_NUM,
		WGH		=> WGH,
		INPUT1	=>	HiddLyr2Out1_s,
		INPUT2	=>	HiddLyr2Out2_s,
		INPUT3	=>	HiddLyr2Out3_s,
		INPUT4	=>	HiddLyr2Out4_s,
		RDY		=> RDY,
		OUTPUT1	=> OUTPUT1,
		OUTPUT2	=> OUTPUT2
	);

	
	--
	-- Logic --------------------------------------------------
	--
    
	-- Inputs
	--

	-- Outputs
	--
	
	-- InOuts
	--

	-- Internals
	--
	HiddLyr1WghSet_s	<= WGH_SET	when	WGH_LYR_NUM = "00" else
								'0';
	HiddLyr2WghSet_s	<= WGH_SET	when	WGH_LYR_NUM = "01" else
								'0';
	OutLyrWghSet_s		<= WGH_SET	when	WGH_LYR_NUM = "10" else
								'0';

end LvnT;

