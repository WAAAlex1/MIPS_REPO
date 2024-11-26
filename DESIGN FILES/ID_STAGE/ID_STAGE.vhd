library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;


entity ID_STAGE is
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
		OFFSET_O        : out STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);-- INST[15-0] SIGN EXTENDED TO 32BIT
		RS_DATA_O       : out STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);-- DATA OF RD REG (32 BIT)
		RT_DATA_O       : out STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);-- DATA OF RT REG (32 BIT)		
		RD_IDX_O        : out STD_LOGIC_VECTOR (ADDR_SIZE-1 DOWNTO 0); -- INST[15-11] IDX OF RD 	
		RT_IDX_O        : out STD_LOGIC_VECTOR (ADDR_SIZE-1 DOWNTO 0); -- INST[20-16] IDX OF RT
		
		--Control Outputs
		WB_CTRL_O       : out WB_CTRL_REG;				              -- CONTROL FOR WB STAGE
		MEM_CTRL_O		: out MEM_CTRL_REG;                           -- CONTROL FOR MEM STAGE
		EX_CTRL_o       : out EX_CTRL_REG;	
		
		-- OUTPUTS TO IF STAGE
        PC_SEL_ID_IF    : out STD_LOGIC;
        PC_ADDR_ID_IF   : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        
        -- OUTPUTS TO TOP LEVEL
        REGISTERS       : out REG_ARR
        	                  
	);
end ID_STAGE;

architecture ARCH_ID_STAGE of ID_STAGE is

-- DECLARATION OF COMPONENTS
    -- COMPONENTS: REGISTER_FILE, CONTROL_UNIT, ID_EX_REGISTERS

component REGISTER_FILE is
    port(
        --INPUTS
        clk         : in STD_LOGIC;
        RESET       : in STD_LOGIC;
        RegWrite    : in STD_LOGIC;
        RS_IDX 	    : in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
        RT_IDX 	    : in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
        RD_IDX 	    : in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
        W_DATA      : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
        --OUTPUTS
        RS_DATA_O   : out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
        RT_DATA_O   : out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
        
        --OUTPUTS TO TOP
        REGISTERS   : out REG_ARR
    );
end component REGISTER_FILE; 

component ID_EX_REGISTERS is
    port(
        -- INPUTS
        CLK                 : in STD_LOGIC;
        RESET               : in STD_LOGIC;
        
        -- SIGNALS CREATED IN ID STAGE
        OFFSET_IN           : in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        RT_IDX_IN           : in STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);--idx is 5 bit
        RD_IDX_IN           : in STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);--idx is 5 bit
        RS_DATA_IN          : in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        RT_DATA_IN          : in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        -- CONTROL SIGNALS CREATED IN ID STAGE
        WB_CTRL_IN          : in WB_CTRL_REG;
        MEM_CTRL_IN         : in MEM_CTRL_REG;
        EX_CTRL_IN          : in EX_CTRL_REG;
              
        --OUTPUTS
        OFFSET_O            : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        RT_IDX_O            : out STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);--idx is 5 bit
        RD_IDX_O            : out STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);--idx is 5 bit
        RT_DATA_O           : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);--data is 32bit
        RS_DATA_O           : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);--data is 32bit
        WB_CTRL_O           : out WB_CTRL_REG;
        MEM_CTRL_O          : out MEM_CTRL_REG;
        EX_CTRL_O           : out EX_CTRL_REG
    );
end component ID_EX_REGISTERS; 

component CONTROL_UNIT is
    port(
    --Inputs
    OPCODE  :   in STD_LOGIC_VECTOR(5 downto 0);
    FUNCT   :   in STD_LOGIC_VECTOR(5 downto 0);
    --Outputs
    
    --CONTROL SIGNALS FOR EX STAGE
    ALUTYPE :   out STD_LOGIC;
    ALUSRC  :   out STD_LOGIC;
    ALULS   :   out STD_LOGIC;
    
    --CONTROL SIGNALS FOR MEM STAGE
    W_R_CTRL:   out STD_LOGIC_VECTOR(1 DOWNTO 0);
    BRANCH  :   out STD_LOGIC_VECTOR(1 DOWNTO 0);

    --CONTROL SIGNALS FOR WB STAGE
    RegWrite:   out STD_LOGIC;
    MemToReg:   out STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
end component CONTROL_UNIT;

component ALU_CONTROL is
	port(
        -- INPUTS				
        FUNCT		:	in STD_LOGIC_VECTOR(5 DOWNTO 0);	
        OPCODE      :   IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        ALU_TYPE	:	in STD_LOGIC;	
        -- OUTPUTS	
        ALU_OPSEL   :	out ALU_OPSELECT	
	);
end component ALU_CONTROL;

component BRANCH_CONTROL is
    port(
        -- INPUTS
        PC_ADDR: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        OFFSET:  in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        RS_DATA: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        RT_DATA: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        BRANCH_CTRL: in STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        -- OUTPUTS
        PC_SEL: out STD_LOGIC;
        PC_ADDR_O: out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0)
    );
