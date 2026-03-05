`default_nettype none
module lm_phy_rx(
	input wire clk,
	input wire rst_n,
	input wire [63:0] rx_out,
	input wire rx_rdy,
	output wire rx_vld,
	output wire[3:0] RX,
	input wire RX_ACK
);

wire[3:0] rx_pulse;
wire rx_shift_nodelay;
wire rx_shift;

pulse_generator rxp(.rx(RX), .clk({4{clk}}), .rx_pulse(rx_pulse);

assign rx_shift_nodelay = |rx_pulse;
assign #25ns rx_shift = rx_shift_nodelay;

endmodule
`default_nettype wire
