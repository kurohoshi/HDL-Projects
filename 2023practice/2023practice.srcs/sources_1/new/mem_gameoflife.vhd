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
--     -- https://github.com/hrvach/Life_MiSTer
--     --   A suitable implementation with a few flaws, the last column is incorrectly computed with an offsetted 3rd column of the neighbors down/up one row.
--     --   This can be corrected with a 0 buffer at the end of each row for no horzontal wraparound, or
--     --   a state machine to insert the correct cell at the end and beginning of each row (uses only 1 register, updated per row) for wraparound
--     --   
--     --   Similarly, vertical wraparound can be achieved by taking some cycles to load the last row into buffer first and load first row a 2nd time
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
    FRAME_HEIGHT  : INTEGER := 480;
    ADDR_WIDTH    : INTEGER := 13
  );
  Port(
    i_addra : in  STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
    i_clka  : in  STD_LOGIC;
    i_addrb : in  STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
    i_clkb  : in  STD_LOGIC;
    o_doutb : out STD_LOGIC;
    i_enb   : in  STD_LOGIC;
    i_mode  : in  STD_LOGIC_VECTOR (1 downto 0);
    i_set   : in  STD_LOGIC
  );
end mem_gameoflife;

architecture Behavioral of mem_gameoflife is
  constant GOL_WIDTH      : INTEGER := FRAME_WIDTH/8;
  constant GOL_HEIGHT     : INTEGER := FRAME_HEIGHT/8;
  constant GOL_ADDR_WIDTH : INTEGER := calc_bits_width(GOL_WIDTH * GOL_HEIGHT);

  signal gol_x : UNSIGNED(calc_bits_width(GOL_WIDTH)-1 downto 0);
  signal gol_y : UNSIGNED(calc_bits_width(GOL_HEIGHT)-1 downto 0);
  signal ren   : STD_LOGIC;
  signal wen   : STD_LOGIC;

  signal rom_addr : STD_LOGIC_VECTOR(GOL_ADDR_WIDTH-1 downto 0);
  signal rom_dout : STD_LOGIC;
  signal rom_en   : STD_LOGIC;
  
  signal delayed_rom_en   : STD_LOGIC;
  signal delayed_rom_addr : STD_LOGIC_VECTOR(GOL_ADDR_WIDTH-1 downto 0);
  
  signal user_din         : STD_LOGIC;
  signal delayed_user_wen : STD_LOGIC;
  
  signal gol_buf_en         : STD_LOGIC;
  signal delayed_gol_buf_en : STD_LOGIC;
  signal buf_top_out, buf_mid_out: STD_LOGIC_VECTOR(0 DOWNTO 0);
  signal cell_tl, cell_tm, cell_tr : UNSIGNED(0 DOWNTO 0);
  signal cell_ml, cell_mm, cell_mr : UNSIGNED(0 DOWNTO 0);
  signal cell_bl, cell_bm, cell_br : UNSIGNED(0 DOWNTO 0);
  signal gol_next_gen       : STD_LOGIC;
  
  signal pattern_addra : STD_LOGIC_VECTOR(GOL_ADDR_WIDTH-1 downto 0);
  signal pattern_dina  : STD_LOGIC;
  signal pattern_douta : STD_LOGIC;
