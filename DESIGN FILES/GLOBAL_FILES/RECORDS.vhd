
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package RECORDS is
    
    -- ALU_OPSELECT ENCODED
    type ALU_OPSELECT is (ADDU, ADDS, SUBU, SUBS, AND0, OR0, SLTU, SLTS, SLL0, SRL0, SL16);
	
	type INSTR_TYPE   is (ADD,ADDU,ADDI,AND0,ANDI,OR0,ORI,SLL0,SRL0,SUB,SUBU,SLT,SLTU,BEQ,BNQ,LB,LBU,LW,LUI,SB,SW);
	
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
        READ		:	STD_LOGIC_VECTOR(1 DOWNTO 0);  -- 11 For reading word, 01 for reading byte, 00 not reading	
        WRITE	    :	STD_LOGIC_VECTOR(1 DOWNTO 0);  -- 11 For writing word, 01 for writing byte, 00 not writing	
    end record;
    
    type WB_CTRL_REG is
	record
		RegWrite	:	STD_LOGIC;	
		MemtoReg	:	STD_LOGIC_VECTOR(1 DOWNTO 0);  -- 10 For sign extend, 01 for no sign extend, 00 no MemToReg.	  
    end record;
    
    
end RECORDS;    