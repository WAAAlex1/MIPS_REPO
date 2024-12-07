library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;

entity EX_STAGE is
	port( 
		--INPUTS
     	CLK			    : in STD_LOGIC;					
		RESET			: in STD_LOGIC;					
     					     	
		RS_DATA	        : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
	    RT_DATA 		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		OFFSET_S	    : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		OFFSET_U	    : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);		
		RT_IDX			: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	
		RD_IDX			: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);			 				
		
		--CONTROL Inputs		
		WB_CTRL			: in WB_CTRL_REG; 				
		MEM_CTRL		: in MEM_CTRL_REG;				
		EX_CTRL			: in EX_CTRL_REG;		     	      
		
		--OUTPUTS			
		RESULT_O		: out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
		RT_DATA_O		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RT_RD_IDX_O	    : out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		
		--Control Outputs
		WB_CTRL_O       : out WB_CTRL_REG;				
		MEM_CTRL_O		: out MEM_CTRL_REG			
	);
end EX_STAGE;


architecture ARCH_EX of EX_STAGE is

--DECLARE COMPONENTS
--ALU,ALU_CONTROL,EX_MEM_R, ADDER

Component ALU is
	generic (N: NATURAL:=0);
	port(
	    -- Two sources and one result.
		SOURCE1	    : in STD_LOGIC_VECTOR(N-1 downto 0);
		SOURCE2	    : in STD_LOGIC_VECTOR(N-1 downto 0);
		RESULT	    : out STD_LOGIC_VECTOR(N-1 downto 0);
		
		-- Record of ALU setting (input from ALU_Control)
		-- Record of ALU FLAGS (Output from here)
		ALU_OPSEL	: in ALU_OPSELECT
	);
end component ALU;

component EX_MEM_REGISTERS is 
    port(
		-- INPUTS USED FOR THE REGISTER ITSELF
		clk		        :	in STD_LOGIC;					             -- CLK
		RESET		    :	in STD_LOGIC;					             -- Synchronous
		
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
end component EX_MEM_REGISTERS;

--SIGNAL DECLARATIONS

    --SIGNALS FOR COMPUTING MUX ON RT AND RS
    signal ALU_REG_INTERNAL2	   : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0); 
    signal ALU_REG_INTERNAL1	   : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0); 
    
    --SIGNALS FOR COMPUTING MUX ON RT_RD_IDX
    signal RT_RD_IDX_INTERNAL : STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);

    --SIGNALS FOR ALU
	signal ALU_RES_INTERNAL	   : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0); 
	signal OFFSET              : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);

begin



-- MUXES    -------------------------------------------------------
    -- RT_RD_IDX MUX
    -- RT_RD_IDX_INTERNAL = RT_IDX(instr[20-16]) when ALUTYPE = 0 (I-TYPE)
    -- RT_RD_IDX_INTERNAL = RT_IDX(instr[15-11]) when ALUTYPE = 1 (R-TYPE)
    with EX_CTRL.ALUTYPE select RT_RD_IDX_INTERNAL <=
           RT_IDX when '0',
           RD_IDX when others;
               
    --ALU INPUT MUX ON RT
    with EX_CTRL.ALUSrc select ALU_REG_INTERNAL2 <=
           RT_DATA when '0',
           OFFSET  when others;
           
    --ALU INPUT MUX ON RS
    with EX_CTRL.ALULS select ALU_REG_INTERNAL1 <=
           RS_DATA when '0',
           OFFSET  when others;      
           
    with EX_CTRL.ALUOpSelect select OFFSET <=
                    OFFSET_U when ADDU,
                    OFFSET_U when SUBU,
                    OFFSET_S when others;            

-- INSTANTIATE COMPONENTS -----------------------------------------

-- ALU
-- ALU RESULT CREATED AND PUT INTO ALU_RES_INTERNAL
-- ALU FLAGS ARE CREATED AND PUT INTO ALU_FLAGS_INTERNAL (CCURENTLY FLAGS ARE NOT USED)
ALU_EX: ALU GENERIC MAP(N => INST_SIZE)
        PORT MAP(
            -- Two sources and one result.
            SOURCE1 	=> ALU_REG_INTERNAL1,
            SOURCE2  	=> ALU_REG_INTERNAL2,
            RESULT	    => ALU_RES_INTERNAL,
            
            -- Record of ALU setting (input from ALU_Control)
            -- Record of ALU FLAGS (Output from here)
            ALU_OPSEL	=> EX_CTRL.ALUOpselect
        );
  
--EX_MEM REGISTERS
EX_MEM_REGS: EX_MEM_REGISTERS PORT MAP(
		clk	=> clk,
		RESET => RESET,
		
		-- INPUTS PROPAGATED THROUGH REGISTER
		ALU_RES_EX    => ALU_RES_INTERNAL,	    
		RT_EX         => RT_DATA,		   
		RT_RD_IDX_EX  => RT_RD_IDX_INTERNAL,
		--Control signals
		WB_CTRL_EX	  => WB_CTRL,
		MEM_CTRL_EX	  => MEM_CTRL, 
		 						     	      
		--OUTPUTS		            
		ALU_RES_MEM	  => RESULT_O,
		RT_MEM		  => RT_DATA_O,
		RT_RD_IDX_MEM => RT_RD_IDX_O,		
		--Control signals
	    WB_CTRL_MEM	  => WB_CTRL_O,			             
		MEM_CTRL_MEM  => MEM_CTRL_O
        );

end ARCH_EX;



