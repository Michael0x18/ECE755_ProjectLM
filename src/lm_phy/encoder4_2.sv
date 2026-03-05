`default_nettype none
module encoder 4_2(
	input wire[3:0] in,
	output wire[1:0] out
);
// Not glitchless - this is ok on this path
always_comb begin
	unique case (in) begin
		4'b0001: out = 2'h0;
		4'b0010: out = 2'h1;
		4'b0100: out = 2'h2;
		4'b1000: out = 2'h3;
	end
end
endmodule
`default_nettype wire
