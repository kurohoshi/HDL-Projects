----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2023 09:07:30 PM
-- Design Name: 
-- Module Name: uart_rx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: UART Receiver
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

entity uart_rx is
  Generic (
    CLKS_PER_BAUD : INTEGER := 868;
    DATA_BITS     : INTEGER := 8;
    STOP_BITS     : INTEGER := 1
  );
  Port (
    i_clk    : in STD_LOGIC;
    i_serial : in STD_LOGIC;
    o_done   : out STD_LOGIC;
    o_err    : out STD_LOGIC;
    o_data   : out STD_LOGIC_VECTOR(DATA_BITS-1 downto 0)
  );
end uart_rx;

-- Refactor!
architecture Behavioral of uart_rx is
  type t_fsm_state IS(idle, active);
  signal s_rx : t_fsm_state;
  
  signal clk_counter  : INTEGER range 0 to CLKS_PER_BAUD;
  signal data_counter : INTEGER range 0 to DATA_BITS;
  signal stop_counter : INTEGER range 0 to STOP_BITS;
  
  signal r_data_receive : STD_LOGIC_VECTOR(o_data'range);
begin
  process(i_clk)
  begin
    if(rising_edge(i_clk)) then
      if(s_rx = idle) then
        if(i_serial = '1') then
          if(clk_counter < (CLKS_PER_BAUD-1)/2) then
            clk_counter <= clk_counter + 1;
          else
            clk_counter <= 0;
            s_rx <= active;
          end if;
        else
          clk_counter  <= 0;
        end if;
        
        o_err <= '0';
        o_done <= '0';
        data_counter <= 0;
        stop_counter <= 0;
      elsif(s_rx = active) then
        if(clk_counter < CLKS_PER_BAUD-1) then
          clk_counter <= clk_counter + 1;
        else
          clk_counter <= 0;
          
          if(data_counter < DATA_BITS) then
            r_data_receive(data_counter) <= i_serial;
            data_counter <= data_counter + 1;
          else
            if(stop_counter < STOP_BITS) then
              if(i_serial = '1') then
                stop_counter <= stop_counter + 1;
              else
                o_err <= '1';
                s_rx <= idle;
              end if;
            else
              o_data <= r_data_receive;
              clk_counter  <= 0;
              data_counter <= 0;
              stop_counter <= 0;
              o_done <= '1';
              s_rx <= idle;
            end if;
          end if;
        end if;
      else
        s_rx <= idle;
      end if;
    end if;
  end process;
end Behavioral;