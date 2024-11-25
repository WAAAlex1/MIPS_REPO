library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;


entity ID_EX_REGISTERS is
    port(
        --INPUTS
        CLK                 : in STD_LOGIC;
        RESET               : in STD_LOGIC;
        
        -- INPUTS FROM IF STAGE
        PC_ADDR_IN          : in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);--PCADDR is 32bit
        -- SIGNALS CREATED IN ID STAGE
        OFFSET_IN           : in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        OPCODE_IN           : in STD_LOGIC_VECTOR(ADDR_SIZE   DOWNTO 0);--opcode is 6 bit
        RT_IDX_IN           : in STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);--idx is 5 bit
        RD_IDX_IN           : in STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);--idx is 5 bit
        RS_DATA_IN          : in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        RT_DATA_IN          : in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        -- CONTROL SIGNALS CREATED IN ID STAGE
        WB_CTRL_IN          : in WB_CTRL_REG;
        MEM_CTRL_IN         : in MEM_CTRL_REG;
        EX_CTRL_IN          : in EX_CTRL_REG;
              
        --OUTPUTS
        PC_ADDR_O           : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);--PCADDR is 32bit
        OFFSET_O            : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        OPCODE_O            : out STD_LOGIC_VECTOR(ADDR_SIZE   DOWNTO 0);--opcode is 6 bit
        RT_IDX_O            : out STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);--idx is 5 bit
        RD_IDX_O            : out STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);--idx is 5 bit
        RT_DATA_O           : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);--data is 32bit
        RS_DATA_O           : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);--data is 32bit
        WB_CTRL_O           : out WB_CTRL_REG;
        MEM_CTRL_O          : out MEM_CTRL_REG;
        EX_CTRL_O           : out EX_CTRL_REG
    );
end ID_EX_REGISTERS;    

architecture ARCH_ID_EX_REGS of ID_EX_REGISTERS IS
begin
    process(CLK,RESET,PC_ADDR_IN,OFFSET_IN,RT_IDX_IN,RD_IDX_IN,RS_DATA_IN,RT_DATA_IN,WB_CTRL_IN,MEM_CTRL_IN,EX_CTRL_IN)
	  begin
		if RESET = '1' then -- ASYNCHRONOUS RESET
				PC_ADDR_O		<= (others => '0');
				OFFSET_O		<= (others => '0');
				OPCODE_O        <= (others => '0');
				RT_IDX_O		<= (others => '0');
				RD_IDX_O		<= (others => '0');
				RS_DATA_O	 	<= (others => '0');
				RT_DATA_O 		<= (others => '0');
				WB_CTRL_O		<= ('0','0');
				MEM_CTRL_O		<= ('0','0','0');
				EX_CTRL_O		<= ('0','0','0');
		elsif rising_edge(CLK) then
		        -- DIRECTLY PROPAGATED FROM IF
				PC_ADDR_O		<= PC_ADDR_IN;
				
				-- SIGNALS CREATED IN ID STAGE
				-- DATA FROM REGISTERS
				RS_DATA_O	 	<= RS_DATA_IN;
				RT_DATA_O 		<= RT_DATA_IN;
				-- REGISTER INDEX 
				RT_IDX_O		<= RT_IDX_IN;
				RD_IDX_O		<= RD_IDX_IN;
				-- OTHER FIELDS OF INSTR USED.
				OFFSET_O		<= OFFSET_IN;
				OPCODE_O        <= OPCODE_IN;
				-- CONTROL SIGNALS
				WB_CTRL_O		<= WB_CTRL_IN;
				MEM_CTRL_O		<= MEM_CTRL_IN;
				EX_CTRL_O		<= EX_CTRL_IN;
		end if;
	  end process;



END ARCH_ID_EX_REGS;



