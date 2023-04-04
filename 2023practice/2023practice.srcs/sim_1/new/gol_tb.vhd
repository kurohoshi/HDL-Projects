----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/25/2023 11:50:53 AM
-- Design Name: 
-- Module Name: gol_tb - Test
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

entity gol_tb is
end gol_tb;

architecture test of gol_tb is
  constant ADDR_WIDTH : INTEGER := 13;
  
  signal clk   : STD_LOGIC := '0';
  signal reset : STD_LOGIC := '0';
  signal mode  : STD_LOGIC_VECTOR (1 downto 0) := "00";
  signal set   : STD_LOGIC := '0';
  
  signal up    : STD_LOGIC := '0';
  signal down  : STD_LOGIC := '0';
  signal left  : STD_LOGIC := '0';
  signal right : STD_LOGIC := '0';
  
  signal hsync : STD_LOGIC := '1';
  signal vsync : STD_LOGIC := '1';
  signal red   : STD_LOGIC_VECTOR(3 downto 0);
  signal green : STD_LOGIC_VECTOR(3 downto 0);
  signal blue  : STD_LOGIC_VECTOR(3 downto 0);
begin
  clk <= not clk after 5ns;

  dut: entity work.VGA_Project(Behavioral)
    port map(
      i_clk   => clk,
      i_reset => reset,
      i_mode  => mode,
      i_set   => set,

      i_up    => up,
      i_down  => down,
      i_left  => left,
      i_right => right,

      o_hsync => hsync,
      o_vsync => vsync,
      o_red   => red,
      o_green => green,
      o_blue  => blue
    );

  process
  begin
    wait for 10ns;
    
    reset <= '1';
    wait for 50ns;
    reset <= '0';
    wait for 100ns;
    
    mode <= "01";
    wait for 1us;
    
    right <= '1';
    wait for 1us;
    right <= '0';
    wait for 1us;
    
    down <= '1';
    wait for 1us;
    down <= '0';
    wait for 1us;
    
    for i in 1 to 3 loop
      set <= '1';
      wait for 1us;
      set <= '0';
      wait for 1us;
      
      left <= '1';
      wait for 1us;
      left <= '0';
      wait for 1us;
    end loop;
    
    set <= '1';
    wait for 1us;
    set <= '0';
    wait for 1us;

    up <= '1';
    wait for 1us;
    up <= '0';
    wait for 1us;

    for i in 1 to 3 loop
      set <= '1';
      wait for 1us;
      set <= '0';
      wait for 1us;
      
      right <= '1';
      wait for 1us;
      right <= '0';
      wait for 1us;
    end loop;

    set <= '1';
    wait for 1us;
    set <= '0';
    wait for 1us;

    up <= '1';
    wait for 1us;
    up <= '0';
    wait for 1us;

    for i in 1 to 3 loop
      set <= '1';
      wait for 1us;
      set <= '0';
      wait for 1us;
      
      left <= '1';
      wait for 1us;
      left <= '0';
      wait for 1us;
    end loop;

    set <= '1';
    wait for 1us;
    set <= '0';
    wait for 1us;

    up <= '1';
    wait for 1us;
    up <= '0';
    wait for 1us;

    for i in 1 to 3 loop
      set <= '1';
      wait for 1us;
      set <= '0';
      wait for 1us;
      
      right <= '1';
      wait for 1us;
      right <= '0';
      wait for 1us;
    end loop;

    set <= '1';
    wait for 1us;
    set <= '0';
    wait for 1us;

    -- down <= '1';
    -- wait for 700us;
    -- down <= '0';
    -- wait for 700us;
    
    -- down <= '1';
    -- wait for 700us;
    -- down <= '0';
    -- wait for 700us;
    
    -- right <= '1';
    -- wait for 700us;
    -- right <= '0';
    -- wait for 700us;
    
    -- right <= '1';
    -- wait for 700us;
    -- right <= '0';
    -- wait for 700us;
    
    -- set <= '1';
    -- wait for 700us;
    -- set <= '0';
    -- wait for 700us;
    
    -- down <= '1';
    -- wait for 700us;
    -- down <= '0';
    -- wait for 700us;
    
    -- set <= '1';
    -- wait for 700us;
    -- set <= '0';
    -- wait for 700us;
    
    -- right <= '1';
    -- wait for 700us;
    -- right <= '0';
    -- wait for 700us;
    
    -- set <= '1';
    -- wait for 700us;
    -- set <= '0';
    -- wait for 700us;
    
    -- up <= '1';
    -- wait for 700us;
    -- up <= '0';
    -- wait for 700us;
    
    -- set <= '1';
    -- wait for 700us;
    -- set <= '0';
    -- wait for 700us;
    
    
    mode <= "00";
    wait for 50us;
    
    set <= '1';
    wait for 100us;
    set <= '0';
    wait for 200us;
    
    wait;
  end process;

end test;
