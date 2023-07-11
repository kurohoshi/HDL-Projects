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
--    -- https://surf-vhdl.com/how-to-implement-a-parallel-to-serial-converter/
--    -- https://forum.digikey.com/t/i2c-master-vhdl/12797
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- RESERVED ADDRESSES
--  ADDRESS  | RW | MODE |    DESCRIPT
-------------|----|------|-------------------
--  0000 000 |  0 |   4  | general call addr
--  0000 000 |  1 |   5  | START byte
--  0000 001 |  X |   1  | CBUS addr
--  0000 010 |  X |   2  | reserved bus format
--  0000 011 |  X |   3  | reserved
--  0000 1xx |  X |   0  | Hs-mode
--  1111 0XX |  1 |   6  | device ID
--  1111 1XX |  X |   7  | 10bit addr mode
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

entity i2c is
  Generic(
    CLK_DIV : INTEGER := 8
  );
  Port(
    i_clk   : in STD_LOGIC;
    i_reset : in STD_LOGIC;
    i_addr  : in STD_LOGIC_VECTOR(9 downto 0);
    i_xaddr : in STD_LOGIC; -- 7bit/10bit addressing
    i_din   : in STD_LOGIC_VECTOR(7 downto 0);
    o_dout  : out STD_LOGIC_VECTOR(7 downto 0);
    i_xbytes : in STD_LOGIC_VECTOR(3 downto 0); -- variable number of bytes to send (max 16)
    i_rw    : in STD_LOGIC;
    i_set   : in STD_LOGIC;
    o_busy  : out STD_LOGIC;
    o_ack_err : out STD_LOGIC;
    io_scl   : inout STD_LOGIC;
    io_sda   : inout STD_LOGIC
  );
end i2c;

