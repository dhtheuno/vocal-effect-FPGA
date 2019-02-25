module ColorGenerator(input        [3:0]  Colorcode,
						  output logic [23:0] outputColor);
		
		always_comb
		begin
			unique case (Colorcode)
				3'b000: outputColor = 24'hffffff; //white
				3'b001: outputColor = 24'h9F9FFD;
				3'b010: outputColor = 24'hff0000; //Red
				3'b011: outputColor = 24'hffffff;
				3'b100: outputColor = 24'hffffff; //White
				3'b101: outputColor = 24'haaaaaa;//Gray
				3'b110: outputColor = 24'h555555;//Dark Gray
				default: outputColor = 24'h000000; //Black	
			endcase
		end
		
endmodule
