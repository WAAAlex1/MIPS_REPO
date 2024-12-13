library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.records.all;
use work.constants_pkg.all;

entity TOP_LEVEL_TB is
end TOP_LEVEL_TB;

architecture Behavioral of TOP_LEVEL_TB is

constant period: time:=10ns;

component TOP_LEVEL is
    port(
        -- INPUTS GENERATED BY BOARD
        CLK: in STD_LOGIC;
        -- INPUTS FROM IO
        SWITCHES: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        -- OUTPUTS TO IO ( 7-SEGMENT AND LEDS)
        LEDS:  out STD_LOGIC_VECTOR(15 DOWNTO 0);
        SEV_SEG_DATA: out STD_LOGIC_VECTOR(7 DOWNTO 1);
        SEV_SEG_CTRL: out STD_LOGIC_VECTOR(4 DOWNTO 1)
    );
end component TOP_LEVEL;

signal CLK: STD_LOGIC;
signal SWITCHES: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal LEDS: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal SEV_SEG_DATA: STD_LOGIC_VECTOR(7 downto 1);
signal SEV_SEG_CTRL: STD_LOGIC_VECTOR(4 DOWNTO 1);

begin

dut: TOP_LEVEL port map(

    CLK => CLK,
    SWITCHES => SWITCHES,
    LEDS => LEDS,
    SEV_SEG_DATA => SEV_SEG_DATA,
    SEV_SEG_CTRL => SEV_SEG_CTRL
    
);

    process
    begin
        clk<='0';
        wait for period/2;
        clk<='1';
        wait for period/2;
    end process;
    
    process
    begin			
		SWITCHES <= (15|13|12|6|8|4|1|2 => '1',others => '0');
		wait for 5*period;
		SWITCHES(6) <= '0';           -- STOP RESETTING
        wait;
    end process;


end Behavioral;
