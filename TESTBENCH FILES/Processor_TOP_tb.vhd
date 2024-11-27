library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


library work;
use work.records.all;
use work.constants_pkg.all;


entity Processor_TOP_tb is
end Processor_TOP_tb;

architecture Behavioral of Processor_TOP_tb is

constant period: time:=200ns;

component PROCESSOR_TOP is
    port(
        CLK: in STD_LOGIC;
        RESET: in STD_LOGIC;
        PROG_SEL: in STD_LOGIC_VECTOR(2 DOWNTO 0);
        INSTRUCTION: in STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        REGISTERS: out REG_ARR
    );
end component PROCESSOR_TOP;

signal CLK: STD_LOGIC;
signal RESET: STD_LOGIC;
signal PROG_SEL: STD_LOGIC_VECTOR(2 DOWNTO 0);
signal INSTRUCTION: STD_LOGIC_VECTOR(31 downto 0);
signal REGISTERS: REG_ARR;

begin

dut: PROCESSOR_TOP port map(

    CLK => CLK,
    RESET => RESET,
    PROG_SEL => PROG_SEL,
    INSTRUCTION => INSTRUCTION,
    REGISTERS => REGISTERS
    
);

    PROG_SEL <= "000";

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
		INSTRUCTION	    <= b"000000_00000_00000_00000_00000_100000"; -- add r0, r0, r0  -- NOP				
     	wait for period;
     	RESET           <= '0';
		INSTRUCTION	    <= b"101011_00000_00001_00000_00000_100000"; -- SW r1, 32(r0)		
        wait for period;
		INSTRUCTION	    <= b"101011_00000_00010_00000_00000_100100"; -- SW r2, 36(r0)	
		wait for period;
		INSTRUCTION	    <= b"101011_00000_00011_00000_00000_101000"; -- SW r3, 40(r0)
		wait for period;
		INSTRUCTION	    <= b"100011_00000_01010_00000_00000_100000"; -- LW r10, 32(r0)		
        wait for period;
		INSTRUCTION	    <= b"100011_00000_01011_00000_00000_100100"; -- LW r11, 36(r0)	
		wait for period;
		INSTRUCTION	    <= b"100011_00000_01100_00000_00000_101000"; -- LW r12, 40(r0)
		wait for period;
		INSTRUCTION	    <= b"100000_00000_01010_00000_00000_100000"; -- LB r10, 32(r0)		
        wait for period;
		INSTRUCTION	    <= b"100000_00000_01011_00000_00000_100100"; -- LB r11, 36(r0)	
		wait for period;
		INSTRUCTION	    <= b"100100_00000_01100_00000_00000_100100"; -- LBU r12, 36(r0)
		wait for period;
		INSTRUCTION	    <= b"100100_00000_01010_00000_00000_101000"; -- LBU r10, 40(r0)		
        wait for period;
		INSTRUCTION	    <= b"100100_00000_01011_00000_00000_101001"; -- LBU r11, 41(r0)	
		wait for period;
		INSTRUCTION	    <= b"100100_00000_01100_00000_00000_101010"; -- LBU r12, 42(r0)
		wait for period;
		INSTRUCTION	    <= b"100100_00000_01100_00000_00000_101011"; -- LBU r12, 43(r0)
		wait for period;
		INSTRUCTION	    <= b"101000_00000_00100_00000_00000_101100"; -- SB r4, 44(r0)
		wait for period;
		INSTRUCTION	    <= b"101000_00000_00100_00000_00000_101101"; -- SB r4, 45(r0)
		wait for period;
		INSTRUCTION	    <= b"101000_00000_00100_00000_00000_101110"; -- SB r4, 46(r0)
		wait for period;
		INSTRUCTION	    <= b"101000_00000_00100_00000_00000_101111"; -- SB r4, 47(r0)
		wait for period;
		INSTRUCTION	    <= b"100011_00000_01100_00000_00000_101100"; -- LW r12, 44(r0)
		wait for 5*period;
        reset <= '1';
        wait;
    end process;


end Behavioral;
