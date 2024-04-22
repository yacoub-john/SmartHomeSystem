module draw_components(
    input clk,                    // System clock
    input slowClk,                // Slow clock
    input reset,                  // Reset signal
    input [9:0] x,                // X coordinate
    input [9:0] y,                // Y coordinate
    input video_on,               // Video enable signal
    input [6:0] char_addr_h10,   // Character address for tens place of hour
    input [6:0] char_addr_h1,    // Character address for ones place of hour
    input [6:0] char_addr_m10,   // Character address for tens place of minute
    input [6:0] char_addr_m1,    // Character address for ones place of minute
    input [6:0] char_addr_s10,   // Character address for tens place of second
    input [6:0] char_addr_s1,    // Character address for ones place of second
    input [6:0] char_addr_semi,  // Character address for colon or separator
    input [6:0] char_addr_ap,    // Character address for AM/PM indicator
    input [6:0] char_addr_apm,   // Character address for AM/PM letter
    input [6:0] char_addr_mo10,  // Character address for tens place of month
    input [6:0] char_addr_mo1,   // Character address for ones place of month
    input [6:0] char_addr_d10,   // Character address for tens place of day
    input [6:0] char_addr_d1,    // Character address for ones place of day
    input [6:0] char_addr_ce10,  // Character address for tens place of century
    input [6:0] char_addr_ce1,   // Character address for ones place of century
    input [6:0] char_addr_y10,   // Character address for tens place of year
    input [6:0] char_addr_y1,    // Character address for ones place of year
    input [6:0] char_addr_p,     // Character address for punctuation or separator
    input  [12:0] volLight,      // Input voltage for light sensor
    input  [12:0] volSound,      // Input voltage for sound sensor
    input  [12:0] volTemp,       // Input voltage for temperature sensor
    input  [7:0] eTemp,          // Temperature value
    input  [7:0] humidity,       // Humidity value
    input  wire systemOn,        // System power status
    input  wire motionOn,        // Motion sensor status
    input  wire UARTOn,          // UART status
    input  wire accelx,          // Accelerometer x-axis reading
    input  wire x_direction,     // Direction of x-axis acceleration
    input  wire accely,          // Accelerometer y-axis reading
    input  wire y_direction,     // Direction of y-axis acceleration
    output [11:0] rgb_out        // RGB output
);

	// Signals declaration
	wire [6:0] ascii;               // Signal is concatenated with X coordinate to get a value for the ROM address                 
	wire [6:0] a[140:0];            // Each index of this array holds a 7-bit ASCII value
	wire d[140:0];                  // Each index of this array holds a signal that says whether the i-th item in array a above should display
	wire displayContents;           // Control signal to determine whether a character should be displayed on the screen
	wire [9:0] calendar_y, clock_y, light_y, sound_y, motion_y, system_y, uart_y, intruder_y, alert_y;

	// Constants for Y coordinates
	assign clock_y = 10'd416;       // Clock y coordinate
	assign calendar_y = 10'd384;    // Calendar y coordinate
	assign light_y = 10'd128;       // Light y coordinate
	assign motion_y = 10'd64;       // Motion y coordinate
	assign system_y = 10'd00;       // System y coordinate
	assign uart_y = 10'd192;		  // UART y coordinate
	//Alert Y coodrinates
	assign intruder_y = uart_y + 10'd64;  
	assign alert_y = intruder_y + 10'd64;

	// Internal registers for various signals
	reg [6:0] light_1, light_2, light_3;
	reg [6:0] motion_1, motion_2, motion_3;
	reg [6:0] itemp_1, itemp_2, itemp_3;
	reg [6:0] system_1, system_2, system_3;
	reg [6:0] sec_i, sec_n, sec_t, sec_r, sec_u, sec_d, sec_e, sec_a, sec_l, sec_exp, uart_1;
	reg [6:0] tam_t, tam_a, tam_m, tam_p, tam_e, tam_r, tam_l, tam_exp;
	reg [6:0] x_1, x_2, x_3, x_4, x_5, x_6;
	reg [6:0] y_1, y_2, y_3, y_4;
	reg [6:0] hum_1, hum_2;
	reg [6:0] temp_1, temp_2;

	// Data processing logic
	always @* begin
		 // Temperature and humidity conversion
		 temp_1 <= {3'b011, eTemp[3:0]};
		 temp_2 <= {3'b011, eTemp[7:4]};
		 hum_1 <= {3'b011, humidity[3:0]};
		 hum_2 <= {3'b011, humidity[7:4]};
		 
		 // System status display logic
		 if(systemOn) begin
			  system_1 <= 7'h4F; // 'O'
			  system_2 <= 7'h4E; // 'N'
			  system_3 <= 7'h00; // OFF
			  
			  if(motionOn) begin //System on and Motion detected
					motion_1 <= 7'h48; // 'H'
					motion_2 <= 7'h49; // 'I'
					motion_3 <= 7'h00; // OFF
			  end
			  else begin
					motion_1 <= 7'h4F; // 'O'
					motion_2 <= 7'h4E; // 'N'
					motion_3 <= 7'h00; // OFF
			  end
		 end
		 else begin
			  system_1 <= 7'h4F; // 'O'
			  system_2 <= 7'h46; // 'F'
			  system_3 <= 7'h46; // 'F'
			  
			  motion_1 <= 7'h4F; // 'O'
			  motion_2 <= 7'h46; // 'F'
			  motion_3 <= 7'h46; // 'F'
		 end
		 
		 // Light sensor status display logic
		 if (volLight/1000 >= 3) begin
			  light_1 <= 7'h48; // 'H'
			  light_2 <= 7'h49; // 'I'
			  light_3 <= 7'h00; // OFF
		 end
		 else if (volLight/100 - (volLight/1000)*10 >= 4) begin
			  light_1 <= 7'h4F; // 'O'
			  light_2 <= 7'h4E; // 'N'
			  light_3 <= 7'h00; // OFF
		 end 
		 else begin
			  light_1 <= 7'h4F; // 'O'
			  light_2 <= 7'h46; // 'F'
			  light_3 <= 7'h46; // 'F'
		 end
		 
		 // UART status display logic
		 if(switchDisp & motionOn & systemOn) begin
			  uart_1 <= 7'h31; // '1'
		 end
		 else begin
			  uart_1 <= 7'h30; // '0'
		 end
		 
		 // Accelerometer display logic
		 if(accelx) begin
			  if(x_direction) begin // Right
					// Display "RIGHT"
					x_1 <= 7'h52; // 'R'
					x_2 <= 7'h49; // 'I'
					x_3 <= 7'h47; // 'G'
					x_4 <= 7'h48; // 'H'
					x_5 <= 7'h54; // 'T'
					x_6 <= 7'h00; // OFF
			  end
			  else begin // Left
					// Display "LEFT"
					x_1 <= 7'h4C; // 'L'
					x_2 <= 7'h45; // 'E'
					x_3 <= 7'h46; // 'F'
					x_4 <= 7'h54; // 'T'
					x_5 <= 7'h00; // OFF
					x_6 <= 7'h00; // OFF
			  end
		 end
		 else begin // Middle
			  // Display "MIDDLE"
			  x_1 <= 7'h4D; // 'M'
			  x_2 <= 7'h49; // 'I'
			  x_3 <= 7'h44; // 'D'
			  x_4 <= 7'h44; // 'D'
			  x_5 <= 7'h4C; // 'L'
			  x_6 <= 7'h45; // 'E'
		 end

		 // Accelerometer y-axis display logic
		 if(accely) begin
			  if(y_direction) begin // Up
					// Display "UP"
					y_1 <= 7'h55; // 'U'
					y_2 <= 7'h50; // 'P'
					y_3 <= 7'h00; // OFF
					y_4 <= 7'h00; // OFF
			  end
			  else begin // Down
					// Display "DOWN"
					y_1 <= 7'h44; // 'D'
					y_2 <= 7'h4F; // 'O'
					y_3 <= 7'h57; // 'W'
					y_4 <= 7'h4E; // 'N'
			  end
		 end
		 else begin // Flat
			  // Display "FLAT"
			  y_1 <= 7'h46; // 'F'
			  y_2 <= 7'h4C; // 'L'
			  y_3 <= 7'h41; // 'A'
			  y_4 <= 7'h54; // 'T'
		 end
	end

	// Divider logic to switch data to display 
	reg [24:0] div = 25'b0;  // Divider to switch data to display 
	always @(posedge clk)
		 div <= div+1'b1; 

	// Switching logic for displaying data
	reg switchDisp = 1'b0; 
	always @(posedge div[24]) // Switch every 0.67 seconds
		 switchDisp <= ~switchDisp; 

	// Mux for switching data
	always @(switchDisp) begin
		 // Intruder alert display logic
		 if(switchDisp & systemOn & motionOn) begin
			  sec_i <= 7'h49; // 'I'
			  sec_n <= 7'h4E; // 'N'
			  sec_t <= 7'h54; // 'T'
			  sec_r <= 7'h52; // 'R'
			  sec_u <= 7'h55; // 'U'
			  sec_d <= 7'h44; // 'D'
			  sec_e <= 7'h45; // 'E'
			  sec_a <= 7'h41; // 'A'
			  sec_l <= 7'h4C; // 'L'
			  sec_exp <= 7'h21; // '!'
		 end
		 else begin
			  // Reset intruder alert display
			  sec_i <= 7'h00;
			  sec_n <= 7'h00; 
			  sec_t <= 7'h00;
			  sec_r <= 7'h00;
			  sec_u <= 7'h00;
			  sec_d <= 7'h00; 
			  sec_e <= 7'h00;
			  sec_a <= 7'h00;
			  sec_l <= 7'h00;
			  sec_exp <= 7'h00; 	
		 end
		 
		 // Tamper alert display logic
		 if(switchDisp & accelx & accely) begin
			  tam_t <= 7'h54; // 'T'
			  tam_a <= 7'h41; // 'A'
			  tam_m <= 7'h4D; // 'M'
			  tam_p <= 7'h50; // 'P'
			  tam_e <= 7'h45; // 'E'
			  tam_r <= 7'h52; // 'R'
			  tam_l <= 7'h4C; // 'L'
			  tam_exp <= 7'h21; // '!'
		 end
		 else begin
			  // Reset tamper alert display
			  tam_t <= 7'h00;
			  tam_a <= 7'h00; 
			  tam_m <= 7'h00;
			  tam_p <= 7'h00;
			  tam_e <= 7'h00;
			  tam_r <= 7'h00; 
			  tam_l <= 7'h00;
			  tam_exp <= 7'h00;
		 end
	end 

	// Convert temperature to ASCII
	bin_to_hex_ascii(volTemp/100 - (volTemp/1000)*10, itemp_1);
	bin_to_hex_ascii(volTemp/10 - (volTemp/100)*10, itemp_2);
	bin_to_hex_ascii(volTemp - (volTemp/10)*10, itemp_3);		

	//TEXT GENERATION MODULES/////////////////////////////////////////////////////////
	textGeneration c0 (.clk(clk),.reset(reset),.asciiData(a[0]), .ascii_In(char_addr_h10), 
	.x(x),.y(y), .displayContents(d[0]), .x_desired(10'd240), .y_desired(clock_y)); //Desirgb_reg[11:8] X and Y coordinate to display char
																											 
	textGeneration c1 (.clk(clk),.reset(reset),.asciiData(a[1]), .ascii_In(char_addr_h1), 
	.x(x),.y(y), .displayContents(d[1]), .x_desired(10'd256), .y_desired(clock_y));

	textGeneration c2 (.clk(clk),.reset(reset),.asciiData(a[2]), .ascii_In(char_addr_semi),
	.x(x),.y(y), .displayContents(d[2]), .x_desired(10'd272), .y_desired(clock_y));

	textGeneration c3 (.clk(clk),.reset(reset),.asciiData(a[3]), .ascii_In(char_addr_m10),
	.x(x),.y(y), .displayContents(d[3]), .x_desired(10'd288), .y_desired(clock_y));

	textGeneration c4 (.clk(clk),.reset(reset),.asciiData(a[4]), .ascii_In(char_addr_m1), 
	.x(x),.y(y), .displayContents(d[4]), .x_desired(10'd304), .y_desired(clock_y));

	textGeneration c5 (.clk(clk),.reset(reset),.asciiData(a[5]), .ascii_In(char_addr_semi),
	.x(x),.y(y), .displayContents(d[5]), .x_desired(10'd320), .y_desired(clock_y));

	textGeneration c6 (.clk(clk),.reset(reset),.asciiData(a[6]), .ascii_In(char_addr_s10),
	.x(x),.y(y), .displayContents(d[6]), .x_desired(10'd336), .y_desired(clock_y));

	textGeneration c7 (.clk(clk),.reset(reset),.asciiData(a[7]), .ascii_In(char_addr_s1),
	.x(x),.y(y), .displayContents(d[7]), .x_desired(10'd352), .y_desired(clock_y));

	textGeneration c8 (.clk(clk),.reset(reset),.asciiData(a[8]), .ascii_In(char_addr_ap),
	.x(x),.y(y), .displayContents(d[8]), .x_desired(10'd384), .y_desired(clock_y));

	textGeneration c9 (.clk(clk),.reset(reset),.asciiData(a[9]), .ascii_In(char_addr_apm),
	.x(x),.y(y), .displayContents(d[9]), .x_desired(10'd400), .y_desired(clock_y));

	//Calendar
	textGeneration c10 (.clk(clk),.reset(reset),.asciiData(a[10]), .ascii_In(char_addr_d10),
	.x(x),.y(y), .displayContents(d[10]), .x_desired(10'd240), .y_desired(calendar_y));

	textGeneration c11 (.clk(clk),.reset(reset),.asciiData(a[11]), .ascii_In(char_addr_d1),
	.x(x),.y(y), .displayContents(d[11]), .x_desired(10'd256), .y_desired(calendar_y));

	textGeneration c12 (.clk(clk),.reset(reset),.asciiData(a[12]), .ascii_In(char_addr_p),
	.x(x),.y(y), .displayContents(d[12]), .x_desired(10'd272), .y_desired(calendar_y));

	textGeneration c13 (.clk(clk),.reset(reset),.asciiData(a[13]), .ascii_In(char_addr_mo10),
	.x(x),.y(y), .displayContents(d[13]), .x_desired(10'd288), .y_desired(calendar_y));

	textGeneration c14 (.clk(clk),.reset(reset),.asciiData(a[14]), .ascii_In(char_addr_mo1),
	.x(x),.y(y), .displayContents(d[14]), .x_desired(10'd304), .y_desired(calendar_y));

	textGeneration c15 (.clk(clk),.reset(reset),.asciiData(a[15]), .ascii_In(char_addr_p),
	.x(x),.y(y), .displayContents(d[15]), .x_desired(10'd320), .y_desired(calendar_y));

	textGeneration c16 (.clk(clk),.reset(reset),.asciiData(a[16]), .ascii_In(char_addr_ce10),
	.x(x),.y(y), .displayContents(d[16]), .x_desired(10'd336), .y_desired(calendar_y));

	textGeneration c17 (.clk(clk),.reset(reset),.asciiData(a[17]), .ascii_In(char_addr_ce1),
	.x(x),.y(y), .displayContents(d[17]), .x_desired(10'd352), .y_desired(calendar_y));

	textGeneration c18 (.clk(clk),.reset(reset),.asciiData(a[18]), .ascii_In(char_addr_y10),
	.x(x),.y(y), .displayContents(d[18]), .x_desired(10'd368), .y_desired(calendar_y));

	textGeneration c19 (.clk(clk),.reset(reset),.asciiData(a[19]), .ascii_In(char_addr_y1),
	.x(x),.y(y), .displayContents(d[19]), .x_desired(10'd384), .y_desired(calendar_y));
	
	//Light:
	textGeneration c20 (.clk(clk),.reset(reset),.asciiData(a[20]), .ascii_In(7'h4C),
	.x(x),.y(y), .displayContents(d[20]), .x_desired(10'd32), .y_desired(light_y));
	
	textGeneration c21 (.clk(clk),.reset(reset),.asciiData(a[21]), .ascii_In(7'h49),
	.x(x),.y(y), .displayContents(d[21]), .x_desired(10'd48), .y_desired(light_y));
	
	textGeneration c22 (.clk(clk),.reset(reset),.asciiData(a[22]), .ascii_In(7'h47),
	.x(x),.y(y), .displayContents(d[22]), .x_desired(10'd64), .y_desired(light_y));
	
	textGeneration c23 (.clk(clk),.reset(reset),.asciiData(a[23]), .ascii_In(7'h48),
	.x(x),.y(y), .displayContents(d[23]), .x_desired(10'd80), .y_desired(light_y));
	
	textGeneration c24 (.clk(clk),.reset(reset),.asciiData(a[24]), .ascii_In(7'h54),
	.x(x),.y(y), .displayContents(d[24]), .x_desired(10'd96), .y_desired(light_y));
	
	textGeneration c25 (.clk(clk),.reset(reset),.asciiData(a[25]), .ascii_In(char_addr_semi),
	.x(x),.y(y), .displayContents(d[25]), .x_desired(10'd112), .y_desired(light_y));
	
	textGeneration c26 (.clk(clk),.reset(reset),.asciiData(a[26]), .ascii_In(light_1),
	.x(x),.y(y), .displayContents(d[26]), .x_desired(10'd128), .y_desired(light_y));
	
	textGeneration c27 (.clk(clk),.reset(reset),.asciiData(a[27]), .ascii_In(light_2),
	.x(x),.y(y), .displayContents(d[27]), .x_desired(10'd144), .y_desired(light_y));
	
	textGeneration c28 (.clk(clk),.reset(reset),.asciiData(a[28]), .ascii_In(light_3),
	.x(x),.y(y), .displayContents(d[28]), .x_desired(10'd160), .y_desired(light_y));
	
	//Sound:
	textGeneration c29 (.clk(clk),.reset(reset),.asciiData(a[29]), .ascii_In(7'h53),
	.x(x),.y(y), .displayContents(d[29]), .x_desired(10'd480), .y_desired(light_y));
	
	textGeneration c30 (.clk(clk),.reset(reset),.asciiData(a[30]), .ascii_In(7'h4F),
	.x(x),.y(y), .displayContents(d[30]), .x_desired(10'd496), .y_desired(light_y));
	
	textGeneration c31 (.clk(clk),.reset(reset),.asciiData(a[31]), .ascii_In(7'h55),
	.x(x),.y(y), .displayContents(d[31]), .x_desired(10'd512), .y_desired(light_y));
	
	textGeneration c32 (.clk(clk),.reset(reset),.asciiData(a[32]), .ascii_In(7'h4E),
	.x(x),.y(y), .displayContents(d[32]), .x_desired(10'd528), .y_desired(light_y));
	
	textGeneration c33 (.clk(clk),.reset(reset),.asciiData(a[33]), .ascii_In(7'h44),
	.x(x),.y(y), .displayContents(d[33]), .x_desired(10'd544), .y_desired(light_y));
	
	textGeneration c34 (.clk(clk),.reset(reset),.asciiData(a[34]), .ascii_In(char_addr_semi),
	.x(x),.y(y), .displayContents(d[34]), .x_desired(10'd560), .y_desired(light_y));
	
	
	//Motion:
	textGeneration c35 (.clk(clk),.reset(reset),.asciiData(a[35]), .ascii_In(7'h4D),
	.x(x),.y(y), .displayContents(d[35]), .x_desired(10'd32), .y_desired(motion_y));
	
	textGeneration c36 (.clk(clk),.reset(reset),.asciiData(a[36]), .ascii_In(7'h4F),
	.x(x),.y(y), .displayContents(d[36]), .x_desired(10'd48), .y_desired(motion_y));
	
	textGeneration c37 (.clk(clk),.reset(reset),.asciiData(a[37]), .ascii_In(7'h54),
	.x(x),.y(y), .displayContents(d[37]), .x_desired(10'd64), .y_desired(motion_y));
	
	textGeneration c38 (.clk(clk),.reset(reset),.asciiData(a[38]), .ascii_In(7'h49),
	.x(x),.y(y), .displayContents(d[38]), .x_desired(10'd80), .y_desired(motion_y));
	
	textGeneration c39 (.clk(clk),.reset(reset),.asciiData(a[39]), .ascii_In(7'h4F),
	.x(x),.y(y), .displayContents(d[39]), .x_desired(10'd96), .y_desired(motion_y));
	
	textGeneration c40 (.clk(clk),.reset(reset),.asciiData(a[40]), .ascii_In(7'h4E),
	.x(x),.y(y), .displayContents(d[40]), .x_desired(10'd112), .y_desired(motion_y));
	
	textGeneration c41 (.clk(clk),.reset(reset),.asciiData(a[41]), .ascii_In(char_addr_semi),
	.x(x),.y(y), .displayContents(d[41]), .x_desired(10'd128), .y_desired(motion_y));
	
	textGeneration c42 (.clk(clk),.reset(reset),.asciiData(a[42]), .ascii_In(motion_1),
	.x(x),.y(y), .displayContents(d[42]), .x_desired(10'd144), .y_desired(motion_y));
	
	textGeneration c43 (.clk(clk),.reset(reset),.asciiData(a[43]), .ascii_In(motion_2),
	.x(x),.y(y), .displayContents(d[43]), .x_desired(10'd160), .y_desired(motion_y));
	
	textGeneration c44 (.clk(clk),.reset(reset),.asciiData(a[44]), .ascii_In(motion_3),
	.x(x),.y(y), .displayContents(d[44]), .x_desired(10'd176), .y_desired(motion_y));
	
	//E-Temp:
	textGeneration c45 (.clk(clk),.reset(reset),.asciiData(a[45]), .ascii_In(7'h45),
	.x(x),.y(y), .displayContents(d[45]), .x_desired(10'd464), .y_desired(motion_y));
	
	textGeneration c46 (.clk(clk),.reset(reset),.asciiData(a[46]), .ascii_In(7'h2D),
	.x(x),.y(y), .displayContents(d[46]), .x_desired(10'd480), .y_desired(motion_y));
	
	textGeneration c47 (.clk(clk),.reset(reset),.asciiData(a[47]), .ascii_In(7'h54),
	.x(x),.y(y), .displayContents(d[47]), .x_desired(10'd496), .y_desired(motion_y));
	
	textGeneration c48 (.clk(clk),.reset(reset),.asciiData(a[48]), .ascii_In(7'h45),
	.x(x),.y(y), .displayContents(d[48]), .x_desired(10'd512), .y_desired(motion_y));
	
	textGeneration c49 (.clk(clk),.reset(reset),.asciiData(a[49]), .ascii_In(7'h4D),
	.x(x),.y(y), .displayContents(d[49]), .x_desired(10'd528), .y_desired(motion_y));
	
	textGeneration c50 (.clk(clk),.reset(reset),.asciiData(a[50]), .ascii_In(7'h50),
	.x(x),.y(y), .displayContents(d[50]), .x_desired(10'd544), .y_desired(motion_y));
	
	textGeneration c51 (.clk(clk),.reset(reset),.asciiData(a[51]), .ascii_In(char_addr_semi),
	.x(x),.y(y), .displayContents(d[51]), .x_desired(10'd560), .y_desired(motion_y));
	
	textGeneration c52 (.clk(clk),.reset(reset),.asciiData(a[52]), .ascii_In(temp_1),
	.x(x),.y(y), .displayContents(d[52]), .x_desired(10'd576), .y_desired(motion_y));
	
	textGeneration c53 (.clk(clk),.reset(reset),.asciiData(a[53]), .ascii_In(temp_2),
	.x(x),.y(y), .displayContents(d[53]), .x_desired(10'd592), .y_desired(motion_y));
	
	textGeneration c54 (.clk(clk),.reset(reset),.asciiData(a[54]), .ascii_In(7'h5C),
	.x(x),.y(y), .displayContents(d[54]), .x_desired(10'd608), .y_desired(motion_y));
	
	textGeneration c55 (.clk(clk),.reset(reset),.asciiData(a[55]), .ascii_In(7'h43),
	.x(x),.y(y), .displayContents(d[55]), .x_desired(10'd624), .y_desired(motion_y));
	
	//System:
	textGeneration c56 (.clk(clk),.reset(reset),.asciiData(a[56]), .ascii_In(7'h53),
	.x(x),.y(y), .displayContents(d[56]), .x_desired(10'd240), .y_desired(system_y));
	
	textGeneration c57 (.clk(clk),.reset(reset),.asciiData(a[57]), .ascii_In(7'h59),
	.x(x),.y(y), .displayContents(d[57]), .x_desired(10'd256), .y_desired(system_y));
	
	textGeneration c58 (.clk(clk),.reset(reset),.asciiData(a[58]), .ascii_In(7'h53),
	.x(x),.y(y), .displayContents(d[58]), .x_desired(10'd272), .y_desired(system_y));
	
	textGeneration c59 (.clk(clk),.reset(reset),.asciiData(a[59]), .ascii_In(7'h54),
	.x(x),.y(y), .displayContents(d[59]), .x_desired(10'd288), .y_desired(system_y));
	
	textGeneration c60 (.clk(clk),.reset(reset),.asciiData(a[60]), .ascii_In(7'h45),
	.x(x),.y(y), .displayContents(d[60]), .x_desired(10'd304), .y_desired(system_y));
	
	textGeneration c61 (.clk(clk),.reset(reset),.asciiData(a[61]), .ascii_In(7'h4D),
	.x(x),.y(y), .displayContents(d[61]), .x_desired(10'd320), .y_desired(system_y));
	
	textGeneration c62 (.clk(clk),.reset(reset),.asciiData(a[62]), .ascii_In(char_addr_semi),
	.x(x),.y(y), .displayContents(d[62]), .x_desired(10'd336), .y_desired(system_y));
	
	textGeneration c63 (.clk(clk),.reset(reset),.asciiData(a[63]), .ascii_In(system_1),
	.x(x),.y(y), .displayContents(d[63]), .x_desired(10'd352), .y_desired(system_y));
	
	textGeneration c64 (.clk(clk),.reset(reset),.asciiData(a[64]), .ascii_In(system_2),
	.x(x),.y(y), .displayContents(d[64]), .x_desired(10'd368), .y_desired(system_y));
	
	textGeneration c65 (.clk(clk),.reset(reset),.asciiData(a[65]), .ascii_In(system_3),
	.x(x),.y(y), .displayContents(d[65]), .x_desired(10'd384), .y_desired(system_y));
	
	
	//HUMD:xx%
	textGeneration c66 (.clk(clk),.reset(reset),.asciiData(a[66]), .ascii_In(7'h48),
	.x(x),.y(y), .displayContents(d[66]), .x_desired(10'd240), .y_desired(motion_y));
	
	textGeneration c67 (.clk(clk),.reset(reset),.asciiData(a[67]), .ascii_In(7'h55),
	.x(x),.y(y), .displayContents(d[67]), .x_desired(10'd256), .y_desired(motion_y));
	
	textGeneration c68 (.clk(clk),.reset(reset),.asciiData(a[68]), .ascii_In(7'h4D),
	.x(x),.y(y), .displayContents(d[68]), .x_desired(10'd272), .y_desired(motion_y));
	
	textGeneration c69 (.clk(clk),.reset(reset),.asciiData(a[69]), .ascii_In(7'h44),
	.x(x),.y(y), .displayContents(d[69]), .x_desired(10'd288), .y_desired(motion_y));
	
	textGeneration c70 (.clk(clk),.reset(reset),.asciiData(a[70]), .ascii_In(char_addr_semi),
	.x(x),.y(y), .displayContents(d[70]), .x_desired(10'd304), .y_desired(motion_y));

	textGeneration c71 (.clk(clk),.reset(reset),.asciiData(a[71]), .ascii_In(hum_1),
	.x(x),.y(y), .displayContents(d[71]), .x_desired(10'd320), .y_desired(motion_y));
	
	textGeneration c72 (.clk(clk),.reset(reset),.asciiData(a[72]), .ascii_In(hum_2),
	.x(x),.y(y), .displayContents(d[72]), .x_desired(10'd336), .y_desired(motion_y));

	textGeneration c73 (.clk(clk),.reset(reset),.asciiData(a[73]), .ascii_In(7'h25),
	.x(x),.y(y), .displayContents(d[73]), .x_desired(10'd352), .y_desired(motion_y));
	
	
	//I-Temp:
	textGeneration c74 (.clk(clk),.reset(reset),.asciiData(a[74]), .ascii_In(7'h49),
	.x(x),.y(y), .displayContents(d[74]), .x_desired(10'd240), .y_desired(light_y));
	
	textGeneration c75 (.clk(clk),.reset(reset),.asciiData(a[75]), .ascii_In(7'h2D),
	.x(x),.y(y), .displayContents(d[75]), .x_desired(10'd256), .y_desired(light_y));
	
	textGeneration c76 (.clk(clk),.reset(reset),.asciiData(a[76]), .ascii_In(7'h54),
	.x(x),.y(y), .displayContents(d[76]), .x_desired(10'd272), .y_desired(light_y));
	
	textGeneration c77 (.clk(clk),.reset(reset),.asciiData(a[77]), .ascii_In(7'h45),
	.x(x),.y(y), .displayContents(d[77]), .x_desired(10'd288), .y_desired(light_y));
	
	textGeneration c78 (.clk(clk),.reset(reset),.asciiData(a[78]), .ascii_In(7'h4D),
	.x(x),.y(y), .displayContents(d[78]), .x_desired(10'd304), .y_desired(light_y));
	
	textGeneration c79 (.clk(clk),.reset(reset),.asciiData(a[79]), .ascii_In(7'h50),
	.x(x),.y(y), .displayContents(d[79]), .x_desired(10'd320), .y_desired(light_y));
	
	textGeneration c80 (.clk(clk),.reset(reset),.asciiData(a[80]), .ascii_In(char_addr_semi),
	.x(x),.y(y), .displayContents(d[80]), .x_desired(10'd336), .y_desired(light_y));
	
	textGeneration c81 (.clk(clk),.reset(reset),.asciiData(a[81]), .ascii_In(itemp_1),
	.x(x),.y(y), .displayContents(d[81]), .x_desired(10'd352), .y_desired(light_y));
	
	textGeneration c82 (.clk(clk),.reset(reset),.asciiData(a[82]), .ascii_In(itemp_2),
	.x(x),.y(y), .displayContents(d[82]), .x_desired(10'd368), .y_desired(light_y));
	
	textGeneration c83 (.clk(clk),.reset(reset),.asciiData(a[83]), .ascii_In(7'h2E),
	.x(x),.y(y), .displayContents(d[83]), .x_desired(10'd384), .y_desired(light_y));
	
	textGeneration c84 (.clk(clk),.reset(reset),.asciiData(a[84]), .ascii_In(itemp_3),
	.x(x),.y(y), .displayContents(d[84]), .x_desired(10'd400), .y_desired(light_y));
	
	textGeneration c85 (.clk(clk),.reset(reset),.asciiData(a[85]), .ascii_In(7'h5C),
	.x(x),.y(y), .displayContents(d[85]), .x_desired(10'd416), .y_desired(light_y));
	
	textGeneration c86 (.clk(clk),.reset(reset),.asciiData(a[86]), .ascii_In(7'h43),
	.x(x),.y(y), .displayContents(d[86]), .x_desired(10'd432), .y_desired(light_y));
	
	
	//UART:
	textGeneration c87 (.clk(clk),.reset(reset),.asciiData(a[87]), .ascii_In(7'h55),
	.x(x),.y(y), .displayContents(d[87]), .x_desired(10'd240), .y_desired(uart_y));
	
	textGeneration c88 (.clk(clk),.reset(reset),.asciiData(a[88]), .ascii_In(7'h41),
	.x(x),.y(y), .displayContents(d[88]), .x_desired(10'd256), .y_desired(uart_y));
	
	textGeneration c89 (.clk(clk),.reset(reset),.asciiData(a[89]), .ascii_In(7'h52),
	.x(x),.y(y), .displayContents(d[89]), .x_desired(10'd272), .y_desired(uart_y));
	
	textGeneration c90 (.clk(clk),.reset(reset),.asciiData(a[90]), .ascii_In(7'h54),
	.x(x),.y(y), .displayContents(d[90]), .x_desired(10'd288), .y_desired(uart_y));
	
	textGeneration c91 (.clk(clk),.reset(reset),.asciiData(a[91]), .ascii_In(char_addr_semi),
	.x(x),.y(y), .displayContents(d[91]), .x_desired(10'd304), .y_desired(uart_y));
	
	textGeneration c106 (.clk(clk),.reset(reset),.asciiData(a[106]), .ascii_In(uart_1),
	.x(x),.y(y), .displayContents(d[106]), .x_desired(10'd320), .y_desired(uart_y));
	
	
	//INTRUDER
	textGeneration c92 (.clk(clk),.reset(reset),.asciiData(a[92]), .ascii_In(sec_i),
	.x(x),.y(y), .displayContents(d[92]), .x_desired(10'd240), .y_desired(intruder_y));
	
	textGeneration c93 (.clk(clk),.reset(reset),.asciiData(a[93]), .ascii_In(sec_n),
	.x(x),.y(y), .displayContents(d[93]), .x_desired(10'd256), .y_desired(intruder_y));
	
	textGeneration c94 (.clk(clk),.reset(reset),.asciiData(a[94]), .ascii_In(sec_t),
	.x(x),.y(y), .displayContents(d[94]), .x_desired(10'd272), .y_desired(intruder_y));

	textGeneration c95 (.clk(clk),.reset(reset),.asciiData(a[95]), .ascii_In(sec_r),
	.x(x),.y(y), .displayContents(d[95]), .x_desired(10'd288), .y_desired(intruder_y));
	
	textGeneration c96 (.clk(clk),.reset(reset),.asciiData(a[96]), .ascii_In(sec_u),
	.x(x),.y(y), .displayContents(d[96]), .x_desired(10'd304), .y_desired(intruder_y));
	
	textGeneration c97 (.clk(clk),.reset(reset),.asciiData(a[97]), .ascii_In(sec_d),
	.x(x),.y(y), .displayContents(d[97]), .x_desired(10'd320), .y_desired(intruder_y));
	
	textGeneration c98 (.clk(clk),.reset(reset),.asciiData(a[98]), .ascii_In(sec_e),
	.x(x),.y(y), .displayContents(d[98]), .x_desired(10'd336), .y_desired(intruder_y));
	
	textGeneration c99 (.clk(clk),.reset(reset),.asciiData(a[99]), .ascii_In(sec_r),
	.x(x),.y(y), .displayContents(d[99]), .x_desired(10'd352), .y_desired(intruder_y));
	
	//ALERT!
	textGeneration c100 (.clk(clk),.reset(reset),.asciiData(a[100]), .ascii_In(sec_a),
	.x(x),.y(y), .displayContents(d[100]), .x_desired(10'd384), .y_desired(intruder_y));
	
	textGeneration c101 (.clk(clk),.reset(reset),.asciiData(a[101]), .ascii_In(sec_l),
	.x(x),.y(y), .displayContents(d[101]), .x_desired(10'd400), .y_desired(intruder_y));
	
	textGeneration c102 (.clk(clk),.reset(reset),.asciiData(a[102]), .ascii_In(sec_e),
	.x(x),.y(y), .displayContents(d[102]), .x_desired(10'd416), .y_desired(intruder_y));
	
	textGeneration c103 (.clk(clk),.reset(reset),.asciiData(a[103]), .ascii_In(sec_r),
	.x(x),.y(y), .displayContents(d[103]), .x_desired(10'd432), .y_desired(intruder_y));
	
	textGeneration c104 (.clk(clk),.reset(reset),.asciiData(a[104]), .ascii_In(sec_t),
	.x(x),.y(y), .displayContents(d[104]), .x_desired(10'd448), .y_desired(intruder_y));
	
	textGeneration c105 (.clk(clk),.reset(reset),.asciiData(a[105]), .ascii_In(sec_exp),
	.x(x),.y(y), .displayContents(d[105]), .x_desired(10'd464), .y_desired(intruder_y));
	
	//ACCEL:
	textGeneration c121 (.clk(clk),.reset(reset),.asciiData(a[121]), .ascii_In(7'h41),
	.x(x),.y(y), .displayContents(d[121]), .x_desired(10'd32), .y_desired(uart_y));
	
	textGeneration c122 (.clk(clk),.reset(reset),.asciiData(a[122]), .ascii_In(7'h43),
	.x(x),.y(y), .displayContents(d[122]), .x_desired(10'd48), .y_desired(uart_y));
	
	textGeneration c123 (.clk(clk),.reset(reset),.asciiData(a[123]), .ascii_In(7'h43),
	.x(x),.y(y), .displayContents(d[123]), .x_desired(10'd64), .y_desired(uart_y));
	
	textGeneration c124 (.clk(clk),.reset(reset),.asciiData(a[124]), .ascii_In(7'h45),
	.x(x),.y(y), .displayContents(d[124]), .x_desired(10'd80), .y_desired(uart_y));
	
	textGeneration c125 (.clk(clk),.reset(reset),.asciiData(a[125]), .ascii_In(7'h4C),
	.x(x),.y(y), .displayContents(d[125]), .x_desired(10'd96), .y_desired(uart_y));
	
	textGeneration c126 (.clk(clk),.reset(reset),.asciiData(a[126]), .ascii_In(char_addr_semi),
	.x(x),.y(y), .displayContents(d[126]), .x_desired(10'd112), .y_desired(uart_y));
	
	//X: MIDDLE LEFT RIGHT
	textGeneration c107 (.clk(clk),.reset(reset),.asciiData(a[107]), .ascii_In(7'h58),
	.x(x),.y(y), .displayContents(d[107]), .x_desired(10'd48), .y_desired(intruder_y));
	
	textGeneration c108 (.clk(clk),.reset(reset),.asciiData(a[108]), .ascii_In(char_addr_semi),
	.x(x),.y(y), .displayContents(d[108]), .x_desired(10'd64), .y_desired(intruder_y));
	
	textGeneration c109 (.clk(clk),.reset(reset),.asciiData(a[109]), .ascii_In(x_1),
	.x(x),.y(y), .displayContents(d[109]), .x_desired(10'd80), .y_desired(intruder_y));
	
	textGeneration c110 (.clk(clk),.reset(reset),.asciiData(a[110]), .ascii_In(x_2),
	.x(x),.y(y), .displayContents(d[110]), .x_desired(10'd96), .y_desired(intruder_y));
	
	textGeneration c111 (.clk(clk),.reset(reset),.asciiData(a[111]), .ascii_In(x_3),
	.x(x),.y(y), .displayContents(d[111]), .x_desired(10'd112), .y_desired(intruder_y));
	
	textGeneration c112 (.clk(clk),.reset(reset),.asciiData(a[112]), .ascii_In(x_4),
	.x(x),.y(y), .displayContents(d[112]), .x_desired(10'd128), .y_desired(intruder_y));
	
	textGeneration c113 (.clk(clk),.reset(reset),.asciiData(a[113]), .ascii_In(x_5),
	.x(x),.y(y), .displayContents(d[113]), .x_desired(10'd144), .y_desired(intruder_y));
	
	textGeneration c114 (.clk(clk),.reset(reset),.asciiData(a[114]), .ascii_In(x_6),
	.x(x),.y(y), .displayContents(d[114]), .x_desired(10'd160), .y_desired(intruder_y));
	
	
	//Y: FLAT UP DOWN
	textGeneration c115 (.clk(clk),.reset(reset),.asciiData(a[115]), .ascii_In(7'h59),
	.x(x),.y(y), .displayContents(d[115]), .x_desired(10'd48), .y_desired(alert_y));
	
	textGeneration c116 (.clk(clk),.reset(reset),.asciiData(a[116]), .ascii_In(char_addr_semi),
	.x(x),.y(y), .displayContents(d[116]), .x_desired(10'd64), .y_desired(alert_y));
	
	textGeneration c117 (.clk(clk),.reset(reset),.asciiData(a[117]), .ascii_In(y_1),
	.x(x),.y(y), .displayContents(d[117]), .x_desired(10'd80), .y_desired(alert_y));
	
	textGeneration c118 (.clk(clk),.reset(reset),.asciiData(a[118]), .ascii_In(y_2),
	.x(x),.y(y), .displayContents(d[118]), .x_desired(10'd96), .y_desired(alert_y));
	
	textGeneration c119 (.clk(clk),.reset(reset),.asciiData(a[119]), .ascii_In(y_3),
	.x(x),.y(y), .displayContents(d[119]), .x_desired(10'd112), .y_desired(alert_y));
	
	textGeneration c120 (.clk(clk),.reset(reset),.asciiData(a[120]), .ascii_In(y_4),
	.x(x),.y(y), .displayContents(d[120]), .x_desired(10'd128), .y_desired(alert_y));
	
	//TAMPER ALERT!
	textGeneration c127 (.clk(clk),.reset(reset),.asciiData(a[127]), .ascii_In(tam_t),
	.x(x),.y(y), .displayContents(d[127]), .x_desired(10'd240), .y_desired(alert_y));
	
	textGeneration c128 (.clk(clk),.reset(reset),.asciiData(a[128]), .ascii_In(tam_a),
	.x(x),.y(y), .displayContents(d[128]), .x_desired(10'd256), .y_desired(alert_y));
	
	textGeneration c129 (.clk(clk),.reset(reset),.asciiData(a[129]), .ascii_In(tam_m),
	.x(x),.y(y), .displayContents(d[129]), .x_desired(10'd272), .y_desired(alert_y));
	
	textGeneration c130 (.clk(clk),.reset(reset),.asciiData(a[130]), .ascii_In(tam_p),
	.x(x),.y(y), .displayContents(d[130]), .x_desired(10'd288), .y_desired(alert_y));
	
	textGeneration c131 (.clk(clk),.reset(reset),.asciiData(a[131]), .ascii_In(tam_e),
	.x(x),.y(y), .displayContents(d[131]), .x_desired(10'd304), .y_desired(alert_y));
	
	textGeneration c132 (.clk(clk),.reset(reset),.asciiData(a[132]), .ascii_In(tam_r),
	.x(x),.y(y), .displayContents(d[132]), .x_desired(10'd320), .y_desired(alert_y));
	
	textGeneration c133 (.clk(clk),.reset(reset),.asciiData(a[133]), .ascii_In(tam_a),
	.x(x),.y(y), .displayContents(d[133]), .x_desired(10'd352), .y_desired(alert_y));
	
	textGeneration c134 (.clk(clk),.reset(reset),.asciiData(a[134]), .ascii_In(tam_l),
	.x(x),.y(y), .displayContents(d[134]), .x_desired(10'd368), .y_desired(alert_y));
	
	textGeneration c135 (.clk(clk),.reset(reset),.asciiData(a[135]), .ascii_In(tam_e),
	.x(x),.y(y), .displayContents(d[135]), .x_desired(10'd384), .y_desired(alert_y));
	
	textGeneration c136 (.clk(clk),.reset(reset),.asciiData(a[136]), .ascii_In(tam_r),
	.x(x),.y(y), .displayContents(d[136]), .x_desired(10'd400), .y_desired(alert_y));
	
	textGeneration c137 (.clk(clk),.reset(reset),.asciiData(a[137]), .ascii_In(tam_t),
	.x(x),.y(y), .displayContents(d[137]), .x_desired(10'd416), .y_desired(alert_y));
	
	textGeneration c138 (.clk(clk),.reset(reset),.asciiData(a[138]), .ascii_In(tam_exp),
	.x(x),.y(y), .displayContents(d[138]), .x_desired(10'd432), .y_desired(alert_y));
	///////////////////////////////////////////////////////////////////////////////////////////////

	// Register to hold the displayContents signal
	reg displayContents_reg;
	
	// Register to hold the ASCII value
	reg [6:0] ascii_reg;
	
	//Decoder to trigger displayContents signal high or low depending on which ASCII char is reached
	//Decoder to assign correct ASCII value depending on which displayContents signal is used                        
	always @* begin
		 displayContents_reg = 0;
		 ascii_reg = 7'h30; // Defaulted to 0
		 for (int i = 0; i < 139; i = i + 1) begin
			  if (d[i] == 1'b1) begin
					displayContents_reg = d[i];
					ascii_reg = a[i];
			  end
		 end
	end

	assign displayContents = displayContents_reg;
	assign ascii = ascii_reg;

	//ASCII_ROM////////////////////////////////////////////////////////////       
	//Connections to ascii_rom
	wire [10:0] rom_addr;
	//Handle the row of the rom
	wire [3:0] rom_row;
	//Handle the column of the rom data
	wire [2:0] rom_col;
	//Wire to connect to rom_data of ascii_rom
	wire [7:0] rom_data;
	//Bit to signal display of data
	wire rom_bit;
	ascii_rom rom1(.clk(clk), .addr(rom_addr), .data(rom_data));

	//Concatenate to get 11 bit rom_addr
	assign rom_row = y[4:1];
	assign rom_addr = {ascii, rom_row};
	assign rom_col = x[3:1];
	assign rom_bit = rom_data[~rom_col]; //need to negate since it initially displays mirrored
	///////////////////////////////////////////////////////////////////////////////////////////////

	//If video on then check
	  //If rom_bit is on
			//If x and y are in the origin/end range
				 //Set RGB to display whatever is in the ROM within the origin/end range
			//Else we are out of range so we should not modify anything, RGB set to blue
	  //rom_bit is off display blue
	//Video_off display black
	wire [11:0] rgb;
	assign rgb = video_on ? (rom_bit ? ((displayContents) ? 12'hFFF: 12'h8): 12'h8) : 12'b0; //rgb_reg[3:0] background white text
	
	// rgb buffer
	reg [11:0] rgb_reg;
	
	// Define starting coordinates for the sound visualization grid
	integer rowStart = 170, columnStart = 600;
	
	// Define the maximum voltage threshold for sound visualization
	wire [0:2] max = 0.5; 


	always @(posedge slowClk) begin	
	 // Check if the current coordinates (x, y) are within each grid cell
    // and update rgb_reg based on the sound sensor readings

    // Sound visualization for each grid cell
    // If the sound voltage exceeds the maximum threshold, set RGB values to display a high intensity color (Red, Yellow, Green based on level)
    // Otherwise, set RGB values to display a low intensity darker color (Dark Red, Yellow, Green meaning off)
		if(x > columnStart && x < columnStart+10 && y > rowStart && y < rowStart+10) begin
			if(volSound[12] >= max) begin
				rgb_reg[11:8] <= 4'hF;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'h0;
			end
			else begin
				rgb_reg[11:8] <= 4'h3;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'h0;
			end
		end
		else if(x > columnStart && x < columnStart+10 && y > rowStart+30 && y < rowStart+40) begin
			if(volSound[11] >= max) begin
				rgb_reg[11:8] <= 4'hF;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'h0;
			end
			else begin
				rgb_reg[11:8] <= 4'h3;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'h0;
			end
		end
		else if(x > columnStart && x < columnStart+10 && y > rowStart+60 && y < rowStart+70) begin
			if(volSound[10]  >= max) begin
				rgb_reg[11:8] <= 4'hF;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'h0;
			end
			else begin
				rgb_reg[11:8] <= 4'h3;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'h0;
			end
		end
		else if(x > columnStart && x < columnStart+10 && y > rowStart+90 && y < rowStart+100) begin
			if(volSound[9]  >= max) begin
				rgb_reg[11:8] <= 4'hF;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'hF;
			end
			else begin
				rgb_reg[11:8] <= 4'h3;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'h3;
			end
		end
		else if(x > columnStart && x < columnStart+10 && y > rowStart+120 && y < rowStart+130) begin
			if(volSound[8]  >= max) begin
				rgb_reg[11:8] <= 4'hF;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'hF;
			end
			else begin
				rgb_reg[11:8] <= 4'h3;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'h3;
			end
		end
		else if(x > columnStart && x < columnStart+10 && y > rowStart+150 && y < rowStart+160) begin
			if(volSound[7]  >= max) begin
				rgb_reg[11:8] <= 4'hF;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'hF;
			end
			else begin
				rgb_reg[11:8] <= 4'h3;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'h3;
			end
		end
		else if(x > columnStart && x < columnStart+10 && y > rowStart+180 && y < rowStart+190) begin
			if(volSound[6]  >= max) begin
				rgb_reg[11:8] <= 4'h0;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'hF;
			end
			else begin
				rgb_reg[11:8] <= 4'h0;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'h3;
			end
		end
		else if(x > columnStart && x < columnStart+10 && y > rowStart+210 && y < rowStart+220) begin
			if(volSound[5]  >= max) begin
				rgb_reg[11:8] <= 4'h0;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'hF;
			end
			else begin
				rgb_reg[11:8] <= 4'h0;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'h3;
			end
		end
		else if(x > columnStart && x < columnStart+10 && y > rowStart+240 && y < rowStart+250) begin
			if(volSound[4]  >= max) begin
				rgb_reg[11:8] <= 4'h0;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'hF;
			end
			else begin
				rgb_reg[11:8] <= 4'h0;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'h3;
			end
		end
		else if(x > columnStart && x < columnStart+10 && y > rowStart+270 && y < rowStart+280) begin
			if(volSound[3] >= max) begin
				rgb_reg[11:8] <= 4'h0;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'hF;
			end
			else begin
				rgb_reg[11:8] <= 4'h0;
				rgb_reg[3:0] <= 4'h0;
				rgb_reg[7:4] <= 4'h3;
			end
		end
		else begin
			rgb_reg <= rgb;
		end
	end
			
	assign rgb_out = rgb_reg;

endmodule