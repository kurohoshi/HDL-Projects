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
-- Description: Simple SPI slave without local clock
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--     -- https://surf-vhdl.com/spi-slave-vhdl-design/
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

entity spi_slave is
  Generic(
    DATA_BITS : INTEGER := 8;
    MODE : INTEGER := 0
  );
  Port(
    -- i_reset   : in  STD_LOGIC;
    
    i_tx_data : in STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
    o_rx_data : out STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
    
    i_sclk   : in STD_LOGIC;
    i_simo   : in STD_LOGIC;
    o_somi   : out STD_LOGIC;
    i_select : in STD_LOGIC
  );
end spi_slave;

architecture Behavioral of spi_slave is
  constant MODE_SIG : STD_LOGIC_VECTOR(1 downto 0) := std_logic_vector(to_unsigned(MODE, 2));
  constant CPOL : STD_LOGIC := MODE_SIG(1);
  constant CPHA : STD_LOGIC := MODE_SIG(0);
  
  signal r_tx_data : STD_LOGIC_VECTOR(i_tx_data'range);
  signal r_rx_data : STD_LOGIC_VECTOR(o_rx_data'range);
  signal r_tx_bit_counter : INTEGER range 0 to i_tx_data'length;
begin
  -- send somi data
  SOMI_serialize: process(i_sclk, i_select)
  begin
    if(falling_edge(i_select)) then
      r_tx_data <= i_tx_data;
      o_somi <= i_tx_data(DATA_BITS-1);

      if(CPHA = '0') then
        r_tx_bit_counter <= DATA_BITS-2;
      else
        r_tx_bit_counter <= DATA_BITS-1;
      end if;
    elsif(rising_edge(i_select)) then
      o_somi <= '0';
    elsif((rising_edge(i_sclk) and (CPOL xor CPHA) = '1') or (falling_edge(i_sclk) and (CPOL xor CPHA) = '0')) then
      o_somi <= r_tx_data(r_tx_bit_counter);

      if(r_tx_bit_counter /= 0) then
        r_tx_bit_counter <= r_tx_bit_counter - 1;
      end if;
    end if;
  end process;
  
  -- receive simo data
  SIMO_read: process(i_sclk, i_select)
  begin
    if((rising_edge(i_sclk) and (CPOL xor CPHA) = '0') or (falling_edge(i_sclk) and (CPOL xor CPHA) = '1')) then
      r_rx_data <= r_rx_data(r_rx_data'length-2 downto 0) & i_simo;
    elsif(rising_edge(i_select)) then
      o_rx_data <= r_rx_data;
    elsif(falling_edge(i_select)) then
      o_rx_data <= (others => '0');
    end if;
  end process;
end Behavioral;
