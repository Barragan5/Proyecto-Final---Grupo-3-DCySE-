----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2022 13:11:19
-- Design Name: 
-- Module Name: ContadorBCD - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;

entity ContadorBCD is
    generic( temp : in natural;
             Nbits : in natural :=25);           -- Valor hasta el que cuenta 
    Port ( rst : in STD_LOGIC;
           enable : in STD_LOGIC;
           clk : in STD_LOGIC;          -- clk de 10ns -> 1seg=10^9 ns = 10ns·10^8   : 20 bits
           fn_cont : out STD_LOGIC;    -- boolean  output indica fin de cuenta
           cuenta : out unsigned (Nbits downto 0):= (others=>'0'));
end ContadorBCD;

architecture Behavioral of ContadorBCD is

signal cont : unsigned (Nbits downto 0):= (others=>'0');       -- cuenta en tiempo real
signal fin_cuenta : std_logic :='0';                        -- boolean indica si se ha llegado al final de cuenta 

    
begin

    process(clk,rst)
    begin
        if(rst='1')then
            cont<=(others=>'0');
        elsif (rising_edge(clk))then
            if(enable='1') then
                if(fin_cuenta='1') then
                    cont<=(others=>'0');
                else
                    cont<=cont+1;
                end if; 
            end if;           
        end if;     
    end process;
    
    
    fin_cuenta <='1' when cont = temp else '0';
    fn_cont <= fin_cuenta;
    cuenta <= cont;    
    

end Behavioral;
