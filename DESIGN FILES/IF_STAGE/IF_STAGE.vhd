library IEEE;
use IEEE.STD_LOGIC_1164.all;                              
use IEEE.numeric_std.all;

library work;
use work.constants_pkg.all;

entity IF_STAGE is
        port(
            --INPUTS
            CLK          : in STD_LOGIC;                                                                          
            RESET        : in STD_LOGIC;                                                                                                                                                                                                
            BRANCH_PC    : in STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);           
            RESET_PC     : in STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);
            PC_SEL       : in STD_LOGIC;                                                    
            --OUTPUTS        (REGISTERED)                 
            MEM_DATA_O   : out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);
            PC_o         : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0)
            );
end IF_STAGE;

architecture IF_ARCH of IF_STAGE is

    signal PC_ADDR: STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0) := (others => '0');
    signal PC_INCd: STD_LOGIC_VECTOR (INST_SIZE-1 DOWNTO 0);

-- COMPONENT DECLARATIONS

component INST_MEM is
   port(
       RESET     : in  std_logic;
       CLK       : in  std_logic;
       ADDR      : in  STD_LOGIC_VECTOR(5 DOWNTO 0);
       DATA_O    : out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0)
       );
end component INST_MEM;

--    component INCREMENTER is
--        GENERIC ( DEPTH: INTEGER := 6 );
--        port(
--           ADDR : in  STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
--           SUM  : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0)
--           );
--    end component INCREMENTER;

    component IF_ID_R is
        port(
           CLK            : in STD_LOGIC;
           RESET          : in STD_LOGIC;
           PC_IN          : in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
           PC_OUT         : out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0)
           );
    end component IF_ID_R; 

-- SIGNAL DECLARATIONS
--...

begin

    -- COMPONENT INSTANTIATION
    
    -- INSTRUCTION MEMORY
    -- PUTS INSTRUCTION AT PC_ADDR ON MEM_DATA_O AFTER 1 CLOCK CYCLE. 
    INSTRUCTION_MEM_BANK: INST_MEM
        PORT MAP(
            RESET     => RESET,
            CLK       => CLK,
            ADDR      => PC_ADDR(5 DOWNTO 0),
            DATA_O    => MEM_DATA_O
        );
 
 --  SIMPLE HALF ADDER FOR INCREMENTING THE PC BY 1.
 --  PC INCREMENTED BY 1 AS THE INSTRUCTION MEMORY IS WORD-ADDRESSABLE. 
 --   INCREMETER: INCREMENTER
 --       GENERIC MAP( DEPTH => 6 )
 --       PORT MAP(
 --           ADDR => PC_ADDR,
 --           SUM => PC_INCd
 --       );
 
    PC_INCd <= std_logic_vector(unsigned(PC_ADDR) + 1);

    -- REGISTER OUTPUT OF IF STAGE (TO ID STAGE)
    -- INSTRUCTION NOT HERE AS IT IS EFFECTIVELY REGISTERED ALREADY
    OUTPUT_REG: IF_ID_R
        PORT MAP(
           CLK => CLK,
           RESET => RESET,
           PC_IN => PC_ADDR, -- COMPUTED ADDDRESS
           PC_OUT => PC_o
         );
              
    -- PC REGISTER WITH LOGIC FOR SELECTING NEXT PC          
    process (CLK, RESET_PC, BRANCH_PC, PC_INCd, RESET)
    begin   
      if (rising_edge(CLK)) then
        if (RESET='1') then
            PC_ADDR <= RESET_PC;   -- RESETTING (SYNCHRONOUS)
        elsif (PC_SEL = '1') then
            PC_ADDR <= BRANCH_PC;  -- BRANCHING        
        elsif (PC_SEL = '0') then
            PC_ADDR <= PC_INCd;    -- NORMAL OPERATION
        end if;
      end if;
    end process;

          

end IF_ARCH;