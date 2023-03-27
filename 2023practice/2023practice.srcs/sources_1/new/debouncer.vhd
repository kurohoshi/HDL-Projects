----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2023 10:11:52 PM
-- Design Name: 
-- Module Name: debouncer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Debouncing logic
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--     -- https://github.com/Digilent/Nexys-4-DDR-GPIO/blob/master/src/hdl/debouncer.vhd
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

entity debouncer is
  Generic (
    DEBOUNCE_CLKS : INTEGER := 2**16
  );
  Port (
    i_in : in STD_LOGIC;
    i_clk : in STD_LOGIC;
    o_out : out STD_LOGIC
  );
end debouncer;

architecture Behavioral of debouncer is
  constant COUNTER_MAX : INTEGER := DEBOUNCE_CLKS - 1;
  
  signal debounce_sig : STD_LOGIC := '0';
begin
  process(i_clk)
    variable counter : UNSIGNED(calc_bits_width(COUNTER_MAX)-1 downto 0);
  begin
    if(rising_edge(i_clk)) then
      if((i_in = '1') xor (debounce_sig = '1')) then
        if(counter = COUNTER_MAX) then
          debounce_sig <= i_in;
          counter := (others => '0');
        else
          counter := counter + 1;
        end if;
      else
        counter := (others => '0');
      end if;
    end if;
  end process;
  
  o_out <= debounce_sig;
end Behavioral;
