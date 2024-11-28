library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library work;

entity IF_STAGE_test is
end IF_STAGE_test;

architecture TB of IF_STAGE_test is
    -- DUT inputs
    signal CLK          : std_logic := '0';
    signal RESET        : std_logic := '0';
    signal BRANCH_PC    : std_logic_vector(31 downto 0) := (others => '0');
    signal RESET_PC     : std_logic_vector(31 downto 0) := (others => '0');
    signal PC_SEL       : std_logic := '0';
    
    -- DUT outputs
    signal MEM_DATA_O   : std_logic_vector(31 downto 0); 
    signal PC_o         : std_logic_vector(31 downto 0);
    
    constant CLK_PERIOD : TIME:= 100 ns;

begin
    -- DUT instantiation
    DUT: entity work.IF_STAGE
        port map(
            CLK          => CLK,
            RESET        => RESET,
            BRANCH_PC    => BRANCH_PC,
            RESET_PC     => RESET_PC,
            PC_SEL       => PC_SEL,
            MEM_DATA_O   => MEM_DATA_O,
            PC_o         => PC_o
        );

    -- Clock generation
    clk_process: process

    begin
        while true loop
            CLK <= '0';
            wait for CLK_PERIOD / 2;
            CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Test procedure
    stimulus_process: 
    process
    begin
        RESET <= '1';
        RESET_PC <= std_logic_vector(to_unsigned(0,32));
        wait for 2*CLK_PERIOD;
        RESET <= '0';
        PC_SEL <= '0';
        wait for 10*CLK_PERIOD;
        PC_SEL <= '1';
        BRANCH_PC <= std_logic_vector(to_unsigned(32,32));
        wait for CLK_PERIOD;
        PC_SEL <= '0';
        wait for 2*CLK_PERIOD;
        RESET <= '1';
        RESET_PC <= std_logic_vector(to_unsigned(10,32));
        wait for CLK_PERIOD;
        RESET <= '0';
        wait;
    end process;

 

end TB;