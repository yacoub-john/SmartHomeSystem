module BinaryToHex(
    input [7:0] binary_input,
    output [6:0] first_output,
    output [6:0] second_output
);

reg [3:0] first_hex_output, second_hex_output;

always_comb begin
    // Convert the first four bits of the binary input to hexadecimal
    case (binary_input[7:4])
        4'b0000: first_hex_output = 4'h0;
        4'b0001: first_hex_output = 4'h1;
        4'b0010: first_hex_output = 4'h2;
        4'b0011: first_hex_output = 4'h3;
        4'b0100: first_hex_output = 4'h4;
        4'b0101: first_hex_output = 4'h5;
        4'b0110: first_hex_output = 4'h6;
        4'b0111: first_hex_output = 4'h7;
        4'b1000: first_hex_output = 4'h8;
        4'b1001: first_hex_output = 4'h9;
        4'b1010: first_hex_output = 4'hA;
        4'b1011: first_hex_output = 4'hB;
        4'b1100: first_hex_output = 4'hC;
        4'b1101: first_hex_output = 4'hD;
        4'b1110: first_hex_output = 4'hE;
        4'b1111: first_hex_output = 4'hF;
        default: first_hex_output = 4'hX; // Error case
    endcase
    
    // Convert the last four bits of the binary input to hexadecimal
    case (binary_input[3:0])
        4'b0000: second_hex_output = 4'h0;
        4'b0001: second_hex_output = 4'h1;
        4'b0010: second_hex_output = 4'h2;
        4'b0011: second_hex_output = 4'h3;
        4'b0100: second_hex_output = 4'h4;
        4'b0101: second_hex_output = 4'h5;
        4'b0110: second_hex_output = 4'h6;
        4'b0111: second_hex_output = 4'h7;
        4'b1000: second_hex_output = 4'h8;
        4'b1001: second_hex_output = 4'h9;
        4'b1010: second_hex_output = 4'hA;
        4'b1011: second_hex_output = 4'hB;
        4'b1100: second_hex_output = 4'hC;
        4'b1101: second_hex_output = 4'hD;
        4'b1110: second_hex_output = 4'hE;
        4'b1111: second_hex_output = 4'hF;
        default: second_hex_output = 4'hX; // Error case
    endcase
	 
	 assign first_output =  {3'b011, first_hex_output};
	 assign second_output =  {3'b011, second_hex_output};
end

endmodule
