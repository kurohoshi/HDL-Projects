----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/02/2023 04:03:12 PM
-- Design Name: 
-- Module Name: i2c - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Simple I2C interface to transfer a byte of data with 7-bit addressing
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
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity i2c is
  Generic(
    CLK_DIV : INTEGER := 8;
    BYTES : INTEGER := 1;
    EXTENDED_ADDRESSING : INTEGER := 0 -- 7bit/10bit addressing
  );
  Port(
    i_clk   : in STD_LOGIC;
    i_reset : in STD_LOGIC;
    i_addr  : in STD_LOGIC_VECTOR(EXTENDED_ADDRESSING*3+6 downto 0); -- hacky way to do 7bit/10bit addressing
    i_din   : in STD_LOGIC_VECTOR(BYTES*8-1 downto 0);
    o_dout  : out STD_LOGIC_VECTOR(BYTES*8-1 downto 0);
    i_rw    : in STD_LOGIC;
    i_set   : in STD_LOGIC;
    o_busy  : out STD_LOGIC;
    io_scl   : inout STD_LOGIC;
    io_sda   : inout STD_LOGIC
  );
end i2c;

architecture Behavioral of i2c is
  constant TOTAL_SCL_PERIODS : INTEGER := (BYTES+1)*9;

  type t_state IS (idle);
  signal s_i2c : t_state;

  signal r_set_delayed : STD_LOGIC;
  signal set_pulse   : STD_LOGIC;

  signal r_addr_rw : STD_LOGIC_VECTOR(i_addr'high+1 downto 0);
  signal r_din  : STD_LOGIC_VECTOR(i_din'range);

  signal scl_clk_counter : INTEGER range 0 to CLK_DIV*2-1;
  signal scl_period : INTEGER range 0 to TOTAL_SCL_PERIODS+1;
  signal r_scl : STD_LOGIC;
  signal r_scl_delayed : STD_LOGIC;
  signal r_sda : STD_LOGIC;
  signal sda_pulse : STD_LOGIC;

  signal sda_addr_bit : INTEGER i_addr'range;
begin
  scl_gen: process(i_reset, i_clk)
  begin
    if(i_reset = '1') then
      scl_clk_counter <= 0;
      scl_period <= 0;
      r_scl <= '1';
      sda_pulse <= '0';
    elsif(rising_edge(i_clk)) then
      sda_pulse <= '0';
      r_scl_delayed <= r_scl;

      if(set_pulse = '1') then
        sda_pulse <= '1';
        scl_clk_counter <= CLK_DIV;
        scl_period <= TOTAL_SCL_PERIODS+1;
      end if;

      if(scl_period /= 0 or scl_clk_counter /= 0) then
        if(scl_clk_counter = CLK_DIV+1) then
          sda_pulse <= '1';
        end if;

        if(scl_clk_counter = 0) then
          r_scl <= not r_scl;
          scl_clk_counter <= CLK_DIV*2-1;
          if(r_scl = '1') then
            scl_period <= scl_period-1;
          end if;
        elsif(r_scl = '1' and io_scl = '0') then -- stretch clk
          scl_clk_counter <= scl_clk_counter;
        else
          scl_clk_counter <= scl_clk_counter-1;
        end if;
      else
        r_scl <= '1';
      end if;
    end if;
  end process;

  data_latch: process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      r_set_delayed <= i_set;

      if(set_pulse = '1') then
        r_addr_rw <= i_addr & i_rw;
        r_din  <= i_din;
      end if;
    end if;
  end process;
  
  set_pulse <= not r_set_delayed and i_set;

  io_scl <= '0' when r_scl = '0'  else 'Z';
end Behavioral;
