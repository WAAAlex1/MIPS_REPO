library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;

-- THIS STAGE DOES THE FOLLOWING:

    -- 1. SIGN EXTEND THE MEMORY DATA IF NECESSARY
    -- 2. MUX THE MEM_DATA AND REG_DATA
    -- 3. PROPAGATE THE REG_IDX TO THE ID STAGE.
    -- 4. PROPAGATE REG_WRITE CONTROL SIGNAL TO ID STAGE. 


entity WB_STAGE is
    port(
        CLK     : in STD_LOGIC;
        RESET   : in STD_LOGIC;
        REG_IDX : in STD_LOGIC_VECTOR(ADDR_SIZE-1 DOWNTO 0);
        REG_DATA: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        MEM_DATA: in STD_LOGIC_VECTOR(INST_SIZE-1 DOWNTO 0);
        WB_CTRL : in WB_CTRL_REG;
        
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

begin

    SIGN_EXTEND_CTRL <= MEM_DATA(7);
    
    with SIGN_EXTEND_CTRL select 
         SIGN_EXTENDED_DATA <= H8b&H16b&MEM_DATA(7 DOWNTO 0) when '1',
                               L8b&L16b&MEM_DATA(7 DOWNTO 0) when others;
    
    UNSIGNED_DATA <= MEM_DATA;
    
    with WB_CTRL.MemToReg select 
         DATA_CORRECTED <= SIGN_EXTENDED_DATA when "10",
                           UNSIGNED_DATA      when "01",
                           REG_DATA           when others;     
                
    
    REG_DATA_O <= DATA_CORRECTED;
    REG_IDX_O <= REG_IDX;
end WB_ARCH;

    