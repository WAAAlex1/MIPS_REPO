library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SEVEN_SEG_DRIVER is
	port(
		clk       : in  std_logic;
		data      : in  std_logic_vector(15 downto 0);
		ano       : out std_logic_vector(4 downto 1);
		seg_out   : out std_logic_vector(7 downto 1)
	);
end SEVEN_SEG_DRIVER;

architecture arch of SEVEN_SEG_DRIVER is
	
	signal cnt: unsigned(18 downto 0) := to_unsigned(0,19); --Need 19 bits to count to 300.000 (3ms uptime for each anode)
	signal ano_1: std_logic_vector(ano'high downto ano'low):=b"1000";
	constant num_bits: natural:=19;
	constant count_target: natural:=300000;
	
	signal index: unsigned(1 downto 0):=b"00";
	
	type DATA_T is ARRAY(3 downto 0) of STD_LOGIC_VECTOR(3 DOWNTO 0);
	signal DATA_IN: DATA_T;
	
	type PATTERN_T is ARRAY(3 downto 0) of STD_LOGIC_VECTOR(7 DOWNTO 1);
	signal pattern: PATTERN_T;
	
begin
    -- INPUTS
    GENERATE_INPUTS: 
	for i in 0 to 3 generate
        DATA_IN(i) <= data(((i+1)*4)-1 DOWNTO i*4);
	end generate; 
	
	-- PROCESS 1 -> TRANSLATE DATA INTO PATTERN
	GENERATE_PATTERNS: 
	for i in 0 to 3 generate
        with to_integer(unsigned(DATA_IN(i))) select
           pattern(i) <= 
           b"0110_000" when 1,
           b"1101_101" when 2,
           b"1111_001" when 3, 
           b"0110_011" when 4, 
           b"1011_011" when 5,
           b"1011_111" when 6,
           b"1110_010" when 7,
           b"1111_111" when 8,
           b"1111_011" when 9,
           b"1110_111" when 10, --A
           b"0011_111" when 11, --b
           b"0111_101" when 12, --C
           b"0111_101" when 13, --d
           b"1001_111" when 14, --E
           b"1000_111" when 15, --F
           b"1111_110" when others;
	end generate;                  
	
	ano <= ano_1;
	
	-- PROCESS 2 -> DRIVE DATA ONTO 7-SEG
	-- 2 segment approach. 
	-- use simple counter. When count reached circular shift anode right once. 
	-- as each digit should then be turned on for 3ms -> 3/1000hZ -> needs 300.000 cycles from 100MHz clock. 
	
	process(clk, cnt, index, ano_1) 
	begin
	if rising_edge(clk) then
	   if cnt = to_unsigned(count_target,num_bits) then
           ano_1 <= ano_1(ano_1'low)&ano_1(ano_1'high downto ano_1'low+1); -- Right circular shifting
           cnt <= to_unsigned(0,num_bits);
           seg_out <= not pattern(to_integer(index));
           if index = 3 then
              index <= to_unsigned(0,2);
           else
              index <= index+1;
           end if;      
       else
           cnt <= cnt+1;
       end if;
	 end if;
	end process;

end arch;