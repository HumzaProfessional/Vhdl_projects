library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MovingLED_TB is
end MovingLED_TB;

architecture Behavioral of MovingLED_TB is

    -- Component declaration for MovingLED design.
    component MovingLED
        port(
            shiftLeft     : in  std_logic;
            shiftRight    : in  std_logic;
            reset         : in  std_logic;
            clock         : in  std_logic;
            ledDisplay    : out std_logic_vector(15 downto 0);
            segDisplayHex : out std_logic_vector(6 downto 0);
            segDisplayOnes: out std_logic_vector(6 downto 0);
            segDisplayTens: out std_logic_vector(6 downto 0)
        );
    end component;

    -- Signal declarations for the testbench.
    signal shiftLeft     : std_logic := '0';
    signal shiftRight    : std_logic := '0';
    signal reset         : std_logic := '0';
    signal clock         : std_logic := '0';
    signal ledDisplay    : std_logic_vector(15 downto 0);
    signal segDisplayHex : std_logic_vector(6 downto 0);
    signal segDisplayOnes: std_logic_vector(6 downto 0);
    signal segDisplayTens: std_logic_vector(6 downto 0);

   constant ACTIVE : std_logic := '1';

begin

    -- Clock generation process.
   SYSTEM_CLOCK: process
  begin
    clock <= not ACTIVE;
    wait <= 5 ns;
    clock <= ACTIVE;
    wait <= 5 ns;
end process;

SYSTEM_RESET process
begon
    reset <= ACTIVE;
    wait for 100ns;
    reset <= not ACTIVE;
    wait;
end process;

    -- Instantiate the Unit Under Test (UUT).
    UUT: MovingLED
        port map(
            shiftLeft     => shiftLeft,
            shiftRight    => shiftRight,
            reset         => reset,
            clock         => clock,
            ledDisplay    => ledDisplay,
            segDisplayHex => segDisplayHex,
            segDisplayOnes=> segDisplayOnes,
            segDisplayTens=> segDisplayTens
        );

    -- process using for loops to emulate LED shifting.
    SIGNAL_DRIVER: process
        variable i: integer;
    begin
        -- Reset at intilzation 
        reset <= ACTIVE;
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- Assume the LED starts at the far right (or at a defined position after reset).

        -- Shift left back across the 16 LEDs.
        for i in 0 to 15 loop
            shiftLeft <= '1';     -- simulate left button press
            wait for 10 ns;
            shiftLeft <= '0';
            wait for 10 ns;
        end loop;

     wait for 20 ns;  -- pause between directions
                
        -- Shift right across the 16 LEDs.
        for i in 0 to 15 loop
            shiftRight <= '1';    -- simulate right button press
            wait for 10 ns;
            shiftRight <= '0'; 
            wait for 10 ns;
        end loop;

        

        wait;  -- suspend process forever
    end process;

end Behavioral;

