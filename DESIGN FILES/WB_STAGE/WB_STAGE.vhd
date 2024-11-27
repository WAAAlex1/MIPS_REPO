library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;

-- THIS STAGE DOES THE FOLLOWING:
    -- 0. CORRECT (SHIFT) THE MEMORY DATA IF NECESSARY
    -- 1. SIGN EXTEND THE MEMORY DATA IF NECESSARY
    -- 2. MUX THE MEM_DATA AND REG_DATA
    -- 3. PROPAGATE THE REG_IDX TO THE ID STAGE.
    -- 4. PROPAGATE REG_WRITE CONTROL SIGNAL TO ID STAGE. 

entity WB_STAGE is
    port(
        RESET   : in STD_LOGIC;
        REG_IDX : in STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);
        REG_DATA: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        MEM_DATA: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        WB_CTRL : in WB_CTRL_REG;
        MEM_CTRL: in MEM_CTRL_REG;
        byte_idx: in STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        REG_DATA_O: out STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        REG_IDX_O : out STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);
        REG_W_CTRL: out STD_LOGIC
    );
end WB_STAGE;


architecture WB_ARCH of WB_STAGE is

-- NO NEED TO DECLARE COMPONENTS / NONE USED.

-- DEFINE SIGNALS:

    signal DATA_CORRECTED: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal SIGN_EXTENDED_DATA: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal UNSIGNED_DATA: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal SIGN_EXTEND_CTRL: STD_LOGIC;
    
    signal data_shift0_O: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift8_O: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift16_O: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift24_O: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal MEM_DATA_CORRECTED: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal MEM_DATA_CORRECTED_Helper: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
begin
    
    -- STEP 1. CORRECT THE MEMORY OUTPUT (SHIFT IT RIGHT)
    
    -- SIGNALS FOR CORRECTING DATA READ OUTPUT
    data_shift0_O  <= MEM_DATA;
    data_shift8_O  <= L8b&MEM_DATA(31 DOWNTO 8);
    data_shift16_O <= L16b&MEM_DATA(31 DOWNTO 16);
    data_shift24_O <= L8b&L16b&MEM_DATA(31 DOWNTO 24);
    -- Selecting the corrected MEM DATA OUTPUT:
    with byte_idx select MEM_DATA_CORRECTED_Helper <=
                        data_shift0_O when "00",
                        data_shift8_O when "01",
                        data_shift16_O when "10",
                        data_shift24_O when others;
    
    MEM_DATA_CORRECTED <= MEM_DATA_CORRECTED_helper when MEM_CTRL.W_R_CTRL = "00" else MEM_DATA;
                      

    -- STEP 2: SIGN EXTEND THE MEMORY OUTPUT ( IF NEEDED ) 

    UNSIGNED_DATA <= L16b&L8b&MEM_DATA_CORRECTED(7 DOWNTO 0);

    SIGN_EXTEND_CTRL <= MEM_DATA_CORRECTED(7);
    with SIGN_EXTEND_CTRL select 
         SIGN_EXTENDED_DATA <= H8b&H16b&MEM_DATA_CORRECTED(7 DOWNTO 0) when '1',
                               L8b&L16b&MEM_DATA_CORRECTED(7 DOWNTO 0) when others;
    
    with WB_CTRL.MemToReg select 
         DATA_CORRECTED <= UNSIGNED_DATA      when "01",
                           SIGN_EXTENDED_DATA when "10",
                           MEM_DATA_CORRECTED when "11",
                           REG_DATA           when others;     
    
    -- RESET SHOULD BE PRIORITIZED ON OUTPUT
    with RESET select
            REG_DATA_O <= DATA_CORRECTED when '0',
                          L32b when others;  
    with RESET select
            REG_IDX_O <= REG_IDX when '0',
                         "00000" when others;
    with RESET select
            REG_W_CTRL <= WB_CTRL.RegWrite when '0',
                          '0' when others;
                          
end WB_ARCH;

    