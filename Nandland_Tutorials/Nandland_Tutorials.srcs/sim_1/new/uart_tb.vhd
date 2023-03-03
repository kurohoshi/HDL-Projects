----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2023 12:32:00 PM
-- Design Name: 
-- Module Name: uart_tb - test
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Simple test inputting multiple serial data into UART receiver.
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

entity uart_tb is
end uart_tb;

architecture test of uart_tb is
  constant CLK_FREQ   : INTEGER := 100_000_000;
  constant BAUD_RATE  : INTEGER := 115200;
  constant DATA_WIDTH : INTEGER := 8;
  constant PARITY     : INTEGER := 0;
  constant STOP_WIDTH : INTEGER := 1;
  constant BAUD_CLK   : INTEGER := CLK_FREQ/BAUD_RATE;

  signal clk    : STD_LOGIC := '0';
  signal reset  : STD_LOGIC := '1';
  signal serial : STD_LOGIC := '1';
  signal data   : STD_LOGIC_VECTOR(7 downto 0);
  
  constant ARRAY_SIZE : INTEGER := 2;
  type DATA_ARRAY is array(INTEGER range <>) of STD_LOGIC_VECTOR(7 downto 0);
  constant data_in : DATA_ARRAY(ARRAY_SIZE-1 downto 0) := ((x"35"),(x"9b"));
begin
  clk <= not clk after 1ns;
  
  dut: entity work.uart(BehavioralSimple)
    generic map(
      CLK_FREQ   => CLK_FREQ,
      BAUD_RATE  => BAUD_RATE,
      DATA_WIDTH => DATA_WIDTH,
      PARITY     => PARITY,
      STOP_WIDTH => STOP_WIDTH
    )
    port map(
      i_clk => clk,
      i_rx_serial => serial,
      i_reset => reset,
      o_rx_data => data
    );

  reset <= '0' after 10ns;
  
  process
  begin
    wait until reset <= '0';
    wait for BAUD_CLK*2ns;

    for i in 0 to ARRAY_SIZE-1 loop
      serial <= '0';
      wait for BAUD_CLK*2ns;
      
      for j in 0 to 7 loop
        serial <= data_in(i)(j);
        wait for BAUD_CLK*2ns;
      end loop;
      
      serial <= '1';
      wait for 10*BAUD_CLK*2ns;
      
      report "Input Data=" & to_hstring(data_in(i)) & "   Output Data=" & to_hstring(data);
    end loop;
  end process;
end test;


