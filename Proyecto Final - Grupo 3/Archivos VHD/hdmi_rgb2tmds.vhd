library ieee;
use ieee.std_logic_1164.all;

entity hdmi_rgb2tmds is
    generic (
        SERIES6 : boolean := false
    );
    port(
        -- reset and clocks
        rst : in std_logic;
        pixelclock : in std_logic;  -- slow pixel clock 1x
        serialclock : in std_logic; -- fast serial clock 5x

        -- video signals
        video_data : in std_logic_vector(23 downto 0);
        video_active  : in std_logic;
        hsync : in std_logic;
        vsync : in std_logic;

        -- tmds output ports
        clk_p : out std_logic;
        clk_n : out std_logic;
        data_p : out std_logic_vector(2 downto 0);
        data_n : out std_logic_vector(2 downto 0)
    );
end hdmi_rgb2tmds;

architecture rtl of hdmi_rgb2tmds is
    signal enred, engreen, enblue : std_logic_vector(9 downto 0) := (others => '0');
    signal sync : std_logic_vector(1 downto 0);

begin

    sync <= vsync & hsync;

    -- tmds encoder
    tb : entity work.hdmi_tmds_encoder(rtl)
        port map (clk=>pixelclock, en=>video_active, ctrl=>sync, din=>video_data(7  downto 0), dout=>enblue);
    tr : entity work.hdmi_tmds_encoder(rtl)
        port map (clk=>pixelclock, en=>video_active, ctrl=>"00", din=>video_data(23 downto 16), dout=>enred);
    tg : entity work.hdmi_tmds_encoder(rtl)
        port map (clk=>pixelclock, en=>video_active, ctrl=>"00", din=>video_data(15 downto 8), dout=>engreen);

    -- tmds output serializers
    ser_b: entity work.hdmi_serializer(rtl)
        generic map (SERIES6=>SERIES6)
        port map (pixclk=>pixelclock, serclk=>serialclock, rst=>rst, endata_i=>enblue,  s_p=>data_p(0), s_n=>data_n(0));
    ser_g: entity work.hdmi_serializer(rtl)
        generic map (SERIES6=>SERIES6)
        port map (pixclk=>pixelclock, serclk=>serialclock, rst=>rst, endata_i=>engreen, s_p=>data_p(1), s_n=>data_n(1));
    ser_r: entity work.hdmi_serializer(rtl)
        generic map (SERIES6=>SERIES6)
        port map (pixclk=>pixelclock, serclk=>serialclock, rst=>rst, endata_i=>enred,   s_p=>data_p(2), s_n=>data_n(2));
    -- tmds clock serializer to phase align with data signals
    ser_c: entity work.hdmi_serializer(rtl)
        generic map (SERIES6=>SERIES6)
        port map (pixclk=>pixelclock, serclk=>serialclock, rst=>rst, endata_i=>"1111100000", s_p=>clk_p, s_n=>clk_n);

end rtl;
