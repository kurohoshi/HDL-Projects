----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2023 02:16:03 PM
-- Design Name: 
-- Module Name: vga_driver - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: VGA Drive Module
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Example VGA Timings (https://web.mit.edu/6.111/www/labkit/vga.shtml)
--                        |                 H                |                  V
--    Format    | Pxl Clk | Width | F Porch | Sync | B Porch | Height | F Porch | Sync | B Porch 
-- -------------|---------|-------|---------|------|---------|--------|---------|------|---------
-- 640x480p60   | 25.175  | 640   | 16      | 96   | 48      | 480    | 11      | 2    | 31
-- 640x480p72   | 31.500  | 640   | 24      | 40   | 128     | 480    | 9       | 3    | 28
-- 640x480p75   | 31.500  | 640   | 16      | 96   | 48      | 480    | 11      | 2    | 32
-- 640x480p85   | 36.000  | 640   | 32      | 48   | 112     | 480    | 1       | 3    | 25
-- 800x600p56   | 38.100  | 800   | 32      | 128  | 128     | 600    | 1       | 4    | 14
-- 800x600p60   | 40.000  | 800   | 40      | 128  | 88      | 600    | 1       | 4    | 23
-- 800x600p72   | 50.000  | 800   | 56      | 120  | 64      | 600    | 37      | 6    | 23
-- 800x600p75   | 49.500  | 800   | 16      | 80   | 160     | 600    | 1       | 2    | 21
-- 800x600p85   | 56.250  | 800   | 32      | 64   | 152     | 600    | 1       | 3    | 27
-- 1024x768p60  | 65.000  | 1024  | 24      | 136  | 160     | 768    | 3       | 6    | 29
-- 1024x768p70  | 75.000  | 1024  | 24      | 136  | 144     | 768    | 3       | 6    | 29
-- 1024x768p75  | 78.750  | 1024  | 16      | 96   | 176     | 768    | 1       | 3    | 28
-- 1024x768p85  | 94.500  | 1024  | 48      | 96   | 208     | 768    | 1       | 3    | 36
-- 1280x1024p60 | 108.00  | 1280  | 48      | 112  | 248     | 768    | 1       | 3    | 38
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

entity vga_driver is
  Generic (
    FRAME_WIDTH  : INTEGER := 640;
    FRAME_HEIGHT : INTEGER := 480;
    
    H_BACK_PORCH  : INTEGER := 48;
    H_FRONT_PORCH : INTEGER := 16;
    H_SYNC_PULSE  : INTEGER := 96;
    
    V_BACK_PORCH  : INTEGER := 31;
    V_FRONT_PORCH : INTEGER := 11;
    V_SYNC_PULSE  : INTEGER := 2
  );
  Port (
    i_pxl_clk : in  STD_LOGIC;
    i_reset   : in  STD_LOGIC;
    o_hsync   : out STD_LOGIC;
    o_vsync   : out STD_LOGIC;
    o_active  : out STD_LOGIC;
    -- There has to be a more elegant way to dynamically calculate the msb of bus
    o_xpos    : out STD_LOGIC_VECTOR (calc_bits_width(FRAME_WIDTH + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH)-1 downto 0);
    o_ypos    : out STD_LOGIC_VECTOR (calc_bits_width(FRAME_HEIGHT + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH)-1 downto 0));
end vga_driver;

architecture Behavioral of vga_driver is
  constant H_SYNC_POSITION_START : INTEGER := H_BACK_PORCH + FRAME_WIDTH + H_FRONT_PORCH;
  constant H_MAX : INTEGER := FRAME_WIDTH + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
  
  constant V_SYNC_POSITION_START  : INTEGER := V_BACK_PORCH + FRAME_HEIGHT + V_FRONT_PORCH;
  constant V_MAX  : INTEGER := FRAME_HEIGHT + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;
  
  signal h_counter : UNSIGNED(calc_bits_width(H_MAX)-1 downto 0);
  signal v_counter : UNSIGNED(calc_bits_width(V_MAX)-1 downto 0);
begin
  process(i_reset, i_pxl_clk)
  begin
    if(i_reset = '1') then
      h_counter <= (others => '0');
      v_counter <= (others => '0');
    elsif(rising_edge(i_pxl_clk)) then
      if(h_counter < H_MAX) then
        h_counter <= h_counter + 1;
      else
        h_counter <= (others => '0');
        if(v_counter < V_MAX) then
          v_counter <= v_counter + 1;
        else
          v_counter <= (others => '0');
        end if;
      end if;
    end if;
  end process;
  
  process(i_reset, i_pxl_clk)
  begin
    if(i_reset = '1') then
      o_active <= '0';
    elsif(h_counter >= H_BACK_PORCH and h_counter < H_BACK_PORCH + FRAME_WIDTH and v_counter >= V_BACK_PORCH and v_counter < V_BACK_PORCH + FRAME_HEIGHT) then
      o_active <= '1';
    else
      o_active <= '0';
    end if;
  
    if(i_reset = '1') then
      o_hsync <= '1';
    elsif(h_counter < H_SYNC_POSITION_START) then
      o_hsync <= '1';
    else
      o_hsync <= '0';
    end if;
    
    if(i_reset = '1') then
      o_vsync <= '1';
    elsif(v_counter < V_SYNC_POSITION_START) then
      o_vsync <= '1';
    else
      o_vsync <= '0';
    end if;

    o_xpos <= STD_LOGIC_VECTOR(h_counter);
    o_ypos <= STD_LOGIC_VECTOR(v_counter);
  end process;
  
  
end Behavioral;
