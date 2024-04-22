module DHT11wdisp(
    input clk_i,           // 50 MHz clock input
    inout w1_o,            // Data wire of DHT11
    output [27:0] DISP,    // Segments of 7-seg display
    output [7:0] temp_7s,  // Temperature output
    output [7:0] hum_7s,   // Humidity output
    output LED_d           // LED that blinks at each transfer
);

wire [15:0] dataDisp;      // Combined data (8 bits of temperature, 8 bits of humidity)

// DHT11 module instance
DHT11 DH_U0(
    .clk_i  (clk_i),
    .w1_o   (w1_o),
    .temp_o (dataDisp[15:8]), // Temperature output from DHT11
    .hum_o  (dataDisp[7:0]),  // Humidity output from DHT11
    .w1_d   (LED_d)           // LED indication for DHT11 data transfer
); 

wire [13:0] temp;           // Temperature in 7-segment form
wire [13:0] hum;            // Humidity in 7-segment form

// Temperature and humidity conversion modules
BIN2BCD DECOD_Temp(
    .clk_i   (clk_i), 
    .bin_i   (dataDisp[15:8]), 
    .uni_o   (temp[6:0]), 
    .dec_o   (temp[13:7])
);

BIN2BCD DECOD_Hum(
    .clk_i   (clk_i), 
    .bin_i   (dataDisp[7:0]), 
    .uni_o   (hum[6:0]), 
    .dec_o   (hum[13:7])
);

// Reversing the order of bits for temperature and humidity
reverse_order #(14) reverse_order_14bit (
    .input_data(temp),
    .output_data(temp_rev)
);
reverse_order #(14) reverse_order_14bit1 (
    .input_data(hum),
    .output_data(hum_rev)
);

// 7-segment encoder modules for temperature and humidity
SEG7_encoder_14bit SEG7_inst_temp (
    .iSEG(temp_rev),
    .oDIG(temp_7s),
);

SEG7_encoder_14bit SEG7_inst_hum (
    .iSEG(hum_rev),
    .oDIG(hum_7s),
);

reg [26:0] div = 27'b0;    // Divider to switch data to display (HR or temp)
always @(posedge clk_i)
    div <= div + 1'b1; 

reg switchDisp = 1'b0;     // Switch for alternating between displaying temperature and humidity
always @(posedge div[26])   // Switch every 2^27/(50*10^6) = 2.68s
    switchDisp <= ~switchDisp; 

reg [27:0] num2disp = 28'b0;   // Register of data to be displayed 
always @(switchDisp, temp_7s, hum_7s) begin // Mux for switching data
    if(switchDisp)
        num2disp <= {temp, 7'b0011100, 7'b0110001};  // {<temp>, '°', 'C'}
    else
        num2disp <= {hum, 7'b1001000, 7'b1111010};   // {<HR>, 'H', 'r'}
end 

// Reversing the order of bits for displaying on 7-segment display
reverse_order #(28) reverse_order_28bit (
    .input_data(num2disp),
    .output_data(DISP)
);

endmodule
