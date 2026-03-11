`default_nettype none
module lm_phy_rx #(
	parameter WIDTH=64
)(
	input wire clk,
	input wire rst_n,
	input wire [63:0] rx_out,
	input wire rx_rdy,
	output wire rx_vld,
	input wire[3:0] RX,
	output reg RX_ACK
);

wire[3:0] rx_pulse;
wire rx_shift_nodelay;
wire rx_shift;

wire[3:0] _Q_n;
wire[3:0] Q;
wire[3:0] S;
wire[3:0] R;

wire ack_toggle;

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

rx_fsm fsm(.clk(clk), .rst_n(rst_n), .rdy(rx_rdy), .vld(rx_vld), .rx_pulse(rx_shift), .ack_toggle(ack_toggle));

always @(posedge ack_toggle, negedge rst_n) begin
	if(~rst_n) begin
		RX_ACK <= 1'b0;
	end else begin
		RX_ACK <= ~RX_ACK;
	end
end

endmodule
`default_nettype wire
