library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;

entity MEM_STAGE is
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
end MEM_STAGE;

architecture MEM_ARCH of MEM_STAGE is

-- COMPONENT DECLARATIONS
component MEMORY_BANK is
    generic(BLOCKSIZE: NATURAL);
	port(
	    RESET     : in  std_logic;
		CLK       : in  std_logic;
		W_R_CTRL  : in  STD_LOGIC_VECTOR(1 DOWNTO 0);
		ADDR      : in  std_logic_vector(INST_SIZE-1 downto 0);
		DATA      : in  std_logic_vector(INST_SIZE-1 downto 0);
		DATA_O    : out std_logic_vector(INST_SIZE-1 downto 0)
	);
end component MEMORY_BANK;

component MEM_WB_R is
    port(
        CLK          : in STD_LOGIC;
        RESET        : in STD_LOGIC;
        
        REG_DATA_MEM : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
        REG_IDX_MEM	 : in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
        WB_CTRL_MEM  : in WB_CTRL_REG;	
        
        REG_DATA_WB  : out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
        REG_IDX_WB	 : out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
        WB_CTRL_WB   : out WB_CTRL_REG
    );
end component MEM_WB_R;  

-- SIGNAL DECLARATIONS
begin

-- COMPONENT INSTANTIATION
MEM_BANK: MEMORY_BANK 
    GENERIC MAP(BLOCKSIZE => MEM_SIZE)
    PORT MAP(
        RESET     => RESET,
        CLK       => CLK,
        W_R_CTRL  => MEM_CTRL.W_R_CTRL,
        ADDR      => M_ADDR,
        DATA      => M_DATA,
        DATA_O    => MEM_DATA_O
);

MEM_WB_REGS: MEM_WB_R 
    PORT MAP(
        CLK          => CLK,
        RESET        => RESET,
        
        REG_DATA_MEM => REG_DATA,
        REG_IDX_MEM	 => RT_RD_IDX,
        WB_CTRL_MEM  => WB_CTRL,
        
        REG_DATA_WB  => REG_DATA_O,
        REG_IDX_WB	 => REG_IDX_O,
        WB_CTRL_WB   => WB_CTRL_O
    );  
    
-- OUTPUTS NOT REGISTERED
   PC_ADDR_O <= PC_ADDR;   
   PC_SRC_O <= (ALU_FLAGS.EQUAL AND MEM_CTRL.BRANCH(1)) OR (not ALU_FLAGS.EQUAL AND MEM_CTRL.BRANCH(0)) ;	

end MEM_ARCH;
