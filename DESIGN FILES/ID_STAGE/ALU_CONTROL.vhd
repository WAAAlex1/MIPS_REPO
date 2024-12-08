library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records.all;

entity ALU_CONTROL is
	port(
			-- INPUTS				
			FUNCT		:	in STD_LOGIC_VECTOR(5 DOWNTO 0);	
			OPCODE      :   IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			ALU_TYPE	:	in STD_LOGIC_VECTOR(1 DOWNTO 0);	
			-- OUTPUTS	
		    ALU_OPSEL   :	out ALU_OPSELECT	
	);
end ALU_CONTROL;

architecture ALU_CONTROL_ARC of ALU_CONTROL is
begin
	
	process(OPCODE,FUNCT,ALU_TYPE)
	begin
	   case ALU_TYPE is
	       when "01" => --DEALING WITH R TYPE INSTRUCTION
	           case FUNCT is
	               when "100000" => -- ADD INSTR
	                   ALU_OPSEL <= ADDS;
	               when "100001" => -- ADDU INSTR
	                   ALU_OPSEL <= ADDU;    
	               when "100010" => -- SUB INSTR
	                   ALU_OPSEL <= SUBS;
	               when "100011" => -- SUBU INSTR
	                   ALU_OPSEL <= SUBU;
	               when "100101" => -- OR INSTR
	                   ALU_OPSEL <= OR0;
	               when "100100" => -- AND INSTR
	                   ALU_OPSEL <= AND0;
	               when "101010" => -- SLT INSTR
	                   ALU_OPSEL <= SLT0;
	               when "101011" => -- SLTU INSTR
	                   ALU_OPSEL <= SLTU;
	               when "000000" => -- SLL INSTR
	                   ALU_OPSEL <= SLL0;
	               when "000100" => -- SLLV INSTR
	                   ALU_OPSEL <= SLLV;    
	               when "000010" =>  -- SRL INSTR
	                   ALU_OPSEL <= SRL0;
	               when "000110" =>  -- SRLV INSTR
	                   ALU_OPSEL <= SRLV;    
                   when "000011" => -- SRA INSTR
	                   ALU_OPSEL <= SRA0;
	               when "000111" => -- SRAV INSTR
	                   ALU_OPSEL <= SRAV;       
	               when "100110" => -- XOR INSTR
	                   ALU_OPSEL <= XOR0;
	               when "100111" => -- NOR INSTR
	                   ALU_OPSEL <= NOR0;       
	               when others =>   -- BASE CASE: ADD SIGNED
	                   ALU_OPSEL <= ADDS;    
	           end case;    
	       when "00" => --DEALING WITH I TYPE INSTRUCTION
	           case OPCODE is
	               --  ADDI INSTR 
	               when "001000" => 
	                   ALU_OPSEL <= ADDS;
	               -- ADDIU INSTR
	               when "001001" => 
	                   ALU_OPSEL <= ADDU;    
	               --   BEQ INSTR  BNE INSTR
	               when "000100" | "000101" => 
	                   ALU_OPSEL <= SUBS;         -- COULD BE CHANGED
	               when "001101" => -- ORI INSTR
	                   ALU_OPSEL <= OR0;
	               when "001100" => -- ANDI INSTR
	                   ALU_OPSEL <= AND0;
	               when "001111" => -- LUI INSTR
	                   ALU_OPSEL <= SL16;
	               when "001110" => -- XORI INSTR
	                   ALU_OPSEL <= XOR0;
	               when "001010" => -- SLTI INSTR
	                   ALU_OPSEL <= SLT0;
	               when "001011" => -- SLTIU INSTR
	                   ALU_OPSEL <= SLTU;                 
	               when others =>   -- BASE CASE: ADD SIGNED
	                   ALU_OPSEL <= ADDS;    
	           end case;
	       when others =>
	           -- WHEN JUMPING WE DONT NEED THE ALU, JUST EXECUTE ADDS
	           ALU_OPSEL <= ADDS;
	   end case;         
	
	end process;

end ALU_CONTROL_ARC;