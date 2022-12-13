----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.10.2022 12:18:32
-- Design Name: 
-- Module Name: mux_1bit - Behavioral
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

entity mux_3bit is
    Port ( E0 : in STD_LOGIC_VECTOR(2 downto 0);
           E1 : in STD_LOGIC_VECTOR(2 downto 0);
           SEL : in STD_LOGIC;
           S0 : out STD_LOGIC_VECTOR(2 downto 0));
end mux_3bit;


-----------------------------------------------------
architecture Concurrent of mux_3bit is
begin
    -- Otro método
    S0 <= E0 when SEL = '0' else E1;
    
end Concurrent;