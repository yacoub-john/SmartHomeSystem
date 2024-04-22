module reverse_order #(
    parameter BIT_WIDTH = 28
)(
    input [BIT_WIDTH-1:0] input_data,
    output reg [BIT_WIDTH-1:0] output_data
);

    always @(*) begin
        integer i;
        output_data = 0; // Initialize output_data to 0

        for (i = 0; i < BIT_WIDTH; i = i + 1) begin
            output_data = output_data | (input_data[i] << (BIT_WIDTH - 1 - i)); // Reverse the order of bits
        end
    end

endmodule