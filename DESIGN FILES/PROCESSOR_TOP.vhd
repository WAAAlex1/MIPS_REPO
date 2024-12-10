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
        PROG_SEL: in STD_LOGIC_VECTOR(3 DOWNTO 0);
        
        REGISTERS: out REG_ARR
    );
end PROCESSOR_TOP;

architecture ARCH_P_TOP of PROCESSOR_TOP is

-- DECLARE COMPONENTS

component IF_STAGE is
    port(
        --INPUTS
        CLK          : in STD_LOGIC;                                                                          
        RESET        : in STD_LOGIC;                                                                                                                                                                                                
        BRANCH_PC    : in STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);           
        RESET_PC     : in STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);
        PC_SEL       : in STD_LOGIC;                                                    
        --OUTPUTS        (REGISTERED)                 
        MEM_DATA_O   : out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);
        PC_o         : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0)
        );
end component IF_STAGE;

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
		OFFSET_O_S      : out STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);-- INST[15-0] SIGN EXTENDED TO 32BIT
		OFFSET_O_U      : out STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);-- INST[15-0] EXTENDED TO 32BIT (UNSIGNED)
		RS_DATA_O       : out STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);-- DATA OF RD REG (32 BIT)
		RT_DATA_O       : out STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);-- DATA OF RT REG (32 BIT)		
		RD_IDX_O        : out STD_LOGIC_VECTOR (ADDR_SIZE-1 DOWNTO 0); -- INST[15-11] IDX OF RD 	
		RT_IDX_O        : out STD_LOGIC_VECTOR (ADDR_SIZE-1 DOWNTO 0); -- INST[20-16] IDX OF RT
		PC_ADDR_O       : out STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0); -- PC_ADDR_O
		
		--Control Outputs
		MEM_WB_CTRL_O   : out MEM_WB_CTRL_REG;                           -- CONTROL FOR MEM STAGE
		EX_CTRL_O       : out EX_CTRL_REG;			                  -- CONTROL FOR EX STAGE
	    
	    --OUTPUTS TO IF STAGE
        PC_SEL_ID_IF    : out STD_LOGIC;
        PC_ADDR_ID_IF   : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        
        -- OUTPUTS TO TOP LEVEL
        REGISTERS       : out REG_ARR
	);
end component ID_STAGE;

component EX_STAGE is
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
		PC_ADDR         : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);			 				
		
		--CONTROL Inputs						
		MEM_WB_CTRL		: in MEM_WB_CTRL_REG;				
		EX_CTRL			: in EX_CTRL_REG;		     	      
		
		--OUTPUTS			
		RESULT_O		: out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
		RT_DATA_O		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RT_RD_IDX_O	    : out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		
		--Control Outputs			
		MEM_WB_CTRL_O   : out MEM_WB_CTRL_REG			
	);
end component EX_STAGE;

component MEM_STAGE is
	port( 
		--INPUTS
     	CLK			    : in STD_LOGIC;					
		RESET			: in STD_LOGIC;					
     					     	
		M_ADDR	        : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
	    M_DATA 		    : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RT_RD_IDX		: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		REG_DATA        : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
				
		--CONTROL Inputs					
		MEM_WB_CTRL		: in MEM_WB_CTRL_REG;				
		
		--OUTPUTS	(REGISTERED)		
		MEM_DATA_O		: out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
		REG_DATA_O		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		REG_IDX_O	    : out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		
		--Control Outputs
		MEM_WB_CTRL_O   : out MEM_WB_CTRL_REG;
		byte_idx_O      : out STD_LOGIC_VECTOR(1 DOWNTO 0)				
	);
end component MEM_STAGE;

component WB_STAGE is
    port(
        RESET   : in STD_LOGIC;
        REG_IDX : in STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);
        REG_DATA: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        MEM_DATA: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        byte_idx: in STD_LOGIC_VECTOR(1 DOWNTO 0);
        MEM_WB_CTRL: in MEM_WB_CTRL_REG;
        
        REG_DATA_O: out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        REG_IDX_O : out STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);
        REG_W_CTRL: out STD_LOGIC
    );
end component WB_STAGE;

-- SIGNALS FOR INTERCONNECTING THE COMPONENTS:

-- SIGNALS FROM IF
signal INSTRUCTION_IF_ID:	STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0):=(others => '0');		
signal PC_ADDR_IF_ID    :   STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0):=(others => '0');	

