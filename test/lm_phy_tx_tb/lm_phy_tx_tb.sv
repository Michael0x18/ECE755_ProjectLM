`timescale 1ps / 1ps

module lm_phy_tx_tb ();

  initial begin
    $dumpfile("lm_phy_tx_tb.vcd");
    $dumpvars(0, lm_phy_tx_tb);
  end

  wire clk;
  wire rst_n;
  wire [63:0] tx_in;
  wire tx_load;
  wire tx_done;
  wire [3:0] TX;
  wire TX_ACK;
  wire TX0;
  wire TX1;
  wire TX2;
  wire TX3;

  assign TX0=TX[0];
  assign TX1=TX[1];
  assign TX2=TX[2];
  assign TX3=TX[3];

  lm_phy_tx iDUT (
      .clk(clk),
      .rst_n(rst_n),
      .tx_in(tx_in),
      .tx_load(tx_load),
      .tx_done(tx_done),
      .TX(TX),
      .TX_ACK(TX_ACK)
  );
endmodule


