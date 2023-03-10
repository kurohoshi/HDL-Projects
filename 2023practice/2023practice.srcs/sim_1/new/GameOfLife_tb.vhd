----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/08/2023 01:25:22 PM
-- Design Name: 
-- Module Name: GameOfLife_tb - test
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

entity GameOfLife_tb is
end GameOfLife_tb;

architecture test of GameOfLife_tb is
  signal clk     : STD_LOGIC := '1';
  signal reset   : STD_LOGIC := '1';
  
  signal hsync : STD_LOGIC;
  signal vsync : STD_LOGIC;
  signal red   : STD_LOGIC_VECTOR(3 downto 0);
  signal green : STD_LOGIC_VECTOR(3 downto 0);
  signal blue  : STD_LOGIC_VECTOR(3 downto 0);
begin
  clk <= not clk after 1ns;

  dut: entity work.VGA_Project(White)
    port map(
      i_clk   => clk,
      i_reset => reset,
      o_hsync => hsync,
      o_vsync => vsync,
      o_red   => red,
      o_green => green,
      o_blue  => blue
    );
  
  process
  begin
    reset <= '0' after 10ns;
    wait for 1ms;
  end process;
end test;
