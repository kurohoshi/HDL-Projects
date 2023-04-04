----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/03/2023 08:50:39 PM
-- Design Name: 
-- Module Name: VGA_Shell - Behavioral
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

entity VGA_Shell is
  Port (
    i_clk   : in STD_LOGIC;
    i_reset : in STD_LOGIC;
    i_mode  : in STD_LOGIC_VECTOR (1 downto 0);
    i_set   : in STD_LOGIC;
    
    i_up    : in STD_LOGIC;
    i_down  : in STD_LOGIC;
    i_left  : in STD_LOGIC;
    i_right : in STD_LOGIC;
    
    o_hsync : out STD_LOGIC;
    o_vsync : out STD_LOGIC;
    o_red   : out STD_LOGIC_VECTOR (3 downto 0);
    o_green : out STD_LOGIC_VECTOR (3 downto 0);
    o_blue  : out STD_LOGIC_VECTOR (3 downto 0)
  );
end VGA_Shell;

architecture Behavioral of VGA_Shell is
  signal debounced_set   : STD_LOGIC;
  signal debounced_up    : STD_LOGIC;
  signal debounced_down  : STD_LOGIC;
  signal debounced_left  : STD_LOGIC;
  signal debounced_right : STD_LOGIC;
begin
  -- debounce all mechanical inputs
  set_debounce: entity work.debouncer(Behavioral)
    port map(
      i_in  => i_set,
      i_clk => i_clk,
      o_out => debounced_set
    );
    
  up_debounce: entity work.debouncer(Behavioral)
    port map(
      i_in  => i_up,
      i_clk => i_clk,
      o_out => debounced_up
    );
    
  down_debounce: entity work.debouncer(Behavioral)
    port map(
      i_in  => i_down,
      i_clk => i_clk,
      o_out => debounced_down
    );
    
  left_debounce: entity work.debouncer(Behavioral)
    port map(
      i_in  => i_left,
      i_clk => i_clk,
      o_out => debounced_left
    );
    
  right_debounce: entity work.debouncer(Behavioral)
    port map(
      i_in  => i_right,
      i_clk => i_clk,
      o_out => debounced_right
    );

  main_module: entity work.VGA_Project(Behavioral)
    port map(
      i_clk   => i_clk,
      i_reset => i_reset,
      i_mode  => i_mode,
      i_set   => debounced_set,

      i_up    => debounced_up,
      i_down  => debounced_down,
      i_left  => debounced_left,
      i_right => debounced_right,

      o_hsync => o_hsync,
      o_vsync => o_vsync,
      o_red   => o_red,
      o_green => o_green,
      o_blue  => o_blue
    );
end Behavioral;