end component BRANCH_CONTROL;

-- DECLARATION OF SIGNALS
signal WB_CTRL_INT		: WB_CTRL_REG;
signal MEM_CTRL_INT		: MEM_CTRL_REG;
signal EX_CTRL_INT		: EX_CTRL_REG;

signal RS_DATA_INTERNAL: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
signal RT_DATA_INTERNAL: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);

signal OFFSET_SIGN_EXTENDED: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
signal BRANCH_INTERNAL: STD_LOGIC_VECTOR(1 DOWNTO 0);

begin

-- SIGN EXTENDING THE OFFSET (immediate value)
with INSTRUCTION(15) select OFFSET_SIGN_EXTENDED <=
                    H16b&Instruction(15 downto 0) when '1',
                    L16b&Instruction(15 downto 0) when others;

--INSTANTIATION OF COMPONENTS
REGFILE: REGISTER_FILE PORT MAP(
    --INPUTS
    clk         => clk,
    RESET       => reset,
    RegWrite    => RegWrite,
    RS_IDX 	    => INSTRUCTION(25 DOWNTO 21),
    RT_IDX 	    => INSTRUCTION(20 DOWNTO 16),
    RD_IDX 	    => REG_ADDR,
    W_DATA      => REG_DATA,
    
    --OUTPUTS
    RS_DATA_O   => RS_DATA_INTERNAL,
    RT_DATA_O   => RT_DATA_INTERNAL,
    
    --OUTPUTS TO TOP LEVEL
    REGISTERS   => REGISTERS
);

CU: CONTROL_UNIT PORT MAP(
    --Inputs
    OPCODE  => INSTRUCTION(INSTRUCTION'High DOWNTO INSTRUCTION'High-5),
    FUNCT   => INSTRUCTION(INSTRUCTION'low + 5 DOWNTO INSTRUCTION'low),
    --Outputs
    
    --CONTROL SIGNALS FOR EX STAGE
    ALUTYPE => EX_CTRL_INT.ALUTYPE,
    ALUSRC  => EX_CTRL_INT.ALUSRC,
    ALULS   => EX_CTRL_INT.ALULS,
    
    --CONTROL SIGNALS FOR MEM STAGE
    W_R_CTRL => MEM_CTRL_INT.W_R_CTRL,
    Branch   => BRANCH_INTERNAL,

    --CONTROL SIGNALS FOR WB STAGE
    RegWrite => WB_CTRL_INT.RegWrite,
    MemToReg => WB_CTRL_INT.MemToReg
);

ALU_CTRL: ALU_CONTROL port map(
    FUNCT		=> INSTRUCTION(5 DOWNTO 0),
    OPCODE      => INSTRUCTION(31 DOWNTO 26),
    ALU_TYPE    => EX_CTRL_INT.ALUTYPE,
    -- OUTPUTS	
    ALU_OPSEL   => EX_CTRL_INT.ALUOpSelect
);

BRA_CTRL: BRANCH_CONTROL port map(
        -- INPUTS
        PC_ADDR => PC_ADDR,
        OFFSET => OFFSET_SIGN_EXTENDED,
        RS_DATA => RS_DATA_INTERNAL,
        RT_DATA => RT_DATA_INTERNAL,
        BRANCH_CTRL => BRANCH_INTERNAL,
        
        -- OUTPUTS
        PC_SEL => PC_SEL_ID_IF,
        PC_ADDR_O => PC_ADDR_ID_IF
);

ID_EX_REGS: ID_EX_REGISTERS PORT MAP(
        -- INPUTS
        CLK          => clk,
        RESET        => RESET,
        
        -- SIGNALS CREATED IN ID STAGE
        OFFSET_IN    => OFFSET_SIGN_EXTENDED,
        RT_IDX_IN    => INSTRUCTION(20 DOWNTO 16),
        RD_IDX_IN    => INSTRUCTION(15 DOWNTO 11),
        RS_DATA_IN   => RS_DATA_INTERNAL,
        RT_DATA_IN   => RT_DATA_INTERNAL,
        
        -- CONTROL SIGNALS CREATED IN ID STAGE
        WB_CTRL_IN   => WB_CTRL_INT,
        MEM_CTRL_IN  => MEM_CTRL_INT,
        EX_CTRL_IN   => EX_CTRL_INT,
              
        --OUTPUTS
        OFFSET_O     => OFFSET_O,
        RT_IDX_O     => RT_IDX_O,
        RD_IDX_O     => RD_IDX_O,
        RT_DATA_O    => RT_DATA_O,
        RS_DATA_O    => RS_DATA_O,
        WB_CTRL_O    => WB_CTRL_O,
        MEM_CTRL_O   => MEM_CTRL_O,
        EX_CTRL_O    => EX_CTRL_O
    );



end ARCH_ID_STAGE;

