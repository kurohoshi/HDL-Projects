----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2023 05:49:51 PM
-- Design Name: 
-- Module Name: init_pattern_tb - Test
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

entity init_pattern_tb is
end init_pattern_tb;

architecture test of init_pattern_tb is
  signal clk   : STD_LOGIC := '1';
  signal reset : STD_LOGIC := '1';
  signal init  : STD_LOGIC := '0';
  
  signal hsync : STD_LOGIC;
  signal vsync : STD_LOGIC;
  signal red   : STD_LOGIC_VECTOR(3 downto 0);
  signal green : STD_LOGIC_VECTOR(3 downto 0);
  signal blue  : STD_LOGIC_VECTOR(3 downto 0);
begin
  clk <= not clk after 5ns;

  dut: entity work.init_pattern
    port map(
      i_clk   => clk,
      i_reset => reset,
      i_init  => init,
      
      o_hsync => hsync,
      o_vsync => vsync,
      o_red   => red,
      o_green => green,
      o_blue  => blue
    );
    
    process
    begin
      wait for 100ns;
      reset <= '0';
      wait for 1ms;
      init <= '1';
--      wait for 1ns;
--      init <= '0';
      wait;
    end process;
end test;
