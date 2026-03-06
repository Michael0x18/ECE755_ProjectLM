`default_nettype none
module rx_shift_reg(
    input wire shift_clk,
    input wire rst_n,
    input wire[1:0] shift_data,
    output reg[63:0] rx_out
);

always @(posedge shift_clk, negedge rst_n) begin
    if(~rst_n) begin
        rx_out <= 64'h0;
    end else begin
        rx_out <= {shift_data, rx_out[63:2]};
    end
end

endmodule
`default_nettype wire
