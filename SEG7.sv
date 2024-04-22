module SEG7(
    output reg [6:0] oSEG,  // 7-segment display output
    input [3:0] iDIG        // Input for digit selection
);

// Segment decoder logic
always @(iDIG)
begin
    case(iDIG)
        // Assign 7-segment codes based on input digit value
        // Each case represents a digit value and its corresponding 7-segment code
        // For example, case 4'h1 represents the digit '1' and its corresponding segment code
        4'h1: oSEG = 7'b1111001;   // Segment code for digit '1'
        4'h2: oSEG = 7'b0100100;   // Segment code for digit '2'
        4'h3: oSEG = 7'b0110000;   // Segment code for digit '3'
        4'h4: oSEG = 7'b0011001;   // Segment code for digit '4'
        4'h5: oSEG = 7'b0010010;   // Segment code for digit '5'
        4'h6: oSEG = 7'b0000010;   // Segment code for digit '6'
        4'h7: oSEG = 7'b1111000;   // Segment code for digit '7'
        4'h8: oSEG = 7'b0000000;   // Segment code for digit '8'
        4'h9: oSEG = 7'b0011000;   // Segment code for digit '9'
        4'ha: oSEG = 7'b0001000;   // Segment code for digit 'A'
        4'hb: oSEG = 7'b0000011;   // Segment code for digit 'B'
        4'hc: oSEG = 7'b1000110;   // Segment code for digit 'C'
        4'hd: oSEG = 7'b0100001;   // Segment code for digit 'D'
        4'he: oSEG = 7'b0000110;   // Segment code for digit 'E'
        4'hf: oSEG = 7'b0001110;   // Segment code for digit 'F'
        4'h0: oSEG = 7'b1000000;   // Segment code for digit '0'
    endcase
end

endmodule
