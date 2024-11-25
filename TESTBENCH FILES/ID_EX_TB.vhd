library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;

-- THIS TESTBENCH TESTS THE ID AND EX STAGE. 

entity ID_EX_TB is
end ID_EX_TB;

architecture Behavioral of ID_EX_TB is

constant period: time:=200ns;

-- COMPONENTS

component ID_EX_TEST is
    port(
        CLK			    : in STD_LOGIC;					
		RESET			: in STD_LOGIC;					
     	
     	-- FROM IF STAGE				     	
		PC_ADDR   	    : in STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);	
		INSTRUCTION	    : in STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);	
	    
	    -- FROM WB STAGE
	    RegWrite        : in STD_LOGIC;  
	    REG_DATA        : in STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);
		REG_ADDR        : in STD_LOGIC_VECTOR (ADDR_SIZE-1 DOWNTO 0);
    
        PC_ADDR_O	    : out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RESULT_O		: out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
		RT_DATA_O		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RT_RD_IDX_O	    : out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		
		--Control Outputs
		ALU_FLAGS_O	    : out ALU_FLAGS;
		WB_CTRL_O       : out WB_CTRL_REG;				
		MEM_CTRL_O		: out MEM_CTRL_REG	
    );
end component ID_EX_TEST;

-- SIGNALS
        signal CLK			    : STD_LOGIC;					
		signal RESET			: STD_LOGIC;					
     	
     	-- FROM IF STAGE				     	
		signal PC_ADDR   	    : STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);	
		signal INSTRUCTION	    : STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);	
	    
	    -- FROM WB STAGE
	    signal RegWrite        :  STD_LOGIC;  
	    signal REG_DATA        :  STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);
		signal REG_ADDR        :  STD_LOGIC_VECTOR (ADDR_SIZE-1 DOWNTO 0);
    
        signal PC_ADDR_O	    : STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		signal RESULT_O		    : STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
		signal RT_DATA_O		: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		signal RT_RD_IDX_O	    : STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		
		--Control Outputs
		signal ALU_FLAGS_O	    : ALU_FLAGS;
		signal WB_CTRL_O        : WB_CTRL_REG;				
		signal MEM_CTRL_O		: MEM_CTRL_REG;	

begin

dut: ID_EX_TEST PORT MAP(
        CLK			    =>CLK,					
		RESET			=>RESET,		
     	
     	-- FROM IF STAGE				     	
		PC_ADDR   	    =>PC_ADDR,
		INSTRUCTION	    =>INSTRUCTION,
	    
	    -- FROM WB STAGE
	    RegWrite        =>RegWrite,
	    REG_DATA        =>REG_DATA,
		REG_ADDR        =>REG_ADDR,
    
        PC_ADDR_O	    =>PC_ADDR_O,
		RESULT_O		=>RESULT_O,
		RT_DATA_O		=>RT_DATA_O,
		RT_RD_IDX_O	    =>RT_RD_IDX_O,
		
		--Control Outputs
		ALU_FLAGS_O	    =>ALU_FLAGS_O,
		WB_CTRL_O       =>WB_CTRL_O,		
		MEM_CTRL_O		=>MEM_CTRL_O
     );

    process
    begin
        clk<='0';
        wait for period/2;
        clk<='1';
        wait for period/2;
    end process;
    
    process
    begin			
		RESET		    <= '1';		     	
		PC_ADDR   	    <= (4 => '1', others => '0');	
		INSTRUCTION	    <= b"000000_00000_00000_00000_00000_100000"; -- add r0, r0, r0  -- NOP				
     	wait for 200 ns;
     	-- STORE "00001111" in REG 17
     	RESET           <= '0';
     	PC_ADDR   	    <= STD_LOGIC_VECTOR(TO_UNSIGNED(4,32));	
	    RegWrite        <= '1';
	    REG_DATA        <= (0|1|2|3 => '1', others => '0');
		REG_ADDR        <= b"10001";
		wait for period;
		-- STORE "11110000" IN REG 18
		PC_ADDR   	    <= STD_LOGIC_VECTOR(TO_UNSIGNED(8,32));
		RegWrite        <= '1';
	    REG_DATA        <= (4|5|6|7 => '1', others => '0');
		REG_ADDR        <= b"10010";
		wait for 2 * period;
		PC_ADDR   	    <= STD_LOGIC_VECTOR(TO_UNSIGNED(12,32));
		RegWrite        <= '0';
		INSTRUCTION	    <= b"000000_10001_10010_10000_00000_100000"; -- add r16, r17, r18				
        wait for period;
		PC_ADDR   	    <= STD_LOGIC_VECTOR(TO_UNSIGNED(16,32));
		INSTRUCTION	    <= b"001000_10011_01010_0000000000000100"; -- addi r10, r19, #4	
		wait for period;
		PC_ADDR   	    <= STD_LOGIC_VECTOR(TO_UNSIGNED(20,32));
		INSTRUCTION	    <= b"100011_10011_01000_0000000000100000"; -- lw r8, 32(r19)
		wait for period;
		PC_ADDR   	    <= STD_LOGIC_VECTOR(TO_UNSIGNED(24,32));
		INSTRUCTION	    <= b"001111_00000_01000_0000010000000100"; -- lui $r8, 1028
		wait for period;
		PC_ADDR   	    <= STD_LOGIC_VECTOR(TO_UNSIGNED(28,32));
		INSTRUCTION	    <= b"000100_01000_00000_0000000000000101"; -- beq $r8, $r0, 5
		wait for period;
		PC_ADDR   	    <= STD_LOGIC_VECTOR(TO_UNSIGNED(32,32));
		INSTRUCTION	    <= b"000000_00000_10001_10000_00001_000010"; -- srl r16, r17, 1
        wait for 1.5*period;
        reset <= '1';
        wait;
    end process;

end Behavioral;
