module HPF(
            input Clk,
            input reset,
            input [31:0] data_in,
            output logic [31:0] data_out,
            
            input AUD_DACLRCK,
            input AUD_BCLK      
            );
            
   
logic [31:0] delay_in;
logic [31:0] delay_out;
initial delay_out = 32'd0;

wire [15:0] left_in = data_in[31:16];
wire [15:0] left_delay_in = delay_in[31:16];
wire [15:0] left_delay_out = delay_out[31:16];

logic signed [15:0] left_final;

wire [15:0] right_in = data_in[15:0];
wire [15:0] right_delay_in = delay_in[15:0];
wire [15:0] right_delay_out = delay_out[15:0];

logic signed [15:0] right_final;



   
always_comb
begin
   left_final = ($signed(left_delay_out)/$signed(16'd4)*$signed(16'd3)) +(($signed(data_in[31:16]) - $signed(left_delay_in))/$signed(16'd4)*$signed(16'd3));

   right_final = ($signed(right_delay_out)/$signed(16'd4)*$signed(16'd3)) +(($signed(data_in[15:0]) - $signed(right_delay_in))/$signed(16'd4)*$signed(16'd3));
   
   data_out = {left_final, right_final};
end

always_ff @ (posedge AUD_BCLK or negedge reset)
begin
   if(!reset)
      begin
         delay_out<= 0;
      end
   else
      begin
      if(AUD_DACLRCK)
         begin
         delay_out <=data_out;
         delay_in <= data_in;

         
         end
      end
end

endmodule

