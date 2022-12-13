----------------------------------------------------------------------------------
-- PRÁCTICA FINAL:  Decide los valores para los colores que se ven por pantalla
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

entity pinta_barras is
  Port (
    -- Entradas
    visible      : in std_logic;
    col          : in unsigned(10-1 downto 0);
    fila         : in unsigned(10-1 downto 0);
    f_personaje  : in unsigned (5 downto 0);
    c_personaje  : in unsigned (5 downto 0);
    clk2         : in std_logic; 
    rst          : in std_logic;
    -- Salidas
    rojo         : out std_logic_vector(8-1 downto 0);
    verde        : out std_logic_vector(8-1 downto 0);
    azul         : out std_logic_vector(8-1 downto 0) );
end pinta_barras;

architecture behavioral of pinta_barras is
  -- Declaración de los componentes
  component mux_3bit is
  Port (  E0    : in STD_LOGIC_VECTOR(2 downto 0);  
          E1    : in STD_LOGIC_VECTOR(2 downto 0);  
          SEL   : in STD_LOGIC;                    
          S0    : out STD_LOGIC_VECTOR(2 downto 0));
  end component;       
  
  component ROM1b_1f_racetrack_1 is
  port ( clk  : in  std_logic;   
         addr : in  unsigned(5-1 downto 0);
         dout : out unsigned(32-1 downto 0)); 
  end component; 
       
  component ROM1b_1f_imagenes16_16x16_bn   
  port ( clk  : in  std_logic;          
         addr : in  unsigned(8-1 downto 0);      
         dout : out unsigned(16-1 downto 0)); 
  end component;

  component Fantasma_FSM is
  Port ( rst             : in std_logic;                                               
         clk             : in std_logic; -- 25 Mhz                                                
         fila_Fantasma   : out unsigned (5 downto 0);                                      
         col_Fantasma    : out unsigned (5 downto 0));                                               
  end component;

  -- 4 bits menos significativos son los 16 pixeles a ancho y alto de cada cuadrado (borde de cuadrado cuando c_int o f_int sea "0000")
  signal c_int : unsigned(3 downto 0) := col(3 downto 0);
  signal f_int : unsigned(3 downto 0) := fila(3 downto 0);  
  signal c_ext : unsigned(5 downto 0) := col(9 downto 4);
  signal f_ext : unsigned(5 downto 0) := fila(9 downto 4);
  
  -- Señales para el acceso a memoria
  signal  dir_pacman    : unsigned (8-1 downto 0)  := ("0011" & f_int); -- Concatenación de las dos partes de la dirección
  signal dout_pacman    : unsigned(16-1 downto 0);
  -- Circuito
  signal  dir_map      : unsigned (5-1 downto 0) := fila(8 downto 4); 
  signal dout_map      : unsigned(32-1 downto 0);
  --Fantasma
  signal fila_Fantasma : unsigned (5 downto 0);
  signal col_Fantasma  : unsigned (5 downto 0);
  signal dir_fantasma  : unsigned (8-1 downto 0)  := ("0100" & f_int);
  signal dout_fantasma : unsigned(16-1 downto 0);
  
  -- Constantes para pintar
  constant ColorPared     : std_logic_vector(2 downto 0) := "000"; 
  constant ColorPasillo   : std_logic_vector(2 downto 0) := "111";
  constant ColorPacman    : std_logic_vector(2 downto 0) := "100";
  constant ColorFantasma  : std_logic_vector(2 downto 0) := "001";
    

  -- Señal del multiplexor
  signal fondo     : std_logic_vector(2 downto 0);
  
  signal SEL1 : std_logic;
  
begin

  mux1 : mux_3bit port map ( E0  => ColorPared,  
                             E1  => ColorPasillo,
                             SEL => SEL1,  --dout_map(TO_INTEGER(col(8 downto 4)),
                             S0  => fondo);  
                                           
                             
   
  Controlador_Fantasma : Fantasma_FSM port map( rst => rst,        
                                                clk => clk2,         
                                                fila_Fantasma => fila_Fantasma,
                                                col_Fantasma  => col_Fantasma);

  Memoria_mapa : ROM1b_1f_racetrack_1 port map(clk  => clk2,
                                               addr => dir_map,
                                               dout => dout_map
                                               ); 
                                               
  Memoria_pacman : ROM1b_1f_imagenes16_16x16_bn port map( clk  => clk2,
                                                          addr => dir_pacman,
                                                          dout => dout_pacman); 
                                                           
  Memoria_fantasma : ROM1b_1f_imagenes16_16x16_bn port map( clk  => clk2,
                                                            addr => dir_fantasma,
                                                            dout => dout_fantasma);                                                          
                                                                                                                   
  process(dout_pacman,dout_fantasma,dout_map)
  begin
    
    if(c_ext<32) then                                     -- A partir de la columna grande 32 el mapa se repitiría porque se ha multiplicado por 16 pero 
        SEL1 <=  dout_map(TO_INTEGER(col(8 downto 4)));   -- Se necesitaría multiplicar por 20 que no es potencia de 2.
    else
        SEL1 <= '0';
    end if;
  end process;
                                              

  P_pinta: Process (visible, col, fila)
  begin    
    
    if visible = '1' then
       
       if(c_ext = c_personaje AND f_ext = f_personaje) then
            if( dout_pacman(TO_INTEGER(c_int))= '0') then 
                rojo   <= (others=>ColorPacman(0));        
                verde  <= (others=>ColorPacman(1));
                azul   <= (others=>ColorPacman(2));
            else
                rojo   <= (others=>fondo(0));
                verde  <= (others=>fondo(1));
                azul   <= (others=>fondo(2));
            end if; 
       elsif(c_ext = col_Fantasma AND f_ext = fila_Fantasma) then     
            if( dout_fantasma(TO_INTEGER(c_int))= '0') then 
                rojo   <= (others=>ColorFantasma(0));        
                verde  <= (others=>ColorFantasma(1));
                azul   <= (others=>ColorFantasma(2));
            else
                rojo   <= (others=>fondo(0));
                verde  <= (others=>fondo(1));
                azul   <= (others=>fondo(2));
            end if;                
       else
            rojo   <= (others=>fondo(0));
            verde  <= (others=>fondo(1));
            azul   <= (others=>fondo(2));

       end if;       
    end if;
  end process;
    
  
end Behavioral;

