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
		W_R_CTRL  : in  STD_LOGIC_VECTOR(1 DOWNTO 0);
		ADDR      : in  std_logic_vector(INST_SIZE-1 DOWNTO 0);
		DATA      : in  std_logic_vector(INST_SIZE-1 DOWNTO 0);
		DATA_O    : out std_logic_vector(INST_SIZE-1 DOWNTO 0)
	);
end MEMORY_BANK;

architecture arch of MEMORY_BANK is

    -- STRUCTURE:
    -- Memory is 32 bit cells.
        -- BOTH READ AND WRITE:
            -- We need to right shift addr by 2 to access the actual address.
            -- MIPS Memory is byte-addressable. Need to be able to store and load from any given byte.
        
        -- READ:
        -- If reading a BYTE:
           -- Save the two lower bit -> these dictate which byte of the word we are interested in
           -- If 00 -> simply mask result with OR 00_00_00_FF
           -- If 01 -> Shift result left by 8.  Then OR-mask with 00_00_00_FF
           -- If 10 -> Shift result left by 16. Then OR-mask with 00_00_00_FF
           -- If 11 -> Shift result left by 24. Then Or-mask with 00_00_00_FF
           -- WB STAGE: Determine whether necessary to sign-extend.  
          
        -- If reading a WORD:
           -- No special case needed. 
    
        -- WRITE:
        -- If writing a byte:
           -- Save the two lower bit -> These dictate how much we should shift the data before storing.
           -- If 00 -> No Shifting needed.  Set WE to 0001.
           -- If 01 -> Shift left by 8.     Set WE to 0010.
           -- If 10 -> Shift left by 16.    Set WE to 0100.
           -- If 11 -> Shift left by 24.    Set WE to 1000.
        -- If writing a WORD:
           -- No changes needed. Set WE to 1111.    
           
           
        -- TO ACCOMPLISH THE ABOVE WE NEED THE FOLLOWING CONTROL SIGNALS:
           -- WRITE/READ-CONTROL -> 2 BIT SIGNAL:
            -- 00 -> NOT WRITING, READING BYTE.
            -- 01 -> WRITING BYTE
            -- 10 -> WRITING WORD
            -- 11 -> NOT WRITING, READING WORD. 
            
    signal byte_index:  STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal corrected_addr: STD_LOGIC_VECTOR(10 DOWNTO 0); -- WORD ADDR IS 11 BIT
    signal WRITE_ENABLE: STD_LOGIC_VECTOR(3 DOWNTO 0);
    -- 0000 FOR READING
    -- 0001 FOR WRITING TO BYTE 0
    -- 0010 FOR WRITING TO BYTE 1
    -- 0100 FOR WRITING TO BYTE 2
    -- 1000 FOR WRITING TO BYTE 3
    -- 1111 FOR WRITING A WHOLE WORD. 
    
    signal data_shift0: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift8: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
	signal data_shift16: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
	signal data_shift24: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
	
	signal corrected_data_w: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
	
	signal mem_data_O: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
	signal data_shift0_O: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift8_O: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
	signal data_shift16_O: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
	signal data_shift24_O: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
	signal corrected_data_O: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
	
begin

    -- SIGNALS FOR CORRECTING ADDRESS
    byte_index <= ADDR(1 DOWNTO 0);     
    corrected_addr <= ADDR(12 DOWNTO 2); -- WORD ADDR is 11 bit // BYTE ADDR IS 13 BIT.
    
    
    -- SIGNALS FOR CORRECTING DATA WRITE INPUT
    data_shift0  <= DATA;
    data_shift8  <= DATA(23 DOWNTO 0)&L8b;
    data_shift16 <= DATA(15 DOWNTO 0)&L16b;
    data_shift24 <= DATA(7 DOWNTO 0)&L16b&L8b;
    -- Process for selecting the corrected DATA INPUT.
    process(DATA, W_R_CTRL, byte_index)
    begin
        if (W_R_CTRL = "01") then -- WRITE BYTE
           CASE byte_index is
                when "00" => 
                   corrected_data_w <= data_shift0;
                   WRITE_ENABLE <= "0001";
                when "01" => 
                   corrected_data_w <= data_shift8;
                   WRITE_ENABLE <= "0010";
                when "10" => 
                   corrected_data_w <= data_shift16;
                   WRITE_ENABLE <= "0100";
                when "11" => 
                   corrected_data_w <= data_shift24;
                   WRITE_ENABLE <= "1000"; 
                when others => 
                   corrected_data_w <= DATA;
                   WRITE_ENABLE <= "0001";
            end CASE;   
        elsif (W_R_CTRL = "00") then -- READ BYTE
            corrected_data_w <= DATA;
            WRITE_ENABLE <= "0000";
        elsif (W_R_CTRL = "10") then -- WRITE WORD
            corrected_data_w <= DATA;
            WRITE_ENABLE <= "1111";
        else                         -- READ WORD
            corrected_data_w <= DATA;
            WRITE_ENABLE <= "0000";
        end if;
    end process;
    
    -- SIGNALS FOR CORRECTING DATA READ OUTPUT
    data_shift0_O  <= mem_data_O;
    data_shift8_O  <= L8b&mem_data_O(31 DOWNTO 8);
    data_shift16_O <= L16b&mem_data_O(31 DOWNTO 16);
    data_shift24_O <= L8b&L16b&mem_data_O(31 DOWNTO 24);
    -- Process for selecting the corrected DATA OUTPUT.
    process(mem_data_O, W_R_CTRL, byte_index)
    begin
        if (W_R_CTRL = "00") then -- READ BYTE
           CASE byte_index is
                when "00" => 
                   corrected_data_O <= data_shift0_O;
                when "01" => 
                   corrected_data_O <= data_shift8_O;
                when "10" => 
                   corrected_data_O <= data_shift16_O;
                when "11" => 
                   corrected_data_O <= data_shift24_O;
                when others => 
                   corrected_data_O <= mem_data_O;
            end CASE;   
        elsif (W_R_CTRL = "01") then -- WRITE BYTE
            corrected_data_O <= mem_data_O;
        elsif (W_R_CTRL = "10") then -- WRITE WORD
            corrected_data_O <= mem_data_O;
        else                         -- READ WORD
            corrected_data_O <= mem_data_O;
        end if;
    end process;
    -- FINAL OUTPUT ASSIGNMENT
    DATA_O <= corrected_data_O;
    
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
   dina => corrected_data_w,       -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
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



  	
end arch;	

