library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;


-- NOTE THAT FOR THE PC_ADDR WE HAVE ELECTED NOT TO SHIFT LEFT BY 2
-- AS THE INSTRUCTION MEMORY IS ALREADY WORD-INDEXED.

entity BRANCH_CONTROL is
    port(
        -- INPUTS
        PC_ADDR: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        OFFSET:  in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        INSTR_INDEX: in STD_LOGIC_VECTOR(25 DOWNTO 0);
        RS_DATA: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        RT_DATA: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        BRANCH_CTRL: in STD_LOGIC_VECTOR(3 DOWNTO 0);
        
        -- OUTPUTS
        PC_SEL: out STD_LOGIC;
        PC_ADDR_O: out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0)
    );
end BRANCH_CONTROL;

architecture BRANCH_ARCH of BRANCH_CONTROL is

-- UNSIGNED/SIGNED 32x32x32 ADDSUB MODULE.
COMPONENT ADD32x32x32_U_S
  PORT (
    A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    CE: IN STD_LOGIC; 
    S : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
END COMPONENT;

signal ZERO: STD_LOGIC;
signal GTZ : STD_LOGIC;
signal LTZ : STD_LOGIC;

signal EQ  : STD_LOGIC;

signal PC_ADDR_B: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
signal PC_ADDR_J: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);


begin

-- HELPER SIGNALS FOR PC_SEL
ZERO <= '1' when signed(RS_DATA) = 0 else '0';
GTZ  <= '1' when signed(RS_DATA) > 0 else '0'; 
LTZ  <= '1' when signed(RS_DATA) < 0 else '0'; 
EQ   <= '1' when RS_DATA = RT_DATA else '0';

-- GET PC_SEL
with BRANCH_CTRL SELECT PC_SEL <=
        EQ          when "0101",  -- BEQ           
        not EQ      when "0110",  -- BNE
        LTZ OR ZERO when "0111",  -- BLEZ
        GTZ         when "1000",  -- BGTZ
        LTZ         when "1001",  -- BLTZ
        GTZ OR ZERO when "1010",  -- BGEZ
        '1'         when "0001",  -- J
        '1'         when "0010",  -- JAL
        '1'         when "0011",  -- JR
        '1'         when "0100",  -- JALR
        '0'         when others;

-- HELPER SIGNALS FOR PC_ADDR_O
PC_ADDR_J <= PC_ADDR(31 downto 26) & INSTR_INDEX;
PC_ADDER: ADD32x32x32_U_S
  PORT MAP (
    A => PC_ADDR,
    B => OFFSET,
    CE => '1',
    S => PC_ADDR_B
  );

-- GET PC_ADDR_O  
with BRANCH_CTRL SELECT PC_ADDR_O <=
        PC_ADDR_B when "0101",  -- BEQ           
        PC_ADDR_B when "0110",  -- BNE
        PC_ADDR_B when "0111",  -- BLEZ
        PC_ADDR_B when "1000",  -- BGTZ
        PC_ADDR_B when "1001",  -- BLTZ
        PC_ADDR_B when "1010",  -- BGEZ
        PC_ADDR_J when "0001",  -- J
        PC_ADDR_J when "0010",  -- JAL
        RS_DATA   when "0011",  -- JR
        RS_DATA   when "0100",  -- JALR
        PC_ADDR   when others;

end BRANCH_ARCH;
