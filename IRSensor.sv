module IRSensor(
    input  logic clk,             // Clock input
    input  logic enable,          // Enable signal
    output logic led0,            // LED output signal
    output logic [7:0] hex0,      // Hexadecimal output 0
    output logic [7:0] hex1,      // Hexadecimal output 1
    output logic displayState     // Display state signal
);

    logic [7:0] O = 8'b11000000;  // Hex value O
    logic [7:0] F = 8'b10001110;  // Hex value F
    logic [7:0] n = 8'b10101011;  // Hex value n
    logic prevEnable;             // Previous state of enable signal

    // Sequential logic to toggle display state on enable signal change
    always_ff @(posedge clk) begin
        if (enable !== prevEnable) begin
            displayState <= ~displayState;  // Toggle display state
        end
        prevEnable <= enable;  // Store current enable signal state
    end

    // Sequential logic to control LED and hexadecimal outputs based on display state
    always_ff @(posedge clk) begin
        if (displayState) begin  // If system is active
            led0 <= 1;           // Turn on LED
            hex0 <= n;           // Output hexadecimal value n on hex0
            hex1 <= O;           // Output hexadecimal value O on hex1
        end else begin          // If system state is disarmed
            led0 <= 0;           // Turn off LED
            hex0 <= F;           // Output hexadecimal value F on hex0
            hex1 <= O;           // Output hexadecimal value O on hex1
        end
    end

endmodule