architecture Behavioral of i2c is
  constant MAX_BYTES : INTEGER := 2**i_xbytes'length;

  type t_sda_state IS (idle, addr_send, addr_ack, data_write, data_read, data_write_ack, data_read_ack, stop_comm);
  signal s_i2c : t_sda_state;

  type t_scl_state IS (idle, active);
  signal s_scl : t_scl_state;

  signal r_set_delayed : STD_LOGIC;
  signal set_pulse   : STD_LOGIC;

  signal r_rw : STD_LOGIC;
  signal r_addr_rw : STD_LOGIC_VECTOR(i_addr'high+1 downto 0);
  signal r_din  : STD_LOGIC_VECTOR(i_din'range);
  signal r_dout : STD_LOGIC_VECTOR(o_dout'range);

  signal scl_clk_counter : INTEGER range 0 to CLK_DIV*2-1;
  -- signal scl_period : INTEGER range 0 to TOTAL_SCL_PERIODS+1;
  signal scl_en : STD_LOGIC;
  signal r_scl : STD_LOGIC;
  signal r_scl_delayed : STD_LOGIC;
  signal tx_sda : STD_LOGIC;
  signal rx_sda : STD_LOGIC;
  signal sda_pulse : STD_LOGIC;

  signal stop_pulse   : STD_LOGIC;
  signal num_bytes : INTEGER := to_integer(unsigned(i_xbytes));
  signal byte_counter : INTEGER range 0 to MAX_BYTES-1;
  signal sda_addr_bit : INTEGER range r_addr_rw'high+1 downto 0;
  signal sda_data_bit : INTEGER range r_din'high+1 downto 0;
  signal res_addr : STD_LOGIC;
  signal res_mode : STD_LOGIC_VECTOR(3 downto 0);
begin
  scl_gen: process(i_reset, i_clk)
  begin
    if(i_reset = '1') then
      scl_clk_counter <= 0;
      r_scl <= '0';
      sda_pulse <= '0';
    elsif(rising_edge(i_clk)) then
      sda_pulse <= '0';
      r_scl_delayed <= r_scl;

      if(s_scl = idle) then
        r_scl <= '0';
        if(set_pulse = '1') then
          sda_pulse <= '1';
          scl_clk_counter <= CLK_DIV;
          s_scl <= active;
        end if;
      elsif(s_scl = active) then
        if(scl_clk_counter = 0) then
          r_scl <= not r_scl;
          scl_clk_counter <= CLK_DIV*2-1;
        elsif(r_scl = '0' and io_scl = '0') then
          scl_clk_counter <= scl_clk_counter;
        else
          scl_clk_counter <= scl_clk_counter-1;
        end if;

        if(scl_clk_counter = CLK_DIV+1) then
          sda_pulse <= '1';
        end if;

        if(stop_pulse = '1') then
          s_scl <= idle;
        end if;
      else
        s_scl <= idle;
      end if;
    end if;
  end process;


  data_latch: process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      r_set_delayed <= i_set;
    end if;
  end process;
  
  set_pulse <= not r_set_delayed and i_set;


  sda_gen: process(i_reset, i_clk)
  begin
    if(i_reset = '1') then
      sda_addr_bit <= 0;
      sda_data_bit <= 0;
      byte_counter <= 0;
      tx_sda <= '1';
      o_ack_err <= '0';
    elsif(rising_edge(i_clk)) then
      stop_pulse <= '0';

      if(set_pulse = '1') then
        r_rw <= i_rw;
        r_addr_rw <= i_addr & i_rw;
        r_din  <= i_din;
        o_busy <= '1';

        if(i_addr(6 downto 3) = "0000") then
          res_addr <= '1';
          if(i_addr(2 downto 0) = "000") then
            res_mode <= "10" & i_rw; -- general call addr and START byte
          elsif(i_addr(2) = '1') then
            res_mode <= "000"; -- Hs-mode
          else
            res_mode <= i_addr(2 downto 0); -- CBUS and other reserved addresses
          end if;
        elsif(i_addr(6 downto 3) = "1111") then
          res_addr <= not i_addr(2) or i_rw;
          res_mode <= "11" & i_addr(2); -- device ID or 10bit addr
        else
          res_addr <= '0';
        end if;
      end if;
      
      if(sda_pulse = '1') then
        if(r_scl = '1') then
          if(s_i2c = addr_send) then
            if(sda_addr_bit = 0) then
              tx_sda <= '0';
            else
              tx_sda <= r_addr_rw(r_addr_rw'high);
              sda_addr_bit <= sda_addr_bit-1;
              r_addr_rw <= r_addr_rw(r_addr_rw'high-1 downto 0) & '0';
            end if;
          elsif(s_i2c = addr_ack) then
            
          elsif(s_i2c = data_write) then
            if(sda_data_bit = 0) then
              tx_sda <= '0';
            else
              tx_sda <= r_din(r_din'high);
              sda_data_bit <= sda_data_bit-1;
              r_din <= r_din(r_din'high-1 downto 0) & '0';
            end if;
          elsif(s_i2c = data_read) then

          elsif(s_i2c = data_read_ack) then
            tx_sda <= '0';
          elsif(s_i2c = stop_comm) then

          end if;
        else
          if(s_i2c = idle) then
              -- kicks off state machine with the first sda_pulse from set_pulse
              sda_addr_bit <= 8;
              sda_data_bit <= 8;
              byte_counter <= num_bytes-1;
              tx_sda <= '0';
              o_ack_err <= '0';
          elsif(s_i2c = addr_ack) then
            -- check if sda is acknowledged
            if(rx_sda = '0') then

            else
              o_ack_err <= '1';
              stop_pulse <= '1';
            end if;
          elsif(s_i2c = data_read) then
            r_dout <= r_dout(r_dout'high-1 downto 0) & rx_sda;
            
            if(sda_data_bit = 0) then
              -- send ACK/NACK sig here
            else
              sda_data_bit <= sda_data_bit-1;
            end if;
          elsif(s_i2c = data_write_ack) then
            -- check if sda is acknowledged
            if(rx_sda = '0') then
              if(byte_counter = 0) then -- 0 bytes left to process

              else
                byte_counter <= byte_counter-1;
              end if;
            else
              o_ack_err <= '1';
              stop_pulse <= '1';
            end if;
          elsif(s_i2c = stop_comm) then
            -- either send stop sig or start another transaction here
            o_dout <= r_dout;
            stop_pulse <= '1';
            tx_sda <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

  state_change: process(i_reset, i_clk)
  begin
    if(i_reset = '1') then
      s_i2c <= idle;
    elsif(rising_edge(i_clk)) then
      if(sda_pulse = '1') then
        if(r_scl = '1') then
          if(s_i2c = addr_send) then
            if(sda_addr_bit = 0) then
              s_i2c <= addr_ack;
            else
              s_i2c <= addr_send;
            end if;
          elsif(s_i2c = addr_ack) then
            
          elsif(s_i2c = data_write) then
            if(sda_data_bit = 0) then
              s_i2c <= data_write_ack;
            else
              s_i2c <= data_write;
            end if;
          elsif(s_i2c = data_read) then

          elsif(s_i2c = data_read_ack) then
            s_i2c <= stop_comm;
          elsif(s_i2c = stop_comm) then

          end if;
        else
          if(s_i2c = idle) then
              -- kicks off state machine with the first sda_pulse from set_pulse
              s_i2c <= addr_send;
          elsif(s_i2c = addr_ack) then
            -- check if sda is acknowledged
            if(rx_sda = '0') then
              if(r_rw = '0') then
                s_i2c <= data_write;
              else
                s_i2c <= data_read;
              end if;
            else
              s_i2c <= idle;
            end if;
          elsif(s_i2c = data_read) then
            if(sda_data_bit = 0) then
              -- send ACK/NACK sig here
              s_i2c <= data_read_ack;
            else
              s_i2c <= data_read;
            end if;
          elsif(s_i2c = data_write_ack) then
            -- check if sda is acknowledged
            if(rx_sda = '0') then
              if(byte_counter = 0) then -- 0 bytes left to process
                s_i2c <= stop_comm;
              else
                s_i2c <= data_write;
              end if;
            else
              s_i2c <= idle;
            end if;
          elsif(s_i2c = stop_comm) then
            -- either send stop sig or start another transaction here
            s_i2c <= idle;
          end if;
        end if;
      end if;
    end if;
  end process;

  io_scl <= '0' when r_scl = '1' else 'Z';
  io_sda <= '0' when tx_sda = '0' else 'Z';
  rx_sda <= '0' when io_sda = '0' else '1';
end Behavioral;
