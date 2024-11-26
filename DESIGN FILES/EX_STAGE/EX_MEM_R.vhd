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
		ALU_RES_EX	    :	in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	 -- Result of ALU
		RT_EX		    :	in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	 -- Propagate RT Operand
		RT_RD_IDX_EX	:	in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	 -- Propagate RT/RD Address
		--Control signals
		WB_CTRL_EX	    :	in WB_CTRL_REG; 				             -- Control signals FOR WB_STAGE
		MEM_CTRL_EX	    :	in MEM_CTRL_REG;				             -- Control signals for MEM_STAGE
		 						     	      
		--OUTPUTS		            
		ALU_RES_MEM	    :	out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
		RT_MEM		    :	out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RT_RD_IDX_MEM	:	out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	
		--Control signals
	    WB_CTRL_MEM	    :	out WB_CTRL_REG; 				             
		MEM_CTRL_MEM	:	out MEM_CTRL_REG	    
        );
end EX_MEM_REGISTERS;

architecture ARCH_EX_MEM_REGS of EX_MEM_REGISTERS is        
begin 

	  process(CLK,RESET)
	  begin
		if RESET = '1' then 	
			ALU_RES_MEM	    <= L32b;
			RT_MEM		    <= L32b;
			RT_RD_IDX_MEM	<= "00000";			
			
			WB_CTRL_MEM	    <= ('0',"00");
			MEM_CTRL_MEM.W_R_CTRL <= "00";
			
		elsif rising_edge(clk) then
			ALU_RES_MEM	    <= ALU_RES_EX;
			RT_MEM		    <= RT_EX;
			RT_RD_IDX_MEM   <= RT_RD_IDX_EX;
			
			WB_CTRL_MEM	    <= WB_CTRL_EX;
			MEM_CTRL_MEM	<= MEM_CTRL_EX;
			
		end if;
	  end process; 

end ARCH_EX_MEM_REGS;