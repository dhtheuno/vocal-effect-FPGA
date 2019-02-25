module Audio_input_ADC(
								input Clk,
								input reset,
								inout AUD_BCLK,
								inout AUD_ADCLRCK,
								input AUD_ADCDAT,
								
								output logic Reci_Done,
								output logic [31:0] Reci_Data
								);

initial Reci_Data = 32'd0;
logic [4:0] Bits_Count = 5'd31;
logic [31:0] buffer; 
enum logic [3:0] {A,B,C,D,E} curr_state, next_state;
always_ff @(posedge AUD_BCLK or negedge reset)
begin
	if(!reset)
		begin
			curr_state <= A;
			Bits_Count <= 5'd31;
		end
	else
		begin
			curr_state <= next_state;
		case(curr_state)
			C:
				begin
					Bits_Count <= Bits_Count - 5'd1;
					buffer[Bits_Count] <= AUD_ADCDAT;
				end
			D:
				begin
					Bits_Count <=5'd31;
					Reci_Data <= buffer;
				end
		endcase 
		end 
end 
always_comb
begin 
	Reci_Done =  1'b0;
	
	unique case(curr_state)
		A:
			begin
				next_state = B;
			end
		B:
			begin
				next_state = B;
				if(AUD_ADCLRCK == 1)
					next_state = C;
			end 
		C:
			begin
				next_state = C;
				if(Bits_Count == 0)
					next_state = D;
			end
		D:
			begin
				Reci_Done = 1'd1;
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
endmodule
			
			
			