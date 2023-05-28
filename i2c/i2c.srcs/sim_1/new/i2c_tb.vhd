----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/02/2023 04:04:01 PM
-- Design Name: 
-- Module Name: i2c_tb - Behavioral
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

entity i2c_tb is
end i2c_tb;

architecture Behavioral of i2c_tb is
  constant CLK_PERIOD  : TIME := 10ns;

  signal clk   : STD_LOGIC := '0';
  signal reset : STD_LOGIC := '0';
  signal set   : STD_LOGIC := '0';

  signal rw : STD_LOGIC := '0';
  signal addr : STD_LOGIC_VECTOR(6 downto 0) := "1011001";
  signal din  : STD_LOGIC_VECTOR(7 downto 0) := "10110011";
  signal dout : STD_LOGIC_VECTOR(7 downto 0);

  signal busy    : STD_LOGIC;
  signal ack_err : STD_LOGIC;

  signal scl : STD_LOGIC;
  signal sda : STD_LOGIC;
begin
  clk <= not clk after CLK_PERIOD/2;

  dut: entity work.i2c(Behavioral)
    port map(
      i_clk   => clk,
      i_reset => reset,
      i_addr  => addr,
      i_din   => din,
      o_dout  => dout,
      i_rw    => rw,
      i_set   => set,
      o_busy  => busy,
      io_scl  => scl,
      io_sda  => sda,
      o_ack_err => ack_err
    );
  
  process
  begin
    wait for CLK_PERIOD*50;

    reset <= '1';
    wait for CLK_PERIOD*2;
    reset <= '0';
    wait for CLK_PERIOD*2;

    set <= '1';
    wait for CLK_PERIOD*2;
    set <= '0';
    
    wait;
  end process;

end Behavioral;
