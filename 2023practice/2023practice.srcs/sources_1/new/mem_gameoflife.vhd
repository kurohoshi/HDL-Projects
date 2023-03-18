----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2023 10:08:44 PM
-- Design Name: 
-- Module Name: mem_gameoflife - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.utils.all;

entity mem_gameoflife is
  Generic(
    FRAME_WIDTH   : INTEGER := 640;
    FRAME_HEIGHT  : INTEGER := 480
  );
  Port(
--    i_addra  : in  STD_LOGIC_VECTOR (12 downto 0);
    i_clka   : in  STD_LOGIC;
--    i_dina   : in  STD_LOGIC;
--    o_douta  : out STD_LOGIC;
--    i_ena    : in  STD_LOGIC;
--    i_wea    : in  STD_LOGIC;
    i_addrb  : in  STD_LOGIC_VECTOR (12 downto 0);
    i_clkb   : in  STD_LOGIC;
    o_doutb  : out STD_LOGIC;
    i_enb    : in  STD_LOGIC;
    i_mode   : in  STD_LOGIC_VECTOR (1 downto 0);
    i_init  : in  STD_LOGIC
  );
end mem_gameoflife;

architecture Behavioral of mem_gameoflife is
  signal rom_addr   : STD_LOGIC_VECTOR(12 downto 0); -- addr width dependent on number of total cells
  signal rom_dout   : STD_LOGIC_VECTOR(0 downto 0);
  signal rom_en     : STD_LOGIC;
  signal r_addr     : STD_LOGIC_VECTOR(12 downto 0);
  signal r_data     : STD_LOGIC_VECTOR(0 downto 0);
  signal r_en       : STD_LOGIC;
  
  signal delayed_rom_en   : STD_LOGIC;
  signal delayed_rom_addr : STD_LOGIC_VECTOR(12 downto 0);
  
  signal pattern_douta : STD_LOGIC_VECTOR(0 downto 0);
  signal pattern_addrb : STD_LOGIC_VECTOR(12 downto 0); -- addr width dependent on number of total cells
  signal pattern_doutb : STD_LOGIC_VECTOR(0 downto 0);
begin
  -- ROM storing initial pattern
  rom_init: entity work.start_pattern
    port map(
      addra => rom_addr,
      clka  => i_clka,
      douta => rom_dout,
      ena   => rom_en
    );
    
  process(i_clka, i_init)
    constant ROM_MAX : UNSIGNED(rom_addr'range) := to_unsigned((FRAME_WIDTH * FRAME_HEIGHT)/(8*8), rom_addr'length);
    
    type t_init_state IS(idle, active, done);
    variable s_init : t_init_state := idle;
    
    variable rom_addr_counter : UNSIGNED(rom_addr'range);
  begin
    if(rising_edge(i_clka)) then
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
    
  rom_addr_delay: entity work.shift_reg_array(Behavioral)
    generic map(
      WIDTH  => rom_addr'length,
      LENGTH => 2
    )
    port map(
      i_clk  => i_clka,
      i_din  => rom_addr,
      o_dout => delayed_rom_addr
    );
    
  rom_en_delay: entity work.shift_reg_array(Behavioral)
    generic map(
      WIDTH  => 1,
      LENGTH => 2
    )
    port map(
      i_clk     => i_clka,
      i_din(0)  => rom_en,
      o_dout(0) => delayed_rom_en
    );
    
  pattern: entity work.pattern_blk
    port map(
      addra    => delayed_rom_addr,
      clka     => i_clka,
      dina     => rom_dout, -- input from rom, game of life logic, and user input
      douta    => pattern_douta,
      ena      => delayed_rom_en,
      wea(0)   => delayed_rom_en,
      addrb    => i_addrb,
      clkb     => i_clkb,
      dinb     => "0",
      doutb(0) => o_doutb,
      enb      => i_enb,
      web      => "0"
    );
end Behavioral;