begin
  process(i_clka, i_set)
    constant ROM_MAX : UNSIGNED(rom_addr'range) := to_unsigned((GOL_WIDTH * GOL_HEIGHT), rom_addr'length);
    
    type t_init_state IS(idle, rom_active, user_active, gol_init, gol_load, gol_save, done);
    variable s_gol : t_init_state := idle;
    
    variable rom_addr_counter : UNSIGNED(rom_addr'range);
  begin
    if(rising_edge(i_clka)) then
      if(s_gol = idle) then
        if(i_mode(0) = '0' and i_set = '1') then -- game of life mode
          ren <= '1';
          wen <= '0';
          s_gol := gol_load;
        elsif(i_mode = "01" and i_set = '1' ) then -- user mode
          ren <= '1';
          wen <= '1';
          s_gol := user_active;
        elsif(i_mode = "11" and i_set = '1') then -- rom mode
          ren <= '1';
          wen <= '1';
          s_gol := rom_active;
        end if;
        rom_addr_counter := (others => '0');
      elsif(s_gol = gol_load) then
        if(gol_x > 2 and gol_y > 0) then -- "greater than" takes care of cell offset, x delay of 2 from mem read
          wen <= '1';
          s_gol := gol_save;
        else
          if(gol_x <= GOL_WIDTH) then
            gol_x <= gol_x + 1;
          else
            gol_x <= (others => '0');
            if(gol_y <= GOL_HEIGHT) then
              gol_y <= gol_y + 1;
            else
              gol_y <= (others => '0');
            end if;
          end if;
        end if;
      elsif(s_gol = gol_save) then
        if(gol_x <= GOL_WIDTH) then
          gol_x <= gol_x + 1;
          wen <= '0';
          s_gol := gol_load;
        else
          gol_x <= (others => '0');
          if(gol_y <= GOL_HEIGHT) then
            gol_y <= gol_y + 1;
            wen <= '0';
            s_gol := gol_load;
          else
            gol_y <= (others => '0');
            ren <= '0';
            wen <= '0';
            s_gol := done;
          end if;
        end if;
      elsif(s_gol = user_active) then -- essentially a pulse sig to write into mem
        ren <= '0';
        wen <= '0';
        s_gol := done;
      elsif(s_gol = rom_active) then -- iterate thru entire rom and load into mem
        if(rom_addr_counter < ROM_MAX) then
          rom_addr <= STD_LOGIC_VECTOR(rom_addr_counter);
          rom_addr_counter := rom_addr_counter + "1";
        else
          ren <= '0';
          wen <= '0';
          s_gol := done;
        end if;
      elsif(s_gol = done) then
        if(i_set = '0') then
          s_gol := idle;
        end if;
      end if;
    end if;
  end process;

  ---------
  -- ROM --
  ---------
  rom_init: entity work.start_pattern
    port map(
      addra    => rom_addr,
      clka     => i_clka,
      douta(0) => rom_dout,
      ena      => rom_en
    );
    
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
  
  ----------------
  -- User Input --
  ----------------
  user_wen_delay: entity work.shift_reg_array(Behavioral)
    generic map(
      WIDTH  => 1,
      LENGTH => 2
    )
    port map(
      i_clk     => i_clka,
      i_din(0)  => wen,
      o_dout(0) => delayed_user_wen
    );
  
  user_din <= not pattern_douta;
  
  ------------------------
  -- Game of Life Logic --
  ------------------------
  gol_buf_top: entity work.shift_reg_en_array(Behavioral)
    generic map(
      WIDTH  => 1,
      LENGTH => GOL_WIDTH-1
    )
    port map(
      i_clk     => i_clka,
      i_en      => delayed_gol_buf_en, -- something that signals a shift in data
      i_din(0)  => std_logic(cell_ml(0)), -- the middle left cell
      o_dout    => buf_top_out  -- the top right cell
    );
    
  gol_buf_mid: entity work.shift_reg_en_array(Behavioral)
    generic map(
      WIDTH  => 1,
      LENGTH => GOL_WIDTH-1
    )
    port map(
      i_clk     => i_clka,
      i_en      => delayed_gol_buf_en, -- something that signals a shift in data
      i_din(0)  => std_logic(cell_bl(0)), -- the bottom left cell
      o_dout    => buf_mid_out  -- the middle right cell
    );
    
  cell_tr <= unsigned(buf_top_out);
  cell_mr <= unsigned(buf_mid_out);
    
  gol_buf_en_delay: entity work.shift_reg_array(Behavioral)
    generic map(
      WIDTH  => 1,
      LENGTH => 2
    )
    port map(
      i_clk     => i_clka,
      i_din(0)  => gol_buf_en,
      o_dout(0) => delayed_gol_buf_en
    );
    
  gol_buf_en <= not i_mode(0) and not wen;
  
  process -- rules for next gen
    variable gol_sum : UNSIGNED(3 downto 0);
  begin
    gol_sum := "0000" + cell_tl + cell_tm + cell_tr + cell_ml + cell_mm + cell_mr + cell_bl + cell_bm + cell_br; -- might need to resize cell bus width
    if(gol_sum(3 downto 1) = "001") then -- either sum of 2 or 3
      gol_next_gen <= '1';
    else
      gol_next_gen <= '0';
    end if;
  end process;
  
  --------------------------
  -- Game of Life Memory ---
  --------------------------
  pattern: entity work.pattern_blk
    port map(
      addra    => pattern_addra,
      clka     => i_clka,
      dina(0)  => pattern_dina, -- input from rom, game of life logic, and user input
      douta(0) => pattern_douta,
      ena      => delayed_rom_en,
      wea(0)   => delayed_rom_en,
      addrb    => i_addrb,
      clkb     => i_clkb,
      dinb     => "0",
      doutb(0) => o_doutb,
      enb      => i_enb,
      web      => "0"
    );
    
  process(i_mode, wen) -- addr and din mux
    variable gol_addr : UNSIGNED(GOL_ADDR_WIDTH-1 downto 0) := gol_x * gol_y;
  begin
    if(i_mode = "01") then -- user mode
      pattern_dina <= user_din;
      pattern_addra <= i_addra;
    elsif(i_mode = "11") then -- rom mode
      pattern_dina <= rom_dout;
      pattern_addra <= delayed_rom_addr;
    else -- game of life mode
      pattern_dina <= gol_next_gen;
      if(wen = '1') then
        pattern_addra <= std_logic_vector(gol_addr - to_unsigned(GOL_WIDTH + 3, GOL_ADDR_WIDTH));
      else
        pattern_addra <= std_logic_vector(gol_addr);
      end if;
    end if;
  end process;
end Behavioral;
