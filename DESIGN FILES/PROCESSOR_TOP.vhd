library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;

-- TOP MODULE FOR THE PROCESSOR.
-- DOES THE FOLLOWING:
-- 1. Instantiates the MIPS Stage modules.
-- 2. Interconnects the MIPS Stage modules.
-- 3. Sends data to TOP_LEVEL
-- 4. Receives CLK, RESET and Program Select from TOP_LEVEL


entity PROCESSOR_TOP is
    port(
        CLK: in STD_LOGIC;
        RESET: in STD_LOGIC;
        PROG_SEL: in STD_LOGIC_VECTOR(2 DOWNTO 0);
        
        DATA1: out STD_LOGIC_VECTOR(7 DOWNTO 0);
        DATA2: out STD_LOGIC_VECTOR(7 DOWNTO 0);
        DATA3: out STD_LOGIC_VECTOR(7 DOWNTO 0);    
        DATA4: out STD_LOGIC_VECTOR(7 DOWNTO 0);
        DATA5: out STD_LOGIC_VECTOR(7 DOWNTO 0);
    );
end PROCESSOR_TOP;

architecture ARCH_P_TOP of PROCESSOR_TOP is

-- DECLARE COMPONENTS

component ID_STAGE is
	port( 
		--INPUTS
     	CLK			    : in STD_LOGIC;					
		RESET			: in STD_LOGIC;					
     	
     	-- FROM IF STAGE				     	
		PC_ADDR   	    : in STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);	
		INSTRUCTION	    : in STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);	
	    
	    -- FROM WB STAGE
	    RegWrite        : in STD_LOGIC;  
	    REG_DATA        : in STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);
		REG_ADDR        : in STD_LOGIC_VECTOR (ADDR_SIZE-1 DOWNTO 0);
		
		--OUTPUTS			
		PC_ADDR_O	    : out STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);-- PC_ADDR DIRECTLY PROPAGATED
		OFFSET_O        : out STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);-- INST[15-0] SIGN EXTENDED TO 32BIT
		OPCODE_O        : out STD_LOGIC_VECTOR (ADDR_SIZE   DOWNTO 0);-- INST[31-26] 	
		RS_DATA_O       : out STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);-- DATA OF RD REG (32 BIT)
		RT_DATA_O       : out STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);-- DATA OF RT REG (32 BIT)		
		RD_IDX_O        : out STD_LOGIC_VECTOR (ADDR_SIZE-1 DOWNTO 0); -- INST[15-11] IDX OF RD 	
		RT_IDX_O        : out STD_LOGIC_VECTOR (ADDR_SIZE-1 DOWNTO 0); -- INST[20-16] IDX OF RT
		
		--Control Outputs
		WB_CTRL_O       : out WB_CTRL_REG;				              -- CONTROL FOR WB STAGE
		MEM_CTRL_O		: out MEM_CTRL_REG;                           -- CONTROL FOR MEM STAGE
		EX_CTRL_O       : out EX_CTRL_REG			                  -- CONTROL FOR EX STAGE
	);
end component ID_STAGE;

component EX_STAGE is
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
end component EX_STAGE;

component MEM_STAGE is
	port( 
		--INPUTS
     	CLK			    : in STD_LOGIC;					
		RESET			: in STD_LOGIC;					
     					     	
		PC_ADDR   	    : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		M_ADDR	        : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
	    M_DATA 		    : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RT_RD_IDX		: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		REG_DATA        : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
				
		--CONTROL Inputs		
		WB_CTRL			: in WB_CTRL_REG; 				
		MEM_CTRL		: in MEM_CTRL_REG;				
		ALU_FLAGS		: in ALU_FLAGS;		     	      
		
		--OUTPUTS	(REGISTERED)		
		MEM_DATA_O		: out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
		REG_DATA_O		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		REG_IDX_O	    : out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		
		--OUTPUTS (NOT REGISTERED)
		PC_ADDR_O       : out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		PC_SRC_O        : out STD_LOGIC;
		
		--Control Outputs
		WB_CTRL_O       : out WB_CTRL_REG				
	);
end component MEM_STAGE;

component WB_STAGE is
    port(
        CLK     : in STD_LOGIC;
        RESET   : in STD_LOGIC;
        REG_IDX : in STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);
        REG_DATA: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        MEM_DATA: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        WB_CTRL : in WB_CTRL_REG;
        
        REG_DATA_O: out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        REG_IDX_O : out STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);
        REG_W_CTRL: out STD_LOGIC
    );
end component WB_STAGE;

-- SIGNALS FOR INTERCONNECTING THE COMPONENTS:

-- SIGNALS FROM ID
signal PC_ADDR_ID_EX    :	STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);	
signal OFFSET_ID_EX     :	STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);		
signal OPCODE_ID_EX     :	STD_LOGIC_VECTOR (ADDR_SIZE   DOWNTO 0); 		
signal RS_DATA_ID_EX    :   STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);		
signal RT_DATA_ID_EX    :	STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);					
signal RD_IDX_ID_EX     :	STD_LOGIC_VECTOR (ADDR_SIZE-1 DOWNTO 0);			
signal RT_IDX_ID_EX     :	STD_LOGIC_VECTOR (ADDR_SIZE-1 DOWNTO 0);
signal WB_CTRL_ID_EX    :	WB_CTRL_REG;
signal MEM_CTRL_ID_EX	:	MEM_CTRL_REG;
signal EX_CTRL_ID_EX    :	EX_CTRL_REG;

