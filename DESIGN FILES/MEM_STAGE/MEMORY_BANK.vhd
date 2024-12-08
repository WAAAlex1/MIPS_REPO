library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;

Library xpm;
use xpm.vcomponents.all;

-- NOTE:
-- SIGN EXTENSION OF LOADED VALUES IS NOT DONE HERE.
-- DO SIGN EXTENSION IN WB STAGE.

entity MEMORY_BANK is
	port(
	    RESET     : in  std_logic;
		CLK       : in  std_logic;
		W_R_CTRL  : in  STD_LOGIC_VECTOR(3 DOWNTO 0);
		ADDR      : in  std_logic_vector(INST_SIZE-1 DOWNTO 0);
		DATA      : in  std_logic_vector(INST_SIZE-1 DOWNTO 0);
		DATA_O    : out std_logic_vector(INST_SIZE-1 DOWNTO 0)
	);
end MEMORY_BANK;

architecture arch of MEMORY_BANK is
       
    signal byte_index:  STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal corrected_addr: STD_LOGIC_VECTOR(10 DOWNTO 0); -- WORD ADDR IS 11 BIT
    signal WRITE_ENABLE: STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    -- 0000 FOR READING
    -- 0001 FOR WRITING TO BYTE 0
    -- 0010 FOR WRITING TO BYTE 1
    -- 0100 FOR WRITING TO BYTE 2
    -- 1000 FOR WRITING TO BYTE 3
    -- 0011 FOR WRITING TO LOWER HALF WORD
    -- 1100 FOR WRITING TO UPPER HALF WORD
    -- 1111 FOR WRITING A WHOLE WORD. 
    
    signal data_shift0: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift8: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
	signal data_shift16: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
	signal data_shift24: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
	
	signal corrected_data_to_mem: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    
	signal mem_data_O: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
		
begin

    -- SIGNALS FOR CORRECTING ADDRESS
    byte_index <= ADDR(1 DOWNTO 0);     
    corrected_addr <= ADDR(12 DOWNTO 2); -- WORD ADDR is 11 bit 
    
    
    -- SIGNALS FOR CORRECTING DATA WRITE INPUT
    data_shift0  <= DATA;
    data_shift8  <= DATA(23 DOWNTO 0)&L8b;
    data_shift16 <= DATA(15 DOWNTO 0)&L16b;
    data_shift24 <= DATA(7 DOWNTO 0)&L16b&L8b;
    -- Process for selecting the corrected DATA INPUT.
    
    WRITE_ENABLE <=
           "0001" when BYTE_INDEX = "00" AND W_R_CTRL = "1101" else
           "0010" when BYTE_INDEX = "01" AND W_R_CTRL = "1101" else
           "0100" when BYTE_INDEX = "10" AND W_R_CTRL = "1101" else
           "1000" when BYTE_INDEX = "11" AND W_R_CTRL = "1101" else
           "0011" when BYTE_INDEX = "00" AND W_R_CTRL = "1110" else
           "1100" when BYTE_INDEX = "10" AND W_R_CTRL = "1110" else
           "1111" when W_R_CTRL = "1111" else
           "0000";        
        
    corrected_data_to_mem <=
           data_shift0 when BYTE_INDEX = "00" AND W_R_CTRL =  "1101" else
           data_shift8 when BYTE_INDEX = "01" AND W_R_CTRL =  "1101" else
           data_shift16 when BYTE_INDEX = "10" AND W_R_CTRL = "1101" else
           data_shift24 when BYTE_INDEX = "11" AND W_R_CTRL = "1101" else
           data_shift0 when BYTE_INDEX = "00" AND W_R_CTRL =  "1110" else
           data_shift16 when BYTE_INDEX = "10" AND W_R_CTRL = "1110" else
           data_shift0;
        
-- xpm_memory_spram: Single Port RAM
-- Xilinx Parameterized Macro, version 2024.2
xpm_memory_spram_inst : xpm_memory_spram
generic map (
   ADDR_WIDTH_A => 11,             -- DECIMAL
   AUTO_SLEEP_TIME => 0,           -- DECIMAL
   BYTE_WRITE_WIDTH_A => 8,        -- DECIMAL
   CASCADE_HEIGHT => 0,            -- DECIMAL
   ECC_BIT_RANGE => "7:0",         -- String
   ECC_MODE => "no_ecc",           -- String
   ECC_TYPE => "none",             -- String
   IGNORE_INIT_SYNTH => 0,         -- DECIMAL
   MEMORY_INIT_FILE => "none",     -- String
   MEMORY_INIT_PARAM => "0",       -- String
   MEMORY_OPTIMIZATION => "true",  -- String
   MEMORY_PRIMITIVE => "auto",     -- String
   MEMORY_SIZE => 65536,           -- DECIMAL
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
   dbiterra => open,               -- 1-bit output: Status signal to indicate double bit error occurrence
                                     -- on the data output of port A.

   douta => mem_data_O,            -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
   sbiterra => open,                -- 1-bit output: Status signal to indicate single bit error occurrence
                                     -- on the data output of port A.

   addra => corrected_addr,        -- ADDR_WIDTH_A-bit input: Address for port A write and read operations.
   clka => CLK,                     -- 1-bit input: Clock signal for port A.
   dina => corrected_data_to_mem,       -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
   ena => '1',                       -- 1-bit input: Memory enable signal for port A. Must be high on clock
                                     -- cycles when read or write operations are initiated. Pipelined
                                     -- internally.

   injectdbiterra => '0',           -- 1-bit input: Controls double bit error injection on input data when
                                     -- ECC enabled (Error injection capability is not available in
                                     -- "decode_only" mode).

   injectsbiterra => '0',           -- 1-bit input: Controls single bit error injection on input data when
                                     -- ECC enabled (Error injection capability is not available in
                                     -- "decode_only" mode).

   regcea => '1',                   -- 1-bit input: Clock Enable for the last register stage on the output
                                     -- data path.

   rsta => RESET,                   -- 1-bit input: Reset signal for the final port A output register
                                     -- stage. Synchronously resets output port douta to the value specified
                                     -- by parameter READ_RESET_VALUE_A.

   sleep => '0',                   -- 1-bit input: sleep signal to enable the dynamic power saving feature.
   wea => WRITE_ENABLE               -- WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                                     -- for port A input data port dina. 1 bit wide when word-wide writes
                                     -- are used. In byte-wide write configurations, each bit controls the
                                     -- writing one byte of dina to address addra. For example, to
                                     -- synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                                     -- is 32, wea would be 4'b0010.

);

-- FINAL OUTPUT ASSIGNMENT
    DATA_O <= mem_data_o;

  	
end arch;	

