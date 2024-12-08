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
        
        -- SIGNALS CREATED IN ID STAGE
        OFFSET_IN_S         : in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        OFFSET_IN_U         : in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        RT_IDX_IN           : in STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);--idx is 5 bit
        RD_IDX_IN           : in STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);--idx is 5 bit
        RS_DATA_IN          : in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        RT_DATA_IN          : in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        PC_ADDR_IN          : in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        -- CONTROL SIGNALS CREATED IN ID STAGE
        MEM_WB_CTRL_IN      : in MEM_WB_CTRL_REG;
        EX_CTRL_IN          : in EX_CTRL_REG;
              
        --OUTPUTS
        OFFSET_O_S          : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        OFFSET_O_U          : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        RT_IDX_O            : out STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);--idx is 5 bit
        RD_IDX_O            : out STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);--idx is 5 bit
        RT_DATA_O           : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);--data is 32bit
        RS_DATA_O           : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);--data is 32bit
        PC_ADDR_O           : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        MEM_WB_CTRL_O       : out MEM_WB_CTRL_REG;
        EX_CTRL_O           : out EX_CTRL_REG
    );
end ID_EX_REGISTERS;    

architecture ARCH_ID_EX_REGS of ID_EX_REGISTERS IS
begin
    process(CLK,RESET)
	  begin
		if rising_edge(CLK) then
		  if RESET = '1' then -- SYNCHRONOUS RESET
				OFFSET_O_S		<= (others => '0');
				OFFSET_O_U		<= (others => '0');
				RT_IDX_O		<= (others => '0');
				RD_IDX_O		<= (others => '0');
				RS_DATA_O	 	<= (others => '0');
				RT_DATA_O 		<= (others => '0');
				PC_ADDR_O       <= (others => '0');
			    MEM_WB_CTRL_O	<= ("0000",'0');
				EX_CTRL_O		<= ("00",'0','0',ADDU);
		  else
				-- SIGNALS CREATED IN ID STAGE
				-- DATA FROM REGISTERS
				RS_DATA_O	 	<= RS_DATA_IN;
				RT_DATA_O 		<= RT_DATA_IN;
				-- REGISTER INDEX 
				RT_IDX_O		<= RT_IDX_IN;
				RD_IDX_O		<= RD_IDX_IN;
				PC_ADDR_O       <= PC_ADDR_IN;
				-- OTHER FIELDS OF INSTR USED.
				OFFSET_O_S		<= OFFSET_IN_S;
				OFFSET_O_U		<= OFFSET_IN_U;
				-- CONTROL SIGNALS
				MEM_WB_CTRL_O	<= MEM_WB_CTRL_IN;
				EX_CTRL_O		<= EX_CTRL_IN;
		  end if;
      end if;  		
    end process;

END ARCH_ID_EX_REGS;



