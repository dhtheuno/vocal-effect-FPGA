module pitch_down(
				input logic Clk,
				input logic reset,
				input logic signed [31:0] data_in,
				output logic signed [31:0] data_out			
				);
				
logic [7:0] counter = 8'd255;
logic signed [31:0] pitch_in;
logic signed [31:0] pitch_out;
logic [7:0] write_addr = 0;
logic [7:0] read_addr =1;
logic [2:0] counter_1 = 1'd1;
				
pitch_down_ram ram1(
	.clock(Clk),
	.data(pitch_in),
	.rdaddress(read_addr),
	.wraddress(write_addr),
	.wren(1'b1),
	.q(pitch_out)
					);
					
always_ff @ (posedge Clk) 
begin
	if(!reset)
		begin
			data_out <= data_in;
			write_addr <= 0;
			read_addr <= 1;
			pitch_in <= data_in;
		end
	else
		begin
			pitch_in <= data_in;
			if(write_addr == counter)
				write_addr <= 8'd0;
			else 
				write_addr <= write_addr+ 8'd1;
			
			if(read_addr == counter)
				read_addr <= 8'd0;
			
			else
				begin
				if(counter_1 == 1'd0)
					begin
					read_addr <= read_addr + 8'd1;
					counter_1 <= 1'd1;
					end
				else
					counter_1 <= counter_1 - 1'd1;
					
				end
			
			data_out <= pitch_out;
		end
end



endmodule
