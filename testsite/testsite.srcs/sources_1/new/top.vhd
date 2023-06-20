----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/19/2023 07:22:54 PM
-- Design Name: 
-- Module Name: top - Behavioral
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

entity top is
  Port (
    i_clk : in STD_LOGIC;
    o_out : out STD_LOGIC
  );
end top;

architecture Behavioral of top is
  signal in1 : STD_LOGIC;
  signal in2 : STD_LOGIC;
begin
  process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      in1 <= not in1;
      if(in1 = '0') then
        in2 <= not in2;
      end if;
    end if;
  end process;

  test_module: entity work.diff_proc(Behavioral)
    port map(
      i_clk => i_clk,
      i_in1 => in1,
      i_in2 => in2,
      o_out => o_out
    );
end Behavioral;
