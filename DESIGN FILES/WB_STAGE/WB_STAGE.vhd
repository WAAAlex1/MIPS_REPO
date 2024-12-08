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
        MEM_WB_CTRL: in MEM_WB_CTRL_REG;
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
    
    signal data_shift0_U: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift8_U: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift16_U: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift24_U: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    
    signal data_shift0_S: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift8_S: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift16_S: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift24_S: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    
    signal data_shift0_S_HW: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift16_S_HW: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift0_U_HW: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    signal data_shift16_U_HW: STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
    
    signal W_R_CTRL: STD_LOGIC_VECTOR(3 DOWNTO 0);
    
begin

    W_R_CTRL <= MEM_WB_CTRL.W_R_CTRL;
    
    -- STEP 1. CORRECT THE MEMORY OUTPUT (SHIFT IT RIGHT)
    
    -- SIGNED AND UNSIGNED VERSIONS OF READING A BYTE AT ANY INDEX:
    data_shift0_U  <= L8b&L16b&MEM_DATA(7 DOWNTO 0);
    data_shift8_U  <= L8b&L16b&MEM_DATA(15 DOWNTO 8);
    data_shift16_U <= L8b&L16b&MEM_DATA(23 DOWNTO 16);
    data_shift24_U <= L8b&L16b&MEM_DATA(31 DOWNTO 24);
   
    data_shift0_S  <= L8b&L16b&MEM_DATA(7 DOWNTO 0) when MEM_DATA(7) = '0' else
                      H8b&H16b&MEM_DATA(7 DOWNTO 0);
    data_shift8_S  <= L8b&L16b&MEM_DATA(15 DOWNTO 8) when MEM_DATA(15) = '0' else
                      H8b&H16b&MEM_DATA(15 DOWNTO 8);
    data_shift16_S <= L8b&L16b&MEM_DATA(23 DOWNTO 16) when MEM_DATA(23) = '0' else
                      H8b&H16b&MEM_DATA(23 DOWNTO 16);
    data_shift24_S <= L8b&L16b&MEM_DATA(31 DOWNTO 24) when MEM_DATA(31) = '0' else
                      H8b&H16b&MEM_DATA(31 DOWNTO 24);
    
    -- SIGNED AND UNSIGNED VERSIONS OF READING A HALFWORD AT INDEX 0 OR 16
    data_shift0_S_HW  <= L16b&MEM_DATA(15 DOWNTO 0) when MEM_DATA(15) = '0' else
                         H16b&MEM_DATA(15 DOWNTO 0);
    data_shift16_S_HW <= L16b&MEM_DATA(31 DOWNTO 16) when MEM_DATA(31) = '0' else
                         H16b&MEM_DATA(31 DOWNTO 16);
    data_shift0_U_HW  <= L16b&MEM_DATA(15 DOWNTO 0);
    data_shift16_U_HW <= L16b&MEM_DATA(31 DOWNTO 16);
    
    -- GENERATE CORRECT OUTPUT FROM CONTROL SIGNALS AND GENERATED DATA SIGNALS
    DATA_CORRECTED <=
           -- LOADING A BYTE
           data_shift0_S  when BYTE_IDX = "00" AND W_R_CTRL = "1000" else
           data_shift8_S  when BYTE_IDX = "01" AND W_R_CTRL = "1000" else
           data_shift16_S when BYTE_IDX = "10" AND W_R_CTRL = "1000" else
           data_shift24_S when BYTE_IDX = "11" AND W_R_CTRL = "1000" else
           data_shift0_U  when BYTE_IDX = "00" AND W_R_CTRL = "1001" else
           data_shift8_U  when BYTE_IDX = "01" AND W_R_CTRL = "1001" else
           data_shift16_U when BYTE_IDX = "10" AND W_R_CTRL = "1001" else
           data_shift24_U when BYTE_IDX = "11" AND W_R_CTRL = "1001" else
           -- LOADING A HALFWORD
           data_shift0_S_HW   when BYTE_IDX = "00" AND W_R_CTRL = "1010" else
           data_shift16_S_HW  when BYTE_IDX = "10" AND W_R_CTRL = "1010" else
           data_shift0_U_HW   when BYTE_IDX = "00" AND W_R_CTRL = "1011" else
           data_shift16_U_HW  when BYTE_IDX = "10" AND W_R_CTRL = "1011" else
           -- LOADING A WORD
           MEM_DATA when W_R_CTRL = "1100" else
           -- WHEN NOT LOADING MAKE REG_DATA AVAILABLE
           REG_DATA;              
    
    -- RESET SHOULD BE PRIORITIZED ON OUTPUT
    -- TECHNICALLY ASYNCHRONOUS
    with RESET select
            REG_DATA_O <= DATA_CORRECTED when '0',
                          L32b when others;  
    with RESET select
            REG_IDX_O <= REG_IDX when '0',
                         "00000" when others;
    with RESET select
            REG_W_CTRL <= MEM_WB_CTRL.RegWrite when '0',
                          '0' when others;
                          
end WB_ARCH;

    