-- SIGNALS FROM ID
signal OFFSET_ID_EX_S   :	STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0):=(others => '0');
signal OFFSET_ID_EX_U   :	STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0):=(others => '0');			
signal RS_DATA_ID_EX    :   STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0):=(others => '0');		
signal RT_DATA_ID_EX    :	STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0):=(others => '0');					
signal RD_IDX_ID_EX     :	STD_LOGIC_VECTOR (ADDR_SIZE-1 DOWNTO 0):=(others => '0');			
signal RT_IDX_ID_EX     :	STD_LOGIC_VECTOR (ADDR_SIZE-1 DOWNTO 0):=(others => '0');
signal MEM_WB_CTRL_ID_EX:	MEM_WB_CTRL_REG;
signal EX_CTRL_ID_EX    :	EX_CTRL_REG;
signal PC_SEL_ID_IF     :   STD_LOGIC;
signal PC_ADDR_ID_IF    :   STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0):=(others => '0');
signal PC_ADDR_ID_EX    :   STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0):=(others => '0'); --asd

-- SIGNALS FROM EX
signal RESULT_EX_MEM    : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0):=(others => '0');	
signal RT_DATA_EX_MEM	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0):=(others => '0');	
signal RT_RD_IDX_EX_MEM : STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0):=(others => '0');		
signal MEM_WB_CTRL_EX_MEM: MEM_WB_CTRL_REG;

-- SIGNALS FROM MEM
signal MEM_DATA_MEM_WB	: STD_LOGIC_VECTOR(INST_SIZE-1 downto 0):=(others => '0');	
signal REG_DATA_MEM_WB  : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0):=(others => '0');	
signal REG_IDX_MEM_WB   : STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0):=(others => '0');
signal MEM_WB_CTRL_MEM_WB: MEM_WB_CTRL_REG;
signal byte_idx_MEM_WB  : STD_LOGIC_VECTOR(1 DOWNTO 0);

-- SIGNALS FROM WB
signal REG_W_CTRL_WB_ID: STD_LOGIC;
signal REG_DATA_WB_ID: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0):=(others => '0');
signal REG_IDX_WB_ID: STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0):=(others => '0');

-- SIGNALS FOR CREATING THE PC WHEN RESET
signal RESET_PC: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0):=(others => '0');

begin

with PROG_SEL SELECT RESET_PC<= x"0000_0000" when "0001", -- TEST PROGRAM 
                                x"0000_0000" when "0010", -- SUM PROGRAM WITH N = 0x0010   x"0000_00E6"
                                x"0000_0000" when "0011", -- SUM PROGRAM WITH N = 0x0100   x"0000_00E9"
                                x"0000_0000" when "0100", -- SUM PROGRAM WITH N = 0xF000   x"0000_00EC"
                                x"0000_0000" when "0101", -- SUM PROGRAM WITH N = 0xFFFF   x"0000_00EF"
                                x"0000_0000" when "0110", -- SUM PROGRAM WITH N = 0x1FFFF  x"0000_00F2"
                                x"0000_0000" when "0111", -- FIBONACCI NUMBER 2            x"0000_012C"
                                x"0000_0000" when "1000", -- FIBONACCI NUMBER 8            x"0000_012F"
                                x"0000_0000" when "1001", -- FIBONACCI NUMBER 16           x"0000_0132"
                                x"0000_0000" when "1010", -- FIBONACCI NUMBER 24           x"0000_0135"
                                x"0000_0000" when "1011", -- FIBONACCI NUMBER ??           x"0000_0138"
                                x"0000_0000" when others; -- DANCING LED SHIFTING PROGRAM  x"0000_0190"

MIPS_IF: IF_STAGE port map(
        --INPUTS
        CLK          => CLK,                                                                 
        RESET        => RESET,                                                                                                                                                  
        BRANCH_PC    => PC_ADDR_ID_IF,       
        RESET_PC     => RESET_PC,      
        PC_SEL       => PC_SEL_ID_IF,                                    
        --OUTPUTS    (REGISTERED)                 
        MEM_DATA_O   => INSTRUCTION_IF_ID,      
        PC_o         => PC_ADDR_IF_ID     
        );

