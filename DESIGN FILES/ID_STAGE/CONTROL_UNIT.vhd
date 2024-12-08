library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants_pkg.all;
use work.records.all;

entity CONTROL_UNIT is
    port(
    --Inputs
    INSTRUCTION: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    --Outputs
    
    --CONTROL SIGNALS FOR IF STAGE
    BRANCH  :   out STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    --CONTROL SIGNALS FOR EX STAGE
    ALUTYPE :   out STD_LOGIC_VECTOR(1 DOWNTO 0);
    ALUSRC  :   out STD_LOGIC;
    ALULS   :   out STD_LOGIC;
    
    --CONTROL SIGNALS FOR MEM/WR STAGE
    W_R_CTRL:   out STD_LOGIC_VECTOR(3 DOWNTO 0);
    RegWrite:   out STD_LOGIC
    );
end CONTROL_UNIT;

    architecture ARCH_CU of CONTROL_UNIT is 
-- DEFINE INTERNAL SIGNALS FOR LOGIC
   signal OPCODE  :  STD_LOGIC_VECTOR(5 downto 0);
   signal FUNCT   :  STD_LOGIC_VECTOR(5 downto 0);
   signal B_FIELD :  STD_LOGIC_VECTOR(4 DOWNTO 0);
   
   signal BRANCH_INTERNAL: STD_LOGIC_VECTOR(3 DOWNTO 0);


   signal ADDI: STD_LOGIC;
   signal ADDIU: STD_LOGIC;
   signal SLTI: STD_LOGIC;
   signal SLTIU: STD_LOGIC;
   signal ANDI: STD_LOGIC;
   signal ORI: STD_LOGIC;
   signal XORI: STD_LOGIC;
   signal LUI: STD_LOGIC;
   
   signal LB: STD_LOGIC;
   signal LBU: STD_LOGIC;
   signal LH: STD_LOGIC;
   signal LHU: STD_LOGIC;
   signal LW: STD_LOGIC;
   signal SB: STD_LOGIC;
   signal SH: STD_LOGIC;
   signal SW: STD_LOGIC;
   signal SLL0: STD_LOGIC;
   signal SRL0: STD_LOGIC;
   signal SRA0: STD_LOGIC;
   signal J   : STD_LOGIC;
   signal JR  : STD_LOGIC;
   signal JALR: STD_LOGIC;
   signal JAL : STD_LOGIC;
   
   signal BEQ : STD_LOGIC;
   signal BNE : STD_LOGIC;
   signal BLEZ: STD_LOGIC; 
   signal BGTZ: STD_LOGIC; 
   signal BLTZ: STD_LOGIC; 
   signal BGEZ: STD_LOGIC;   
     
   signal R_TYPE: STD_LOGIC;
   
begin

-- OPCODE AND FUNCT AND BRANCH-FIELD
    OPCODE <= INSTRUCTION(31 DOWNTO 26);
    FUNCT  <= INSTRUCTION(5 DOWNTO 0);
    B_FIELD <= INSTRUCTION(20 DOWNTO 16);
    
-- USE OPCODE TO SET INTERNAL SIGNALS
    ADDI    <= '1' when OPCODE = "001000" else '0';
    ADDIU   <= '1' when OPCODE = "001001" else '0';
    SLTI    <= '1' when OPCODE = "001010" else '0';
    SLTIU   <= '1' when OPCODE = "001011" else '0';
    ANDI    <= '1' when OPCODE = "001100" else '0';
    ORI     <= '1' when OPCODE = "001101" else '0';
    XORI    <= '1' when OPCODE = "001101" else '0';
    LUI     <= '1' when OPCODE = "001111" else '0';
    LB      <= '1' when OPCODE = "100000" else '0';
    LBU     <= '1' when OPCODE = "100100" else '0';
    LH      <= '1' when OPCODE = "100001" else '0';
    LHU     <= '1' when OPCODE = "100101" else '0';
    LW      <= '1' when OPCODE = "100011" else '0';
    SB      <= '1' when OPCODE = "101000" else '0';
    SH      <= '1' when OPCODE = "101001" else '0';
    SW      <= '1' when OPCODE = "101011" else '0';
    BEQ     <= '1' when OPCODE = "000100" else '0';
    BNE     <= '1' when OPCODE = "000101" else '0';
    BGTZ    <= '1' when OPCODE = "000111" else '0';
    BLEZ    <= '1' when OPCODE = "000110" AND B_FIELD = "00000" else '0';
    BLTZ    <= '1' when OPCODE = "000001" AND B_FIELD = "00000" else '0';
    BGEZ    <= '1' when OPCODE = "000001" AND B_FIELD = "00001" else '0';
    J       <= '1' when OPCODE = "000010" else '0';
    JAL     <= '1' when OPCODE = "000011" else '0'; 
    SLL0    <= '1' when OPCODE = "000000" AND FUNCT  = "000000" else '0';
    SRL0    <= '1' when OPCODE = "000000" AND FUNCT  = "000010" else '0';
    SRA0    <= '1' when OPCODE = "000000" AND FUNCT  = "000011" else '0';
    JR      <= '1' when OPCODE = "000000" AND FUNCT  = "001000" else '0'; 
    JALR    <= '1' when OPCODE = "000000" AND FUNCT  = "001001" else '0';  
    
    R_TYPE  <= '1' when OPCODE = "000000" else '0'; --When opcode = 0 must be R-type
    
