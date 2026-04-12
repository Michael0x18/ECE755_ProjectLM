`default_nettype none
module clock_gate_low(
    input wire clk,
    input wire en,
    output wire clk_gated
);
reg q_L;
// Infer latch
// should use integrated clock gate from std cel library
always_latch begin
    if(~clk) begin
        q_L = en;
    end
end

assign clk_gated = clk & q_L;

endmodule
`default_nettype wire
