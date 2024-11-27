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
    W_R_CTRL:   out STD_LOGIC_VECTOR(1 DOWNTO 0);
    Branch  :   out STD_LOGIC_VECTOR(1 DOWNTO 0);

    --CONTROL SIGNALS FOR WB STAGE
    RegWrite:   out STD_LOGIC;
    MemToReg:   out STD_LOGIC_VECTOR(1 DOWNTO 0)
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
    SLL0    <= '1' when FUNCT  = "000000" else '0';
    SRL0    <= '1' when FUNCT  = "000010" else '0';

    R_TYPE  <= '1' when OPCODE = "000000" else '0'; --When opcode = 0 must be R-type
    
-- USE INTERNAL SIGNALS TO SET OUTPUTS:

    -- W_R_CTRL = 10 WE ARE STORING A WORD
    -- W_R_CTRL = 01 WE ARE STORING A BYTE
    -- W_R_CTRL = 11 WE ARE LOADING A WORD
    -- W_R_CTRL = 00 WE ARE LOADING A BYTE 
    
    W_R_CTRL <= "10" when SW = '1' else
                "01" when SB = '1' else
                "00" when LB = '1' else
                "11" when LW = '1' else
                "00";
    
    -- ALUSRC should be high whenever we need to use an immediate value for our ALU operation (I type instructions)
    -- Note: Branch instructions use Immediate values BUT NOT IMM FOR THE ALU (NEEDS BOTH REGS IN ALU)
    ALUSRC <= (not R_TYPE) and (not (BEQ OR BNE));
    
    -- Branch should be high whenever we are handling a BRANCH instruction
    -- Branch also encodes the type of branching, used later to decided if branch taken or not. 
    -- BRANCH = 10 -> BEQ
    -- BRANCH = 01 -> BNE
    -- BRANCH = 00 -> NOT BRANCHING
    
    BRANCH <= "10" when BEQ = '1' else
              "01" when BNE = '1' else
              "00";

    -- RegWrite should be high whenever:
        -- 1. We are handling an R-type instruction
        -- 2. I-TYPE instruction which does one of the following:
            -- Loading a value into register from memory (LW, LB, LBU)
            -- Stores to a register (ADDI, ADDIU, ANDI, ORI, LUI)
        -- In other words, RegWrite should always be high unless: SB,SW,BNE,BEQ    
    RegWrite <= R_TYPE OR (LW OR LB OR LBU) OR (ADDI OR ADDIU OR ANDI OR ORI OR LUI);
    
    -- MemToReg should be high whenever we are reading a value in mem and storing it in a register. 
        -- This is the same as READ (we have no instructions reading from memory which does not store to reg)
        
        -- MemToReg = 11 When reading full word -> no sign extension
        -- MemToReg = 10 WHEN SIGN_EXTENSION OF MEMORY IS NEEDED.
        -- MemToReg = 01 WHEN SIGN_EXTENSION OF MEMORY IS NOT NEEDED
        -- MemToReg = 00 WHEN WE ARE NOT TRANSFERRING MEM TO REG. 
        
    MemToReg <= "01" when LBU = '1' else
                "10" when LB = '1' else
                "11" when LW = '1' else
                "00";     
    
    --ALUTYPE DESCRIBES WHAT INSTRUCTION TYPE WE ARE DEALING WITH
    -- '1' FOR R TYPE
    -- '0' FOR I TYPE
    -- NOTICE THAT J-TYPE INSTRUCTIONS ARE NOT INCLUDED IN THIS LIMITED INSTRUCTION SET.
    ALUTYPE <= R_TYPE; 
    
    --ALULS IS A SPECIAL CASE -> WHEN LOGICAL SHIFTING WE WANT TO SET SOURCE 1 OF THE ALU TO OFFSET
    --AND SOURCE 2 TO RT_DATA. THIS CONTROLSIGNAL IS USED TO SET SOURCE 1 PROPERLY IN THE EX STAGE.
    ALULS <= R_TYPE and (SLL0 OR SRL0);
    
end ARCH_CU;

