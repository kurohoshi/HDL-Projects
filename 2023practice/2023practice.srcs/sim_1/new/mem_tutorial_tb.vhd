----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/08/2023 09:46:18 PM
-- Design Name: 
-- Module Name: mem_tutorial_tb - test
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

entity mem_tutorial_tb is
--  Port ( );
end mem_tutorial_tb;

architecture test of mem_tutorial_tb is
  signal clk  : STD_LOGIC := '1';
  signal addr : STD_LOGIC_VECTOR(3 downto 0);
  signal en   : STD_LOGIC;
  signal dout : STD_LOGIC_VECTOR(7 downto 0);
begin
  clk <= not clk after 1ns;

  dut: entity work.mem_tutorial(Behavioral)
    port map(
      i_clk  => clk,
      i_addr => addr,
      i_en   => en,
      o_dout => dout
    );
    
    
    
    process
    begin
      en <= '1' after 10ns;
      addr <= "0000";
      wait for 4ns;
      addr <= "0001";
      wait for 4ns;
      addr <= "0010";
      wait for 4ns;
      addr <= "0011";
      wait for 4ns;
      addr <= "0100";
      wait for 4ns;
      addr <= "0101";
      wait for 4ns;
      en <= '0';
      addr <= "0110";
      wait for 10ns;
      addr <= "0111";
      wait for 10ns;
      addr <= "1000";
      wait for 10ns;
      addr <= "1001";
      wait for 10ns;
      addr <= "1010";
      wait for 10ns;
      addr <= "1011";
      wait for 10ns;
      addr <= "1100";
      wait for 10ns;
      addr <= "1101";
      wait for 10ns;
      addr <= "1110";
      wait for 10ns;
      addr <= "1111";
      wait for 10ns;
    end process;

end test;
