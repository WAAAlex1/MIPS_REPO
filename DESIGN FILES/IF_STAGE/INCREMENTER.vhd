library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.constants_pkg.all;

entity INCREMENTER is
    Generic ( DEPTH: INTEGER := 6 );
    port(  
           ADDR : in  STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);
           SUM  : out STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0)
         );
end INCREMENTER;

architecture Behavioral of INCREMENTER is
begin

    -- WE CAN SIMPLIFY THIS IF WE WANT -> SINCE ADDR IS ONLY 6 BITS WE CAN
    -- ONLY INCREMENT THE FIRST 6 BITS. THIS IS LESS GENERAL BUT MORE OPTIMAL.
    process(ADDR)
        variable carry : std_logic := '1';
        variable temp_sum : STD_LOGIC_VECTOR(INST_SIZE-1 downto 0) := (others => '0');
    begin
        for i in 0 to DEPTH-1 loop
                -- Apply half-adder logic for each bit: sum = ADDR(i) XOR 1, carry = ADDR(i) AND 1
                temp_sum(i) := ADDR(i) XOR carry;  -- sum=ADRR+1
                carry := ADDR(i) AND carry;
        end loop;
        SUM <= temp_sum;    
    end process;

end Behavioral;