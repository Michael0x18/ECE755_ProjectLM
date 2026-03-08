`default_nettype none
module lm_phy_tx(
	input wire clk,
	input wire rst_n,
	input wire [63:0] tx_in,
	input wire tx_load,
	output wire tx_done,
	output wire[3:0] TX,
	input wire TX_ACK
);

// TODO: Add control FSM

// TODO: Assign these
wire load_clk;
wire load_en; 
wire shift_clk; 
assign load_clk = clk;
assign load_en = tx_load;

wire[1:0] shift_data;
tx_shift_reg shift_reg(.load_clk(load_clk), .rst_n(rst_n), .load_en(load_en), .load_data(tx_in), .shift_clk(shift_clk),
	.shift_data(shift_data));

wire shift_delay;
assign #100ps shift_delay = shift_clk;

wire[3:0] decode_out;
decoder2_4 decoder(.in(shift_data), .out(decode_out));

genvar i;
generate
	for(i = 0; i < 4; i = i + 1) begin
		toggle tgl(.rst_n(rst_n), .pulse(decode_out[i] & shift_delay), .data(TX[i]) );
	end
endgenerate


endmodule
`default_nettype wire
