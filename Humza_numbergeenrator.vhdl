library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity lfsr_random_gen is
   Generic: 
    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC;
          button: in STD_LOGIC;
           random_num0 : out STD_LOGIC_VECTOR(7 downto 0));
           random_num1 : out STD_LOGIC_VECTOR(7 downto 0));
           random_num2 : out STD_LOGIC_VECTOR(7 downto 0));
          
          
end lfsr_random;

architecture random_gen_ARCH  of lfsr_random is
    signal lfsr_reg : STD_LOGIC_VECTOR(7 downto 0) := "10101010"; -- Seed
begin
    process(clock, reset)
    begin
        if rst = '1' then
            lfsr_reg <= "10101010"; -- Reset to initial seed
        elsif rising_edge(clk) then
            lfsr_reg <= lfsr_reg(6 downto 0) & (lfsr_reg(7) xor lfsr_reg(5));
        end if;
    end process;
  SHIFT_REG process (clock, reset)
begin 
  if (reset = ACTIVE) then
     dataOUT <= (others => '0');
  elsif (risingedge(clock)) then
    
    rnd <= lfsr_reg-ARCH;
end Behavioral;

  

    
