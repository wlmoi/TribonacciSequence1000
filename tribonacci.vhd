library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tribonacci is
    Port (
        clk    : in  std_logic;                -- Clock signal
        reset  : in  std_logic;                -- Reset signal
        N      : in  unsigned(9 downto 0);     -- Input: Number of Tribonacci terms (0 to 1024)
        T_out  : out unsigned(725 downto 0)    -- Output: Last Tribonacci value (726 bits)
    );
end tribonacci;

architecture Behavioral of tribonacci is
    -- Define states for the state machine
    type state_type is (RESET_STATE, INIT_STATE, CALC_STATE, DONE_STATE);
    signal current_state, next_state : state_type;

    -- Internal signals
    signal T0, T1, T2, T_next : unsigned(725 downto 0); -- Registers for Tribonacci values
    signal i                  : unsigned(9 downto 0);   -- Counter for iterations (0 to 1024)
    signal calc_done          : std_logic;             -- Signal to indicate calculation completion
begin
    -- State transition process
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= RESET_STATE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- State behavior process
    process(current_state, i, N)
        variable i_var : unsigned(9 downto 0) := to_unsigned(3, 10); -- Counter variable
    begin
        -- Default transitions and outputs
        next_state <= current_state;
        calc_done <= '0';

        case current_state is
            -- RESET_STATE: Initialize all registers and signals
            when RESET_STATE =>
                T0 <= (others => '0'); -- Tribonacci[0] = 0
                T1 <= (others => '0'); T1(0) <= '1'; -- Tribonacci[1] = 1
                T2 <= (others => '0'); T2(0) <= '1'; -- Tribonacci[2] = 1
                T_next <= (others => '0');
                i <= to_unsigned(3, i'length); -- Start counter at 3
                T_out <= (others => '0');
                next_state <= INIT_STATE;

            -- INIT_STATE: Prepare initial values
            when INIT_STATE =>
                if N = 0 then
                    T_out <= T0; -- If N = 0, output T0
                    next_state <= DONE_STATE;
                elsif N = 1 then
                    T_out <= T1; -- If N = 1, output T1
                    next_state <= DONE_STATE;
                elsif N = 2 then
                    T_out <= T2; -- If N = 2, output T2
                    next_state <= DONE_STATE;
                else
                    next_state <= CALC_STATE; -- Otherwise, proceed to calculation
                end if;

            -- CALC_STATE: Perform iterative calculation
            when CALC_STATE =>
                if i > N then
                 next_state <= DONE_STATE; -- End calculation when i >= N
                else 
                    -- Compute next Tribonacci value
                    T_next <= T0 + T1 + T2;

                    -- Shift registers for next iteration
                    T0 <= T1;
                    T1 <= T2;
                    T2 <= T_next;

                    -- Output the current Tribonacci value
                    T_out <= T_next;
                    
                
                    -- Update counter
                    i_var := i_var + 1;
                    i <= i_var; -- Synchronize variable to signal             

                end if;

            -- DONE_STATE: Calculation complete, hold the result
            when DONE_STATE =>
                calc_done <= '1'; -- Indicate that calculation is complete

            when others =>
                next_state <= RESET_STATE; -- Default to RESET_STATE
        end case;
    end process;

end Behavioral;
