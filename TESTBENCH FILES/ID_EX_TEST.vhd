library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.records.all;
use work.constants_pkg.all;


entity ID_EX_TEST is
    port(
        CLK			    : in STD_LOGIC;					
		RESET			: in STD_LOGIC;					
     	
     	-- FROM IF STAGE				     	
		PC_ADDR   	    : in STD_LOGIC_VECTOR (32-1 DOWNTO 0);	
		INSTRUCTION	    : in STD_LOGIC_VECTOR (32-1 DOWNTO 0);	
	    
	    -- FROM WB STAGE
	    RegWrite        : in STD_LOGIC;  
	    REG_DATA        : in STD_LOGIC_VECTOR (32-1 DOWNTO 0);
		REG_ADDR        : in STD_LOGIC_VECTOR (5-1 DOWNTO 0);
    
        PC_ADDR_O	    : out STD_LOGIC_VECTOR (32-1 downto 0);	
		RESULT_O		: out STD_LOGIC_VECTOR(32-1 downto 0);	
		RT_DATA_O		: out STD_LOGIC_VECTOR (32-1 downto 0);	
		RT_RD_IDX_O	    : out STD_LOGIC_VECTOR (5-1 downto 0);
		
		--Control Outputs
		ALU_FLAGS_O	    : out ALU_FLAGS;
		WB_CTRL_O       : out WB_CTRL_REG;				
		MEM_CTRL_O		: out MEM_CTRL_REG	
    );
end ID_EX_TEST;

architecture Behavioral of ID_EX_TEST is

component ID_STAGE is
	port( 
		--INPUTS
     	CLK			    : in STD_LOGIC;					
		RESET			: in STD_LOGIC;					
     	
     	-- FROM IF STAGE				     	
		PC_ADDR   	    : in STD_LOGIC_VECTOR (32-1 DOWNTO 0);	
		INSTRUCTION	    : in STD_LOGIC_VECTOR (32-1 DOWNTO 0);	
	    
	    -- FROM WB STAGE
	    RegWrite        : in STD_LOGIC;  
	    REG_DATA        : in STD_LOGIC_VECTOR (32-1 DOWNTO 0);
		REG_ADDR        : in STD_LOGIC_VECTOR (5-1 DOWNTO 0);
		
		--OUTPUTS			
		PC_ADDR_O	    : out STD_LOGIC_VECTOR (32-1 DOWNTO 0);-- PC_ADDR DIRECTLY PROPAGATED
		OFFSET_O        : out STD_LOGIC_VECTOR (32-1 DOWNTO 0);-- INST[15-0] SIGN EXTENDED TO 32BIT
		OPCODE_O        : out STD_LOGIC_VECTOR (5   DOWNTO 0);-- INST[31-26] 	
		RS_DATA_O       : out STD_LOGIC_VECTOR (32-1 DOWNTO 0);-- DATA OF RD REG (32 BIT)
		RT_DATA_O       : out STD_LOGIC_VECTOR (32-1 DOWNTO 0);-- DATA OF RT REG (32 BIT)		
		RD_IDX_O        : out STD_LOGIC_VECTOR (5-1 DOWNTO 0); -- INST[15-11] IDX OF RD 	
		RT_IDX_O        : out STD_LOGIC_VECTOR (5-1 DOWNTO 0); -- INST[20-16] IDX OF RT
		
		--Control Outputs
		WB_CTRL_O       : out WB_CTRL_REG;				              -- CONTROL FOR WB STAGE
		MEM_CTRL_O		: out MEM_CTRL_REG;                           -- CONTROL FOR MEM STAGE
		EX_CTRL_o       : out EX_CTRL_REG			                  -- CONTROL FOR EX STAGE
	);
end component ID_STAGE;

component EX_STAGE is
	port( 
		--INPUTS
     	CLK			    : in STD_LOGIC;					
		RESET			: in STD_LOGIC;					
     					     	
		PC_ADDR   	    : in STD_LOGIC_VECTOR (32-1 downto 0);	
		RS_DATA	        : in STD_LOGIC_VECTOR (32-1 downto 0);	
	    RT_DATA 		: in STD_LOGIC_VECTOR (32-1 downto 0);	
		OFFSET			: in STD_LOGIC_VECTOR (32-1 downto 0);	
		OPCODE          : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		RT_IDX			: in STD_LOGIC_VECTOR (5-1 downto 0);	
		RD_IDX			: in STD_LOGIC_VECTOR (5-1 downto 0);			 				
		
		--CONTROL Inputs		
		WB_CTRL			: in WB_CTRL_REG; 				
		MEM_CTRL		: in MEM_CTRL_REG;				
		EX_CTRL			: in EX_CTRL_REG;		     	      
		
		--OUTPUTS			
		PC_ADDR_O	    : out STD_LOGIC_VECTOR (32-1 downto 0);	
		RESULT_O		: out STD_LOGIC_VECTOR(32-1 downto 0);	
		RT_DATA_O		: out STD_LOGIC_VECTOR (32-1 downto 0);	
		RT_RD_IDX_O	    : out STD_LOGIC_VECTOR (5-1 downto 0);
		
		--Control Outputs
		ALU_FLAGS_O	    : out ALU_FLAGS;
		WB_CTRL_O       : out WB_CTRL_REG;				
		MEM_CTRL_O		: out MEM_CTRL_REG			
	);
