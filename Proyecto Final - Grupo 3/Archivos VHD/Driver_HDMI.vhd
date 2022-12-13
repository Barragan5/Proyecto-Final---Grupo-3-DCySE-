----------------------------------------------------------------------------------
-- PRÁCTICA FINAL:  Arquitectura Global del proyecto
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

entity Driver_HDMI is
    Port ( ------ Entradas -------
           clk      : in STD_LOGIC;
           rst      : in STD_LOGIC;
           data_in_snes    : in STD_LOGIC;
           ------ Salidas ---------
           clk_snes : out STD_LOGIC;
           latch_snes : out STD_LOGIC;
           clk_p    : out STD_LOGIC;
           clk_n    : out STD_LOGIC;
           data_p   : out STD_LOGIC_VECTOR(2 downto 0);
           data_n   : out STD_LOGIC_VECTOR(2 downto 0) );
end Driver_HDMI;

architecture Behavioral of Driver_HDMI is

    component Control_packmanV1
                            Port ( 
                                   clk_snes     : out STD_LOGIC;
                                   latch_snes   : out STD_LOGIC;
                                   data_in_snes : in STD_LOGIC := '0';
                                   Fmax : in unsigned(5 downto 0) := TO_UNSIGNED(29,6) ;  
                                   Cmax : in unsigned(5 downto 0) := TO_UNSIGNED(39,6);
                                   clk2 : in STD_LOGIC;  
                                   rst  : in STD_LOGIC;
                                   f_p  : out unsigned (5 downto 0);
                                   c_p  : out unsigned (5 downto 0) );
    end component;
    
    component hdmi_rgb2tmds generic (                                                 
                                SERIES6 : boolean := false                            
                            );                                                        
                            port(
                                rst             : in std_logic;
                                pixelclock      : in std_logic; 
                                serialclock     : in std_logic;
                                video_data      : in std_logic_vector(23 downto 0);
                                video_active    : in std_logic;
                                hsync           : in std_logic;
                                vsync           : in std_logic;
                                clk_p           : out std_logic;
                                clk_n           : out std_logic;
                                data_p          : out std_logic_vector(2 downto 0);
                                data_n          : out std_logic_vector(2 downto 0) );                                                        
    end component;
    
    component clock_gen generic (                                                
                        CLKIN_PERIOD    : real := 8.000;   -- input clock period (8ns)
                        CLK_MULTIPLY    : integer := 8;    -- multiplier               
                        CLK_DIVIDE      : integer := 1;    -- divider                    
                        CLKOUT0_DIV     : integer := 8;    -- serial clock divider      
                        CLKOUT1_DIV     : integer := 40 ); -- pixel clock divider                                                        
                        port(                                                    
                        clk_i   : in std_logic;            -- input clock                     
                        rst     : in std_logic;                      
                        clk0_o  : out std_logic;           -- serial clock                  
                        clk1_o  : out std_logic );         -- pixel clock                                       
     end component; 
                                                                            
    component pinta_barras Port (                                
                             visible      : in std_logic;                         
                             col          : in unsigned(10-1 downto 0);           
                             fila         : in unsigned(10-1 downto 0);
                             f_personaje  : in unsigned (5 downto 0);
                             c_personaje  : in unsigned (5 downto 0);
                             clk2         : in std_logic; 
                             rst          : in std_logic;                                          
                             rojo         : out std_logic_vector(8-1 downto 0);   
                             verde        : out std_logic_vector(8-1 downto 0);   
                             azul         : out std_logic_vector(8-1 downto 0)    
                           );                                                     
    
    end component;
    
    component SYNC_VGA Port ( clk       : in STD_LOGIC;               
                             rst        : in STD_LOGIC;                
                             cols       : out UNSIGNED (9 downto 0);  
                             filas      : out UNSIGNED (9 downto 0); 
                             Visible    : out STD_LOGIC;           
                             HSYNC      : out STD_LOGIC;             
                             VSYNC      : out STD_LOGIC);   
    end component;
    
    -- Controlador del PacMan
    signal f_p : unsigned(5 downto 0);
    signal c_p : unsigned(5 downto 0);
    
    -- HDMI
    signal Sclk_p   : std_logic;                    
    signal Sclk_n   : std_logic;                    
    signal Sdata_p  : std_logic_vector(2 downto 0);
    signal Sdata_n  : std_logic_vector(2 downto 0);
     
    -- Pinta
    signal VRGB : std_logic_vector (23 downto 0);
     
    -- clock_gen                       
    signal clk1 : std_logic;                         
    signal clk2 : std_logic;                         
     
    -- SYNC_VGA                         
    signal  cols    : unsigned (9 downto 0);
    signal  filas   : unsigned (9 downto 0); 
    signal Visible  :  STD_LOGIC;  
    signal HSYNC    : STD_LOGIC; 
    signal VSYNC    : STD_LOGIC;
                                  
begin

MOTION : Control_packmanV1  port map( 
                                      clk_snes      => clk_snes,
                                      latch_snes    => latch_snes,
                                      data_in_snes  => data_in_snes,                                                                                                                 
                                      clk2 => clk2,                                                                    
                                      rst => rst,
                                      Fmax(5 downto 0) => TO_UNSIGNED(30,6),
                                      Cmax(5 downto 0) => TO_UNSIGNED(40,6),                                                                       
                                      f_p => f_p,
                                      c_p => c_p);

SYNC : SYNC_VGA port map(   clk => clk2, 
                            rst => rst,   
                            cols => cols, 
                            filas => filas,
                            Visible => Visible            
                            );            
                            
PLL : clock_gen port map(                                   
                         clk_i => clk, 
                         rst => rst,    
                         clk0_o => clk1, 
                         clk1_o => clk2  
                         );  

PINTA : pinta_barras port map(                                     
                               visible => Visible,                  
                               col => cols,        
                               fila  => filas,
                               clk2 => clk2,
                               rst  => rst, 
                               rojo => VRGB(23 downto 16),       
                               verde => VRGB(15 downto 8),       
                               azul => VRGB(7 downto 0),
                               f_personaje => f_p,
                               c_personaje => c_p ); 
                              
 TDMS : hdmi_rgb2tmds port map(                                                                                                       
                                rst => rst,                                               
                                pixelclock => clk2,                
                                serialclock => clk1,                                                  
                                video_data => VRGB,                   
                                video_active => Visible,                                     
                                hsync => HSYNC,                                             
                                vsync => VSYNC,                                             
                                clk_p  => clk_p,                       
                                clk_n  => clk_n,                       
                                data_p => data_p,                       
                                data_n => data_n );                                                                    
 
end Behavioral;
