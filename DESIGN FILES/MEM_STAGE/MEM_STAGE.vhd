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
end MEM_STAGE;

architecture MEM_ARCH of MEM_STAGE is

-- COMPONENT DECLARATIONS
component MEMORY_BANK is
	port(
	    RESET     : in  std_logic;
		CLK       : in  std_logic;
		W_R_CTRL  : in  STD_LOGIC_VECTOR(3 DOWNTO 0);
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
        MEM_WB_CTRL_MEM : in MEM_WB_CTRL_REG;	
        byte_idx_MEM : in STD_LOGIC_VECTOR(1 DOWNTO 0);		
	        
        REG_DATA_WB  : out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
        REG_IDX_WB	 : out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
        MEM_WB_CTRL_WB	: out MEM_WB_CTRL_REG;	
        byte_idx_WB  : out STD_LOGIC_VECTOR(1 DOWNTO 0)	
    );
end component MEM_WB_R;  

-- SIGNAL DECLARATIONS
begin

-- COMPONENT INSTANTIATION
MEM_BANK: MEMORY_BANK 
    PORT MAP(
        RESET     => RESET,
        CLK       => CLK,
        W_R_CTRL  => MEM_WB_CTRL.W_R_CTRL,
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
        MEM_WB_CTRL_MEM => MEM_WB_CTRL,
        byte_idx_MEM => M_ADDR(1 DOWNTO 0),
        
        REG_DATA_WB  => REG_DATA_O,
        REG_IDX_WB	 => REG_IDX_O,
        MEM_WB_CTRL_WB => MEM_WB_CTRL_O,
        byte_idx_WB => byte_idx_O
        
    );  

end MEM_ARCH;
