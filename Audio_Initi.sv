module Audio_Initializer(
									input Clk,
									input reset,
									inout I2C_SDAT,
									output I2C_SCLK
									);
									
parameter I2C_ADDR = 7'b0011010;
logic [6:0] Codec_Regi [0:5];
logic [8:0] Codec_Data [0:5];

logic [3:0] Curr_State;
logic [2:0] Initi_State;

logic I2C_Start;
initial I2C_Start = 1'b0;

logic [6:0] I2C_REGISTER;
logic [8:0] I2C_DATA;
logic I2C_FINISH;

i2c i2c_1(
				.clk(Clk),
				.rst(I2C_Start),
				.address(I2C_ADDR),
				.register(I2C_REGISTER),
				.data(I2C_DATA),
				.rw(1'b0),
				.SDAT(I2C_SDAT),
				.SDCLK(I2C_SCLK),
				.done(I2C_FINISH)
				);

always_ff @ (posedge Clk or negedge reset)
begin
	if(!reset)
		begin
			Initi_State<= 0;
		end 
	else
		begin
			case(Initi_State)
				3'd0:
					begin
						Codec_Regi[0] <= 7'b0000110;
						Codec_Data[0] <=9'b000010000;
						
						Codec_Regi[1] <= 7'b0000111;
						Codec_Data[1] <= 9'b001010011;
						
						Codec_Regi[2] <= 7'b0000100;
						Codec_Data[2] <= 9'b000010100;
						
						Codec_Regi[3] <= 7'b0000101;
						Codec_Data[3] <= 9'b000000000;
						
						Codec_Regi[4] <= 7'b0001001;
						Codec_Data[4] <= 9'b000000001;
						
						Codec_Regi[5] <= 7'b0000110;
						Codec_Data[5] <= 9'b000000000;
						
						
						Initi_State <= Initi_State + 1'b1;
			
					end	
				3'd1:
					begin
						I2C_Start <=1;
						I2C_REGISTER <= Codec_Regi[Curr_State];
						I2C_DATA <= Codec_Data[Curr_State];
						
						Initi_State <= Initi_State + 1'b1;
					end 
				3'd2:
					begin
						if(I2C_FINISH)
							begin
								Initi_State <= Initi_State+1'b1;
							end
						else 
							begin
							end
					end
				3'd3:
					begin
					I2C_Start <= 1'b0;
					if(Curr_State<5)
						begin
							Curr_State <= Curr_State +1'b1;
							Initi_State <=3'd1;
						end
					else
						begin
							Initi_State = 3'd4;
						end
					end
				3'd4:
					begin
						I2C_Start <=1'b0;
					end
				default:
					begin
					end
		endcase
	end
end

endmodule
			
					