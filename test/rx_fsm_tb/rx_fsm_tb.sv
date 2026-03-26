`timescale 1ps / 1ps


module rx_fsm_tb();

  logic clk;
  logic rst_n;
  logic rdy;
  logic vld;
  logic rx_pulse;
  logic ack_toggle;

  rx_fsm iDUT (
      .clk(clk),
      .rst_n(rst_n),
      .rdy(rdy),
      .vld(vld),
      .rx_pulse(rx_pulse),
      .ack_toggle(ack_toggle)
  );

initial begin
  $dumpfile("rx_fsm_tb.vcd");
  $dumpvars(0, rx_fsm_tb);
end
endmodule
