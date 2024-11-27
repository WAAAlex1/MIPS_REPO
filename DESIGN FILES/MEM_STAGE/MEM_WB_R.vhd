library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records.all;
use work.constants_pkg.all;

entity MEM_WB_R is
    port(
        CLK          : in STD_LOGIC;
        RESET        : in STD_LOGIC;
        
        REG_DATA_MEM : in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
        REG_IDX_MEM	 : in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
        WB_CTRL_MEM  : in WB_CTRL_REG;
        MEM_CTRL_MEM : in MEM_CTRL_REG;
        byte_idx_MEM : in STD_LOGIC_VECTOR(1 DOWNTO 0);		
        
        REG_DATA_WB  : out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
        REG_IDX_WB	 : out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
        WB_CTRL_WB   : out WB_CTRL_REG;
        MEM_CTRL_WB	 : out MEM_CTRL_REG;
        byte_idx_WB  : out STD_LOGIC_VECTOR(1 DOWNTO 0)		
    );
end MEM_WB_R;   
    
architecture MEM_WB_R_ARCH of MEM_WB_R is
begin
    process(CLK,RESET)
	  begin
		if RESET = '1' then 	
			REG_DATA_WB	    <= L32b;
			REG_IDX_WB		<= "00000";
			WB_CTRL_WB	    <= ('0',"00");		
			MEM_CTRL_WB.W_R_CTRL <= "00";
			byte_idx_WB     <= "00";
		elsif rising_edge(clk) then
			REG_DATA_WB	    <= REG_DATA_MEM;
			REG_IDX_WB		<= REG_IDX_MEM;
			WB_CTRL_WB	    <= WB_CTRL_MEM;
			MEM_CTRL_WB     <= MEM_CTRL_MEM;
			byte_idx_WB     <= byte_idx_MEM;
		end if;
	  end process; 

end MEM_WB_R_ARCH;     
