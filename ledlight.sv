module ledlight(
						input Clk,
						input reset,
						input [31:0] curr_DAC_DATA,
						output [15:0]LEDR
						);
						
logic signed [15:0] average;
logic signed [31:0] leftaudio;
logic signed [31:0] rightaudio;

always_comb
begin
	leftaudio = {{16{curr_DAC_DATA[31]}}, curr_DAC_DATA[31:16]};
	rightaudio = {{16{curr_DAC_DATA[15]}}, curr_DAC_DATA[15:0]};
	
	average = ((leftaudio + rightaudio) / 32'd2);
	for(int i = 0; i < 16; i++)
	begin
		LEDR[i] = (average > (2048*i) ) ? 1'b1 : 1'b0;
	end
end
endmodule