----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/03/2023 03:10:19 PM
-- Design Name: 
-- Module Name: vga_driver_tb - Behavioral
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

library work;
use work.utils.all;

entity vga_driver_tb is
end vga_driver_tb;

architecture test of vga_driver_tb is
  constant FRAME_WIDTH   : INTEGER := 640;
  constant FRAME_HEIGHT  : INTEGER := 480;
  constant H_BACK_PORCH  : INTEGER := 48;
  constant H_FRONT_PORCH : INTEGER := 16;
  constant H_SYNC_PULSE  : INTEGER := 96;
  constant V_BACK_PORCH  : INTEGER := 31;
  constant V_FRONT_PORCH : INTEGER := 11;
  constant V_SYNC_PULSE  : INTEGER := 2;
  
  constant H_BIT_WIDTH : INTEGER := calc_bits_width(FRAME_WIDTH);
  constant V_BIT_WIDTH : INTEGER := calc_bits_width(FRAME_HEIGHT);
               
  signal clk     : STD_LOGIC := '1';
  signal reset   : STD_LOGIC := '1';
  signal pxl_clk : STD_LOGIC;

  signal active : STD_LOGIC;
  signal h_sync : STD_LOGIC;
  signal v_sync : STD_LOGIC;
  signal x_pos  : STD_LOGIC_VECTOR(H_BIT_WIDTH-1 downto 0);
  signal y_pos  : STD_LOGIC_VECTOR(V_BIT_WIDTH-1 downto 0); 
begin
  -- make clock divider
  -- make BRAM module
  clk <= not clk after 1ns;
  
  pxl_clk_div: entity work.clk_div(Behavioral)
    generic map(
      DIV => 4
    )
    port map(
      i_reset => reset,
      i_clk   => clk,
      o_clk   => pxl_clk
    );
  
  dut: entity work.vga_driver(Behavioral)
    generic map(
      FRAME_WIDTH   => FRAME_WIDTH,
      FRAME_HEIGHT  => FRAME_HEIGHT,
      H_BACK_PORCH  => H_BACK_PORCH,
      H_FRONT_PORCH => H_FRONT_PORCH,
      H_SYNC_PULSE  => H_SYNC_PULSE,
      V_BACK_PORCH  => V_BACK_PORCH,
      V_FRONT_PORCH => V_FRONT_PORCH,
      V_SYNC_PULSE  => V_SYNC_PULSE
    )
    port map(
      i_pxl_clk => pxl_clk,
      i_reset   => reset,
      o_hsync   => h_sync,
      o_vsync   => v_sync,
      o_active  => active,
      o_xpos    => x_pos,
      o_ypos    => y_pos
    );

  reset <= '0' after 10ns;
  
  process
  begin
    wait until reset = '0';
    wait for 4ms;
  end process;
end test;
