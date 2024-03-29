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
    i_set   : in  STD_LOGIC;
    
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
  constant MEM_WIDTH      : INTEGER := FRAME_WIDTH/8;
  constant MEM_HEIGHT     : INTEGER := FRAME_HEIGHT/8;
  constant MEM_ADDR_WIDTH : INTEGER := calc_bits_width(MEM_WIDTH) + calc_bits_width(MEM_HEIGHT);
  
  signal pxl_clk : STD_LOGIC;
  
  signal pulse_en  : STD_LOGIC;
  signal pulse_set : STD_LOGIC;
  
  signal user_addr : STD_LOGIC_VECTOR(MEM_ADDR_WIDTH-1 downto 0);
  
  signal active : STD_LOGIC;
  signal h_sync : STD_LOGIC;
  signal v_sync : STD_LOGIC;
  signal x_pos  : STD_LOGIC_VECTOR(H_BIT_WIDTH-1 downto 0);
  signal y_pos  : STD_LOGIC_VECTOR(V_BIT_WIDTH-1 downto 0);
  
  signal active_buf : STD_LOGIC_VECTOR(1 downto 0);
    
  signal delayed_active : STD_LOGIC;
  
  signal pattern_set   : STD_LOGIC;
  signal pattern_addrb : STD_LOGIC_VECTOR(MEM_ADDR_WIDTH-1 downto 0);
  signal delayed_pattern_addrb : STD_LOGIC_VECTOR(MEM_ADDR_WIDTH-1 downto 0);
  signal pattern_doutb : STD_LOGIC;
  
  signal u_cursor : STD_LOGIC;
begin
  -- generate pixel clock, this determines the framerate of video output
  pxl_clk_gen: entity work.clk_wiz_0
    port map(
      reset    => i_reset,
      clk_in1  => i_clk,
      clk_out1 => pxl_clk
    );
    
  pulse_gen: entity work.pulser(Behavioral)
    port map(
      i_en    => pulse_en,
      i_clk   => i_clk,
      o_pulse => pulse_set
    );
  
  pulse_en <= '1' when i_mode = "10" else '0';
    
  -- user input
  user_ctrl: entity work.User_Control(Behavioral)
    port map(
      i_clk   => i_clk,
      i_reset => i_reset,
      i_mode  => i_mode,
      i_up    => i_up,
      i_down  => i_down,
      i_left  => i_left,
      i_right => i_right,
      o_addr  => user_addr
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
    
  addrb_delay: entity work.shift_reg_array(Behavioral)
    generic map(
      WIDTH  => pattern_addrb'length,
      LENGTH => 2
    )
    port map(
      i_clk  => pxl_clk,
      i_din  => pattern_addrb,
      o_dout => delayed_pattern_addrb
    );
    
  module_gol: entity work.mem_gameoflife(Behavioral)
    port map(
      i_addra => user_addr,
      i_clka  => i_clk,
      i_addrb => pattern_addrb,
      i_clkb  => pxl_clk,
      o_doutb => pattern_doutb,
      i_enb   => delayed_active,
      i_mode  => i_mode,
      i_set   => pattern_set,
      i_reset => i_reset
    );
    
  pattern_set <= pulse_set when i_mode = "10" else i_set;
    
  pattern_addrb <= std_logic_vector((unsigned(y_pos(y_pos'high downto 3)) * to_unsigned(FRAME_WIDTH/8, H_BIT_WIDTH-3)) + unsigned(x_pos(x_pos'high downto 3)));
  delayed_active <= active or active_buf(0) or active_buf(1); -- keep enabled for 2 extra clocks

  -- should be a black display until init button is pressed
  u_cursor <= '1' when user_addr = delayed_pattern_addrb and i_mode = "01" else '0';
  o_red   <= (others => active_buf(0) and (pattern_doutb or u_cursor));
  o_green <= (others => active_buf(0) and pattern_doutb and not u_cursor);
  o_blue  <= (others => active_buf(0) and pattern_doutb and not u_cursor);
end Behavioral;
