`timescale 1ps / 1ps

//recall that the lm_phy_top works as follows
///////INPUTS//////////
//clk: clock signal from the tx side(?)
//rst_n_async: asynchronous reset signal
//tx_in[63:0]: input to the transmit module
//tx_load: enable signal to tell the transmit module "hey, accept this shit"
//rx_rdy: telling the module "hey, im ready to recieve"
///////OUTPUTS//////////
module lm_phy_top_tb ();
localparam WIDTH=16;

  initial begin
    $dumpfile("lm_phy_top_tb.vcd");
    $dumpvars(0, lm_phy_top_tb);
  end
  wire clk;
  wire rst_n;

  // TX chip side interface
  wire [WIDTH-1:0] tx_in;
  wire tx_load;
  wire tx_done;

  // RX chip side interface
  wire [WIDTH-1:0] rx_out;
  wire rx_vld;
  wire rx_rdy;

  // TX off chip interface
  wire [3:0] TX;
  wire TX_ACK;

  // TX off chip interface


  //assume TB uses a width of 16. parameterize later
  lm_phy_top #(WIDTH) iDUT (
      .clk(clk),
      .rst_n(rst_n),
      .tx_in(tx_in),
      .tx_load(tx_load),
      .tx_done(tx_done),
      .rx_out(rx_out),
      .rx_vld(rx_vld),
      .rx_rdy(rx_rdy),
      .TX(TX),
      .TX_ACK(TX_ACK),
      .RX(TX),
      .RX_ACK(TX_ACK)
  );
endmodule


