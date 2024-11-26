-- WRITING AND READING SHOULD NEVER BE POSSIBLE IN THE SAME CYCLE.
    
    -- ALLIGN CHECK TO GET AROUND OVERFLOW ERRORS
    corrected_addr <= ADDR(ADDR'High DOWNTO 2)&"00";
    ADDR_INT <= TO_INTEGER(UNSIGNED(corrected_addr));
 
    -- WRITE PROCESS
    process(RESET, CLK, WE, ADDR, DATA)
    begin
        -- SYNCHRONOUS RESET
        if rising_edge(clk) then
            if RESET = '1' then
                for i in BLOCKSIZE-1 DOWNTO 0 loop
                    MEM_BANK(i) <= (others=>'0');
                end loop;
            elsif WE = b"11" then -- THIS IS FOR WRITING A WHOLE WORD            
                MEM_BANK(ADDR_INT+3) <= DATA(31 DOWNTO 24);
                MEM_BANK(ADDR_INT+2) <= DATA(23 DOWNTO 16);
                MEM_BANK(ADDR_INT+1) <= DATA(15 DOWNTO 8);
                MEM_BANK(ADDR_INT+0) <= DATA(7  DOWNTO 0);
            elsif WE = b"10" then -- THIS IS FOR WRITING A HALF WORD
                MEM_BANK(ADDR_INT+1) <= DATA(15 DOWNTO 8);
                MEM_BANK(ADDR_INT+0) <= DATA(7  DOWNTO 0);
            elsif WE = b"01" then -- THIS IS FOR WRITING A BYTE 
                MEM_BANK(ADDR_INT+0) <= DATA(7  DOWNTO 0);
            else                    -- IF WRITESTATE NOT KNOWN OR IF WRITE NOT ENABLED
                null;
            end if; 
        end if;
    end process;    
              

    -- READ PROCESS
    process(RESET, CLK, RE, ADDR)
    begin
        -- SYNCHRONOUS RESET
        if rising_edge(clk) then
            if RESET = '1' then
               DATA_O <= L32b;
            elsif RE = b"11" then -- THIS IS FOR READING A WHOLE WORD            
               DATA_O <= MEM_BANK(ADDR_INT+3)&MEM_BANK(ADDR_INT+2)&MEM_BANK(ADDR_INT+1)&MEM_BANK(ADDR_INT);
            elsif RE = b"10" then -- THIS IS FOR READING A HALF WORD
               DATA_O <= L16b&MEM_BANK(ADDR_INT+1)&MEM_BANK(ADDR_INT); 
            elsif RE = b"01" then -- THIS IS FOR READING A BYTE 
               DATA_O <= L16b&L8b&MEM_BANK(ADDR_INT); 
            else                  -- IF READSTATE NOT KNOWN OR IF WRITE NOT ENABLED
               DATA_O <= L32b;
            end if;
        end if;
    end process;  