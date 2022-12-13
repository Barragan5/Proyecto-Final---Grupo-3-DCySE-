----------------------------------------------------------------------------------
-- PRÁCTICA FINAL:  Cuenta las columnas y las filas de los píxeles para generar
--                  las señales para pintar y para transmitir por HDMI.
--
-- GRUPO 3: Alejandro López del Peso
--          Juan Camilo Martínez
--          Marta Barragán 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity SYNC_VGA is
    Port ( clk      : in STD_LOGIC;
           rst      : in STD_LOGIC;
           cols     : out UNSIGNED (9 downto 0);
           filas    : out UNSIGNED (9 downto 0);
           Visible  : out STD_LOGIC;
           HSYNC    : out STD_LOGIC;
           VSYNC    : out STD_LOGIC);
           
end SYNC_VGA;

architecture Behavioral of SYNC_VGA is
    
    component contadorBCD Generic( temp     : in natural;               -- Valor hasta el que cuenta    
                                   Nbits    : in natural := 25 );                                    
                          Port(    rst      : in STD_LOGIC;                                                                      
                                   enable   : in STD_LOGIC;                                                                   
                                   clk      : in STD_LOGIC;             
                                   fn_cont  : out STD_LOGIC;            -- Pulso de fin de cuenta
                                   cuenta   : out unsigned (Nbits downto 0) );                   
    end component;
    
    signal new_line     : std_logic; -- Fin de cuenta para las columnas
    signal new_frame    : std_logic; -- Fin de cuenta para las filas
    
    signal pxl_visible  : std_logic;
    signal line_visible : std_logic;
    
    signal  C : unsigned (9 downto 0); 
    signal  F : unsigned (9 downto 0);
    
begin

    conta_cols : contadorBCD generic map( temp => 799, -- clk = 25 MHz (40ns por pixel)
                                          Nbits => 9 )
                             port map  (  rst => rst,
                                          enable => '1',
                                          clk => clk,
                                          fn_cont => new_line,
                                          cuenta => C );
                                       
    conta_filas : contadorBCD generic map ( temp => 524,
                                            Nbits => 9 ) 
                                 port map ( rst => rst,
                                            enable => new_line,
                                            clk => clk,
                                            fn_cont => new_frame,
                                            cuenta => F );
     
     
    VSYNC   <= '0' when (F>488 and F<491) else '1';
    HSYNC   <= '0' when (C>655 and C<752) else '1';
    Visible <= '1' when (C<640 and F<480) else '0';                                                                         
    
    cols    <= C;
    filas   <= F;

end Behavioral;
