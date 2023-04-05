----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2023 09:50:09 PM
-- Design Name: 
-- Module Name: pulser - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


library work;
use work.utils.all;

entity pulser is
  Generic(
    PERIOD : INTEGER := 100
  );
  Port(
    i_en    : in STD_LOGIC;
    i_clk   : in STD_LOGIC;
    o_pulse : out STD_LOGIC
  );
end pulser;

architecture Behavioral of pulser is
  constant MAX : INTEGER := PERIOD * 100000;
  
  signal counter : UNSIGNED(calc_bits_width(MAX)-1 downto 0);
begin
  process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      if(i_en = '0') then
        counter <= (others => '0');
      else
        if(counter < MAX-1) then
          counter <= counter + 1;
        else
          counter <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  o_pulse <= '1' when counter = MAX-1 else '0';
end Behavioral;
