library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity timer_scaffed is
		port( 
		    rst          : in bit; 
			clk          : in std_logic; -- clock
			scanner_data : in bit; -- scanner data 
			--en           : in bit; -- enable line
			DACK         : in bit; -- acknowlage from dma
			DREQ         : out bit; -- request from dma
			counter_data : out bit_vector(1 downto 0)); -- counter output
		end timer_scaffed;

architecture timers_arch of timer_scaffed is

signal counter: integer := 0;
signal capture_DOWN,reset_count_DOWN : bit  := '0';
signal capture_UP,reset_count_UP : bit  := '1';
signal capture : bit_vector(1 downto 0);
 
begin

-----------------------------------
	process (clk, rst,reset_count_UP,reset_count_DOWN)
		begin
		if (rst='1')then
		counter <= 0;
		elsif(reset_count_UP'event or reset_count_DOWN'event)then
		counter <= 0;
		elsif rising_edge(clk) then
			counter <= counter + 1;
		end if;
    end process;
-----------------------------------
	 process (scanner_data)
			begin
			if (scanner_data='1')then
			capture_UP <= '1';
			capture_DOWN <= '0';
			else
			capture_UP <= '0';
			capture_DOWN <= '1';
			end if;
			reset_count_UP <= not reset_count_UP;
			reset_count_DOWN <= not reset_count_DOWN;
	end process;
------------------------------------------------------------
	process(capture_DOWN,capture_UP,DACK)
	  begin
	if (capture_UP'event )then 
		if (counter=4 )then
			DREQ <= '1';
			capture <= "01";
			elsif(counter=8 )then
			DREQ <= '1';
			capture <= "11";
			end if;
		elsif( capture_DOWN'event)then
			if (counter=4 )then
			DREQ <= '1';
			capture <= "01";
			elsif(counter=8 )then
			DREQ <= '1';
			capture <= "11";
		end if;
	end if;
	    --if(en='1')then
		
	    if (DACK'event and DACK='1') then
		counter_data <= capture;
		DREQ <= '0' after 10 ns;
		end if;
	
	end process;

end timers_arch; 



