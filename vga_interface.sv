module vga_interface(
	input wire clk,rst_n,
	//asyn_fifo IO
	input wire empty_fifo,
	input wire[15:0] din,
	output wire clk_vga,
	output reg rd_en,
	//VGA output
	output reg[3:0] vga_out_r,
	output reg[3:0] vga_out_g,
	output reg[3:0] vga_out_b,
	output wire vga_out_vs,vga_out_hs
    );
	 //FSM state declarations
	 localparam delay=0,
					idle=1,
					display=2;
					
	 reg[1:0] state_q,state_d;
	 wire[11:0] pixel_x,pixel_y;
	 //register operations
	 always @(posedge clk_vga,negedge rst_n) begin
		if(!rst_n) begin
			state_q<=delay;
		end
		else begin
			state_q<=state_d;
		end
	 end
	 
	 //FSM next-state logic
	 always @* begin
	 state_d=state_q;
	 rd_en=0;
	 vga_out_r=0;
	 vga_out_g=0;
	 vga_out_b=0;
		case(state_q)
		  delay: if(pixel_x==1 && pixel_y==1) state_d=idle; //delay of one frame(33ms) needed to start up the camera
			idle:  if(pixel_x==1 && pixel_y==0 && !empty_fifo) begin //wait for pixel-data coming from asyn_fifo 
							vga_out_r=din[15:11] >> 1; 
							vga_out_g=din[10:5] >> 2;
							vga_out_b=din[4:0] >> 1;
							rd_en=1;	
							state_d=display;
					end
		display: if(pixel_x>=1 && pixel_x<=640 && pixel_y<480) begin //we will continue to read the asyn_fifo as long as current pixel coordinate is inside the visible screen(640x480) 
						vga_out_r=din[15:11] >> 1; //Shift data to go from RGB 565 to RGB 444 for DE-10's 4 bit color
						vga_out_g=din[10:5] >> 2;
						vga_out_b=din[4:0] >> 1;
						rd_en=1;	
					end
			idle: state_d=delay;
		endcase
	 end
	 	
	// Instantiate the VGA controller module
	vga_controller vga_inst (
		 .pixel_clk(clk_vga),
		 .reset_n(rst_n),
		 .h_sync(vga_out_hs),
		 .v_sync(vga_out_vs),
		 .disp_ena(),
		 .column(pixel_x),
		 .row(pixel_y)
	);
	
	 
	//25MHz clock for vga(620x480 60fps) 
	pll_ip pll_inst2 (.inclk0(clk), .c2(clk_vga));

endmodule
