module LPF(input Clk,
				input reset,
				input AUD_BCLK,
				input AUD_DACLRCK,
				input AUD_ADCLRCK,
				input [31:0] datain,
				output logic [31:0] dataout
				);

logic [31:0] firstin;
logic [31:0] firstout;

wire signed [31:0]leftAudio = {{16{datain[31]}}, datain[31:16]};
wire signed [31:0]leftfirstout = {{16{firstout[31]}}, firstout[31:16]};


wire signed [31:0]rightAudio = {{16{datain[15]}}, datain[15:0]};
wire signed [31:0]rightfirstout = {{16{firstout[15]}}, firstout[15:0]};

logic signed [31:0]leftresult;
logic signed [31:0]rightresult;

logic signed[15:0]templeft;
logic signed[15:0]tempright;

always_comb
begin
	leftresult = ($signed(leftAudio) / $signed(32'd10)) + ((($signed(leftfirstout)) / $signed(32'd10)) * $signed(32'd9));
	rightresult = ($signed(rightAudio) / $signed(32'd10)) + ((($signed(rightfirstout)) / $signed(32'd10)) * $signed(32'd9));
	dataout[31:16] = leftresult[15:0];
	dataout[15:0] = rightresult[15:0];
end

always_ff @ (posedge AUD_BCLK or negedge reset)
begin
	if(reset == 0)
	begin
		firstout <= 0;
	end
	else
	begin
		if(AUD_DACLRCK == 1)
		begin
			firstout <= dataout;
		end
	end
end

endmodule