end component EX_STAGE;

        signal PC_ADDR_INT: STD_LOGIC_VECTOR (32-1 DOWNTO 0);-- PC_ADDR DIRECTLY PROPAGATED
		signal OFFSET_INT : STD_LOGIC_VECTOR (32-1 DOWNTO 0);-- INST[15-0] SIGN EXTENDED TO 32BIT
		signal OPCODE_INT : STD_LOGIC_VECTOR (5   DOWNTO 0);-- INST[31-26] 	
		signal RS_DATA_INT: STD_LOGIC_VECTOR (32-1 DOWNTO 0);-- DATA OF RD REG (32 BIT)
		signal RT_DATA_INT: STD_LOGIC_VECTOR (32-1 DOWNTO 0);-- DATA OF RT REG (32 BIT)		
		signal RD_IDX_INT : STD_LOGIC_VECTOR (5-1 DOWNTO 0); -- INST[15-11] IDX OF RD 	
		signal RT_IDX_INT : STD_LOGIC_VECTOR (5-1 DOWNTO 0); -- INST[20-16] IDX OF RT
		
		--Control Outputs
		signal WB_CTRL_INT  : WB_CTRL_REG;				              -- CONTROL FOR WB STAGE
		signal MEM_CTRL_INT	: MEM_CTRL_REG;                           -- CONTROL FOR MEM STAGE
		signal EX_CTRL_INT  : EX_CTRL_REG;			                  -- CONTROL FOR EX STAGE

begin

ID: ID_STAGE port map(
        --INPUTS
     	CLK			    => CLK,			
		RESET			=> RESET,		
     	
     	-- FROM IF STAGE				     	
		PC_ADDR   	    => PC_ADDR,
		INSTRUCTION	    => INSTRUCTION,
	    
	    -- FROM WB STAGE
	    RegWrite        => RegWrite,
	    REG_DATA        => REG_DATA,
		REG_ADDR        => REG_ADDR,
		
		--OUTPUTS			
		PC_ADDR_O	    => PC_ADDR_INT,
		OFFSET_O        => OFFSET_INT,
		OPCODE_O        => OPCODE_INT,
		RS_DATA_O       => RS_DATA_INT,
		RT_DATA_O       => RT_DATA_INT,	
		RD_IDX_O        => RD_IDX_INT,
		RT_IDX_O        => RT_IDX_INT,
		
		--Control Outputs
		WB_CTRL_O       => WB_CTRL_INT,
		MEM_CTRL_O		=> MEM_CTRL_INT,
		EX_CTRL_o       => EX_CTRL_INT

);

EX: EX_STAGE port map(

        CLK			    => CLK,				
		RESET			=> RESET,						
     					     	
		PC_ADDR   	    =>PC_ADDR_INT,	
		RS_DATA	        =>RS_DATA_INT,	
	    RT_DATA 		=>RT_DATA_INT,	
		OFFSET			=>OFFSET_INT,		
		OPCODE          =>OPCODE_INT,	
		RT_IDX			=>RT_IDX_INT,	
		RD_IDX			=>RD_IDX_INT,				 				
		
		--CONTROL Inputs		
		WB_CTRL			=>WB_CTRL_INT,			
		MEM_CTRL		=>MEM_CTRL_INT,					
		EX_CTRL			=>EX_CTRL_INT,		     	      
		
		--OUTPUTS			
		PC_ADDR_O	    =>PC_ADDR_O,	
		RESULT_O		=>RESULT_O,		
		RT_DATA_O		=>RT_DATA_O,	
		RT_RD_IDX_O	    =>RT_RD_IDX_O,	
		
		--Control Outputs
		ALU_FLAGS_O	    =>ALU_FLAGS_O,	
		WB_CTRL_O       =>WB_CTRL_O,				
		MEM_CTRL_O		=>MEM_CTRL_O
);

end Behavioral;
