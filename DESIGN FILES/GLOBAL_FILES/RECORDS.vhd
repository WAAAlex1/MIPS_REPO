
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package RECORDS is
    
    -- ALU_OPSELECT ENCODED
    type ALU_OPSELECT is (ADDU, ADDS, SUBU, SUBS, AND0, OR0, SLTU, SLTS, SLL0, SRL0, SL16);
    
    
    	
	type ALU_FLAGS is
    record
        --LESS        :   STD_LOGIC;
        --GREATER     :   STD_LOGIC;
        EQUAL       :   STD_LOGIC;
    end record;
    
    type EX_CTRL_REG is
    record
       	ALUTYPE		:	STD_LOGIC; -- 1 for R type, 0 for I type
		ALUSrc		:	STD_LOGIC; -- 1 for using immediate value, 0 for not
		ALULS       :   STD_LOGIC; -- 1 for Logical shifting, 0 for not
    end record;

    type MEM_CTRL_REG is
    record
        Branch		:	STD_LOGIC_VECTOR(1 DOWNTO 0);  -- 01 for BNE, 10 for BEQ, 00 for not branching
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