module bin_to_hex_ascii (
    input [3:0] binary,
    output reg [7:0] hex_ascii
);

always @(*) begin
    case(binary)
        4'b0000: hex_ascii = 8'h30; // '0' in ASCII
        4'b0001: hex_ascii = 8'h31; // '1' in ASCII
        4'b0010: hex_ascii = 8'h32; // '2' in ASCII
        4'b0011: hex_ascii = 8'h33; // '3' in ASCII
        4'b0100: hex_ascii = 8'h34; // '4' in ASCII
        4'b0101: hex_ascii = 8'h35; // '5' in ASCII
        4'b0110: hex_ascii = 8'h36; // '6' in ASCII
        4'b0111: hex_ascii = 8'h37; // '7' in ASCII
        4'b1000: hex_ascii = 8'h38; // '8' in ASCII
        4'b1001: hex_ascii = 8'h39; // '9' in ASCII
        4'b1010: hex_ascii = 8'h41; // 'A' in ASCII
        4'b1011: hex_ascii = 8'h42; // 'B' in ASCII
        4'b1100: hex_ascii = 8'h43; // 'C' in ASCII
        4'b1101: hex_ascii = 8'h44; // 'D' in ASCII
        4'b1110: hex_ascii = 8'h45; // 'E' in ASCII
        4'b1111: hex_ascii = 8'h46; // 'F' in ASCII
        default: hex_ascii = 8'h2D; // '-' in ASCII for invalid input
    endcase
end

endmodule
