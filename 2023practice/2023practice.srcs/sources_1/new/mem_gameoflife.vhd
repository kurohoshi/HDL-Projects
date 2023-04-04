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
    FRAME_WIDTH  : INTEGER := 640;
    FRAME_HEIGHT : INTEGER := 480;
    ADDR_WIDTH   : INTEGER := 13
  );
  Port(
    i_addra : in  STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
    i_clka  : in  STD_LOGIC;
    i_addrb : in  STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
    i_clkb  : in  STD_LOGIC;
    o_doutb : out STD_LOGIC;
    i_enb   : in  STD_LOGIC;
    i_mode  : in  STD_LOGIC_VECTOR (1 downto 0);
    i_set   : in  STD_LOGIC;
    i_reset : in  STD_LOGIC
  );
end mem_gameoflife;

architecture Behavioral of mem_gameoflife is
  constant MEM_DELAY      : INTEGER := 3;
  constant GOL_WIDTH      : INTEGER := FRAME_WIDTH/8;
  constant GOL_HEIGHT     : INTEGER := FRAME_HEIGHT/8;
  constant GOL_ADDR_WIDTH : INTEGER := calc_bits_width(GOL_WIDTH * GOL_HEIGHT);

  type t_state IS (idle, rom_active, user_active, gol_init, gol_load, gol_save, gol_end_load, gol_end_save, gol_done, done);
  signal s_gol : t_state := idle;

  signal gol_x : UNSIGNED(calc_bits_width(GOL_WIDTH)-1 downto 0);
  signal gol_y : UNSIGNED(calc_bits_width(GOL_HEIGHT)-1 downto 0);
  signal delayed_gol_x : STD_LOGIC_VECTOR(gol_x'range);
  signal delayed_gol_y : STD_LOGIC_VECTOR(gol_y'range);
  signal ren : STD_LOGIC;
  signal wen : STD_LOGIC;
  signal delayed_ren  : STD_LOGIC;
  signal delayed_wen1 : STD_LOGIC;
  signal delayed_wen2 : STD_LOGIC;
  signal s_flag : STD_LOGIC_VECTOR(i_mode'range);

  signal rom_addr : STD_LOGIC_VECTOR(GOL_ADDR_WIDTH-1 downto 0);
  signal delayed_rom_addr : STD_LOGIC_VECTOR(rom_addr'range);
  signal rom_addr_counter : UNSIGNED(rom_addr'range);
  signal rom_dout : STD_LOGIC;
  signal rom_en   : STD_LOGIC;

  signal user_din : STD_LOGIC;
  
  signal set_zero           : STD_LOGIC;
  signal delayed_set_zero   : STD_LOGIC;
  signal gol_in             : STD_LOGIC_VECTOR(0 DOWNTO 0);
  signal gol_buf_en         : STD_LOGIC;
  signal delayed_gol_buf_en : STD_LOGIC;
  signal buf_top_in, buf_mid_in    : STD_LOGIC_VECTOR(0 DOWNTO 0);
  signal buf_top_out, buf_mid_out  : STD_LOGIC_VECTOR(0 DOWNTO 0);
  signal cell_tl, cell_tm, cell_tr : UNSIGNED(0 DOWNTO 0);
  signal cell_ml, cell_mm, cell_mr : UNSIGNED(0 DOWNTO 0);
  signal cell_bl, cell_bm, cell_br : UNSIGNED(0 DOWNTO 0);
  signal gol_sum      : UNSIGNED(3 DOWNTO 0);
  signal gol_next_gen : STD_LOGIC;
  signal gol_addr                  : STD_LOGIC_VECTOR(GOL_ADDR_WIDTH-1 downto 0);
  signal gol_addr_read             : STD_LOGIC_VECTOR(GOL_ADDR_WIDTH-1 downto 0);
  signal gol_buf_addr_read         : STD_LOGIC_VECTOR(GOL_ADDR_WIDTH-1 downto 0);
  signal delayed_gol_buf_addr_read : STD_LOGIC_VECTOR(GOL_ADDR_WIDTH-1 downto 0);
  signal gol_addr_write            : STD_LOGIC_VECTOR(GOL_ADDR_WIDTH-1 downto 0);
  
  signal pattern_wea   : STD_LOGIC;
  signal pattern_addra : STD_LOGIC_VECTOR(GOL_ADDR_WIDTH-1 downto 0);
  signal pattern_dina  : STD_LOGIC;
  signal pattern_douta : STD_LOGIC;
begin
  master_fsm: process(i_reset, i_clka)
    constant ROM_MAX : UNSIGNED(rom_addr'range) := to_unsigned((GOL_WIDTH * GOL_HEIGHT), rom_addr'length);

    variable state_delay : UNSIGNED(1 downto 0) := "00";
  begin
    if(i_reset = '1') then
      gol_x <= (others => '0');
      gol_y <= (others => '0');
      rom_addr_counter <= (others => '0');
    elsif(rising_edge(i_clka)) then
      if(s_gol = idle) then
        if(i_set = '1') then
          if(i_mode = "01") then -- user mode
            ren <= '1';
            wen <= '1';
            s_gol <= user_active;
          elsif(i_mode = "11") then -- rom mode
            ren <= '1';
            wen <= '1';
            s_gol <= rom_active;
          else -- game of life mode
            ren <= '1';
            wen <= '0';
            set_zero <= '1';
            gol_buf_en <= '1';
            s_gol <= gol_init;
          end if;
          
          s_flag <= i_mode;
        end if;
      elsif(s_gol = gol_init) then -- initialize row -1
        if(gol_x < GOL_WIDTH+1) then
          gol_x <= gol_x + 1;
        else
          gol_x <= (others => '0');
          set_zero <= '0';
          s_gol <= gol_load;
        end if;
      elsif(s_gol = gol_load) then -- load into register
        if(gol_x > 0 and gol_y > 0) then
          wen <= '1';
        else
          wen <= '0';
        end if;
        
        gol_buf_en <= '0';
        s_gol <= gol_save;
      elsif(s_gol = gol_save) then -- write next gen into mem
        if(gol_x < GOL_WIDTH) then
          gol_x <= gol_x + 1;
          gol_buf_en <= '1';
          s_gol <= gol_load;
        else
          gol_x <= (others => '0');
          gol_y <= gol_y + 1;
          if(gol_y < GOL_HEIGHT-1) then
            gol_buf_en <= '1';
            s_gol <= gol_load;
          else
            ren <= '0';
            gol_buf_en <= '1';
            s_gol <= gol_end_load;
          end if;
        end if;

        if(gol_x = GOL_WIDTH-1 or gol_y = GOL_HEIGHT) then -- load 0 into register
          set_zero <= '1';
        else
          set_zero <= '0';
        end if;
        
        wen <= '0';
      elsif(s_gol = gol_end_load) then
        ren <= '1';
        wen <= '1';
        gol_buf_en <= '0';
        s_gol <= gol_end_save;
      elsif(s_gol = gol_end_save) then -- write last row of next gen into mem
        if(gol_x < GOL_WIDTH) then
          gol_x <= gol_x + 1;
          ren <= '0';
          wen <= '0';
          gol_buf_en <= '1';
          s_gol <= gol_end_load;
        else
          gol_x <= (others => '0');
          gol_y <= (others => '0');
          gol_buf_en <= '1';
          s_gol <= gol_done;
        end if;
      elsif(s_gol = gol_done) then -- finish writing last couple of cells into mem
        if(state_delay = MEM_DELAY) then
          ren <= '0';
          wen <= '0';
          set_zero <= '0';
          gol_buf_en <= '0';
          if(i_set = '0') then
            state_delay := "00";
            s_gol <= idle;
          end if;
        else
          state_delay := state_delay + 1;
        end if;
      elsif(s_gol = user_active) then -- essentially a pulse sig to write into mem
        wen <= '0';
        s_gol <= done;
      elsif(s_gol = rom_active) then
        if(rom_addr_counter < ROM_MAX-1) then
          rom_addr_counter <= rom_addr_counter + "1";
        else
          wen <= '0';
          rom_addr_counter <= (others => '0');
          s_gol <= done;
        end if;
      elsif(s_gol = done) then
        if(state_delay = MEM_DELAY-1) then
          ren <= '0';
          if(i_set = '0') then
            state_delay := "00";
            s_gol <= idle;
          end if;
        else
          state_delay := state_delay + 1;
        end if;
      end if;
    end if;
  end process;

  ren_delay: entity work.shift_reg_array(Behavioral)
    generic map(
      WIDTH  => 1,
      LENGTH => MEM_DELAY
    )
    port map(
      i_clk     => i_clka,
      i_din(0)  => ren,
      o_dout(0) => delayed_ren
    );

  wen_delay1: entity work.shift_reg_array(Behavioral)
    generic map(
      WIDTH  => 1,
      LENGTH => MEM_DELAY
    )
    port map(
      i_clk     => i_clka,
      i_din(0)  => wen,
      o_dout(0) => delayed_wen1
    );

  wen_delay2: entity work.shift_reg_array(Behavioral)
    generic map(
      WIDTH  => 1,
      LENGTH => 1
    )
    port map(
      i_clk     => i_clka,
      i_din(0)  => delayed_wen1,
      o_dout(0) => delayed_wen2
    );
    
  set_zero_delay: entity work.shift_reg_array(Behavioral)
    generic map(
      WIDTH  => 1,
      LENGTH => MEM_DELAY
    )
    port map(
      i_clk     => i_clka,
      i_din(0)  => set_zero,
      o_dout(0) => delayed_set_zero
    );
    
  gol_buf_en_delay: entity work.shift_reg_array(Behavioral)
    generic map(
      WIDTH  => 1,
      LENGTH => MEM_DELAY
    )
    port map(
      i_clk     => i_clka,
      i_din(0)  => gol_buf_en,
      o_dout(0) => delayed_gol_buf_en
    );
    
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
    
  rom_addr <= STD_LOGIC_VECTOR(rom_addr_counter);
  rom_en <= ren when s_flag = "11" else '0';
    
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
    
  ----------------
  -- User Input --
  ----------------
  user_din <= not pattern_douta;
  
  ------------------------
  -- Game of Life Logic --
  ------------------------
  gol_x_delay: entity work.shift_reg_array(Behavioral)
    generic map(
      WIDTH  => gol_x'length,
      LENGTH => MEM_DELAY
    )
    port map(
      i_clk  => i_clka,
      i_din  => STD_LOGIC_VECTOR(gol_x),
      o_dout => delayed_gol_x
    );
  
  gol_y_delay: entity work.shift_reg_array(Behavioral)
    generic map(
      WIDTH  => gol_y'length,
      LENGTH => MEM_DELAY
    )
    port map(
      i_clk  => i_clka,
      i_din  => STD_LOGIC_VECTOR(gol_y),
      o_dout => delayed_gol_y
    );

  gol_buf_top: entity work.shift_reg_en_array(Behavioral)
    generic map(
      WIDTH  => 1,
      LENGTH => GOL_WIDTH-1
    )
    port map(
      i_clk  => i_clka,
      i_en   => delayed_gol_buf_en,
      i_din  => buf_top_in,
      o_dout => buf_top_out
    );
    
  gol_buf_mid: entity work.shift_reg_en_array(Behavioral)
    generic map(
      WIDTH  => 1,
      LENGTH => GOL_WIDTH-1
    )
    port map(
      i_clk  => i_clka,
      i_en   => delayed_gol_buf_en,
      i_din  => buf_mid_in,
      o_dout => buf_mid_out
    );
    
  cell_tr <= unsigned(buf_top_out);
  buf_top_in <= STD_LOGIC_VECTOR(cell_ml);
  cell_mr <= unsigned(buf_mid_out);
  buf_mid_in <= STD_LOGIC_VECTOR(cell_bl);
  gol_in <= "0" when unsigned(delayed_gol_x) = GOL_WIDTH or unsigned(delayed_gol_y) = GOL_HEIGHT or delayed_set_zero = '1' else (others => pattern_douta);
  
  process(i_clka)
  begin
    if(rising_edge(i_clka)) then
      if(delayed_gol_buf_en = '1') then
        cell_br <= unsigned(gol_in);
        cell_bm <= cell_br;
        cell_bl <= cell_bm;
        
        cell_mm <= cell_mr;
        cell_ml <= cell_mm;
        
        cell_tm <= cell_tr;
        cell_tl <= cell_tm;
      end if;
    end if;
  end process;
  
  -- rules for next gen
  gol_sum <= "0000" + cell_tl + cell_tm + cell_tr + cell_ml + cell_mr + cell_bl + cell_bm + cell_br;
  gol_next_gen <= '1' when(gol_sum(3 downto 1) = "001") and ((gol_sum(0) = '1') or (cell_mm = "1")) else '0'; -- 2: same state, 3: live state, others: dead state

  --------------------------
  -- Game of Life Memory ---
  --------------------------
  pattern: entity work.pattern_blk
    port map(
      addra    => pattern_addra,
      clka     => i_clka,
      dina(0)  => pattern_dina,
      douta(0) => pattern_douta,
      ena      => ren,
      wea(0)   => pattern_wea,
      addrb    => i_addrb,
      clkb     => i_clkb,
      dinb     => "0",
      doutb(0) => o_doutb,
      enb      => i_enb,
      web      => "0"
    );

  with s_flag select 
    pattern_dina <= user_din when "01", -- user
      rom_dout when "11",               -- rom
      gol_next_gen when others;         -- gol
  
  with s_flag select
    pattern_addra <= i_addra when "01", -- user
      delayed_rom_addr when "11",       -- rom
      gol_addr when others;             -- gol
      
  with s_flag(0) select
    pattern_wea <= delayed_wen1 when '1', -- user and rom
      delayed_wen2 when others;           -- gol

  gol_addr_read  <= STD_LOGIC_VECTOR((unsigned(gol_y) * to_unsigned(GOL_WIDTH, gol_x'length)) + unsigned(gol_x));

  gol_buf_addr_read <= STD_LOGIC_VECTOR((unsigned(delayed_gol_y) * to_unsigned(GOL_WIDTH, delayed_gol_x'length)) + unsigned(delayed_gol_x)); -- can use gol_addr_read to carry addr to next stage
  gol_addr_write <= STD_LOGIC_VECTOR(unsigned(delayed_gol_buf_addr_read) - to_unsigned(GOL_WIDTH + 1, delayed_gol_buf_addr_read'length));
  gol_addr_write_delay: entity work.shift_reg_en_array(Behavioral)
    generic map(
      WIDTH  => gol_buf_addr_read'length,
      LENGTH => 1
    )
    port map(
      i_clk  => i_clka,
      i_en   => delayed_gol_buf_en,
      i_din  => gol_buf_addr_read,
      o_dout => delayed_gol_buf_addr_read
    );
  
  with delayed_wen2 select
    gol_addr <= gol_addr_read when '0', -- read addr
      gol_addr_write when others; -- write addr
end Behavioral;
