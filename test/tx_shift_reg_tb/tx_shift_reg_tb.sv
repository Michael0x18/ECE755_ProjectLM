`timescale 1ps / 1ps

module tx_shift_reg_tb ();

  initial begin
    $dumpfile("tx_shift_reg_tb.vcd");
    $dumpvars(0, tx_shift_reg_tb);
  end

  wire load_clk;
  wire rst_n;
  wire load_en;
  wire [63:0] load_data;
  wire shift_clk;
  wire [1:0] shift_data;
	wire clk;

  tx_shift_reg iDUT(
		.clk(clk),
    .load_clk(load_clk),
    .rst_n(rst_n),
    .load_en(load_en),
    .load_data(load_data),
    .shift_clk(shift_clk),
    .shift_data(shift_data)
    );



endmodule


