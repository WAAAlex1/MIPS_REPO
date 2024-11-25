library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package CONSTANTS_PKG is

	-- Package which contains constants used profusely throughout the entire program.
	-- Using a package allows us to not define these explicitly in each file. 
	
	constant INST_SIZE	: INTEGER := 32;		
	constant ADDR_SIZE	: INTEGER := 5;			
	constant NUM_REG	: INTEGER := 32;		
	constant NUM_ADDR	: INTEGER := 1024;		
	
	-- Constant used for 
	constant PC_COUNT	: STD_LOGIC_VECTOR(31 downto 0) :=  "00000000000000000000000000000100";	

    -- Constants used for bit extension, signed and unsigned. 
	constant L32b	: STD_LOGIC_VECTOR(31 downto 0) :=  "00000000000000000000000000000000";	
	constant L16b	: STD_LOGIC_VECTOR(15 downto 0) :=  "0000000000000000";
	constant H32b		: STD_LOGIC_VECTOR(31 downto 0) :=  "11111111111111111111111111111111";	
	constant H16b		: STD_LOGIC_VECTOR(15 downto 0) :=  "1111111111111111";	

end CONSTANTS_PKG;