library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MEMORY_GAME is
    Port (
        clock       : in std_logic;
        reset       : in std_logic;
        switches    : in std_logic_vector(7 downto 0);
        button      : in std_logic;
        seven_seg   : out std_logic_vector(6 downto 0);
        display_val : out std_logic_vector(15 downto 0);
        game_over   : out std_logic
    );
end MEMORY_GAME;

architecture Behavioral of MEMORY_GAME is

    ----------------------constant declaration-------------------------------------
    constant ACTIVE : std_logic := '1';
    constant TOTAL_NUMS : integer := 5;

    --------------------------State machine declaration------------------------------------
    type game_state_type is (
        INIT,
        GEN_RANDOM,
        SHOW_NUM,
        WAIT_INPUT,
        CHECK_INPUT,
        CORRECT,
        INC_SPEED,
        GAME_OVER
    );

    -------------------signal declaration---------------------------
    signal current_state, next_state : game_state_type;
    signal speed_level    : integer range 0 to 15 := 0;
    signal numselect      : integer range 0 to TOTAL_NUMS-1 := 0;
    signal rand0, rand1, rand2, rand3, rand4 : std_logic_vector(3 downto 0);
    signal current_rand   : std_logic_vector(3 downto 0);
    signal mirror_mode    : std_logic := '0';
    signal timerMode      : std_logic_vector(3 downto 0);
    signal nextEn         : std_logic := '0';

    component random_generator is
        Port (
            clock     : in std_logic;
            reset     : in std_logic;
            nextEn    : in std_logic;
            rand0     : out std_logic_vector(3 downto 0);
            rand1     : out std_logic_vector(3 downto 0);
            rand2     : out std_logic_vector(3 downto 0);
            rand3     : out std_logic_vector(3 downto 0);
            rand4     : out std_logic_vector(3 downto 0)
        );
    end component;

    component MirroredSegments is
        Port (
            value     : in std_logic_vector(3 downto 0);
            mode      : in std_logic;
            sevenSeg  : out std_logic_vector(6 downto 0)
        );
    end component;

    component GAME_TIMER is
        Port (
            clock     : in std_logic;
            reset     : in std_logic;
            timerMode : in std_logic_vector(3 downto 0);
            done      : out std_logic
        );
    end component;

    signal timer_done : std_logic;

begin

    game_over <= ACTIVE when current_state = GAME_OVER else '0';

    -- Random number generator instance
    rand_gen_inst : random_generator
    port map (
        clock   => clock,
        reset   => reset,
        nextEn  => nextEn,
        rand0   => rand0,
        rand1   => rand1,
        rand2   => rand2,
        rand3   => rand3,
        rand4   => rand4
    );

    -- Timer instance
    timer_inst : GAME_TIMER
    port map (
        clock     => clock,
        reset     => reset,
        timerMode => timerMode,
        done      => timer_done
    );

    -- Multiplexer to select the current number
    with numselect select
        current_rand <= rand0 when 0,
                        rand1 when 1,
                        rand2 when 2,
                        rand3 when 3,
                        rand4 when others;

    -- Display the selected number (as 16-bit integer on output)
    display_val <= (11 downto 0 => '0') & current_rand;

    -- LED driver (7-segment) instance
    seven_seg_driver : MirroredSegments
    port map (
        value    => current_rand,
        mode     => mirror_mode,
        sevenSeg => seven_seg
    );

    --------------------------------------------------------
    -- State Machine Register
    --------------------------------------------------------
    process(clock, reset)
    begin
        if reset = ACTIVE then
            current_state <= INIT;
            speed_level   <= 0;
            numselect     <= 0;
        elsif rising_edge(clock) then
            current_state <= next_state;

            if current_state = CORRECT then
                if numselect = TOTAL_NUMS - 1 then
                    numselect <= 0;
                    speed_level <= speed_level + 1;
                else
                    numselect <= numselect + 1;
                end if;
            end if;
        end if;
    end process;

    --------------------------------------------------------
    -- State Machine Control
    --------------------------------------------------------
    process(current_state, switches, button, numselect, speed_level, timer_done)
    begin
        next_state <= current_state;
        nextEn     <= '0';
        timerMode  <= std_logic_vector(to_unsigned(speed_level, 4));

        case current_state is
            when INIT =>
                if switches = "00000000" then
                    next_state <= GEN_RANDOM;
                    nextEn <= ACTIVE;
                end if;

            when GEN_RANDOM =>
                next_state <= SHOW_NUM;

            when SHOW_NUM =>
                if timer_done = ACTIVE then
                    next_state <= WAIT_INPUT;
                end if;

            when WAIT_INPUT =>
                if button = ACTIVE then
                    next_state <= CHECK_INPUT;
                end if;

            when CHECK_INPUT =>
                if switches(3 downto 0) = current_rand then
                    next_state <= CORRECT;
                else
                    next_state <= GAME_OVER;
                end if;

            when CORRECT =>
                if numselect = TOTAL_NUMS - 1 then
                    if speed_level < 15 then
                        next_state <= INC_SPEED;
                    else
                        next_state <= GAME_OVER;
                    end if;
                else
                    next_state <= SHOW_NUM;
                end if;

            when INC_SPEED =>
                next_state <= GEN_RANDOM;
                nextEn <= ACTIVE;

            when GAME_OVER =>
                next_state <= GAME_OVER;

            when others =>
                next_state <= INIT;
        end case;
    end process;

end Behavioral;
