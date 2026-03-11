`default_nettype none
module rx_shift_reg #(parameter WIDTH = 64) (
    input wire shift_clk,
    input wire rst_n,
    input wire[1:0] shift_data,
    output reg[WIDTH-1:0] rx_out
);

always @(posedge shift_clk, negedge rst_n) begin
    if(~rst_n) begin
        rx_out <= '0;
    end else begin
        rx_out <= {shift_data, rx_out[WIDTH-1:2]};
    end
end

endmodule
`default_nettype wire