-- SIGNALS FROM EX
signal PC_ADDR_EX_MEM   : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
signal RESULT_EX_MEM    : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
signal RT_DATA_EX_MEM	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
signal RT_RD_IDX_EX_MEM : STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		
		--Control Outputs
signal ALU_FLAGS_EX_MEM : ALU_FLAGS;
signal WB_CTRL_EX_MEM   : WB_CTRL_REG;				
signal MEM_CTRL_EX_MEM	: MEM_CTRL_REG

-- SIGNALS FROM MEM
signal MEM_DATA_MEM_WB	: STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
signal REG_DATA_MEM_WB  : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
signal REG_IDX_MEM_WB   : STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
signal PC_ADDR_MEM_IF   : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
signal PC_SRC_MEM_IF    : STD_LOGIC;
signal WB_CTRL_MEM_WB   : WB_CTRL_REG

-- SIGNALS FROM WB
signal REG_W_CTRL_WB_ID: STD_LOGIC;
signal REG_DATA_WB_ID: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
signal REG_IDX_WB_ID: STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);

begin

MIPS_ID: ID_STAGE port map(
        --INPUTS
     	CLK			    => CLK,					
		RESET			=> RESET,			
     	
     	-- FROM IF STAGE				     	
		PC_ADDR   	    =>,		
		INSTRUCTION	    =>,		
	    
	    -- FROM WB STAGE
	    RegWrite        => REG_W_CTRL_WB_ID,		
	    REG_DATA        => REG_DATA_WB_ID,		
		REG_ADDR        => REG_IDX_WB_ID,		
		
		--OUTPUTS			
		PC_ADDR_O	    => PC_ADDR_ID_EX,		
		OFFSET_O        => OFFSET_ID_EX,		
		OPCODE_O        => OPCODE_ID_EX,		
		RS_DATA_O       => RS_DATA_ID_EX,		
		RT_DATA_O       => RT_DATA_ID_EX,				
		RD_IDX_O        => RD_IDX_ID_EX,		
		RT_IDX_O        => RT_IDX_ID_EX,		
		
		--Control Outputs
		WB_CTRL_O       => WB_CTRL_ID_EX,						  
		MEM_CTRL_O		=> MEM_CTRL_ID_EX,		                  
		EX_CTRL_O       => EX_CTRL_ID_EX		
        );

MIPS_EX: EX_STAGE port map(
        --INPUTS
     	CLK			    => CLK,			
		RESET			=> RESET,				
     					     	
		PC_ADDR   	    => PC_ADDR_ID_EX,		
		RS_DATA	        => RS_DATA_ID_EX,		
	    RT_DATA 		=> RT_DATA_ID_EX,		
		OFFSET			=> OFFSET_ID_EX,		
		OPCODE          => OPCODE_ID_EX,		
		RT_IDX			=> RT_IDX_ID_EX, 			
		RD_IDX			=> RT_IDX_ID_EX,				 				
		
		--CONTROL Inputs		
		WB_CTRL			=> WB_CTRL_ID_EX,				
		MEM_CTRL		=> MEM_CTRL_ID_EX,					
		EX_CTRL			=> EX_CTRL_ID_EX,		     	      
		
		--OUTPUTS			
		PC_ADDR_O	    => PC_ADDR_EX_MEM,		
		RESULT_O		=> RESULT_EX_MEM,			
		RT_DATA_O		=> RT_DATA_EX_MEM,		
		RT_RD_IDX_O	    => RT_RD_IDX_EX_MEM,		
		
		--Control Outputs
		ALU_FLAGS_O	    => ALU_FLAGS_EX_MEM,		
		WB_CTRL_O       => WB_CTRL_EX_MEM,				
		MEM_CTRL_O		=> MEM_CTRL_EX_MEM
        );

MIPS_MEM: MEM_STAGE port map (
        --INPUTS
     	CLK			    => CLK,				
		RESET			=> RESET,			
     					     	
		PC_ADDR   	    => PC_ADDR_EX_MEM,	
		M_ADDR	        => RESULT_EX_MEM,	
	    M_DATA 		    => RT_DATA_EX_MEM,	
		RT_RD_IDX		=> RT_RD_IDX_EX_MEM,	
		REG_DATA        => RESULT_EX_MEM,	
				
		--CONTROL Inputs		
		WB_CTRL			=> WB_CTRL_EX_MEM,			
		MEM_CTRL		=> MEM_CTRL_EX_MEM,	
		ALU_FLAGS		=> ALU_FLAGS_EX_MEM,	    	      
		
		--OUTPUTS	(REGISTERED)		
		MEM_DATA_O		=> MEM_DATA_MEM_WB,	
		REG_DATA_O		=> REG_DATA_MEM_WB,		
		REG_IDX_O	    => REG_IDX_MEM_WB,	
		
		--OUTPUTS (NOT REGISTERED)
		PC_ADDR_O       => PC_ADDR_MEM_IF,	
		PC_SRC_O        => PC_SRC_MEM_IF,	
		
		--Control Outputs
		WB_CTRL_O       => WB_CTRL_MEM_WB		
        );
        
MIPS_WB: WB_STAGE port map(
        -- INPUTS
        CLK             => CLK,
        RESET           => RESET,
        REG_IDX         => REG_IDX_MEM_WB,
        REG_DATA        => REG_DATA_MEM_WB,
        MEM_DATA        => MEM_DATA_MEM_WB,
        WB_CTRL         => WB_CTRL_MEM_WB,
        -- OUTPUTS
        REG_DATA_O      => REG_DATA_WB_ID,
        REG_IDX_O       => REG_IDX_WB_ID,
        REG_W_CTRL      => REG_W_CTRL_WB_ID
        );   
             
end ARCH_P_TOP;    
    
