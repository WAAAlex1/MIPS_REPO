library IEEE;
use IEEE.STD_LOGIC_1164.all;                              
use IEEE.numeric_std.all;
library work;
use work.constants_pkg.all;

Library xpm;
use xpm.vcomponents.all;


entity INST_MEM is
        port(
            RESET     : in  std_logic;
            CLK       : in  std_logic;
            ADDR      : in  STD_LOGIC_VECTOR (5 DOWNTO 0);
            PC_SEL    : in  STD_LOGIC;
            DATA_O    : out std_logic_vector(INST_SIZE-1 DOWNTO 0)
        );
end INST_MEM;

architecture arch of INST_MEM is

    signal mem_data_O: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal din: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    
    signal pc_sel_old: STD_LOGIC;
   
 begin
    DATA_O <= mem_data_O when pc_sel_old = '0' else x"00000020";
    din <= (others=>'0'); -- NOTE: NEVER WRITING TO INSTRUCTION MEMORY

    process(CLK)
    begin
        if rising_edge(CLK) then
            pc_sel_old <= PC_SEL;
        end if;
    end process;

-- xpm_memory_spram: Single Port RAM
-- Xilinx Parameterized Macro, version 2024.2
xpm_memory_spram_inst : xpm_memory_spram

generic map (

   ADDR_WIDTH_A => 6,              -- DECIMAL
   AUTO_SLEEP_TIME => 0,           -- DECIMAL
   BYTE_WRITE_WIDTH_A => 8,        -- DECIMAL
   CASCADE_HEIGHT => 0,            -- DECIMAL
   ECC_BIT_RANGE => "7:0",         -- String
   ECC_MODE => "no_ecc",           -- String
   ECC_TYPE => "none",             -- String
   IGNORE_INIT_SYNTH => 0,         -- DECIMAL
   MEMORY_INIT_FILE => "INSTR_MEM_INIT.mem", -- String
   MEMORY_INIT_PARAM => "0",       -- String
   MEMORY_OPTIMIZATION => "true",  -- String
   MEMORY_PRIMITIVE => "auto",     -- String
   MEMORY_SIZE => 2048,           -- DECIMAL
   MESSAGE_CONTROL => 0,           -- DECIMAL
   RAM_DECOMP => "auto",           -- String
   READ_DATA_WIDTH_A => 32,        -- DECIMAL
   READ_LATENCY_A => 1,            -- DECIMAL
   READ_RESET_VALUE_A => "0",      -- String
   RST_MODE_A => "SYNC",           -- String
   SIM_ASSERT_CHK => 0,            -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   USE_MEM_INIT => 1,              -- DECIMAL
   USE_MEM_INIT_MMI => 0,          -- DECIMAL
   WAKEUP_TIME => "disable_sleep", -- String
   WRITE_DATA_WIDTH_A => 32,       -- DECIMAL
   WRITE_MODE_A => "write_first",   -- String
   WRITE_PROTECT => 1              -- DECIMAL
)

port map (
   dbiterra => open,            -- 1-bit output: Status signal to indicate double bit error occurrence
                                     -- on the data output of port A.

   douta => mem_data_O,         -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
   sbiterra => open,                -- 1-bit output: Status signal to indicate single bit error occurrence
                                     -- on the data output of port A.
   addra => ADDR,               -- ADDR_WIDTH_A-bit input: Address for port A write and read operations.
   clka => CLK,                     -- 1-bit input: Clock signal for port A.
   dina => din,                 -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
   ena => '1',                       -- 1-bit input: Memory enable signal for port A. Must be high on clock
                                     -- cycles when read or write operations are initiated. Pipelined
                                     -- internally.
   injectdbiterra => '0',      -- 1-bit input: Controls double bit error injection on input data when
                                     -- ECC enabled (Error injection capability is not available in
                                     -- "decode_only" mode).

   injectsbiterra => '0',           -- 1-bit input: Controls single bit error injection on input data when
                                     -- ECC enabled (Error injection capability is not available in

   regcea => '1',                   -- 1-bit input: Clock Enable for the last register stage on the output
                                     -- data path.

   rsta => RESET,                   -- 1-bit input: Reset signal for the final port A output register
                                         -- stage. Synchronously resets output port douta to the value specified
                                         -- by parameter READ_RESET_VALUE_A.
   sleep => '0',                   -- 1-bit input: sleep signal to enable the dynamic power saving feature.
   wea => b"0000"                  -- WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                                        -- for port A input data port dina. 1 bit wide when word-wide writes
                                        -- are used. In byte-wide write configurations, each bit controls the
                                        -- writing one byte of dina to address addra. For example, to
                                         -- synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                                         -- is 32, wea would be 4'b0010.
 );
               
end arch;