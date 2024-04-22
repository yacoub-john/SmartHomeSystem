module MotionController(
    input  logic clk,               // Clock input
    input  logic motion,            // Motion detection signal
    input  logic enable,            // Enable signal
    input  logic systemOn,          // System power on signal
    input  logic [3:0] tamper_counter, // Tamper counter input
    output logic buzzer,            // Buzzer output signal
    output logic led0               // LED output signal
);

// Always block triggered on positive edge of clock
always @(posedge clk) begin
   
    // Check conditions for activating LED and buzzer
    if ((~motion) && enable && systemOn) begin 
        led0 <= 1;                  // Turn on LED
        buzzer <= 1;                // Activate buzzer
    end else begin 
        led0 <= 0;                  // Turn off LED
        buzzer <= 0;                // Deactivate buzzer
    end
end

endmodule
