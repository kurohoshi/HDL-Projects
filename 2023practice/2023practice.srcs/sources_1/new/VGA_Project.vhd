----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2023 10:08:44 PM
-- Design Name: 
-- Module Name: init_pattern - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Simple module demonstrating initializing BRAM with a ROM
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--    -- Output via VGA signalling
--    -- Also demonstrating Clock Domain Crossing
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

entity VGA_Project is
  Port (
    i_clk   : in  STD_LOGIC;
    i_reset : in  STD_LOGIC;
    i_mode  : in  STD_LOGIC_VECTOR(1 downto 0);
    i_init  : in  STD_LOGIC;
    
    o_hsync : out STD_LOGIC;
    o_vsync : out STD_LOGIC;
    o_red   : out STD_LOGIC_VECTOR (3 downto 0);
    o_green : out STD_LOGIC_VECTOR (3 downto 0);
    o_blue  : out STD_LOGIC_VECTOR (3 downto 0)
  );
end VGA_Project;

architecture Behavioral of VGA_Project is
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
    
--  signal rom_addr   : STD_LOGIC_VECTOR(12 downto 0); -- addr width dependent on number of total cells
--  signal rom_dout   : STD_LOGIC_VECTOR(0 downto 0);
--  signal rom_en     : STD_LOGIC;
--  signal r_addr     : STD_LOGIC_VECTOR(12 downto 0);
--  signal r_data     : STD_LOGIC_VECTOR(0 downto 0);
--  signal r_en       : STD_LOGIC;
  
--  signal delayed_rom_en   : STD_LOGIC;
--  signal delayed_rom_addr : STD_LOGIC_VECTOR(12 downto 0);
  signal delayed_active   : STD_LOGIC;
  
--  signal pattern_douta : STD_LOGIC_VECTOR(0 downto 0);
  signal pattern_addrb : STD_LOGIC_VECTOR(12 downto 0); -- addr width dependent on number of total cells
  signal pattern_doutb : STD_LOGIC;
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
      active_buf(1) <= active;
      active_buf(0) <= active_buf(1);
    end if;
  end process;
  
  hsync_delay: entity work.shift_reg_array(Behavioral)
    generic map(
      WIDTH  => 1,
      LENGTH => 2
    )
    port map(
      i_clk     => i_clk,
      i_din(0)  => h_sync,
      o_dout(0) => o_hsync
    );
    
  vsync_delay: entity work.shift_reg_array(Behavioral)
    generic map(
      WIDTH  => 1,
      LENGTH => 2
    )
    port map(
      i_clk     => i_clk,
      i_din(0)  => v_sync,
      o_dout(0) => o_vsync
    );
    
  module_gameoflife: entity work.mem_gameoflife(Behavioral)
    port map(
--      i_addra  => , -- user selected addr
      i_clka     => i_clk,
--      i_dina   => , -- user data toggle?
--      o_douta  => , -- used only for game of life update cycle
--      i_ena      => , -- determined by internal state machine
--      i_wea      => , -- determined by internal state machine
      i_addrb    => pattern_addrb,
      i_clkb     => pxl_clk,
      o_doutb    => pattern_doutb,
      i_enb      => delayed_active,
      i_mode   => i_mode,
      i_init   => i_init
    );
    
  pattern_addrb <= std_logic_vector((unsigned(y_pos(V_BIT_WIDTH-1 downto 3)) * to_unsigned(FRAME_WIDTH/8, H_BIT_WIDTH-3)) + unsigned(x_pos(H_BIT_WIDTH-1 downto 3)));
  delayed_active <= active or active_buf(0) or active_buf(1); -- keep enabled for 2 extra clocks
  
  -- should be a black display until init button is pressed
  o_red   <= (others => pattern_doutb and delayed_active);
  o_green <= (others => pattern_doutb and delayed_active);
  o_blue  <= (others => pattern_doutb and delayed_active);
end Behavioral;
