module clock #(parameter D = 32'd25000000) (cin,cout);

input cin;
output reg cout;
reg[31:0] count;
always @(posedge cin) begin
	count <= count + 32'd1;
	if (count >= (D-1)) begin
		cout <= ~cout;
		count <= 32'd0;
end
end
endmodule 