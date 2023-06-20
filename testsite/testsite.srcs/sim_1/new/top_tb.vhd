----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/19/2023 07:23:25 PM
-- Design Name: 
-- Module Name: top_tb - Behavioral
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

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is
  constant CLK_PERIOD : TIME := 10ns;

  signal clk : STD_LOGIC := '0';
  signal in1 : STD_LOGIC := '0';
  signal in2 : STD_LOGIC := '0';
begin
  clk <= not clk after CLK_PERIOD/2;

  dut: entity work.top(Behavioral)
    port map(
      i_clk => clk,
      i_in1 => in1,
      i_in2 => in2
    );

  process
  begin
    wait for CLK_PERIOD*5;

    in1 <= '1';
    wait for CLK_PERIOD*2;
    in2 <= '1';
    wait for CLK_PERIOD*2;
    in1 <= '0';
    
    wait;
  end process;
end Behavioral;
