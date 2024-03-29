----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2023 02:58:54 AM
-- Design Name: 
-- Module Name: init_pattern_fail - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: non-working version of init_pattern
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--     How to not implement delay registers/buffering
--       BRAM read consumes 2 clock cycles, so any signals used in tandem
--       with the data output should be delayed by 2 clock cycles
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

entity init_pattern_fail is
  Port (
    i_clk   : in  STD_LOGIC;
    i_reset : in  STD_LOGIC;
    i_init  : in  STD_LOGIC;
    
    o_hsync : out STD_LOGIC;
    o_vsync : out STD_LOGIC;
    o_red   : out STD_LOGIC_VECTOR (3 downto 0);
    o_green : out STD_LOGIC_VECTOR (3 downto 0);
    o_blue  : out STD_LOGIC_VECTOR (3 downto 0)
  );
end init_pattern_fail;

architecture Behavioral of init_pattern_fail is
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
    
  signal rom_addr   : STD_LOGIC_VECTOR(12 downto 0); -- addr width dependent on number of total cells
  signal rom_dout   : STD_LOGIC_VECTOR(0 downto 0);
  signal rom_en     : STD_LOGIC;
  
  signal pattern_douta : STD_LOGIC_VECTOR(0 downto 0);
  signal pattern_addrb : STD_LOGIC_VECTOR(12 downto 0); -- addr width dependent on number of total cells
  signal pattern_doutb : STD_LOGIC_VECTOR(0 downto 0);
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
  
  -- ROM storing initial pattern
  rom_init: entity work.start_pattern
    port map(
      addra => rom_addr,
      clka  => i_clk,
      douta => rom_dout,
      ena   => rom_en
    );
    
  process(i_clk, i_init)
    constant ROM_MAX : UNSIGNED(rom_addr'range) := to_unsigned((FRAME_WIDTH * FRAME_HEIGHT)/(8*8), rom_addr'length);
    
    type t_init_state IS(idle, active, done);
    variable s_init : t_init_state := idle;
    
    variable rom_addr_counter : UNSIGNED(rom_addr'range);
  begin
    if(rising_edge(i_clk)) then
      if(s_init = idle) then
        if(i_init = '1') then
          rom_en <= '1';
          s_init := active;
        end if;
        rom_addr_counter := (others => '0');
      elsif(s_init = active) then
        if(rom_addr_counter < ROM_MAX) then
          rom_addr <= STD_LOGIC_VECTOR(rom_addr_counter);
          rom_addr_counter := rom_addr_counter + "1";
        else
          rom_en <= '0';
          s_init := done;
        end if;
      elsif(s_init = done) then
        if(i_init = '0') then
          s_init := idle;
        end if;
      end if;
    end if;
  end process;
  
  pattern: entity work.pattern_blk
    port map(
      addra  => rom_addr,
      clka   => i_clk,
      dina   => rom_dout, -- input from rom, game of life logic, and user input
      douta  => pattern_douta,
      ena    => rom_en,
      wea(0) => rom_en,
      addrb  => pattern_addrb,
      clkb   => pxl_clk,
      dinb   => "0",
      doutb  => pattern_doutb,
      enb    => active,
      web    => "0"
    );
    
  pattern_addrb <= std_logic_vector((unsigned(y_pos(V_BIT_WIDTH-1 downto 3)) * to_unsigned(FRAME_WIDTH/8, H_BIT_WIDTH-3)) + unsigned(x_pos(H_BIT_WIDTH-1 downto 3)));
  
  -- should fail since bad timings fail to load data into BRAM
  o_red   <= (others => pattern_doutb(0) and active);
  o_green <= (others => pattern_doutb(0) and active);
  o_blue  <= (others => pattern_doutb(0) and active);
end Behavioral;
