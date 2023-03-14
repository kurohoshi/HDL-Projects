----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/08/2023 09:44:54 PM
-- Design Name: 
-- Module Name: mem_tutorial - Behavioral
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

entity mem_tutorial is
  Port(
    i_clk  : in STD_LOGIC;
    i_addr : in STD_LOGIC_VECTOR (3 downto 0);
    i_en   : in STD_LOGIC;
    o_dout : out STD_LOGIC_VECTOR (7 downto 0)
  );
end mem_tutorial;

architecture Behavioral of mem_tutorial is
  type buffer_array is array(NATURAL range <>) of STD_LOGIC_VECTOR(3 downto 0);
  signal rom_buf : buffer_array(1 downto 0);
begin
  rom_init: entity work.small_rom
    port map(
      addra => i_addr,
      clka  => i_clk,
      douta => o_dout,
      ena   => i_en
    );
    
  process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      rom_buf(1) <= i_addr;
      rom_buf(0) <= rom_buf(1);
    end if;
  end process;
end Behavioral;
