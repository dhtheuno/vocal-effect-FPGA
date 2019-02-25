module Audio_Top(
						input Clk,
						input reset,
						
						input AUD_ADCDAT,
						output AUD_DACDAT,
						input AUD_ADCLRCK,
						input AUD_DACLRCK,
						
						output AUD_XCK,
						input AUD_BCLK,
						
						inout I2C_SDAT,
						output I2C_SDCLK
						
						
						
						);

logic Audio_Clk;
logic reset_source_reset;

Audio_Clock Aucio_Clock1(
								.audio_clk_clk(Audio_Clk),
								.ref_clk_clk(Clk),
								.ref_reset_reset(reset),
								.reset_source_reset(reset_source_reset)
								);

Audio_Initializer AI1(
							.Clk(Clk),
							.reset(~reset),
							.I2C_SCLK(I2C_SCLK),
							.I2C_SDAT(I2C_SDAT)
							);

logic ADC_DONE;
logic DAC_DONE;

logic [31:0] curr_ADC_DATA;
logic [31:0] curr_DAC_DATA;

logic AUD_DACDATOUT;

Audio_Output_DAC DAC1(
							 .Clk(Clk),
							 .reset(reset),
							 .AUD_BCLK(AUD_BCLK),
							 .ADU_DACLRCK(AUD_DACLRCK),
							 .data(curr_DAC_DATA),
							 .Send_Done(DAC_DONE),
							 .AUD_DACDAT(AUD_DACDATOUT);
								);
assign AUD_DACDATOUT = 1'b1;

Audio_input_ADC ADC1(
							.Clk,
							.reset(reset),
							.AUD_BCLK(AUD_BCLK),
							.AUD_ADCLRCK(AUD_ADCLRCK),
							.AUD_ADCDAT(AUD_ADCDAT),
							
							.Reci_Done(ADC_DONE);
							.Reci_Data(curr_ADC_DATA)
							); 

assign Curr_DAC_DATA = Curr_ADC_DATA;

