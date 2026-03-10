`default_nettype none
module tx_shift_reg (
    input wire load_clk,
    input wire rst_n,
    input wire load_en,
    input wire [63:0] load_data,
    input wire shift_clk,
    output wire [1:0] shift_data
);

  wire load_clk_gated;

  clock_gate_low cgate (
      .clk(load_clk),
      .en(load_en),
      .clk_gated(load_clk_gated)
  );

  wire reg_clk;
  assign reg_clk = load_clk_gated | shift_clk;


  reg [63:0] data;
  assign shift_data = data[1:0];
  always @(posedge reg_clk, negedge rst_n) begin
    if (~rst_n) begin
      data <= 64'h0;
    end else if (load_en) begin
      // Load parallel
      data <= load_data;
    end else begin
      data <= {2'b0, data[63:2]};
    end
  end

endmodule
`default_nettype wire
