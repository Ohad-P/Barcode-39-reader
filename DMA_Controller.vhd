library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity DMA_Controller is
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
			
				BHE : out bit; --?? mabye not use it
				MEM_W : out bit;
				EOP : out bit
				);
end DMA_Controller;



architecture DMA_Arch of DMA_Controller is

signal adress_out : std_logic_vector(19 downto 0) := x"00000";
signal BHEin : bit :='1';

begin
  BHE <= BHEin;
	process (DREQ,HLDA,rst)
	  begin
	  if(rst='1')then
	      EOP <= '0';
		  MEM_W <= '0';
		  DACK <= '0';
		  HOLD <= '0';
		  adress_out<= x"00000";
		elsif (DREQ'event and DREQ ='1') then
			HOLD <='1';
		elsif(DREQ='0')then
			MEM_W <= '0' after 100 ns;
		    DACK <= '0';
		end if;
		if (HLDA'event and HLDA='1') then
		  if( adress_out = end_addr )then
		  EOP <= '1';
		  MEM_W <= '0';
		  DACK <= '0';
		  HOLD <= '0';
		  
		  else
		   
		   BHEin<= not(BHEin); 
		   EOP <= '0';
		   addr<=to_bitvector(adress_out) after 100 ns;
		   DACK <= '1';
		   if(BHEin='0')then
		   adress_out <= adress_out + '1';
		   MEM_W <= '1';
		   end if;
		   HOLD <= '0';
		   
		end if;
		end if;
		
	end process;

	end DMA_Arch;