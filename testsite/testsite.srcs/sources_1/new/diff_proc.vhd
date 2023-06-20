----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/19/2023 07:22:54 PM
-- Design Name: 
-- Module Name: diff_proc - Behavioral
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

entity diff_proc is
  Port (
    i_clk : in STD_LOGIC;
    i_in1 : in STD_LOGIC;
    i_in2 : in STD_LOGIC;
    o_out : out STD_LOGIC
  );
end diff_proc;

architecture Behavioral of diff_proc is
  signal cond1 : STD_LOGIC;
  signal cond2 : STD_LOGIC;

  signal sig11 : STD_LOGIC;
  signal sig12 : STD_LOGIC;

  signal sig21 : STD_LOGIC;
  signal sig22 : STD_LOGIC;
begin
  process (i_clk)
  begin
    if(rising_edge(i_clk)) then
      cond1 <= i_in1;
      cond2 <= i_in2;
    end if;
  end process;

  -- -- pure logic
  -- process
  -- begin
  --     sig11 <= cond1 and not cond2;
  -- end process;

  -- process
  -- begin
  --     sig12 <= not (cond1 and not cond2);
  -- end process;

  -- -- if statements
  -- process
  -- begin
  --   if(cond1 = '1' and cond2 = '0') then
  --     sig11 <= '1';
  --   else
  --     sig11 <= '0';
  --   end if;
  -- end process;

  -- process
  -- begin
  --   if(cond1 = '1' and cond2 = '0') then
  --     sig12 <= '0';
  --   else
  --     sig12 <= '1';
  --   end if;
  -- end process;

  -- if statements, flipping conditional statement to match
  process
  begin
    if(cond1 = '1' and cond2 = '0') then
      sig11 <= '1';
    else
      sig11 <= '0';
    end if;
  end process;

  process
  begin
    if(cond1 = '0' and cond2 = '1') then
      sig12 <= '1';
    else
      sig12 <= '0';
    end if;
  end process;

  -- -- combining both processes
  -- process
  -- begin
  --   if(cond1 = '1' and cond2 = '0') then
  --     sig12 <= '0';
  --     sig11 <= '1';
  --   else
  --     sig12 <= '1';
  --     sig11 <= '0';
  --   end if;
  -- end process;

  -- -- same as pure logic, but  outside of process
  -- sig21 <= i_in1 and not i_in2;
  -- sig22 <= not (i_in1 and not i_in2);

  -- o_out <= (sig11 xnor sig21) xor (sig12 xnor sig22);
  o_out <= sig11 xor sig12;
end Behavioral;
