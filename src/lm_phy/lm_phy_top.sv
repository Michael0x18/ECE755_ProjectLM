`default_nettype none
module lm_phy_top(
	input wire clk,
	input wire rst_n_async,

	// TX chip side interface
	input wire[63:0] tx_in,
	input wire tx_load,
	output wire tx_done,

	// RX chip side interface
	output wire[63:0] rx_out,
	output wire rx_vld,
	input wire rx_rdy,

	// TX off chip interface
	output wire[3:0] TX,
	input wire TX_ACK,
	
	// TX off chip interface
	input wire[3:0] RX,
	output wire RX_ACK
);
	
	wire rst_n;
	reset_sync u_rst_sync(.clk(clk), .rst_n_async(rst_n_async), .rst_n(rst_n));

	lm_phy_tx u_lm_phy_tx(.clk(clk), .rst_n(rst_n), .TX(TX), .TX_ACK(TX_ACK), .tx_in(tx_in), .tx_load(tx_load), .tx_done(tx_done));
	lm_phy_rx u_lm_phy_rx(.clk(clk), .rst_n(rst_n), .RX(RX), .RX_ACK(RX_ACK), .rx_out(rx_out), .rx_vld(rx_vld), .rx_rdy(rx_rdy));

endmodule
`default_nettype wire
