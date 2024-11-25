library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants_pkg.all;
use work.records.all;

entity CONTROL_UNIT is
    port(
    --Inputs
    OPCODE  :   in STD_LOGIC_VECTOR(5 downto 0);
    FUNCT   :   in STD_LOGIC_VECTOR(5 downto 0);
    --Outputs
    
    --CONTROL SIGNALS FOR EX STAGE
    ALUTYPE :   out STD_LOGIC;
    ALUSRC  :   out STD_LOGIC;
    ALULS   :   out STD_LOGIC;
    
    --CONTROL SIGNALS FOR MEM STAGE
    WRITE   :   out STD_LOGIC;
    READ    :   out STD_LOGIC;
    Branch  :   out STD_LOGIC;

    --CONTROL SIGNALS FOR WB STAGE
    RegWrite:   out STD_LOGIC;
    MemToReg:   out STD_LOGIC
    );
end CONTROL_UNIT;

architecture ARCH_CU of CONTROL_UNIT is 
-- DEFINE INTERNAL SIGNALS FOR LOGIC
   signal ADDI: STD_LOGIC;
   signal ADDIU: STD_LOGIC;
   signal ANDI: STD_LOGIC;
   signal ORI: STD_LOGIC;
   signal BEQ: STD_LOGIC;
   signal BNE: STD_LOGIC;
   signal LB: STD_LOGIC;
   signal LBU: STD_LOGIC;
   signal LW: STD_LOGIC;
   signal LUI: STD_LOGIC;
   signal SB: STD_LOGIC;
   signal SW: STD_LOGIC;
   signal SLL0: STD_LOGIC;
   signal SRL0: STD_LOGIC;
   signal R_TYPE: STD_LOGIC;
   signal branch_internal: STD_LOGIC;
   signal write_internal: STD_LOGIC;
begin
    
-- USE OPCODE TO SET INTERNAL SIGNALS
    ADDI    <= '1' when OPCODE = "001000" else '0';
    ANDI    <= '1' when OPCODE = "001100" else '0';
    ADDIU   <= '1' when OPCODE = "001001" else '0';
    ORI     <= '1' when OPCODE = "001101" else '0';
    BEQ     <= '1' when OPCODE = "000100" else '0';
    BNE     <= '1' when OPCODE = "000101" else '0';
    LB      <= '1' when OPCODE = "100000" else '0';
    LBU     <= '1' when OPCODE = "100100" else '0';
    LW      <= '1' when OPCODE = "100011" else '0';
    LUI     <= '1' when OPCODE = "001111" else '0';
    SB      <= '1' when OPCODE = "101000" else '0';
    SW      <= '1' when OPCODE = "101011" else '0';
    SLL0      <= '1' when FUNCT = "000000" else '0';
    SRL0      <= '1' when FUNCT = "000010" else '0';

    R_TYPE  <= '1' when OPCODE = "000000" else '0'; --When opcode = 0 must be R-type
    
   
-- USE INTERNAL SIGNALS TO SET OUTPUTS:
   
    -- WRITE should be HIGH whenever we need to write to MEMORY
    -- SW and SB does this.
    Write_internal <= SW OR SB;
    WRITE <= Write_internal;
    
    -- READ should be HIGH whenever we need to read from MEMORY
    -- LW and LB and LBU does this.
    READ <= LW OR LB OR LBU;
    
    -- ALUSRC should be high whenever we need to use an immediate value for our ALU operation (I type instructions)
    -- Note: Branch instructions use Immediate values BUT NOT THE ALU
    ALUSRC <= (not R_TYPE) and (not Branch_internal);
    
    -- Branch should be high whenever we are handling a BRANCH instruction
    Branch_internal <= BEQ or BNE;
    Branch <= Branch_internal;
    
    -- RegWrite should be high whenever:
        -- 1. We are handling an R-type instruction
        -- 2. I-TYPE instruction which does one of the following:
            -- Loading a value into register from memory (LW, LB, LBU)
            -- Stores to a register (ADDI, ADDIU, ANDI, ORI, LUI)
        -- In other words, RegWrite should always be high unless: SB,SW,BNE,BEQ    
    RegWrite <= R_TYPE OR (LW OR LB OR LBU) OR (ADDI OR ADDIU OR ANDI OR ORI OR LUI);
    
    -- MemToReg should be high whenever we are reading a value in mem and storing it in a register. 
        -- This is the same as READ (we have no instructions reading from memory which does not store to reg)
    MemToReg <= LW OR LB OR LBU;  
    
    --ALUTYPE DESCRIBES WHAT INSTRUCTION TYPE WE ARE DEALING WITH
    -- '1' FOR R TYPE
    -- '0' FOR I TYPE
    -- NOTICE THAT J-TYPE INSTRUCTIONS ARE NOT INCLUDED IN THIS LIMITED INSTRUCTION SET.
    ALUTYPE <= R_TYPE; 
    
    --ALULS IS A SPECIAL CASE -> WHEN SHIFTING LEFT WE WANT TO SET SOURCE 1 OF THE ALU TO OFFSET
    -- AND SOURCE 2 TO RT_DATA. THIS CONTROLSIGNAL IS USED TO SET SOURCE 1 PROPERLY.
    ALULS <= R_TYPE and (SLL0 OR SRL0);
    
end ARCH_CU;

