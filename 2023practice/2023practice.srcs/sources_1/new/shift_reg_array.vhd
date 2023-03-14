----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2023 10:06:34 PM
-- Design Name: 
-- Module Name: shift_reg_array - Behavioral
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
--    -- https://vhdlwhiz.com/shift-register/
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

entity shift_reg_array is
  Generic (
    WIDTH  : INTEGER := 1;
    LENGTH : INTEGER := 2
  );
  Port (
    i_clk : in STD_LOGIC;
    i_din  : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    o_dout : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
  );
end shift_reg_array;

architecture Behavioral of shift_reg_array is
  type shifter is array(LENGTH-1 downto 0) of STD_LOGIC_VECTOR(i_din'range);
  signal arr_data : shifter;
begin
  process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      arr_data(0) <= i_din;
      if(LENGTH > 1) then
        for i in arr_data'low+1 to arr_data'high loop
          arr_data(i) <= arr_data(i-1);
        end loop;
      end if;
    end if;
  end process;

  o_dout <= arr_data(arr_data'high);
end Behavioral;
