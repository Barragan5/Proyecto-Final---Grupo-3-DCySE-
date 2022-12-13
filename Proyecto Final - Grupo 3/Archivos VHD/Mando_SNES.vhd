----------------------------------------------------------------------------------
-- PRÁCTICA FINAL:  descripción del funcionamiento del mando de la SNES
--                  
-- 29/11/2022
-- GRUPO 3: Alejandro López del Peso
--          Juan Camilo Martínez
--          Marta Barragán 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity Mando_SNES is
    Port ( clk          : in STD_LOGIC; 
           rst          : in STD_LOGIC;
           clk_snes     : out STD_LOGIC;
           latch_snes   : out STD_LOGIC;
           data_in_snes : in STD_LOGIC := '0';
           BotonesSNES  : out unsigned (3 downto 0); -- Registro con los datos de los botones del mando   
           finish       : out STD_LOGIC);         
end Mando_SNES;

architecture Mando of Mando_SNES is
    -- Declaración del contador
    component contadorBCD generic( temp : in natural;
                               Nbits    : in natural:= 21);                                      
                         Port( rst      : in STD_LOGIC;                                                                      
                               enable   : in STD_LOGIC;                                                                   
                               clk      : in STD_LOGIC;             
                               fn_cont  : out STD_LOGIC;    
                               cuenta   : out unsigned (Nbits downto 0));
    end component;
    
    -- Estados de FSM
    type Estados_SNES is (State_1, State_2, State_3, State_4);
    
    -- Señales Intermedias
    signal fCuenta6us, fCuenta12us                               : STD_LOGIC; -- Pulsos de final de cuenta
    signal clk_snesSignal, finishSignal                          : STD_LOGIC;
    signal start                                                 : STD_LOGIC := '1';
    signal CuentaActual                                          : unsigned (10 downto 0);
    signal EstadoActual, EstadoSiguiente                         : Estados_SNES;
    signal CounterBTN                                            : unsigned (4 downto 0);
    signal BotonesSNES_Signal, BotonesSNES_Incompleto            : unsigned (14 downto 0) := (others => '0');                         
    signal en_count                                              : std_logic;                        
    signal f_count_clk                                           : std_logic;                        
    signal en_count_clk                                          : std_logic := '0';                        
begin
    -- Instanciación del contador para el puso del latch
    Countr12us : ContadorBCD 
        generic map ( temp   => 299, -- Contar 12 us 
                      Nbits  => 10 ) 
        port map ( clk      => clk,
                   rst      => rst,
                   fn_cont  => fCuenta12us,
                   cuenta   => CuentaActual,
                   enable   => en_count );
                   
    -- Final de cuenta de 6 us ---------------------------------------------
    fCuenta6us <= '1' when CuentaActual = 149 OR fCuenta12us = '1' else '0'; 
    
    en_count   <= '1' when EstadoActual = State_1 or EstadoActual = State_2 
                        or EstadoActual = State_3 or EstadoActual = State_4 else '0';

    -- Proceso Síncrono de Actualización de Estados
    P_SEC_FMS : process (rst, clk)
    begin
        if rst = '1' then                                       -- Si hay un reset
            EstadoActual <= State_1;                            -- Se vuelve al estado inicial
        elsif rising_edge(clk) then                             -- Si hay un flanco de subida de reloj
            EstadoActual <= EstadoSiguiente;                    -- Se actualiza el estado actual
        end if;
    end process;
    
    -- Proceso Asíncrono de Actualización de Estados Siguientes
    P_COMB_FMS : process (EstadoActual, fCuenta6us, fCuenta12us, start)
    begin
        case EstadoActual is
            when State_1 => 
                latch_snes <= '1'; 
                clk_snesSignal <= '1';
                if fCuenta12us = '1' then
                    EstadoSiguiente <= State_2;
                else EstadoSiguiente <= EstadoActual;
                end if;
        -------------------------------------------------------
            when State_2 =>
                clk_snesSignal <= '1';
                latch_snes <= '0';  -- RNC
                finishSignal <= '0';
                if fCuenta6us = '1' then
                    EstadoSiguiente <= State_3;
                else EstadoSiguiente <= EstadoActual;
                end if;
        -------------------------------------------------------
            when State_3 =>
                latch_snes <= '0';  -- RNC
                finishSignal <= '0';
                if CounterBTN = 15 then -- RNC
                    clk_snesSignal <= '1';
                else
                    clk_snesSignal <= '0';
                end if;
                if fCuenta12us = '1' then
                    if f_count_clk = '0' then
                        EstadoSiguiente <= State_2;
                    else EstadoSiguiente <= State_4;
                         finishSignal <= '1';
                    end if;
                else EstadoSiguiente <= EstadoActual;
                end if;
        -------------------------------------------------------
            when State_4 =>
                latch_snes <= '0';  -- RNC
                clk_snesSignal <= '1';
                if fCuenta12us = '1' then
                    EstadoSiguiente <= State_1;
                    finishSignal <= '0';
                else EstadoSiguiente <= EstadoActual;
                end if;
        -------------------------------------------------------
        end case;
    end process;
    en_count_clk <= '1' when EstadoActual = State_2 or EstadoActual = State_3 else '0';
    
    -- Contador de veces en las que se tiene que leer el clk
    COUNT_CLKS: process(clk, rst)
    begin
        if rst = '1' then
            CounterBTN <= (others => '0');
        elsif clk'event and clk='1' then
            if f_count_clk = '1' and fCuenta12us = '1'  then
                CounterBTN <= (others => '0');
            else
                if en_count_clk = '1' and fCuenta12us = '1' then        
                    CounterBTN <= CounterBTN + 1;
                end if;
            end if;
        end if;
    end process;
    f_count_clk <= '1' when CounterBTN = 15 else '0';
            
    -- Concatenar los datos de cada botón en un registro
    BTN_Mando : process (rst, clk_snesSignal)
    begin
        if rst = '1' then
            BotonesSNES_Incompleto <= (others => '0');
        elsif falling_edge(clk_snesSignal) then -- Se realiza cuando haya un flanco de bajada
            BotonesSNES_Incompleto(14 downto 0) <=  data_in_snes & BotonesSNES_Incompleto(14 downto 1);
        end if;
    end process;
    
    -- Guarda en BotonesSNES_signal el último registro entero del mando
    process (finishSignal,rst)
    begin
        if rst = '1' then
            BotonesSNES <= (others => '0');
        elsif rising_edge (finishSignal) then
            BotonesSNES  <= BotonesSNES_Incompleto(7 downto 4);
        end if;
    end process;
    --pre_finish <= '1' when EstadoActual = State_4 else '0';  -- RNC:

    -- Las señales se vuelcan a las variables de salida
    clk_snes    <= clk_snesSignal;      -- Reloj del mando
    
    finish <= finishSignal;

end Mando;


