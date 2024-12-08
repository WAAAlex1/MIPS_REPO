
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package RECORDS is
    
    -- ALU_OPSELECT ENCODED
    type ALU_OPSELECT is (ADDU, ADDS, SUBU, SUBS, AND0, OR0, SLTU, SLT0, SLL0, SLLV, SRL0, SRLV, SL16, XOR0, NOR0, SRA0, SRAV);
    type REG_ARR is ARRAY(31 DOWNTO 0) of STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    type EX_CTRL_REG is
    record
       	ALUTYPE		:	STD_LOGIC_VECTOR(1 DOWNTO 0);
                                                        -- '11' FOR JAL
                                                        -- '10' FOR JALR
                                                        -- '01' FOR R-TYPE
                                                        -- '00' FOR I TYPE
                                                        
		ALUSrc		:	STD_LOGIC; -- 1 for using immediate value, 0 for not
		ALULS       :   STD_LOGIC; -- 1 for Logical shifting, 0 for not
		ALUOpSelect :   ALU_OPSELECT;
    end record;

    type MEM_WB_CTRL_REG is
    record
        W_R_CTRL	:	STD_LOGIC_VECTOR(3 DOWNTO 0);  -- 00 Reading BYTE, 
                                                       -- 01 Writing BYTE, 
                                                       -- 10 Writing WORD,
                                                       -- 11 Reading WORD
       RegWrite	:	STD_LOGIC;                                             	
    end record;
    
    
end RECORDS;    