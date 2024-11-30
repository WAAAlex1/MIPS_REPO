library IEEE;
use IEEE.STD_LOGIC_1164.all;                              
use IEEE.numeric_std.all;
library work;
use work.constants_pkg.all;

entity IF_ID_R is
    port(
        CLK            : in STD_LOGIC;
        RESET          : in STD_LOGIC;
        PC_IN          : in STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);
        PC_OUT         : out STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0)
    );
end IF_ID_R;  

architecture IF_ID_R_ARCH of IF_ID_R is
begin
    process(CLK,RESET)
      begin
        if rising_edge(CLK) then
            -- WHEN BRANCHING (PC_SEL = '1') WE NEED TO FLUSH THE IF_STAGE REGISTERS.
            -- WHEN RESETTING, WE NEED TO FLUSH THE IF_STAGE REGISTERS.
            if RESET = '1' then          
                PC_OUT <= (others => '0');
            else
                PC_OUT <= PC_IN; --Note that the instruction already has a clock cycle delay, effectively registered
            end if;
        end if;
    end process;
end IF_ID_R_ARCH;