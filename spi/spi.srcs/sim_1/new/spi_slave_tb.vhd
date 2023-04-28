----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2023 11:36:05 PM
-- Design Name: 
-- Module Name: spi_slave_tb - Behavioral
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

entity spi_slave_tb is
end spi_slave_tb;

architecture Behavioral of spi_slave_tb is
  constant MODE : INTEGER := 0;
  constant SCLK_PERIOD : TIME := 6ns;
  constant SIMO_DATA : STD_LOGIC_VECTOR(7 downto 0) := x"7a";

  constant MODE_SIG : STD_LOGIC_VECTOR(1 downto 0) := std_logic_vector(to_unsigned(MODE, 2));
  alias CPOL : STD_LOGIC is MODE_SIG(1);
  alias CPHA : STD_LOGIC is MODE_SIG(0);

  signal reset : STD_LOGIC := '0';

  signal sel_sig : STD_LOGIC := '1';
  signal sclk : STD_LOGIC := CPOL;
  signal somi : STD_LOGIC;
  signal simo : STD_LOGIC := '0';

  signal tx_data : STD_LOGIC_VECTOR(7 downto 0) := x"5c";
  signal rx_data : STD_LOGIC_VECTOR(7 downto 0);
begin
  dut: entity work.spi_slave(Behavioral)
    generic map(
      MODE => MODE
    )
    port map(
      i_reset   => reset,
      i_tx_data => tx_data,
      o_rx_data => rx_data,
      i_sclk    => sclk,
      i_simo    => simo,
      o_somi    => somi,
      i_select  => sel_sig
    );
  
  process
  begin
    wait for SCLK_PERIOD*5;

    reset <= '1';
    wait for SCLK_PERIOD*2;
    reset <= '0';
    wait for SCLK_PERIOD*2;

    sel_sig <= '0';
    wait for (SCLK_PERIOD)*SIMO_DATA'length+(SCLK_PERIOD/2);
    sel_sig <= '1';

    wait;
  end process;

  -- sclk signalling
  process
  begin
    wait until sel_sig = '0';

    wait for SCLK_PERIOD/2;

    for i in (SIMO_DATA'length*2)-1 downto 0 loop
      sclk <= not sclk;
      wait for SCLK_PERIOD/2;
    end loop;

    wait;
  end process;

  -- simo signalling
  process
  begin
    wait until sel_sig = '0';

    if(CPHA = '1') then
      wait for SCLK_PERIOD/2;
    end if;

    for i in SIMO_DATA'length-1 downto 0 loop
      simo <= SIMO_DATA(i);
      wait for SCLK_PERIOD;
    end loop;

    simo <= '0';
    wait for SCLK_PERIOD*1;
    wait;
  end process;
end Behavioral;
