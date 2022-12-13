----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.11.2022 20:44:24
-- Design Name: 
-- Module Name: PLL - Behavioral
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

entity clock_gen is generic (                                                  
                    CLKIN_PERIOD : real := 8.000; -- input clock period (8ns)  
                    CLK_MULTIPLY : integer := 8; -- multiplier                 
                    CLK_DIVIDE : integer := 1; -- divider                      
                    CLKOUT0_DIV : integer := 8; -- serial clock divider        
                    CLKOUT1_DIV : integer := 40 -- pixel clock divider         
                    );                                                         
                    port(                                                      
                    clk_i : in std_logic; -- input clock                       
                    rst : in std_logic; -- input clock                       
                    clk0_o : out std_logic; -- serial clock                    
                    clk1_o : out std_logic -- pixel clock                      
                    );                                                         

end clock_gen;

architecture Behavioral of clock_gen is

signal pllclk0 : std_logic;
signal pllclk1 : std_logic;
signal clkfbout : std_logic;

begin
    -- buffer output clocks
    clk0buf: BUFG port map (I=>pllclk0, O=>clk0_o);
    clk1buf: BUFG port map (I=>pllclk1, O=>clk1_o);
    
    clock: PLLE2_BASE generic map( clkin1_period => CLKIN_PERIOD,
                                   clkfbout_mult => CLK_MULTIPLY,  
                                   clkout0_divide => CLKOUT0_DIV,  
                                   clkout1_divide => CLKOUT1_DIV,  
                                   divclk_divide => CLK_DIVIDE)    
                                    
                         port map( rst => rst,                   
                                   pwrdwn => '0',                  
                                   clkin1 => clk_i,                
                                   clkfbin => clkfbout,            
                                   clkfbout => clkfbout,           
                                   clkout0 => pllclk0,  
                                   clkout1 => pllclk1    
                                   );                              

end Behavioral;