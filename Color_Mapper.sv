module  color_mapper (input		          Clk, reset, HIGH, LOW, ECHO, PITCH,UP,DOWN,
						    input        [9:0]   DrawX, DrawY,         
							 output logic [7:0]   VGA_R, VGA_G, VGA_B); 


	 logic [9:0] wordxpos, wordypos, wordxsize, wordysize;
	 logic [1439:0] highwordpixel,lowwordpixel,echowordpixel,pitchwordpixel, uppixel, downpixel;
	 logic [7:0]   Red, Green, Blue;
	 logic [2:0]	Color;
	 logic highwordwrite, lowwordwrite, echowordwrite, pitchwordwrite, upwrite, downwrite ;
	 

	 
	 
	 Words highs(			.high(1'b1), 
										   .low(1'b0), 
											.echo(1'b0), 
											.pitch(1'b0),
											.pixel_map(highwordpixel)
											);
	 Words LOWs( 			.high(1'b0), 
										   .low(1'b1), 
											.echo(1'b0), 
											.pitch(1'b0), 
											.pixel_map(lowwordpixel)
											);		
	Words ECHOs( 			.high(1'b0), 
										   .low(1'b0), 
											.echo(1'b1), 
											.pitch(1'b0), 
											.pixel_map(echowordpixel)
											);
	Words PITCHs( 			.high(1'b0), 
										   .low(1'b0), 
											.echo(1'b0), 
											.pitch(1'b1), 
											.pixel_map(pitchwordpixel)
											);
	uparrowgenerator up(
											.UP,
											.pixel_map(uppixel)
											);
	downarrowgenerator down(
											.DOWN,
											.pixel_map(downpixel)
											);
										
	 ColorGenerator c1(.Colorcode(Color), 
							.outputColor({Red, Green, Blue})
							);
	 

    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
    
    always_comb
    begin : writeword
		upwrite = 1'b0;
		downwrite = 1'b0;
		highwordwrite = 1'b0; 
		lowwordwrite = 1'b0;
		echowordwrite = 1'b0;
		pitchwordwrite = 1'b0;
		if (DrawX >= 20 && DrawX <= 20 + 120 && DrawY >= 240 && DrawY <= 240 + 12)
			highwordwrite = 1'b1;
		else if (DrawX >= 170 && DrawX <= 170 + 120 && DrawY >= 240 && DrawY <= 240 + 12)
			lowwordwrite = 1'b1;
		else if(DrawX >= 320 && DrawX <= 320 + 120 && DrawY >= 240 && DrawY <= 240 + 12)
			echowordwrite = 1'b1;
		else if(DrawX >= 470 && DrawX <= 470 + 120 && DrawY >= 240 && DrawY <= 240 + 12)
			pitchwordwrite = 1'b1;
		else if(DrawX >= 460 && DrawX <= 460 + 120 && DrawY >= 210 && DrawY <= 210 + 12)
			upwrite = 1'b1;
		else if(DrawX >= 460 && DrawX <= 460 + 120 && DrawY >= 270 && DrawY <= 270 +12)
			downwrite = 1'b1;
		else
		begin
			upwrite = 1'b0;
			downwrite = 1'b0;
			highwordwrite = 1'b0; 
			lowwordwrite = 1'b0;
			echowordwrite = 1'b0;
			pitchwordwrite = 1'b0;
		end

    end
    

    always_comb
    begin : WRITECOLOR
				if(highwordwrite)
				begin
					if (highwordpixel[(12 - (DrawY-240))*120 + (120 - (DrawX-20))])
					begin
						if(HIGH)
							Color = 3'b010;
						else
							Color = 3'b111;
					end
					else
						Color = 3'b000;
				end
				
				else if(lowwordwrite)
				begin
					if (lowwordpixel[(12 - (DrawY-240))*120 + (120 - (DrawX-170))])
					begin
						if(LOW)
							Color = 3'b010;
						else
							Color = 3'b111;
					end
					else
						Color = 3'b000;
				end
				
				else if(echowordwrite)
				begin
					if (echowordpixel[(12 - (DrawY-240))*120 + (120 - (DrawX-320))])
					begin
						if(ECHO)
							Color = 3'b010;
						else 
							Color = 3'b111;
					end
					else
						Color = 3'b000;
				end
				
				else if(pitchwordwrite)
				begin
					if (pitchwordpixel[(12 - (DrawY-240))*120 + (120 - (DrawX-470))])
					begin
						if (PITCH)
							Color = 3'b010;
						else 
							Color = 3'b111;
					end
					else
						Color = 3'b000;
				end
				
				else if(upwrite)
				begin
					if( uppixel [(12-(DrawY-210))*120 + (120-(DrawX-460))])
					begin
						if (UP)
							Color = 3'b010;
						else
							Color = 3'b111;
					end
					else
						Color = 3'b000;
				end
				
				else if(downwrite)
				begin
					if(downpixel[(12-(DrawY-270))*120 + (120-(DrawX-460))])
					begin
						if (DOWN)
							Color = 3'b010;
						else
							Color = 3'b111;
					end
					else
						Color = 3'b000;
				end
				
				else Color = 3'b000;
    end 
    
endmodule
