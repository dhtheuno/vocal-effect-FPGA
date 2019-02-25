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
						output I2C_SCLK,
						output [15:0]LEDR,
						//things from lab8
						//input CLOCK_50,
						//input logic [18:0] SW,
						input [18:0] SW,
						output logic [6:0] HEX0, HEX1,
						output logic [7:0] VGA_R,
												VGA_G,        //VGA Green
												VGA_B,        //VGA Blue
						output logic      VGA_CLK,      //VGA Clock
												VGA_SYNC_N,   //VGA Sync signal
												VGA_BLANK_N,  //VGA Blank signal
												VGA_VS,       //VGA virtical sync signal
												VGA_HS,		  //VGA horizontal sync signal
				// CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input             	OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
						);


logic reset_source_reset;
logic audio_clk;
Audio_Clock1 Aucio_Clock1(
								.audio_clk_clk(audio_clk),
								.ref_clk_clk(Clk),
								.ref_reset_reset(reset),
								.reset_source_reset(reset_source_reset)
								);

logic HIGH, LOW, ECHO, PITCH, UP, DOWN;
logic Reset_h, Clk_new;
logic [7:0] keycode;
logic [9:0] DrawX, DrawY;
assign Clk_new = Clk;
always_ff @ (posedge Clk_new) begin
		Reset_h <= ~(reset);
end

logic [1:0] hpi_addr;
logic [15:0] hpi_data_in, hpi_data_out;
logic hpi_r, hpi_w, hpi_cs, hpi_reset;

// Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk_new),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );

     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     nios_system nios_system(
                             .clk_clk(Clk_new),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );

    HexDriver hex_inst_0 (keycode[3:0], HEX0);
    HexDriver hex_inst_1 (keycode[7:4], HEX1);
    
// Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // TODO: Fill in the connections for the rest of the modules 
    VGA_controller vga_controller_instance(.Reset(Reset_h), .*);
    
    color_mapper color_instance(.*);
	 
assign AUD_XCK = audio_clk;

Audio_Initializer AI9(
								.Clk(Clk),
								.reset(reset),
								.I2C_SDAT(I2C_SDAT),
								.I2C_SCLK(I2C_SCLK)
							);




logic ADC_DONE;
logic DAC_DONE;

logic [31:0] curr_ADC_DATA;
logic [31:0] curr_DAC_DATA;
logic [31:0] echo_data;
logic [31:0] pitch_down_data, pitch_up_data;
logic [31:0] high_data, low_data;

Audio_Output_DAC DAC1(
							 .Clk(Clk),
							 .reset(reset),
							 .AUD_BCLK(AUD_BCLK),
							 .AUD_DACLRCK(AUD_DACLRCK),
							 .data(curr_DAC_DATA),
							 .Send_Done(DAC_DONE),
							 .AUD_DACDAT(AUD_DACDAT)
								);


Audio_input_ADC ADC1(
							.Clk(Clk),
							.reset(reset),
							.AUD_BCLK(AUD_BCLK),
							.AUD_ADCLRCK(AUD_ADCLRCK),
							.AUD_ADCDAT(AUD_ADCDAT),
							
							.Reci_Done(ADC_DONE),
							.Reci_Data(curr_ADC_DATA)
							); 

echo echo1 (
				
				.data_input(curr_ADC_DATA),
				.Clk,
				.AUD_ADCLRCK,
				.reset(reset),
				.data_output(echo_data)
				);
						
pitch_up pitch_up1(
				.Clk(AUD_ADCLRCK),
				.reset(reset),
				.data_in(curr_ADC_DATA),
				.data_out(pitch_up_data)		
				);
	
pitch_down pitch_down1(
				.Clk(AUD_ADCLRCK),
				.reset(reset),
				.data_in(curr_ADC_DATA),
				.data_out(pitch_down_data)		
				);		
LPF lowPassFilter(
.Clk,
.reset(reset),
.AUD_BCLK(AUD_BCLK),
.AUD_DACLRCK(AUD_DACLRCK),
.AUD_ADCLRCK(AUD_ADCLRCK),
.datain(curr_ADC_DATA),
.dataout(low_data)
);

HPF highPassFilter(
.Clk,
.reset,
.AUD_BCLK(AUD_BCLK),
.AUD_DACLRCK(AUD_DACLRCK),
.data_in(curr_ADC_DATA),
.data_out(high_data)
);

ledlight ledlight(
			.Clk,
			.reset,
			.curr_DAC_DATA,
			.LEDR
			);

//always_comb
//begin
//	curr_DAC_DATA = echo_data;
//	if(SW[0] == 1'b1)
//	begin
//	curr_DAC_DATA = curr_ADC_DATA;
//	end
//	else
//	begin
//	curr_DAC_DATA = echo_data;
//	end
//end
int a;
always_comb
begin
	HIGH = 1'b0; //0b
	LOW = 1'b0;	//0F
	PITCH = 1'b0; //13, up18 down07
	ECHO = 1'b0; //08
	UP = 1'b0;
	DOWN = 1'b0;
	a = 0;
	curr_DAC_DATA = curr_ADC_DATA;
	
	if(keycode[7:0] == 6'h0b) //hpf press h
		begin
			curr_DAC_DATA = high_data;
			HIGH = 1'b1;
			//LEDR[0] = 1'b1;
		end
	else if(keycode[7:0] == 6'h0F) //lpf press L
		begin
			curr_DAC_DATA = low_data;
			LOW = 1'b1;
		end
	else if(keycode[7:0] == 6'h08) //echo
		begin
			curr_DAC_DATA = curr_ADC_DATA;
			ECHO = 1'b1;
		end
	else if(keycode[7:0] == 6'h18)//pitch up
		begin
			curr_DAC_DATA = pitch_up_data;
			PITCH = 1'b1;
			UP = 1'b1;
		end
	else if(keycode[7:0] == 6'h07) //pitch down
		begin
			curr_DAC_DATA = pitch_down_data;
			PITCH = 1'b1;
			DOWN = 1'b1;
		end
	else
		begin
			curr_DAC_DATA = curr_ADC_DATA;
				HIGH = 1'b0; //0b
				LOW = 1'b0;	//0F
				PITCH = 1'b0; //13, up18 down07
				ECHO = 1'b0; //08
				UP = 1'b0;
				DOWN = 1'b0;
				a = 0;
		end
end
endmodule 

