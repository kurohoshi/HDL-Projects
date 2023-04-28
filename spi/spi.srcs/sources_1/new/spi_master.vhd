----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2023 05:03:59 PM
-- Design Name: 
-- Module Name: spi_master - Behavioral
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
--      https://github.com/nandland/spi-master
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_master is
  Generic(
    DATA_BITS : INTEGER := 8;
    CLKS_PER_HALF_SCLK: INTEGER := 2
  );
  Port(
    i_clk   : in  STD_LOGIC;
    i_init  : in  STD_LOGIC;
    i_reset : in  STD_LOGIC;
    
    i_mode  : in STD_LOGIC_VECTOR(1 downto 0);
    
    i_tx_data : in STD_LOGIC_VECTOR(7 downto 0);
    o_rx_data : out STD_LOGIC_VECTOR(7 downto 0);
    
    o_sclk : out STD_LOGIC;
    o_mosi : out STD_LOGIC;
    i_miso : in STD_LOGIC;
    o_select  : out STD_LOGIC
  );
end spi_master;

architecture Behavioral of spi_master is
  signal sclk_counter : INTEGER range 0 to CLKS_PER_HALF_SCLK;
  
  signal r_sclk : STD_LOGIC;
  signal r_en   : STD_LOGIC;
  signal en_pulse : STD_LOGIC;
  signal r_select : STD_LOGIC;
  signal r_sclk_edge_counter : INTEGER range 0 to DATA_BITS*2+1;
  
  signal r_tx_data : STD_LOGIC_VECTOR(i_tx_data'range);
  signal r_rx_data : STD_LOGIC_VECTOR(o_rx_data'range);
  signal r_tx_bit_counter : INTEGER range 0 to DATA_BITS-1;
  signal r_rx_bit_counter : INTEGER range 0 to DATA_BITS-1;
  
  signal sclk_pulse : STD_LOGIC;
  signal mosi_pulse : STD_LOGIC;
  signal miso_pulse : STD_LOGIC;
  
  alias cpol : STD_LOGIC is i_mode(1);
  alias cpha : STD_LOGIC is i_mode(0);
begin
  sclk_gen: process(i_clk, i_reset)
  begin
    if(i_reset = '1') then
      r_sclk <= cpol;
      sclk_counter <= 0;
      r_sclk_edge_counter <= 0;
    elsif(rising_edge(i_clk)) then
      sclk_counter <= 0;

      if(en_pulse = '1') then
        r_sclk <= cpol;
        sclk_counter <= CLKS_PER_HALF_SCLK-1;
        r_sclk_edge_counter <= DATA_BITS*2+1;
      else
        if(r_sclk_edge_counter /= 0) then
          if(sclk_counter = 0) then
            if(r_sclk_edge_counter > 1) then
              r_sclk <= not r_sclk;
              sclk_counter <= CLKS_PER_HALF_SCLK-1;
            end if;
            
            r_sclk_edge_counter <= r_sclk_edge_counter - 1;
          else
            sclk_counter <= sclk_counter - 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  r_select <= '0' when r_sclk_edge_counter /= 0 else '1';
  sclk_pulse <= '1' when sclk_counter = 0 and r_sclk_edge_counter > 1 else '0';
  mosi_pulse <= sclk_pulse and (r_sclk xor (i_mode(1) xor i_mode(0)));
  miso_pulse <= sclk_pulse and not (r_sclk xor (i_mode(1) xor i_mode(0)));
  
  data_reg: process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      r_en <= i_init;
      
      if(i_init = '1' and r_en = '0') then
        en_pulse <= '1';
        r_tx_data <= i_tx_data;
      else
        en_pulse <= '0';
      end if;
    end if;
  end process;
  
  MOSI_serialize: process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      if(en_pulse = '1') then
        r_tx_bit_counter <= 7;
      end if;

      if((en_pulse = '1' and cpha = '0') or mosi_pulse = '1') then
        if(not (cpha = '1' and r_sclk_edge_counter = DATA_BITS*2+1) and r_tx_bit_counter /= 0) then
          r_tx_bit_counter <= r_tx_bit_counter - 1;
        end if;
      end if;
    end if;
  end process;

  o_mosi <= r_tx_data(r_tx_bit_counter) when r_select = '0' else '0';
  
  MISO_read: process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      if(en_pulse = '1') then
        r_rx_bit_counter <= 7;
      end if;

      if(miso_pulse = '1' ) then
        r_rx_data(r_rx_bit_counter) <= i_miso;
        
        if(r_rx_bit_counter /= 0) then
          r_rx_bit_counter <= r_rx_bit_counter - 1;
        end if;
      end if;
    end if;
  end process;
  
  rx_data_out: process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      if(sclk_counter = 0 and r_sclk_edge_counter = 1) then
        o_rx_data <= r_rx_data;
      end if;  
    end if;
  end process;

  o_sclk <= r_sclk;
  o_select  <= r_select;
end Behavioral;
