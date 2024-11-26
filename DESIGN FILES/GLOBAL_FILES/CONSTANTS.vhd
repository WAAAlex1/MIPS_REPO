library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package CONSTANTS_PKG is

	-- Package which contains constants used profusely throughout the entire program.
	-- Using a package allows us to not define these explicitly in each file. 
	
	constant INST_SIZE	: INTEGER := 32;		
	constant ADDR_SIZE	: INTEGER := 5;			
	constant NUM_REG	: INTEGER := 32;		
	constant MEM_SIZE	: INTEGER := 4096;	
	constant CELL_SIZE  : INTEGER := 8;	
	
	-- Constant used for 
	constant PC_COUNT	: STD_LOGIC_VECTOR(31 downto 0) :=  "00000000000000000000000000000100";	

    -- Constants used for bit extension, signed and unsigned. 
	constant L32b	: STD_LOGIC_VECTOR(31 downto 0) :=  b"0000_0000_0000_0000_0000_0000_0000_0000";	
	constant L16b	: STD_LOGIC_VECTOR(15 downto 0) :=  b"0000_0000_0000_0000";
	constant L8b    : STD_LOGIC_VECTOR(7 DOWNTO 0)  :=  b"0000_0000";
	constant H32b		: STD_LOGIC_VECTOR(31 downto 0) :=  b"1111_1111_1111_1111_1111_1111_1111_1111";	
	constant H16b		: STD_LOGIC_VECTOR(15 downto 0) :=  b"1111_1111_1111_1111";	

end CONSTANTS_PKG;