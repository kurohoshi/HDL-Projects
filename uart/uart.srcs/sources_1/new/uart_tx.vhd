----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2023 09:07:30 PM
-- Design Name: 
-- Module Name: uart_tx - Behavioral
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
--   https://nandland.com/project-8-uart-part-2-transmit-data-to-computer/
--     -- Common Configurations:
--     -- Baud Rate: 9600, 19200, 115200
--     -- Data Bits: 7, 8
--        -- NOTE: historically 7 bit data was more advantageous when Baud rate was low and is enough to cover all ASCII chars
--     -- Parity Bits: 0, 1
--     -- Stop Bits: 0, 1, 2
--        -- NOTE: 2 stop bits mainly used for tranmitter to allow extra time for receivers
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

entity uart_tx is
  Generic (
    CLKS_PER_BAUD : INTEGER := 868;
    DATA_BITS     : INTEGER := 8;
    STOP_BITS     : INTEGER := 1
  );
  Port (
    i_clk    : in STD_LOGIC;
    i_set    : in STD_LOGIC;
    i_data   : in STD_LOGIC_VECTOR(7 downto 0);
    o_busy   : out STD_LOGIC;
    o_serial : out STD_LOGIC
  );
end uart_tx;

architecture Behavioral of uart_tx is
  type t_fsm_state IS(tx_idle, tx_start, tx_data, tx_stop);
  signal s_tx : t_fsm_state;

  signal clk_counter  : INTEGER range 0 to CLKS_PER_BAUD;
  signal data_counter : INTEGER range 0 to DATA_BITS;
  signal stop_counter : INTEGER range 0 to STOP_BITS;
  
  signal r_tx_data : STD_LOGIC_VECTOR(i_data'range);
begin
  process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      if(s_tx = tx_idle) then
        if(i_set = '1') then
          r_tx_data <= i_data;
          o_serial <= '0';
          o_busy <= '1';
          s_tx <= tx_start;
        end if;

        clk_counter  <= 0;
        data_counter <= 0;
        stop_counter <= 0;
      elsif(s_tx = tx_start) then
        if(clk_counter < CLKS_PER_BAUD-1) then
          clk_counter <= clk_counter + 1;
        else
          clk_counter <= 0;
          o_serial <= r_tx_data(data_counter);
          data_counter <= data_counter + 1;
          s_tx <= tx_data;
        end if;
      elsif(s_tx = tx_data) then
        if(clk_counter < CLKS_PER_BAUD-1) then
          clk_counter <= clk_counter + 1;
        else
          clk_counter <= 0;
          if(data_counter < DATA_BITS) then
            o_serial <= r_tx_data(data_counter);
            data_counter <= data_counter + 1;
          else
            o_serial <= '1';
            s_tx <= tx_stop;
          end if;
        end if;
      elsif(s_tx = tx_stop) then
        if(clk_counter < CLKS_PER_BAUD-1) then
          clk_counter <= clk_counter + 1;
        else
          if(stop_counter < STOP_BITS) then
            stop_counter <= stop_counter + 1;
          else
            o_busy <= '0';
            s_tx <= tx_idle;
          end if;
        end if;
      else
        s_tx <= tx_idle;
      end if;
    end if;
  end process;
end Behavioral;
