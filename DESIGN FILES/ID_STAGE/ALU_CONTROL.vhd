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
			ALU_TYPE	:	in STD_LOGIC;	
			-- OUTPUTS	
		    ALU_OPSEL   :	out ALU_OPSELECT	
	);
end ALU_CONTROL;

architecture ALU_CONTROL_ARC of ALU_CONTROL is
begin
	
	process(OPCODE,FUNCT,ALU_TYPE)
	begin
	   case ALU_TYPE is
	       when '1' => --DEALING WITH R TYPE INSTRUCTION
	           case FUNCT is
	               when "1-0000" => -- ADD INSTR
	                   ALU_OPSEL <= ADDS;
	               when "1-0001" => -- ADDU INSTR
	                   ALU_OPSEL <= ADDU;    
	               when "1-0010" => -- SUB INSTR
	                   ALU_OPSEL <= SUBS;
	               when "1-0011" => -- SUBU INSTR
	                   ALU_OPSEL <= SUBU;
	               when "1-0101" => -- OR INSTR
	                   ALU_OPSEL <= OR0;
	               when "1-0100" => -- AND INSTR
	                   ALU_OPSEL <= AND0;
	               when "1-1010" => -- SLT INSTR
	                   ALU_OPSEL <= SLTS;
	               when "1-1011" => -- SLTU INSTR
	                   ALU_OPSEL <= SLTU;
	               when "0-0000" => -- SLL INSTR
	                   ALU_OPSEL <= SLL0;
	               when "0-0010" => -- SRL INSTR
	                   ALU_OPSEL <= SRL0;
	               when others =>   -- BASE CASE: ADD SIGNED
	                   ALU_OPSEL <= ADDS;    
	           end case;    
	       when '0' => --DEALING WITH I TYPE INSTRUCTION
	           case OPCODE is
	               --  ADDI INSTR  SB INSTR   SW INSTR   LB INSTR   LW INSTR
	               when "0-1000" | "1-1000" | "1-1011" | "1-0000" | "1-0011" => 
	                   ALU_OPSEL <= ADDS;
	               -- ADDIU INSTR LBU INSTR
	               when "0-1001" | "1-0100" => 
	                   ALU_OPSEL <= ADDU;    
	               --   BEQ INSTR  BNE INSTR
	               when "0-0100" | "0-0101" => 
	                   ALU_OPSEL <= SUBS;         -- COULD BE CHANGED
	               when "0-1101" => -- ORI INSTR
	                   ALU_OPSEL <= OR0;
	               when "0-1100" => -- ANDI INSTR
	                   ALU_OPSEL <= AND0;
	               when "0-1111" => -- LUI INSTR
	                   ALU_OPSEL <= SL16;    
	               when others =>   -- BASE CASE: ADD SIGNED
	                   ALU_OPSEL <= ADDS;    
	           end case;
	       when others =>
	           null;
	   end case;         
	
	end process;

end ALU_CONTROL_ARC;