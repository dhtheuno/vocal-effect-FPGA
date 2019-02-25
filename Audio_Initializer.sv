module Audio_Initializer(
									input Clk,
									input reset,
									
									output I2C_SCLK,
									inout I2C_SDAT
								);
								
logic [15:0] c_I2C_CLK_DIV;
logic [23:0] c_I2C_DATA;
logic c_I2C_CLK;
logic c_I2C_GO;
logic c_I2C_END;
logic c_I2C_ACK;


logic [2:0] index;
logic [3:0] setup;
logic [15:0] DATA;

always_ff@(posedge Clk or posedge reset)
begin
	if(reset)
		begin
			c_I2C_CLK <= 0;
			c_I2C_CLK_DIV <=0;
		end
	else 
		begin
			if(c_I2C_CLK_DIV < (50000000/20000))
				c_I2C_CLK_DIV <= c_I2C_CLK_DIV+1;
			else
				begin
					c_I2C_CLK_DIV <= 0;
					c_I2C_CLK <= ~c_I2C_CLK;
				end
		end
end

i2c I2C_1(
				.CLOCK(c_I2C_CLK),
				.I2C_SCLK(I2C_SCLK),
				.I2C_SDAT(I2C_SDAT),
				.I2C_DATA(c_I2C_DATA),
				.GO(c_I2C_GO),
				.END(c_I2C_END),
				.ACK(c_I2C_ACK),
				.RESET(!reset)
			);


always_ff@(posedge c_I2C_CLK or posedge reset)
begin
	if(reset)
	begin
		index <=0;
		setup <=0;
		c_I2C_GO <=0;
	end 
	else 
	begin
		if(index < 10)
			begin
				case(setup)
				0: 
					begin
						c_I2C_DATA <={8'h34,DATA};
						c_I2C_GO<=1;
						setup <=1;
					end
				1:
					begin
						if(c_I2C_END)
							begin
								if(!c_I2C_ACK)
									setup <=2;
								else
									setup<=0;
									c_I2C_GO <=0;
							end
					end
				2:
					begin
						index <= index+1;
						setup<=0;
					end
				endcase
			end
		end
end

always_ff
begin
	case(index)
	0: DATA <= {7'h2, 9'd119};
	1: DATA <= {7'h3, 9'd119};
	2: DATA <= {7'h4,9'd20};
	3: DATA <= {7'h5,9'd6};
	4: DATA <= {7'h6,9'h000};
	5: DATA <= {7'h7,9'd77};
	6: DATA <= {7'h8,9'd0};
	7: DATA <= {7'h9,9'h001};
	endcase
end

endmodule
	

