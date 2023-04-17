----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2023 02:49:58 PM
-- Design Name: 
-- Module Name: uart_tx_tb - test
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

entity uart_tx_tb is
end uart_tx_tb;

architecture test of uart_tx_tb is
  constant CLK_FREQ  : INTEGER := 100_000_000;
  constant BAUD_RATE : INTEGER := 115200;
  constant CLKS_PER_BAUD : INTEGER := CLK_FREQ/BAUD_RATE;
  constant DATA_BITS : INTEGER := 8;
  constant STOP_BITS : INTEGER := 1;
  
  constant CLK_PERIOD  : TIME := 10ns;
  constant BAUD_PERIOD : TIME := CLK_PERIOD*CLKS_PER_BAUD;
  constant INPUT_DATA  : STD_LOGIC_VECTOR(DATA_BITS-1 downto 0) := "00110010";
  
  signal clk : STD_LOGIC := '0';
  signal set_sig : STD_LOGIC := '0';
  
  signal serial_output : STD_LOGIC;
  signal busy_sig : STD_LOGIC;
begin
  clk <= not clk after CLK_PERIOD/2;

  dut: entity work.uart_tx(Behavioral)
    generic map(
      CLKS_PER_BAUD => CLKS_PER_BAUD,
      DATA_BITS     => DATA_BITS,
      STOP_BITS     => STOP_BITS
    )
    port map(
      i_clk    => clk,
      i_set    => set_sig,
      i_data   => INPUT_DATA,
      o_busy   => busy_sig,
      o_serial => serial_output
    );
    
  process
  begin
    wait for BAUD_PERIOD*5;
    set_sig <= '1'; -- start signal
    
    wait for BAUD_PERIOD;
    set_sig <= '0'; -- stop transmitting
    wait;
  end process;
end test;
