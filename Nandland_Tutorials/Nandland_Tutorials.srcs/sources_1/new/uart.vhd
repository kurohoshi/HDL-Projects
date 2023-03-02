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
    i_rx_serial : in STD_LOGIC;
    i_reset     : in STD_LOGIC;
    o_rx_data   : out STD_LOGIC_VECTOR (7 downto 0)
  );
end uart;

architecture BehavioralSimple of uart is
    type t_fsm_state IS(idle, active);
    signal s_rx_state : t_fsm_state;
    
begin
    -- take care of non state machine stuff here
    process(i_reset, i_clk)
        
    begin
        if(i_reset = '0') then
            -- reset all signals to default values
        elsif(rising_edge(i_clk)) then
            -- do stuff here
        end if;
    end process;

    -- receive FSM
    process(i_reset, i_clk)
      constant MAX_BAUD_CLK : INTEGER := CLK_FREQ/BAUD_RATE;
      variable clk_counter  : INTEGER := 0;
      variable data_counter : INTEGER range 0 to DATA_WIDTH-1 := 0;
      
    begin
        if(i_reset = '1') then
            -- reset all signals to default values
            
        elsif(falling_edge(i_clk)) then
          case s_rx_state is
            when idle =>
              if(i_rx_serial = '0') then
                if(clk_counter < MAX_BAUD_CLK/2) then
                  clk_counter := clk_counter + 1;
                  -- state remains unchanged
                else
                  clk_counter := 0;
                  s_rx_state <= active;
                end if;
              end if;
            when active =>
              if(clk_counter < MAX_BAUD_CLK-1) then
                clk_counter := clk_counter + 1;
                -- state remains unchanged
              elsif(data_counter < DATA_WIDTH) then -- counter has reached next baud midpoint
                o_rx_data(data_counter) <= i_rx_serial;
                clk_counter := 0;
                data_counter := data_counter + 1;
                
                -- state remains unchanged
              else -- stop bits
                clk_counter := 0;
                data_counter := 0;
                s_rx_state <= idle;
              end if;
            end case;
        end if;
    end process;
end BehavioralSimple;