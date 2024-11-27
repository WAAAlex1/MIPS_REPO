library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;

entity REGISTER_FILE is
    port(
        --INPUTS
        clk         : in STD_LOGIC;
        RESET       : in STD_LOGIC;
        RegWrite    : in STD_LOGIC;
        RS_IDX 	    : in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
        RT_IDX 	    : in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
        RD_IDX 	    : in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
        W_DATA      : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
        --OUTPUTS
        RS_DATA_O   : out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
        RT_DATA_O   : out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
        --OUTPUTS TO TOP
        REGISTERS   : out REG_ARR
        
    );
end REGISTER_FILE;    

architecture ARCH_REG_FILE OF REGISTER_FILE IS

-- CUSTOM ARRAY TYPE FOR REGISTERS
signal REG_FILE: REG_ARR;

signal RS_INDEX: integer:=0;
signal RT_INDEX: integer:=0;

signal RD_INDEX: integer:=0;
begin
    
    RS_INDEX <= to_integer(unsigned(RS_IDX));
    RT_INDEX <= to_integer(unsigned(RT_IDX));
    RD_INDEX <= to_integer(unsigned(RD_IDX));
    
    --Combinatorial logic for reading REG_FILE:
    RS_DATA_O <= REG_FILE(RS_INDEX);  
    RT_DATA_O <= REG_FILE(RT_INDEX);  
            
    -- PROCESS FOR WRITING TO REG_FILE AND RESETTING REG FILE.
    process(clk,RESET,W_DATA,RD_INDEX)
    begin
        if(RESET = '1') THEN -- ASYNCHRONOUS RESET.
            for i in 5 to REG_ARR'High loop
                REG_FILE(i) <= (others=>'0');
                REG_FILE(0) <= (others=>'0');
                REG_FILE(1) <= x"0F_0F_0F_0F";
                REG_FILE(2) <= x"F0_F0_F0_F0";
                REG_FILE(3) <= x"11_44_C0_AB";
                REG_FILE(4) <= x"00_00_00_20";
            end loop;
        elsif rising_edge(clk) then
            if RegWrite = '1' then
                if(RD_INDEX /= 0) then -- Ensuring that REG0 can never be touched
                    REG_FILE(RD_INDEX) <= W_DATA;
                end if;    
            end if;
        end if;    
    end process;
    
    -- OUTPUTS TO TOP
    REGISTERS <= REG_FILE;
    
end ARCH_REG_FILE;