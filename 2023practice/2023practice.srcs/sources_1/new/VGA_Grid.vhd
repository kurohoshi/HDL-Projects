----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2023 01:48:30 PM
-- Design Name: 
-- Module Name: VGA_Grid - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Simple VGA display using ROM data output
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--      https://electronics.stackexchange.com/questions/209462/fpga-vga-driver-not-working
--      -- color signals should be driven low during hsync and vsync
--      --   since sync signals is used to calibrate color levels with color signals
--      --   therefore, output won't display properly if not accounted for
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

entity VGA_Grid is
  Port (
    i_clk   : in  STD_LOGIC;
    i_reset : in  STD_LOGIC;
    o_hsync : out STD_LOGIC;
    o_vsync : out STD_LOGIC;
    o_red   : out STD_LOGIC_VECTOR (3 downto 0);
    o_green : out STD_LOGIC_VECTOR (3 downto 0);
    o_blue  : out STD_LOGIC_VECTOR (3 downto 0)
  );
end VGA_Grid;

architecture Behavioral of VGA_Grid is
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
  
  signal pxl_clk : STD_LOGIC;
  
  signal active : STD_LOGIC;
  signal h_sync : STD_LOGIC;
  signal v_sync : STD_LOGIC;
  signal x_pos  : STD_LOGIC_VECTOR(H_BIT_WIDTH-1 downto 0);
  signal y_pos  : STD_LOGIC_VECTOR(V_BIT_WIDTH-1 downto 0);
  
  signal active_buf : STD_LOGIC_VECTOR(1 downto 0);
  signal hsync_buf  : STD_LOGIC_VECTOR(1 downto 0);
  signal vsync_buf  : STD_LOGIC_VECTOR(1 downto 0);
    
  signal rom_addr   : STD_LOGIC_VECTOR(12 downto 0); -- addr width dependent on number of total cells
  signal rom_dout   : STD_LOGIC_VECTOR(0 downto 0);
  signal delayed_active : STD_LOGIC;
begin
  -- generate pixel clock, this determines the framerate of video output
  pxl_clk_gen: entity work.clk_wiz_0
    port map(
      reset    => i_reset,
      clk_in1  => i_clk,
      clk_out1 => pxl_clk
    );
  
  -- drive VGA signals
  vga_driver: entity work.vga_driver(Behavioral)
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
      i_reset   => i_reset,
      o_hsync   => h_sync,
      o_vsync   => v_sync,
      o_active  => active,
      o_xpos    => x_pos,
      o_ypos    => y_pos
    );
  
  -- shift register to buffer 2 clock cycles
  process(pxl_clk)
  begin
    if(rising_edge(pxl_clk)) then
      hsync_buf(1) <= h_sync;
      hsync_buf(0) <= hsync_buf(1);
      o_hsync <= hsync_buf(0);
      vsync_buf(1) <= v_sync;
      vsync_buf(0) <= vsync_buf(1);
      o_vsync <= vsync_buf(0);
      active_buf(1) <= active;
      active_buf(0) <= active_buf(1);
    end if;
  end process;
  
  -- ROM storing initial pattern
  rom_init: entity work.start_pattern
    port map(
      addra => rom_addr,
      clka  => pxl_clk,
      douta => rom_dout,
      ena   => delayed_active
    );

  rom_addr <= std_logic_vector((unsigned(y_pos(V_BIT_WIDTH-1 downto 3)) * to_unsigned(FRAME_WIDTH/8, H_BIT_WIDTH-3)) + unsigned(x_pos(H_BIT_WIDTH-1 downto 3)));
  delayed_active <= active or active_buf(0) or active_buf(1); -- keep enabled for 2 extra clocks
  
  -- should be static grid of black/white cells
  o_red   <= (others => rom_dout(0) and delayed_active);
  o_green <= (others => rom_dout(0) and delayed_active);
  o_blue  <= (others => rom_dout(0) and delayed_active);
end Behavioral;
