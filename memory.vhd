library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity MAIN_MEM is
	port
	(
			data_bus_in	: in bit_vector(15 downto 0);
			data_bus_out : out bit_vector(15 downto 0);
			addr_bus	: in bit_vector (19 downto 0);
			write_en	: in bit ;
			clk		    : in std_logic;
			BHE         : in bit
				
	);
	
end entity;

architecture mem_arc of MAIN_MEM is
	component	single_port_ram 
	
		port (
			
		data	: in bit_vector(7 downto 0);
		addr	: in natural range 0 to 1000;
		we		: in bit := '1';
		clk		: in std_logic;
		q		: out bit_vector(7 downto 0)
			
		);
	end component;
	
	------------------------signal--------------------
	
	signal chip_select_I0,chip_select_I1 : bit ;
	signal addres : natural range 0 to 1000; 
	signal data_reg,data_reg_out,data : bit_vector(15 downto 0);
	
	------------------------rtl-----------------------------
	begin
	chip_select_I0<=   write_en;-- and (not BHE);
	chip_select_I1<=   write_en;-- and BHE;
        I0	:	single_port_ram					-- lsb

			port map(
						
				clk	=> clk,
				addr 	=> addres,
				data	=> data_reg(7 downto 0),
				we    => chip_select_I0 ,
				q     => data_reg_out(7 downto 0)
				
			);
		
		I1	:	single_port_ram					-- msb
		
			port map(
		
				clk  	=> clk,
				addr 	=> addres,
				data 	=> data_reg(15 downto 8),
				we    => chip_select_I1,
				q     => data_reg_out(15 downto 8)
				
			);

		process(clk)
			begin
				if(falling_edge(clk)) then
					if(write_en = '1') then
					data_reg <= data;
					end if;
					
					-- Register the address for reading
					addres <= conv_integer(to_stdlogicvector(addr_bus(10 downto 0)));
				end if;
			
			end process;
			
		data_bus_out <= data_reg_out;
			
			process(clk)
			  begin
			       if(BHE='1')then
						data(15 downto 8) <= data_bus_in(7 downto 0);
						else
						data(7 downto 0) <= data_bus_in(7 downto 0);
						end if;
			  end process;
			
		end mem_arc;			
					
