`default_nettype none
module lm_phy_tx #(
	parameter WIDTH=64
)(
	input wire clk,
	input wire rst_n,
	input wire [WIDTH-1:0] tx_in,
	input wire tx_load,
	output wire tx_done,
	output wire[3:0] TX,
	input wire TX_ACK
);

wire load_clk;
wire load_en; 
wire shift_clk;
wire shift;

wire send_data;

wire ack_pulse;
pulse_generator pgen(.rx(TX_ACK), .clk(clk), .rx_pulse(ack_pulse));

clock_gate_low load_cgate(.clk(clk), .en(load_en), .clk_gated(load_clk));
//clock_gate_low shift_cgate(.clk(clk), .en(shift), .clk_gated(shift_clk));
assign shift_clk=shift;

tx_fsm #(WIDTH) tx_fsm(.clk(clk), .load_clk(load_clk), .rst_n(rst_n), .load(tx_load), .ack_pulse(ack_pulse), .done(tx_done), 
	.shift(shift), .send_data(send_data), .load_en(load_en));

wire[1:0] shift_data;
tx_shift_reg #(WIDTH) shift_reg(.load_clk(load_clk), .rst_n(rst_n), .load_en(load_en), .load_data(tx_in), .shift_clk(shift_clk),
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
