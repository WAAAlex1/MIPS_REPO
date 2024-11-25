library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;

entity EX_MEM_REGISTERS is 
    port(
		-- INPUTS USED FOR THE REGISTER ITSELF
		clk		        :	in STD_LOGIC;					             -- CLK
		RESET		    :	in STD_LOGIC;					             -- Asynchronous 
		
		-- INPUTS PROPAGATED THROUGH REGISTER
		PC_ADDR_EX	    :	in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	 -- Propagate PC_ADDR		
		ALU_RES_EX	    :	in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	 -- Result of ALU
		RT_EX		    :	in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	 -- Propagate RT Operand
		RT_RD_IDX_EX	:	in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	 -- Propagate RT/RD Address
		--Control signals
		ALU_FLAGS_EX	:	in ALU_FLAGS;					             -- Propagate ALU_FLAGS
		WB_CTRL_EX	    :	in WB_CTRL_REG; 				             -- Control signals FOR WB_STAGE
		MEM_CTRL_EX	    :	in MEM_CTRL_REG;				             -- Control signals for MEM_STAGE
		 						     	      
		--OUTPUTS		            
		PC_ADDR_MEM	    :	out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);					
		ALU_RES_MEM	    :	out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
		RT_MEM		    :	out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RT_RD_IDX_MEM	:	out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	
		--Control signals
		ALU_FLAGS_MEM	:	out ALU_FLAGS;
	    WB_CTRL_MEM	    :	out WB_CTRL_REG; 				             
		MEM_CTRL_MEM	:	out MEM_CTRL_REG	    
        );
end EX_MEM_REGISTERS;

architecture ARCH_EX_MEM_REGS of EX_MEM_REGISTERS is        
begin 

	  process(clk,RESET,PC_ADDR_EX,ALU_RES_EX,RT_EX,RT_RD_IDX_EX,ALU_FLAGS_EX,WB_CTRL_EX,MEM_CTRL_EX)
	  begin
		if RESET = '1' then 	
			PC_ADDR_MEM	    <= L32b;
			ALU_RES_MEM	    <= L32b;
			RT_MEM		    <= L32b;
			RT_RD_IDX_MEM	<= "00000";			
			
			ALU_FLAGS_MEM	<= ('0','0','0');
			WB_CTRL_MEM	    <= ('0','0');
			MEM_CTRL_MEM	<= ('0','0','0');
			
		elsif rising_edge(clk) then
			PC_ADDR_MEM	    <= PC_ADDR_EX;
			ALU_RES_MEM	    <= ALU_RES_EX;
			RT_MEM		    <= RT_EX;
			RT_RD_IDX_MEM   <= RT_RD_IDX_EX;
			
			ALU_FLAGS_MEM	<= ALU_FLAGS_EX;
			WB_CTRL_MEM	    <= WB_CTRL_EX;
			MEM_CTRL_MEM	<= MEM_CTRL_EX;
			
		end if;
	  end process; 

end ARCH_EX_MEM_REGS;