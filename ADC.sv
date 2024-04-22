module ADC (
    input clk,                            // System clock input
    output reg [12:0] volLight,          // Output for light voltage
    output reg [12:0] volSound,          // Output for sound voltage
    output reg [12:0] volTemp,          // Output for temp voltage
	 output [8:0] LEDR
);

    wire reset_n;                        // Reset signal
    wire sys_clk;                        // System clock signal

	 assign reset_n = 1'b1;

    // ADC instance
    adc_qsys u0 (
        .clk_clk(clk),                            // ADC clock input
        .reset_reset_n(reset_n),                  // Reset signal
        .modular_adc_0_command_valid(command_valid),          // Command valid signal
        .modular_adc_0_command_channel(command_channel),      // Command channel signal
        .modular_adc_0_command_startofpacket(command_startofpacket),  // Command start of packet signal
        .modular_adc_0_command_endofpacket(command_endofpacket),      // Command end of packet signal
        .modular_adc_0_command_ready(command_ready),          // Command ready signal
        .modular_adc_0_response_valid(response_valid),        // Response valid signal
        .modular_adc_0_response_channel(response_channel),    // Response channel signal
        .modular_adc_0_response_data(response_data),          // Response data signal
        .modular_adc_0_response_startofpacket(response_startofpacket),  // Response start of packet signal
        .modular_adc_0_response_endofpacket(response_endofpacket),      // Response end of packet signal
        .clock_bridge_sys_out_clk_clk(sys_clk)          // System clock output
    );

    ////////////////////////////////////////////
    // Command
    wire command_valid;              // Command valid signal
    reg [4:0] command_channel;       // Command channel
    wire command_startofpacket;      // Command start of packet
    wire command_endofpacket;        // Command end of packet
    wire command_ready;              // Command ready

    // Continued send command
    assign command_startofpacket = 1'b1; // Start of packet always high
    assign command_endofpacket = 1'b1;   // End of packet always high
    assign command_valid = 1'b1;         // Command valid always high

    ////////////////////////////////////////////
    // Response
    wire response_valid;                // Response valid signal
    wire [4:0] response_channel;        // Response channel
    wire [11:0] response_data;          // Response data
    wire response_startofpacket;        // Response start of packet
    wire response_endofpacket;          // Response end of packet
    reg [4:0] cur_adc_ch;               // Current ADC channel
    reg [11:0] adc_sample_data;         // ADC sample data
    reg [12:0] volOut, volOutS ;                  // Volume output
    reg [1:0] state;                    // State machine for multiplexing sensor input
		 	 	
	
	always @ (posedge sys_clk) begin
		 case(state)
			  // State 00
			  2'b00: begin
					// Set command_channel to 1
					command_channel <= 1;

					// If response is valid, update ADC sample data, current ADC channel, and voltage for light
					if (response_valid) begin
						 adc_sample_data <= response_data;
						 cur_adc_ch <= response_channel;
						 // Calculate volume for light
						 volOutS <= response_data * 2 * 2500 / 4095;
					end

					// Move to state 01
					state <= 2'b01;
			  end

			  // State 01
			  2'b01: begin
					// Set command_channel to 2
					command_channel <= 2;

					// If response is valid, update ADC sample data, current ADC channel, and voltage for sound
					if (response_valid) begin
						 adc_sample_data <= response_data;
						 cur_adc_ch <= response_channel;
						 // Calculate volume for sound
						 volLight <= response_data * 2 * 2500 / 4095;
					end

					// Move to state 10
					state <= 2'b10;
			  end

			  // State 10
			  2'b10: begin
					// Set command_channel to 3
					command_channel <= 3;

					// If response is valid, update ADC sample data, current ADC channel, and voltage for motion
					if (response_valid) begin
						 adc_sample_data <= response_data;
						 cur_adc_ch <= response_channel;
						 // Calculate volume for motion
						 volOut <= response_data * 2 * 2500 / 4095;
					end

					// Move back to state 00
					state <= 2'b00;
			  end
		 endcase
	end
		
assign LEDR[8:0] = volOutS[11:3];  // led is high active

	
clock #(32'd250000) slow(clk, slowClk);

//Buffer Sound and Temp outputs
always @(posedge slowClk) begin
   volTemp <= volOut;
	volSound <= volOutS;
end
		


endmodule