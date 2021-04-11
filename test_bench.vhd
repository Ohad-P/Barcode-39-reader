----------------------------
--testbench
--------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;


ENTITY test_bench is
	signal clk,read_bus : std_logic := '0';
	signal input,rst  : bit := '1';
	signal EOP,DACK,DREQ,WriteOrReadNot : bit := '0';
	signal HOLD_req,HOLD_ack,BHE,ALE: bit := '0';
	signal 	ADDRES_bus,ADDRES_bus_MEM,ADDRES_bus_DMA:  bit_vector(19 downto 0):=x"00000";
	signal 	DATA_bus,DATA_out:  bit_vector(15 downto 0):=x"0000";
    


end test_bench;

architecture test_rtl of test_bench is
---------------------------files parameter------------------------------------------
signal gen : boolean := true;
signal done : boolean := false;
constant input_file : string(1 to 47) := "C:\Users\OhadP\Desktop\final_dcs\input_file.txt";
constant output_file : string(1 to 48) := "C:\Users\OhadP\Desktop\final_dcs\output_file.txt";
------------------------------------------------------------------------------------

-- components declerations
			
	  component timer_scaffed 
	
		port( 
		    rst          : in bit; --reset
			clk          : in std_logic; -- clock
			scanner_data : in bit ; -- scanner data 
			--en           : in bit; -- enable line
			DACK         : in bit; -- acknowlage from dma
			DREQ         : out bit; -- request from dma
			counter_data : out bit_vector(1 downto 0)); -- counter output
		
	end component;
	
	component MAIN_MEM 
		port
		(
			data_bus_in	: in bit_vector(15 downto 0);
			data_bus_out : out bit_vector(15 downto 0);
			addr_bus	: in bit_vector (19 downto 0);
			write_en	: in bit ;
			clk		    : in std_logic;
			BHE         : in bit);
			
	end component;
	
	
	component DMA_Controller 
				generic (
					end_addr : integer  --num of byte we save (109=0x6D)
				);
		port( 
		        rst : in bit;
				clk : in std_logic; -- clock
				DREQ : in bit;
				HLDA : in bit;
				--en : in std_logic; -- enable line

				DACK : out bit; -- acknowlage from dma
				HOLD : out bit;
				Addr : out bit_vector(19 downto 0); -- counter output
				BHE : out bit; --
				MEM_W : out bit;
				EOP : out bit			);

	end component;
	
	
	----------------------------------------------------------------------------------------arch_start-------------------------------------
	begin
	
	  clk   <= not(clk) after 25 ns;  -- 50 ns / 2
      gen   <= not(gen) after 100 ns;  -- 200 ns / 2
	  
	  --en <= ADDRES_bus_MEM(17) ;

    
	
		I0	:	timer_scaffed 

			port map (
						
				rst => rst,          
				clk => clk,       
				scanner_data => input,
				--en => en ,          
				DACK  =>   DACK,    
				DREQ  =>  DREQ,  
				counter_data => DATA_bus(1 downto 0) 
			);	
			
		I1	:	DMA_Controller

				generic map(
		              end_addr =>   54  --num of byte we save (109=0x6D)
	                )
		    port map( 
		        rst => rst,
				clk => clk,
				DREQ => DREQ,
				HLDA => HOLD_ack,
				--en : in std_logic; -- enable line

				DACK => DACK,
				HOLD => HOLD_req,
				Addr => ADDRES_bus_DMA,
		
				BHE => BHE,
				MEM_W => WriteOrReadNot ,
				EOP => EOP
				);
     
        I2  :  MAIN_MEM 
			port map(
				data_bus_in   => DATA_bus,
				data_bus_out => DATA_out,
				addr_bus   => ADDRES_bus_MEM,
				write_en   => WriteOrReadNot,
				clk		   => clk,
				BHE        => BHE
						
				);	 
			-- rtl code
