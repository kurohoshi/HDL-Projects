----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2023 01:57:58 AM
-- Design Name: 
-- Module Name: User_Control - Behavioral
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

library work;
use work.utils.all;

entity User_Control is
  Generic(
    FRAME_WIDTH  : INTEGER := 640;
    FRAME_HEIGHT : INTEGER := 480;
    ADDR_WIDTH   : INTEGER := 13
  );
  Port(
    i_clk   : in  STD_LOGIC;
    i_reset : in  STD_LOGIC;
    i_mode  : in  STD_LOGIC_VECTOR(1 downto 0);
    
    i_up    : in STD_LOGIC;
    i_down  : in STD_LOGIC;
    i_left  : in STD_LOGIC;
    i_right : in STD_LOGIC;
    
    o_addr : out STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0)
  );
end User_Control;

architecture Behavioral of User_Control is
  constant MEM_WIDTH      : INTEGER := FRAME_WIDTH/8;
  constant MEM_HEIGHT     : INTEGER := FRAME_HEIGHT/8;
  constant MEM_ADDR_WIDTH : INTEGER := calc_bits_width(MEM_WIDTH) + calc_bits_width(MEM_HEIGHT);
  
  signal user_in : STD_LOGIC;
  signal user_x  : UNSIGNED(calc_bits_width(MEM_WIDTH)-1 downto 0); 
  signal user_y  : UNSIGNED(calc_bits_width(MEM_HEIGHT)-1 downto 0); 
begin
  user_cursor: process(i_reset, i_clk)
    type t_init_state IS(idle, active);
    variable s_user : t_init_state := idle;
  begin
    if(i_reset = '1') then
      user_x <= (others => '0');
      user_y <= (others => '0');
    elsif(rising_edge(i_clk)) then
      if(i_mode = "01") then
        if(s_user = active) then
          if(i_up = '1') then
            if(user_y = 0) then
              user_y <= to_unsigned(MEM_HEIGHT-1, user_y'length);
            else
              user_y <= user_y - 1;
            end if;
          elsif(i_down = '1') then
            if(user_y = MEM_HEIGHT-1) then
              user_y <= to_unsigned(0, user_y'length);
            else
              user_y <= user_y + 1;
            end if;
          elsif(i_left = '1') then
            if(user_x = 0) then
              user_x <= to_unsigned(MEM_WIDTH-1, user_x'length);
            else
              user_x <= user_x - 1;
            end if;
          elsif(i_right = '1') then
            if(user_x = MEM_WIDTH-1) then
              user_x <= to_unsigned(0, user_x'length);
            else
              user_x <= user_x + 1;
            end if;
          end if;
          
          if(user_in = '1') then
            s_user := idle;
          end if;
        elsif(s_user = idle) then
          if(user_in = '0') then
            s_user := active;
          end if;
        end if;
      end if;
    end if;
  end process;
  
  user_in <= i_up or i_down or i_left or i_right;
  o_addr <= STD_LOGIC_VECTOR((user_y * to_unsigned(MEM_WIDTH, user_x'length)) + user_x);

end Behavioral;
