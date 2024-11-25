library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;


--CURRENTLY NOT CHANGING ANY FLAGS. MIGHT NEED TO CHANGE/IMPLEMENT. 

entity ALU is 
	generic (N: NATURAL:=0);
	port(
	    -- Two sources and one result.
		SOURCE1 	: in STD_LOGIC_VECTOR(N-1 downto 0);
		SOURCE2  	: in STD_LOGIC_VECTOR(N-1 downto 0);
		RESULT  	: out STD_LOGIC_VECTOR(N-1 downto 0);
		
		-- Record of ALU setting (input from ALU_Control)
		-- Record of ALU FLAGS (Output from here)
		ALU_OPSEL	: in ALU_OPSELECT;
		FLAGS   	: out ALU_FLAGS
	);
end;

architecture ALU_ARCH of ALU is
-- INSTANTIATING THE ADDSUB MODULES (XILINX IP)
-- SIGNED 32x32x32 ADDSUB MODULE.
-- S = A - B
-- ADD CONTROLS +- (+ IF HIGH, - IF LOW).

COMPONENT ADDSUB32x32x32
  PORT (
    A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    ADD : IN STD_LOGIC;
    CE: IN STD_LOGIC; 
    S : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
END COMPONENT;

-- UNSIGNED 32x32x32 ADDSUB MODULE.
-- S = A - B
-- ADD CONTROLS +- (+ IF HIGH, - IF LOW).
COMPONENT ADDSUB32x32x32Unsigned
  PORT (
    A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    ADD : IN STD_LOGIC;
    CE: IN STD_LOGIC; 
    S : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

signal SOURCE1_UNSIGNED: unsigned(N-1 downto 0);
signal SOURCE2_UNSIGNED: unsigned(N-1 downto 0);

signal SOURCE1_SIGNED: signed(N-1 downto 0);
signal SOURCE2_SIGNED: signed(N-1 downto 0);

signal RESULT_ADDSUB: STD_LOGIC_VECTOR(N-1 DOWNTO 0);

signal ADD: STD_LOGIC;

begin

FLAGS <= ('0','0','0');

SOURCE1_UNSIGNED <= unsigned(SOURCE1);
SOURCE2_UNSIGNED <= unsigned(SOURCE2);
SOURCE1_SIGNED   <= signed(SOURCE1);
SOURCE2_SIGNED   <= signed(SOURCE2);


-- SELECT IF ADDING OR SUBTRACTING
with ALU_OPSEL select
    ADD <= '0' when SUBU,
           '0' when SUBS,
           '1' when others;

ADDSUB: ADDSUB32x32x32
  PORT MAP (
    A => SOURCE1,
    B => SOURCE2,
    ADD => ADD,
    S => RESULT_ADDSUB,
    CE => '1'
  );

process(ALU_OPSEL, SOURCE1, SOURCE2, RESULT_ADDSUB)
    variable SOURCE1_AS_INT: INTEGER;
begin
    case ALU_OPSEL is
        when ADDS =>    -- ADD (SIGNED)
            RESULT <= RESULT_ADDSUB;
        when SUBS =>    -- SUB (SIGNED)
            RESULT <= RESULT_ADDSUB;
        when ADDU =>    -- ADD (UNSIGNED)
            RESULT <= RESULT_ADDSUB;
        when SUBU =>    -- SUB (UNSIGNED)
            RESULT <= RESULT_ADDSUB;
        when OR0 =>     -- LOGICAL OR
            RESULT <= SOURCE1 OR SOURCE2;
        when AND0 =>    -- LOGICAL AND
            RESULT <= SOURCE1 AND SOURCE2;
        when SLTS =>    -- SIGNED COMPARISON (SLT)
            if(SOURCE1_SIGNED < SOURCE2_SIGNED) then
               RESULT <= (Result'low => '1', others => '0');
            else
               RESULT <= (others => '0');  
            end if;
        when SLTU =>    -- UNSIGNED COMPARISON (SLT)
            if(SOURCE1_UNSIGNED < SOURCE2_UNSIGNED) then
               RESULT <= (Result'low => '1', others => '0');
            else
               RESULT <= (others => '0');  
            end if;    
        when SLL0 =>    --LEFT LOGICAL SHIFTING
            SOURCE1_AS_INT := TO_INTEGER(SOURCE1_UNSIGNED(10 DOWNTO 6)); -- ACCESS SHAMT FIELD
            RESULT <= STD_LOGIC_VECTOR(shift_left(SOURCE2_UNSIGNED,SOURCE1_AS_INT)); 
        when SRL0 =>    --RIGHT LOGICAL SHIFTING
            SOURCE1_AS_INT := TO_INTEGER(SOURCE1_UNSIGNED(10 DOWNTO 6)); -- ACCESS SHAMT FIELD
            RESULT <= STD_LOGIC_VECTOR(shift_right(SOURCE2_UNSIGNED,SOURCE1_AS_INT)); 
        when SL16 =>    --SHIFT LEFT LOGICAL 16 BIT (SOURCE2). 
            RESULT <= STD_LOGIC_VECTOR(shift_left(SOURCE2_UNSIGNED,16));                    
        when others =>  --BASE CASE: ASSIGN THE UNSIGNED RESULT.
           RESULT <= RESULT_ADDSUB;
    end case;        
end process;

end ALU_ARCH;
