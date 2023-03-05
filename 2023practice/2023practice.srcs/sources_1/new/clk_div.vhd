----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/04/2023 10:57:42 PM
-- Design Name: 
-- Module Name: clk_div - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Clock Divider
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

entity clk_div is
  Generic (
    DIV : INTEGER := 2
  );
  Port (
    i_reset : in STD_LOGIC;
    i_clk   : in STD_LOGIC;
    o_clk   : out STD_LOGIC
  );
end clk_div;

architecture Behavioral of clk_div is
  signal div_clk : STD_LOGIC;
begin
  process(i_clk)
    variable counter : INTEGER := 0;
    
  begin
    if(i_reset = '1') then
      counter := 0;
      div_clk <= '0';
    elsif(i_clk'EVENT) then
      if(counter < DIV-1) then
        counter := counter + 1;
      else
        div_clk <= not div_clk;
        counter := 0;
      end if;
    end if;
  end process;

  o_clk <= div_clk;
end Behavioral;
