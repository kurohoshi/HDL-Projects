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
  constant CLKS_PER_BAUD : INTEGER := CLK_FREQ/BAUD_RATE;
  constant DATA_BITS : INTEGER := 8;
  constant PARITY     : INTEGER := 0;
  constant STOP_BITS : INTEGER := 1;
  
  constant CLK_PERIOD  : TIME := 10ns;
  constant BAUD_PERIOD : TIME := CLK_PERIOD*CLKS_PER_BAUD;
    
  signal clk : STD_LOGIC := '0';
  signal set : STD_LOGIC := '0';
  signal input_data   : STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
  signal input_serial : STD_LOGIC := '0';
  
  signal rx_busy : STD_LOGIC;
  signal tx_busy : STD_LOGIC;
  signal output_data   : STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
  signal output_serial : STD_LOGIC;
  
  constant ARRAY_SIZE : INTEGER := 2;
  type DATA_ARRAY is array(INTEGER range <>) of STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
  constant data_in : DATA_ARRAY(ARRAY_SIZE-1 downto 0) := ((x"35"),(x"9b"));
begin
  clk <= not clk after CLK_PERIOD/2;
  
  dut: entity work.uart(Behavioral)
    generic map(
      CLK_FREQ  => CLK_FREQ,
      BAUD_RATE => BAUD_RATE,
      DATA_BITS => DATA_BITS,
      PARITY    => PARITY,
      STOP_BITS => STOP_BITS
    )
    port map(
      i_clk       => clk,
      i_tx_set    => set,
      i_tx_data   => input_data,
      o_tx_busy   => tx_busy,
      o_tx_serial => output_serial,
      i_rx_serial => input_serial,
      o_rx_busy   => rx_busy,
      o_rx_data   => output_data
    );

  process
  begin
    wait for BAUD_PERIOD;

    for i in 0 to ARRAY_SIZE-1 loop
      input_serial <= '0';
      wait for BAUD_PERIOD;
      
      for j in 0 to 7 loop
        input_serial <= data_in(i)(j);
        wait for BAUD_PERIOD;
      end loop;
      
      input_serial <= '1';
      wait for BAUD_PERIOD*5;
      
      report "Input Data=" & to_hstring(data_in(i)) & "   Output Data=" & to_hstring(output_data);
    end loop;
  end process;
end test;