-- USE INTERNAL SIGNALS TO SET OUTPUTS:
    
    -- ALUSRC should be high whenever we need to use an immediate value for our ALU operation (I type instructions)
    -- Note: Branch instructions use Immediate values BUT NOT IMM FOR THE ALU (NEEDS BOTH REGS IN ALU)
    ALUSRC <= '0' when (BRANCH_INTERNAL /= b"0000") else
              '0' when R_TYPE = '1' else
              '1'; 

    -- Branch should be high whenever we are handling a BRANCH instruction
    -- Branch also encodes the type of branching, used later to decided if branch taken or not. 
    -- BRANCH = 10 -> BEQ
    -- BRANCH = 01 -> BNE
    -- BRANCH = 00 -> NOT BRANCHING
    BRANCH_INTERNAL <= 
              "0001" when J   = '1' else
              "0010" when JAL = '1' else
              "0011" when JR  = '1' else
              "0100" when JALR= '1' else
              "0101" when BEQ = '1' else
              "0110" when BNE = '1' else
              "0111" when BLEZ= '1' else
              "1000" when BGTZ= '1' else
              "1001" when BLTZ= '1' else
              "1010" when BGEZ= '1' else
              "0000";
    
    BRANCH <= BRANCH_INTERNAL;           

    -- RegWrite should be high whenever:
        -- 1. We are handling an R-type instruction
        -- 2. I-TYPE instruction which does one of the following:
            -- Loading a value into register from memory (LW, LB, LBU)
            -- Stores to a register (ADDI, ADDIU, ANDI, ORI, LUI, XORI, SLTI, SLTIU)  
    RegWrite <= R_TYPE OR (LW OR LB OR LBU OR LH OR LHU) 
                       OR (ADDI OR ADDIU OR ANDI OR ORI OR LUI OR XORI OR SLTI OR SLTIU) 
                       OR JAL;   
                           
    
    -- W_R_CTRL -> WRITE READ CONTROL SIGNAL FOR RAM
    W_R_CTRL <= "1000" when LB = '1'  else
                "1001" when LBU = '1' else
                "1010" when LH = '1' else
                "1011" when LHU = '1' else
                "1100" when LW = '1' else
                "1101" when SB = '1' else
                "1110" when SH = '1' else
                "1111" when SW = '1' else
                "0000"; -- WHEN NOT LOADING FROM OR WRITING TO MEM
                
    
    --ALUTYPE DESCRIBES WHAT INSTRUCTION TYPE WE ARE DEALING WITH
    -- '11' FOR JAL
    -- '10' FOR JALR
    -- '01' FOR R-TYPE
    -- '00' FOR I TYPE
    ALUTYPE <= "11" when JAL = '1' else
               "10" when JALR = '1' else
               '0'&R_TYPE;
    
    --ALULS IS A SPECIAL CASE -> WHEN LOGICAL SHIFTING IMM WE WANT TO SET SOURCE 1 OF THE ALU TO OFFSET
    --AND SOURCE 2 TO RT_DATA. THIS CONTROLSIGNAL IS USED TO SET SOURCE 1 PROPERLY IN THE EX STAGE.
    ALULS <= SRA0 OR SRL0 OR SLL0; 
             
end ARCH_CU;

