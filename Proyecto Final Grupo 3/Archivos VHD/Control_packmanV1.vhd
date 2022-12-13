----------------------------------------------------------------------------------
-- PRÁCTICA FINAL:  descripción del funcionamiento del control del PacMan
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

entity Control_packmanV1 is
    Port ( clk_snes     : out STD_LOGIC;
           latch_snes   : out STD_LOGIC;
           data_in_snes : in STD_LOGIC := '0';
           Fmax         : in unsigned(5 downto 0) := TO_UNSIGNED(29,6) ;  
           Cmax         : in unsigned(5 downto 0) := TO_UNSIGNED(39,6);
           clk2         : in STD_LOGIC;  
           rst          : in STD_LOGIC;
           f_p          : out unsigned (5 downto 0);   -- Fila de celdas del personaje    (se lleva al pinta)
           c_p          : out unsigned (5 downto 0));  -- Columna de celdas del personaje (se lleva al pinta)
           
end Control_packmanV1;

architecture Behavioral of Control_packmanV1 is
    -- Declaración del Contador
    component contadorBCD Generic( temp     : in natural;
                                   Nbits    : in natural:= 21);                                      
                             Port( rst      : in STD_LOGIC;                                                                      
                                   enable   : in STD_LOGIC;                                                                   
                                   clk      : in STD_LOGIC;             
                                   fn_cont  : out STD_LOGIC;    
                                   cuenta   : out unsigned (Nbits downto 0));                   
    end component;
    component Mando_SNES is
        Port ( clk          : in STD_LOGIC; 
               rst          : in STD_LOGIC;
               clk_snes     : out STD_LOGIC;
               latch_snes   : out STD_LOGIC;
               data_in_snes : in STD_LOGIC := '0';
               BotonesSNES  : out unsigned (3 downto 0); -- Registro con los datos de los botones del mando   
               finish       : out STD_LOGIC);         
    end component Mando_SNES;
    
    component ROM1b_1f_racetrack_1 is
        port ( clk  : in  std_logic;   
               addr : in  unsigned(5-1 downto 0);
               dout : out unsigned(32-1 downto 0)); 
    end component;
                          
    signal f, c           : unsigned(5 downto 0);
    signal SampClk1       : STD_LOGIC;
    signal SampClk2       : STD_LOGIC;
    signal SampClk_actual : STD_LOGIC;
    signal Botones        : unsigned (3 downto 0);
    
    -- Circuito
    signal  dir_map      : unsigned (5-1 downto 0) := f(4 downto 0); 
    signal dout_map      : unsigned(32-1 downto 0);

begin


    Sampling_clk1 : ContadorBCD generic map (temp  => (25e5)-1, -- 100 ms
                                            Nbits => 22)
                               port map(rst     => rst,
                                        enable  => '1',
                                        clk     => clk2,
                                        fn_cont => SampClk1 );
                                        
    Sampling_clk2 : ContadorBCD generic map (temp  => (100e5)-1, -- 500 ms
                                            Nbits => 22)
                               port map(rst     => rst,
                                        enable  => '1',
                                        clk     => clk2,
                                        fn_cont => SampClk2 );                                    
                                        
    Mando : Mando_SNES port map ( clk           => clk2,
                                  rst           => rst,
                                  clk_snes      => clk_snes,
                                  latch_snes    => latch_snes,
                                  data_in_snes  => data_in_snes,
                                  BotonesSNES   => Botones );
                                  
    Memoria_mapa : ROM1b_1f_racetrack_1 port map(clk  => clk2,                                  
                                                 addr => dir_map,                                  
                                                 dout => dout_map );                                  
                                  
 
    process(clk2) -- Cambia el tiempo de muestreo del input en función de si el pacman está dentro o fuera de pista. Se traduce en cambiar la velocidad de movimiento
    begin
        if (dout_map(TO_INTEGER(c(4 downto 0)))='0') then
            SampClk_actual <= SampClk2;   
        else
            SampClk_actual <= SampClk1;
        end if;                         
    end process;      
                                    
    -- Proceso para mover al objeto en las diferentes direcciones                       
    Contador_fc : process(Botones, rst)       -- Direcciones y reset
    begin
        if(rst='1')then                       -- Si hay un reset
            f <= (others=>'0');               -- Se vuelve a la posición inicial
            c <= (others=>'0');
        elsif rising_edge(SampClk_actual) AND Botones /= "0000" then   -- Cuando hayan pasado 100 ms
            -- IZQUIERDA -------------
            if(Botones = not("0100")) then
                if(c = "000000") then
                    c <= Cmax;                                         -- En caso de desbordamiento por la izq, aparece en el margen derecho
                else  
                    c <= c - 1;  
                end if;
            -- DERECHA ----------------                         
            elsif(Botones = not("1000")) then
                if(c = Cmax) then
                    c <= (others =>'0');                              -- En caso de desbordamiento por la der, aparece en el margen izquierdo
                else
                    c <= c + 1; 
                end if;  
            else
                c <= c;    
            end if; 
            
            -- ABAJO ------------------                                                                                           
            if(Botones = not("0010")) then                                                                                    
                if(f = Fmax) then                                                                                   
                    f <=(others =>'0');                              -- En caso de desbordamiento por abajo, aparece en el margen superior  
                else                                                                                              
                    f <= f + 1;                                                                                     
                end if;                                                                                           
            -- ARRIBA -----------------                                                                                            
            elsif(Botones = not("0001")) then                                                                                   
                if(f = "000000") then                                                                                      
                    f <= Fmax;                                      -- En caso de desbordamiento por arriba, aparece en el margen inferior 
                else                                                                                              
                    f <= f - 1;                                                                                     
                end if;
            else
                f <= f;     
            end if;
        else f <= f;
             c <= c;                                                                                              
        end if;       
    end process;
    
    -- Proceso para actualizar las variables de salida de fila y columna     
    process(f,c)
    begin
        if (rising_edge(clk2))then
            f_p <= f;
            c_p <= c;
        end if;    
    end process;

end Behavioral;
