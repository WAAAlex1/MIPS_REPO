
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity CLOCK_MANAGER is
    port(
        CLK_ENABLE: IN STD_LOGIC;
        CLK_SELECT: IN STD_LOGIC;
        CLK_IN    : IN STD_LOGIC;
        
        CLK_O : OUT STD_LOGIC
    );
end CLOCK_MANAGER;

architecture Behavioral of CLOCK_MANAGER is

    signal CLK_SLOW: STD_LOGIC:='0';
    signal CLK_SLOW_ENABLE: STD_LOGIC:='0';
    signal COUNT: unsigned(25 downto 0):= to_unsigned(0,26);
    
    signal CLK_SELECTED: STD_LOGIC;
begin

---------------- CLOCK DIVIDER ---------------------------------
-- INPUT: 100MHZ CLOCK
-- OUTPUT: 1Hz CLOCK
Process(CLK_IN)
begin
    if rising_edge(CLK_IN) then
        if(COUNT = 50000000 ) then
            COUNT <= to_unsigned(0,26);
            CLK_SLOW_ENABLE <= '1';
        else
            COUNT <= COUNT+1;
            CLK_SLOW_ENABLE <= '0';
        end if;     
    end if;
end process;
----------------------------------------------------------------

-------------- COMPONENT USED FOR GENERATING SLOW CLOCK --------
-- VERY LOW DUTY CYCLE
-- BUFGCE: Global Clock Buffer with Clock Enable 7 Series     
-- Xilinx HDL Language Template, version 2021.1
BUFGCE_SLOW_CLOCK_GEN : BUFGCE
port map (
   O => CLK_SLOW,   -- 1-bit output: Clock output
   CE => CLK_SLOW_ENABLE, -- 1-bit input: Clock enable input for I0
   I => CLK_IN    -- 1-bit input: Primary clock
);
----------------------------------------------------------------

-- COMPONENT USED FOR SELECTING BETWEEN THE GENERATED CLOCKS ---
-- BUFGMUX: Global Clock Mux Buffer 7 Series
-- Xilinx HDL Language Template, version 2021.1
BUFGMUX_CLOCK_SELECTOR : BUFGMUX
port map (
   O => CLK_SELECTED,   -- 1-bit output: Clock output
   I0 => CLK_IN,        -- 1-bit input: Clock input (S=0)
   I1 => CLK_SLOW,      -- 1-bit input: Clock input (S=1)
   S => CLK_SELECT      -- 1-bit input: Clock select
);
----------------------------------------------------------------

-------------- COMPONENT USED FOR CLOCK ENABLE -----------------
-- BUFGCE: Global Clock Buffer with Clock Enable 7 Series     
-- Xilinx HDL Language Template, version 2021.1

BUFGCE_CLOCK_ENABLE : BUFGCE
port map (
   O => CLK_O,   -- 1-bit output: Clock output
   CE => CLK_ENABLE, -- 1-bit input: Clock enable input for I0
   I => CLK_SELECTED    -- 1-bit input: Primary clock
);
----------------------------------------------------------------

end Behavioral;
