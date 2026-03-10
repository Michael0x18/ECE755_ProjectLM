`default_nettype none
module lm_phy_rx(
	input wire clk,
	input wire rst_n,
	input wire [63:0] rx_out,
	input wire rx_rdy,
	output wire rx_vld,
	input wire[3:0] RX,
	input wire RX_ACK
);

wire[3:0] rx_pulse;
wire rx_shift_nodelay;
wire rx_shift;

wire[3:0] _Q_n;
wire[3:0] Q;
wire[3:0] S;
wire[3:0] R;

genvar i;
generate
	for(i = 0; i < 4; ++i) begin
		pulse_generator rxp(.rx(RX[i]), .clk(clk), .rx_pulse(rx_pulse[i]));
		sr srl(.S(S[i]), .R(R[i]), .Q(Q[i]), .Q_n(_Q_n[i]));
	end
endgenerate

assign R = rx_pulse;
assign S[0] = R[1]|R[2]|R[3];
assign S[1] = R[0]|R[2]|R[3];
assign S[2] = R[0]|R[1]|R[3];
assign S[3] = R[0]|R[1]|R[2];


assign rx_shift_nodelay = |rx_pulse;
assign #500ps rx_shift = rx_shift_nodelay;

endmodule
`default_nettype wire
