----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/04/2023 01:32:37 AM
-- Design Name: 
-- Module Name:  utils
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Package of utility stuff
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package utils is
  function calc_bits_width(num : NATURAL)
    return NATURAL;
end package utils;

package body utils is
  function calc_bits_width(num : NATURAL) return NATURAL is
    variable remainder : NATURAL := num;
    variable width     : NATURAL := 0;
  begin
    while remainder > 0 loop
      remainder := remainder/2;
      width := width + 1;
    end loop;
    
    return width;
  end function;
end package body utils;
