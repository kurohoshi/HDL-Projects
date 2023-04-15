----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2023 05:03:59 PM
-- Design Name: 
-- Module Name: spi_slave - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: SPI slave with local clock
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_slave is
  Generic(
    MODE : STD_LOGIC_VECTOR(1 downto 0) := "00"; -- keep as generic or move it to port?
    CLKS_PER_HALF_SCLK: INTEGER := 2
  );
  Port(
    i_clk     : in  STD_LOGIC;
    i_reset   : in  STD_LOGIC;
    
    i_tx_data : in STD_LOGIC_VECTOR(7 downto 0);
    o_rx_data : out STD_LOGIC_VECTOR(7 downto 0);
    
    i_sclk : in STD_LOGIC;
    i_simo : in STD_LOGIC;
    o_somi : out STD_LOGIC;
    i_select : in STD_LOGIC
  );
end spi_slave;

architecture Behavioral of spi_slave is
  signal sclk_counter : INTEGER range 0 to CLKS_PER_HALF_SCLK;
  signal r_select     : STD_LOGIC;
  signal select_pulse : STD_LOGIC;

  signal sclk_pulse : STD_LOGIC;
  signal simo_pulse : STD_LOGIC;
  signal somi_pulse : STD_LOGIC;
  
  signal r_tx_data : STD_LOGIC_VECTOR(i_tx_data'range);
  signal r_rx_data : STD_LOGIC_VECTOR(o_rx_data'range);
  signal r_tx_bit_counter : INTEGER range 0 to 7;
  signal r_rx_bit_counter : INTEGER range 0 to 7;
begin
  -- use mode to determine simo and somi pulse signals
  pulse_gen: process(i_clk, i_reset)
  begin
    if(i_reset = '1') then
      -- signals need reset?
    elsif(rising_edge(i_clk)) then
      if(i_select = '0') then
        if(sclk_counter = CLKS_PER_HALF_SCLK-1) then
          sclk_counter <= 0;
          sclk_pulse <= '1';
        else
          sclk_counter <= sclk_counter + 1;
          sclk_pulse <= '0';
        end if;
      end if;
    end if;
  end process;
   
  -- verify that this is correct
  simo_pulse <= sclk_pulse and (i_sclk xor (MODE(1) xor MODE(0)));
  somi_pulse <= sclk_pulse and not (i_sclk xor (MODE(1) xor MODE(0)));

  -- latch data when select sig drives low
  data_reg: process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      r_select <= i_select;
      
      if(i_select = '0' and r_select = '1') then
        r_tx_data <= i_tx_data;
      end if;
    end if;
  end process;
  
  select_pulse <= not i_select and r_select;

  -- send somi data
  SOMI_serialize: process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      if(i_select = '0') then
        if(select_pulse = '1' and MODE(0) = '0') then
          o_somi <= r_tx_data(7);
          r_tx_bit_counter <= 6;
        elsif(somi_pulse = '1') then
          o_somi <= r_tx_data(r_tx_bit_counter);
          r_tx_bit_counter <= r_tx_bit_counter - 1;
        end if;
      end if;
    end if;
  end process;
  
  -- receive simo data
  SIMO_read: process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      if(i_select = '0') then
        if(select_pulse = '1') then
          r_rx_bit_counter <= 7;
        elsif(simo_pulse = '1') then
          r_rx_data(r_rx_bit_counter) <= i_simo;
          r_rx_bit_counter <= r_rx_bit_counter - 1;
          if(r_rx_bit_counter = 0) then
            o_rx_data <= r_rx_data;
          end if;
        end if;
      end if;
    end if;
  end process;
end Behavioral;
