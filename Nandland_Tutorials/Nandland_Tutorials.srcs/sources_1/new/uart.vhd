----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/28/2023 10:42:05 PM
-- Design Name: 
-- Module Name: uart - Behavioral
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
--   https://nandland.com/project-7-uart-part-1-receive-data-from-computer/
--     -- Common Configurations:
--     -- Baud Rate: 9600, 19200, 115200
--     -- Data Bits: 7, 8
--     -- Parity Bits: 0, 1
--     -- Stop Bits: 0, 1, 2
--     -- Flow Control: None, On, Hardware
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

entity uart is
  GENERIC (
    CLK_FREQ   : INTEGER := 100_000_000;
    BAUD_RATE  : INTEGER := 115_200;
    DATA_WIDTH : INTEGER := 8;
    PARITY     : INTEGER := 0;
    STOP_WIDTH : INTEGER := 1
  );
  Port (
    i_clk       : in STD_LOGIC;
    
    i_tx_en     : in STD_LOGIC;
    i_tx_data   : in STD_LOGIC_VECTOR (7 downto 0);
    o_tx_busy   : out STD_LOGIC;
    o_tx_done   : out STD_LOGIC;
    o_tx_serial : out STD_LOGIC;
    
    
    i_rx_serial : in STD_LOGIC;
    o_rx_done   : out STD_LOGIC;
    o_rx_err    : out STD_LOGIC;
    o_rx_data   : out STD_LOGIC_VECTOR (7 downto 0)
  );
end uart;

architecture Behavioral of uart is
    type t_fsm_state IS(idle, active);
    signal s_rx_state : t_fsm_state;
    
begin
  uart_tx: entity work.uart_tx(Behavioral)
    port map(
      i_clk    => i_clk,
      i_en     => i_tx_en,
      i_data   => i_tx_data,
      o_busy   => o_tx_busy,
      o_done   => o_tx_done,
      o_serial => o_tx_serial
    );
    
  uart_rx: entity work.uart_rx(Behavioral)
    port map(
      i_clk    => i_clk,
      i_serial => i_rx_serial,
      o_done   => o_rx_done,
      o_err    => o_rx_err,
      o_data   => o_rx_data
    );
    
  -- Some sort of logic disabling tx or rx when the other is active?
end Behavioral;