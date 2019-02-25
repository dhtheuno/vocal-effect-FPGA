module echo (
					input [31:0]data_input,
					input Clk,
					input AUD_ADCLRCK,
					input reset,
					output [31:0]data_output
					
					);
					
logic [31:0] delay; 
logic [31:0] delayloop;
logic [15:0] left_audio;
logic [15:0] right_audio;
initial delay = 32'b0000;

assign delayloop = data_output; 
assign left_audio = $signed(delay[31:16])/$signed(16'd2);
assign right_audio = $signed(delay[15:0])/$signed(16'd2);

shift regi1 (
	.clock(AUD_ADCLRCK),
	.shiftin(delayloop),
	.shiftout(delay)
				);
				
always @ (posedge AUD_ADCLRCK or negedge reset)
begin 
		data_output = {left_audio,right_audio}+data_input;
end

endmodule
	