-------------cpu--------------
	  process(HOLD_req)
	    begin
	      
	      HOLD_ack<= HOLD_req after 10 ns;

	  end process;
	  
    process(clk)
      begin
      ALE  <= not ALE;  --  ns / 2
	 end process;
	 
	 process(clk,read_bus)
	 begin
	 if (read_bus='0')then	
	ADDRES_bus_MEM <= ADDRES_bus_DMA;
	else
	ADDRES_bus_MEM <= ADDRES_bus;
	  end if;
     end process;
	-----------------------------------  
	process
	  file infile : text open read_mode is input_file;
	  file outfile : text open write_mode is output_file;
	  variable L : line;
	  variable good : boolean;
	  variable input_vector : bit_vector(1 to 256):= x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
	  variable letter : bit_vector (15 downto 0):=x"0000";
	  variable index   : integer;
	  --variable valu    : bit :='0';
	  variable address :integer :=0;
	  constant star : string(1 to 1) := "*";
	  constant err  :string (1 to 5) := "error";
	  begin
	  
	
	  while not endfile(infile) loop
	  readline(infile,L);
	  read(L,input_vector(1 to L'length),good);
	  next when not good;
	    for i in 1 to input_vector'length loop
	     
	    wait until (gen'event and gen= false);
	       read_bus<='0';
	       rst <= '0';--chip_selcet
	       input <= input_vector(i);

		end loop;
	  end loop;
		
			  

     file_close(infile);
     report "end of input file" severity note;
      
   IF (EOP = '1') THEN
    read_bus<='1';
	address := 0; 
	FOR j IN 0 TO 10 LOOP ---11 caracter
		index := 0;
		FOR i IN 1 TO 5 LOOP ---9 byte for caracter + 1 byte seperat
			ADDRES_bus <= to_bitvector(conv_std_logic_vector(address, 20));
			WAIT UNTIL (gen'EVENT AND gen = true);
 
			address := address + 1;
 
			IF (index < 12) THEN
				IF (DATA_out(1 DOWNTO 0) = "01") THEN
					index := index + 1;
					letter(12 - index) := '0';
					REPORT " : " & INTEGER'image(0);
 
				ELSIF (DATA_out(1 DOWNTO 0) = "11") THEN
					IF (index < 11) THEN
						index := index + 1;
						letter(12 - index) := '0';
						REPORT " : " & INTEGER'image(0);
 
						index := index + 1;
						letter(12 - index) := '0';
						REPORT " : " & INTEGER'image(0);
					END IF;
				END IF;
 
             if(index<12)then
				IF (DATA_out(9 DOWNTO 8) = "01") THEN
					index := index + 1;
					letter(12 - index) := '1';
					REPORT " : " & INTEGER'image(1);
				ELSIF (DATA_out(9 DOWNTO 8) = "11") THEN
					IF (index < 11) THEN
						index := index + 1;
						letter(12 - index) := '1';
						REPORT " : " & INTEGER'image(1);
 
						index := index + 1;
						letter(12 - index) := '1';
						REPORT " : " & INTEGER'image(1);
					END IF;
				END IF;
			END IF;
          end if;
 
		END LOOP;
 
		CASE letter IS
 
			WHEN x"0692" => write(L, star);
			WHEN x"0592" => write(L, 0, left, 1);
			WHEN x"02D4" => write(L, 1, left, 1);
			WHEN x"04D4" => write(L, 2, left, 1);
			WHEN x"026A" => write(L, 3, left, 1);
			WHEN x"0594" => write(L, 4, left, 1);
			WHEN x"02CA" => write(L, 5, left, 1);
			WHEN x"04CA" => write(L, 6, left, 1);
			WHEN x"05A4" => write(L, 7, left, 1);
			WHEN x"02D2" => write(L, 8, left, 1);
			WHEN x"04D2" => write(L, 9, left, 1);
			WHEN OTHERS => write(L, err);--for debuging
 
		END CASE;
 
	END LOOP;
	writeline(outfile, L); 
	done <= true;
	file_close(outfile);
	REPORT "END OF output FILE" SEVERITY note;

END IF;
     wait;
         		
  end process;
  
   
end test_rtl;