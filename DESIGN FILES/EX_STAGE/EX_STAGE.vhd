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
     					     	
		PC_ADDR   	    : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RS_DATA	        : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
	    RT_DATA 		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		OFFSET			: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		OPCODE          : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		RT_IDX			: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	
		RD_IDX			: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);			 				
		
		--CONTROL Inputs		
		WB_CTRL			: in WB_CTRL_REG; 				
		MEM_CTRL		: in MEM_CTRL_REG;				
		EX_CTRL			: in EX_CTRL_REG;		     	      
		
		--OUTPUTS			
		PC_ADDR_O	    : out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RESULT_O		: out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
		RT_DATA_O		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RT_RD_IDX_O	    : out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		
		--Control Outputs
		ALU_FLAGS_O	    : out ALU_FLAGS;
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
		ALU_OPSEL	: in ALU_OPSELECT;
		FLAGS	    : out ALU_FLAGS
	);
end component ALU;

component ALU_CONTROL is
	port(
		-- INPUTS				
        FUNCT		:	in STD_LOGIC_VECTOR(5 DOWNTO 0);	
        OPCODE      :   IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        ALU_TYPE	:	in STD_LOGIC;	
        -- OUTPUTS	
        ALU_OPSEL	:	out ALU_OPSELECT	
	);
end component ALU_CONTROL;

component EX_MEM_REGISTERS is 
    port(
		-- INPUTS USED FOR THE REGISTER ITSELF
		clk		        :	in STD_LOGIC;					             -- CLK
		RESET		    :	in STD_LOGIC;					             -- Asynchronous 
		
		-- INPUTS PROPAGATED THROUGH REGISTER
		PC_ADDR_EX 	    :	in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	 -- Propagate PC_ADDR		
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
end component EX_MEM_REGISTERS;

-- UNSIGNED 32x32x32 ADDSUB MODULE.
-- S = A - B
-- ADD CONTROLS +- (+ IF HIGH, - IF LOW).
COMPONENT ADD32x32x32_U_S
  PORT (
    A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    CE: IN STD_LOGIC; 
    S : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
END COMPONENT;

--SIGNAL DECLARATIONS

    --SIGNALS COMPUTING PC_ADDR_O
    signal OFFSET_LS2	       : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
    signal PC_ADDR_INTERNAL	   : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0); 
    
    --SIGNALS FOR COMPUTING MUX ON RT AND RS
    signal ALU_REG_INTERNAL2	   : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0); 
    signal ALU_REG_INTERNAL1	   : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0); 
    
    --SIGNALS FOR COMPUTING MUX ON RT_RD_IDX
    signal RT_RD_IDX_INTERNAL : STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);

    --SIGNALS FOR ALU
    signal ALU_OPSEL_INTERNAL  : ALU_OPSELECT; -- ALU_OPSELECT
	signal ALU_RES_INTERNAL	   : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0); 
	signal ALU_FLAGS_INTERNAL  : ALU_FLAGS;

begin

-- SHIFTING -------------------------------------------------------
    OFFSET_LS2 <= OFFSET(29 DOWNTO 0) & b"00";

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

-- INSTANTIATE COMPONENTS -----------------------------------------
-- ALU_CONTROL
-- ALU_OPSEL CONTROL SIGNAL CREATED AND PUT INTO ALU_OPSEL_INTERNAL
ALU_CONTROL_EX: ALU_CONTROL 
         PORT MAP(
            -- INPUTS				
            FUNCT		=> OFFSET(5 DOWNTO 0),	
            OPCODE      => OPCODE,
            ALU_TYPE	=> EX_CTRL.ALUTYPE,
            -- OUTPUTS	
            ALU_OPSEL   => ALU_OPSEL_INTERNAL  
         );

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
            ALU_OPSEL	=> ALU_OPSEL_INTERNAL,
            FLAGS	    => ALU_FLAGS_INTERNAL
        );

--ADDER
-- NEW PC_ADDR IS COMPUTED AND PUT INTO PC_ADDR_INTERNAL
-- A IS UNSIGNED, B IS SIGNED.
-- ALWAYS ADDING
PC_ADDER: ADD32x32x32_U_S
  PORT MAP (
    A => PC_ADDR,
    B => OFFSET_LS2,
    CE => '1',
    S => PC_ADDR_INTERNAL
  );
  
--EX_MEM REGISTERS
EX_MEM_REGS: EX_MEM_REGISTERS PORT MAP(
		clk	=> clk,
		RESET => RESET,
		
		-- INPUTS PROPAGATED THROUGH REGISTER
		PC_ADDR_EX    => PC_ADDR_INTERNAL,	  	
		ALU_RES_EX    => ALU_RES_INTERNAL,	    
		RT_EX         => RT_DATA,		   
		RT_RD_IDX_EX  => RT_RD_IDX_INTERNAL,
		--Control signals
		ALU_FLAGS_EX  => ALU_FLAGS_INTERNAL,	
		WB_CTRL_EX	  => WB_CTRL,
		MEM_CTRL_EX	  => MEM_CTRL, 
		 						     	      
		--OUTPUTS		            
		PC_ADDR_MEM	  => PC_ADDR_O, 					
		ALU_RES_MEM	  => RESULT_O,
		RT_MEM		  => RT_DATA_O,
		RT_RD_IDX_MEM => RT_RD_IDX_O,		
		--Control signals
		ALU_FLAGS_MEM => ALU_FLAGS_O,	    
	    WB_CTRL_MEM	  => WB_CTRL_O,			             
		MEM_CTRL_MEM  => MEM_CTRL_O
        );

end ARCH_EX;