MIPS_ID: ID_STAGE port map(
        --INPUTS
     	CLK			    => CLK,					
		RESET			=> RESET,			
     	
     	-- FROM IF STAGE				     	
		PC_ADDR   	    => PC_ADDR_IF_ID,		
		INSTRUCTION	    => INSTRUCTION_IF_ID,		
	    
	    -- FROM WB STAGE
	    RegWrite        => REG_W_CTRL_WB_ID,		
	    REG_DATA        => REG_DATA_WB_ID,		
		REG_ADDR        => REG_IDX_WB_ID,		
		
		--OUTPUTS			
		OFFSET_O_S      => OFFSET_ID_EX_S,
		OFFSET_O_U      => OFFSET_ID_EX_U,	
		RS_DATA_O       => RS_DATA_ID_EX,		
		RT_DATA_O       => RT_DATA_ID_EX,				
		RD_IDX_O        => RD_IDX_ID_EX,		
		RT_IDX_O        => RT_IDX_ID_EX,
		PC_ADDR_O       => PC_ADDR_ID_EX,		
		
		--Control Outputs
		MEM_WB_CTRL_O	=> MEM_WB_CTRL_ID_EX,		                  
		EX_CTRL_O       => EX_CTRL_ID_EX,
		
		--OUTPUTS TO IF STAGE
        PC_SEL_ID_IF    => PC_SEL_ID_IF,
        PC_ADDR_ID_IF   => PC_ADDR_ID_IF,
        
        -- OUTPUTS TO TOP LEVEL
        REGISTERS       => REGISTERS
        );

MIPS_EX: EX_STAGE port map(
        --INPUTS
     	CLK			    => CLK,			
		RESET			=> RESET,				
   
   		RS_DATA	        => RS_DATA_ID_EX,		
	    RT_DATA 		=> RT_DATA_ID_EX,		
		OFFSET_S		=> OFFSET_ID_EX_S,
		OFFSET_U		=> OFFSET_ID_EX_U,		
		RT_IDX			=> RT_IDX_ID_EX, 			
		RD_IDX			=> RD_IDX_ID_EX,
		PC_ADDR         => PC_ADDR_ID_EX,				 				
		
		--CONTROL Inputs		
		MEM_WB_CTRL		=> MEM_WB_CTRL_ID_EX,					
		EX_CTRL			=> EX_CTRL_ID_EX,		     	      
		
		--OUTPUTS			
		RESULT_O		=> RESULT_EX_MEM,			
		RT_DATA_O		=> RT_DATA_EX_MEM,		
		RT_RD_IDX_O	    => RT_RD_IDX_EX_MEM,		
		
		--Control Outputs		
		MEM_WB_CTRL_O		=> MEM_WB_CTRL_EX_MEM
        );

MIPS_MEM: MEM_STAGE port map (
        --INPUTS
     	CLK			    => CLK,				
		RESET			=> RESET,			
     					     	
		M_ADDR	        => RESULT_EX_MEM,	
	    M_DATA 		    => RT_DATA_EX_MEM,	
		RT_RD_IDX		=> RT_RD_IDX_EX_MEM,	
		REG_DATA        => RESULT_EX_MEM,	
				
		--CONTROL Inputs		
		MEM_WB_CTRL		=> MEM_WB_CTRL_EX_MEM,	
		
		--OUTPUTS	(REGISTERED)		
		MEM_DATA_O		=> MEM_DATA_MEM_WB,	
		REG_DATA_O		=> REG_DATA_MEM_WB,		
		REG_IDX_O	    => REG_IDX_MEM_WB,	
		
		--Control Outputs
		MEM_WB_CTRL_O	=> MEM_WB_CTRL_MEM_WB,
		byte_idx_O      => byte_idx_MEM_WB		
        );
        
MIPS_WB: WB_STAGE port map(
        -- INPUTS
        RESET           => RESET,
        REG_IDX         => REG_IDX_MEM_WB,
        REG_DATA        => REG_DATA_MEM_WB,
        MEM_DATA        => MEM_DATA_MEM_WB,
        MEM_WB_CTRL     => MEM_WB_CTRL_MEM_WB,
        byte_idx        => byte_idx_MEM_WB,
        
        -- OUTPUTS
        REG_DATA_O      => REG_DATA_WB_ID,
        REG_IDX_O       => REG_IDX_WB_ID,
        REG_W_CTRL      => REG_W_CTRL_WB_ID
        );   
             
end ARCH_P_TOP;    
    
