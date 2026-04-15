`timescale 1ps / 1ps

module tx_shift_reg_tb ();
  reg clk;

  initial begin
    clk = 1'b0;
    $dumpfile("tx_shift_reg_tb.vcd");
    $dumpvars(0, tx_shift_reg_tb);
  end

  wire rst_n;
  wire load_en;
  wire [63:0] load_data;
  wire shift_clk;
  wire [1:0] shift_data;
  wire load_clk_gated;

  tx_shift_reg iDUT(
    .load_clk_gated(load_clk_gated),
    .rst_n(rst_n),
    .load_en(load_en),
    .load_data(load_data),
    .shift_clk(shift_clk),
    .shift_data(shift_data)
    );

  //always #2ps clk = ~clk;

endmodule


