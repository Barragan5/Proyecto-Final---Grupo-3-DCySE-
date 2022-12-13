----------------------------------------------------------------------------------
-- PRÁCTICA FINAL: Pintar una cuadrícula 16x16 con el fantasma
-- 9/12/2022
-- GRUPO 3: Alejandro López del Peso
--          Juan Camilo Martínez
--          Marta Barragán 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity Fantasma_FSM is
    Port (
    rst             : in std_logic; 
    clk             : in std_logic; -- 25Mhz
    -- Bits más significativos para saber en qué cuadrícula pintar el fantasma
    fila_Fantasma   : out unsigned (5 downto 0);  
    col_Fantasma    : out unsigned (5 downto 0)); 
end Fantasma_FSM;

architecture Behavioral of Fantasma_FSM is
    -- Estados de la FSM
    type Estados_Fantasma is (DownLeft, UpLeft, UpRight, DownRight);

    -- Señales Intermedias
    signal EstadoActual, EstadoSiguiente : Estados_Fantasma;
    signal fCounter100ms                 : std_logic;               -- Cada cuanto se va a mover el fantasma
    signal f_Fantasma, c_Fantasma        : unsigned (5 downto 0);   -- Señales para poder leer fila_Fantasma, col_Fantasma

    -- Declaración del contador como componente
    
    component ContadorBCD  generic( temp : in natural := (25e5)-1;                                                                 
                                    Nbits : in natural :=22); 
                           Port ( rst : in STD_LOGIC;         
                                  enable : in STD_LOGIC;      
                                  clk : in STD_LOGIC;         
                                  fn_cont : out STD_LOGIC;    
                                  cuenta : out unsigned (Nbits downto 0):= (others=>'0'));   
    end component;                                                        

begin

    -- Instanciación del contador para actualizar el movimiento del fantasma 
    Countr100ms : ContadorBCD 
        generic map ( temp     => (25e5)-1, -- Se le va a pasar el reloj de 25 MHz
                      Nbits    =>  22
                     )     
           port map ( clk      => clk,
                      rst      => rst,
                      fn_cont  => fCounter100ms,
                      enable   => '1');
   
    -- Proceso para cambiar el 
--    process(c_Fantasma,f_Fantasma)
--    begin
--    if (rising_edge(clk))then
        col_Fantasma <= c_Fantasma; 
        fila_Fantasma <= f_Fantasma;
--    end if;    
--    end process;


    P_SEC_FMS : process(clk,rst)
    begin
        if rst = '1' then
            EstadoActual <= DownLeft;
        elsif rising_edge(clk) then
            EstadoActual <= EstadoSiguiente;
        end if;    
    end process;


    P_COMB_FMS : process (clk,fCounter100ms,rst)
    begin
        -- Esto debería ir en otro proceso ------------
        if rst = '1' then
            c_Fantasma <= TO_UNSIGNED(7, 6);
            c_Fantasma <= TO_UNSIGNED(0, 6);
        end if;
        -----------------------------------------------
        if rising_edge(fCounter100ms) then
            case EstadoActual is
            -------------------------------------------
                when DownLeft =>
                    if f_Fantasma = 29 then
                        EstadoSiguiente <= UpLeft;
                    elsif c_Fantasma = 0 then
                        EstadoSiguiente <= DownRight;
                    else f_Fantasma <= f_Fantasma + 1;
                         c_Fantasma <= c_Fantasma - 1;
                    end if;
            -------------------------------------------
                when UpLeft =>
                    if f_Fantasma = 0 then
                        EstadoSiguiente <= DownLeft;
                    elsif c_Fantasma = 0 then
                        EstadoSiguiente <= UpRight;
                    else f_Fantasma <= f_Fantasma - 1;
                         c_Fantasma <= c_Fantasma - 1;
                    end if;  
            -------------------------------------------
                when UpRight =>
                    if f_Fantasma = 0 then
                        EstadoSiguiente <= DownLeft;
                    elsif c_Fantasma = 39 then
                        EstadoSiguiente <= UpLeft;
                    else f_Fantasma <= f_Fantasma - 1;
                         c_Fantasma <= c_Fantasma + 1;
                    end if;
            -------------------------------------------
                when DownRight =>
                    if f_Fantasma = 29 then
                        EstadoSiguiente <= UpRight;
                    elsif c_Fantasma = 39 then
                        EstadoSiguiente <= DownLeft;
                    else f_Fantasma <= f_Fantasma + 1;
                         c_Fantasma <= c_Fantasma + 1;
                    end if;
            end case;
        -- Se deja como está:
        else f_Fantasma <= f_Fantasma;
             c_Fantasma <= c_Fantasma;
        end if;
    end process;

end Behavioral;