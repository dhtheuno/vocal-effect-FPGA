module Audio_Output_DAC(
								input Clk,
								input reset,
								inout AUD_BCLK,
								inout AUD_DACLRCK,
								input [31:0]data,
								
								output logic Send_Done,
								output logic AUD_DACDAT
								);
								

logic [4:0] Bits_Count;
logic [31:0] buffer;
 								
enum logic [3:0] {A,B,C,D,E} curr_state, next_state;

always_ff @ (posedge AUD_BCLK or negedge reset)
begin
	if(!reset)begin
		curr_state <= A;
		Bits_Count <= 5'd31;
		end
	else
		begin
			curr_state<=next_state;
			case(curr_state)
				B:
					begin
						if(AUD_DACLRCK == 1)
							buffer <= data;
					end
				C:
					begin
						Bits_Count <= Bits_Count - 5'd1;
					end
				D:
					begin
						Bits_Count <= 5'd31;
					end
			endcase
		end
end
								
always_comb
begin
	Send_Done = 1'b0;
	
	unique case (curr_state)
		A: 
			begin
				next_state = B;
			end
		
		B: 
			begin
				next_state = B;
				if(AUD_DACLRCK == 1)
					next_state = C;
			end 
		C: 
			begin
				next_state = C;	
				if(Bits_Count ==0)
					next_state = D;
			end 
		D: 
			begin
				Send_Done = 1'b1;
				next_state = B;
			end
		E:
			begin
				next_state = E;
			end
		default:
		 begin
			next_state = E;
		end

	endcase
end 
								
always_comb 
begin	
	AUD_DACDAT = buffer[Bits_Count];
end 

endmodule 

	
				
				