
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package RECORDS is
    
    -- ALU_OPSELECT ENCODED
    type ALU_OPSELECT is (ADDU, ADDS, SUBU, SUBS, AND0, OR0, SLTU, SLTS, SLL0, SRL0, SL16);
    type REG_ARR is ARRAY(31 DOWNTO 0) of STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    type EX_CTRL_REG is
    record
       	ALUTYPE		:	STD_LOGIC; -- 1 for R type, 0 for I type
		ALUSrc		:	STD_LOGIC; -- 1 for using immediate value, 0 for not
		ALULS       :   STD_LOGIC; -- 1 for Logical shifting, 0 for not
		ALUOpSelect :   ALU_OPSELECT;
    end record;

    type MEM_CTRL_REG is
    record
        W_R_CTRL	:	STD_LOGIC_VECTOR(1 DOWNTO 0);  -- 00 Reading BYTE, 
                                                       -- 01 Writing BYTE, 
                                                       -- 10 Writing WORD,
                                                       -- 11 Reading WORD	
    end record;
    
    type WB_CTRL_REG is
	record
		RegWrite	:	STD_LOGIC;	
		MemtoReg	:	STD_LOGIC_VECTOR(1 DOWNTO 0);  -- 10 For sign extend, 01 for no sign extend, 00 no MemToReg.	  
    end record;
    
    
end RECORDS;    