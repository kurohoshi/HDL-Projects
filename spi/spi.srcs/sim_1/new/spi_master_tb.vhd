----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2023 11:36:05 PM
-- Design Name: 
-- Module Name: spi_master_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_master_tb is
end spi_master_tb;

architecture Behavioral of spi_master_tb is
  constant CLK_PERIOD  : TIME := 10ns;
  constant CLKS_PER_SCLK : INTEGER := 6;
  constant MISO_DATA : STD_LOGIC_VECTOR(7 downto 0) := x"7a";

  signal clk   : STD_LOGIC := '0';
  signal reset : STD_LOGIC := '0';
  signal sample : STD_LOGIC := '0';
  signal mode  : STD_LOGIC_VECTOR(1 downto 0) := "00";

  signal sclk : STD_LOGIC;
  signal mosi : STD_LOGIC;
  signal miso : STD_LOGIC := '0';

  signal tx_data : STD_LOGIC_VECTOR(7 downto 0) := x"5c";
  signal rx_data : STD_LOGIC_VECTOR(7 downto 0);
  signal sel_sig : STD_LOGIC;
begin
  clk <= not clk after CLK_PERIOD/2;

  dut: entity work.spi_master(Behavioral)
    generic map(
      CLKS_PER_HALF_SCLK => CLKS_PER_SCLK/2
    )
    port map(
      i_clk     => clk,
      i_init  => sample,
      i_reset   => reset,
      i_mode    => mode,
      i_tx_data => tx_data,
      o_sel    => sel_sig,
      o_rx_data => rx_data,
      o_sclk    => sclk,
      o_mosi    => mosi,
      i_miso    => miso
    );
  
  process
  begin
    wait for CLK_PERIOD*CLKS_PER_SCLK*3;

    reset <= '1';
    wait for CLK_PERIOD*2;
    reset <= '0';
    wait for CLK_PERIOD*2;

    sample <= '1';
    wait for CLK_PERIOD*(CLKS_PER_SCLK/2)*2;
    sample <= '0';
    
    wait;
  end process;

  -- miso signalling
  process
  begin
    wait until sel_sig = '1';

    if(mode(0) = '1') then
      wait for CLK_PERIOD*CLKS_PER_SCLK/2;
    end if;

    for i in MISO_DATA'length-1 downto 0 loop
      miso <= MISO_DATA(i);
      wait for CLK_PERIOD*CLKS_PER_SCLK;
    end loop;

    miso <= '0';
    wait for CLK_PERIOD*CLKS_PER_SCLK*1;
    wait;
  end process;
end Behavioral;
