library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity TOP_LEVEL is
port(
    -- INPUTS GENERATED BY BOARD
    CLK: in STD_LOGIC;
    -- INPUTS FROM IO
    SWITCHES: in STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    -- OUTPUTS TO IO ( 7-SEGMENT AND LEDS)
    LEDS:  out STD_LOGIC_VECTOR(15 DOWNTO 0);
    SEV_SEG_DATA: out STD_LOGIC_VECTOR(6 DOWNTO 0);
    SEV_SEG_CTRL: out STD_LOGIC_VECTOR(3 DOWNTO 0)
);
end TOP_LEVEL;

architecture ARCH_TOP of TOP_LEVEL is

-- DECLARE COMPONENTS

-- 7-SEGMENT DRIVER:
component SEVEN_SEG_DRIVER is
	port(
		clk       : in  std_logic;
		data      : in  std_logic_vector(15 downto 0);
		ano       : out std_logic_vector(4 downto 1);
		seg_out   : out std_logic_vector(7 downto 1)
	);
end component SEVEN_SEG_DRIVER;

-- PROCESSOR_TOP:
component PROCESSOR_TOP is
    port(
        CLK         : in STD_LOGIC;
        RESET       : in STD_LOGIC;
        PROG_SEL    : in STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        REGISTERS   : out REG_ARR
    );
end component PROCESSOR_TOP;

component CLOCK_MANAGER is
    port(
        CLK_ENABLE: IN STD_LOGIC;
        CLK_SELECT: IN STD_LOGIC;
        CLK_IN    : IN STD_LOGIC;
        
        CLK_O : OUT STD_LOGIC
    );
end component CLOCK_MANAGER;

-- DEFINE INTERNAL SIGNALS
signal SWITCHES_INT: integer := 0;

--SIGNALS FOR METASTABILITY SYNCHRONIZER OF SWITCHES
signal SWITCHES_0   : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
signal SWITCHES_1   : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
signal SWITCHES_SYNC: STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');

--SIGNALS FOR SEVEN SEG
signal SEVEN_SEG_DRIVER_DATA: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal SEVEN_SEG_DATA_ENC   : STD_LOGIC_VECTOR(7 DOWNTO 1);
signal SEVEN_SEG_CTRL_ENC   : STD_LOGIC_VECTOR(3 DOWNTO 0);

-- SIGNALS FOR PROCESSOR_TOP
signal REGISTERS : REG_ARR;
signal RESET     : STD_LOGIC;
signal P_SEL     : STD_LOGIC_VECTOR(1 DOWNTO 0);

-- SIGNALS FOR PROCESSING THE CLOCKS
signal CLOCK            : STD_LOGIC;
signal CLK_ENABLE       : STD_LOGIC := '0';
signal CLK_SELECT       : STD_LOGIC := '0';

begin

RESET <= SWITCHES_SYNC(6); -- SYNCHRONOUS RESET

-- SWITCHES METASTABILITY SYNCHRONIZER
process(CLK, SWITCHES)
begin
    if rising_edge(CLK) then
        SWITCHES_0 <= SWITCHES;
        SWITCHES_1 <= SWITCHES_0;
        SWITCHES_SYNC <= SWITCHES_1;
    end if;
end process;

SWITCHES_INT <= TO_INTEGER(unsigned(SWITCHES_SYNC(4 DOWNTO 0))); -- SWITCHES_SYNC

-- OUTPUT ASSIGNMENTS
P_SEL <= SWITCHES_SYNC(15 DOWNTO 14);
LEDS <= REGISTERS(SWITCHES_INT)(31 DOWNTO 16);--REGISTERS(SWITCHES_INT)(15 DOWNTO 0); -- LEDS HOLDS BITS 15-0 OF CHOSEN REGISTER
SEV_SEG_DATA <= SEVEN_SEG_DATA_ENC;
SEV_SEG_CTRL <= SEVEN_SEG_CTRL_ENC;

-- SELECT WHICH DATA IS PUT ON 7-SEGMENT
SEVEN_SEG_DRIVER_DATA <= REGISTERS(SWITCHES_INT)(31 DOWNTO 16); -- 7-SEG HOLDS BITS 31-16 OF CHOSEN REGISTER

-- SEVEN_SEG_DRIVER
SEV_SEG_DRIVER: SEVEN_SEG_DRIVER port map(
        -- INPUTS
        clk       => CLK,
		data      => SEVEN_SEG_DRIVER_DATA,
		-- OUTPUTS
		ano       => SEVEN_SEG_CTRL_ENC,
		seg_out   => SEVEN_SEG_DATA_ENC
        );

-- PROCESSOR_TOP
MIPS_TOP: PROCESSOR_TOP port map(
        -- INPUTS
        CLK         => CLOCK,
        RESET       => RESET,
        PROG_SEL    => P_SEL,
        -- OUTPUTS
        REGISTERS   => REGISTERS
        );

CLK_SELECT <= SWITCHES_SYNC(9);
CLK_ENABLE <= SWITCHES_SYNC(8);

CLK_MANAGER: CLOCK_MANAGER port map(
        CLK_ENABLE => CLK_ENABLE,
        CLK_SELECT => CLK_SELECT,
        CLK_IN     => CLK,
        
        CLK_O      => CLOCK
);

end ARCH_TOP;
