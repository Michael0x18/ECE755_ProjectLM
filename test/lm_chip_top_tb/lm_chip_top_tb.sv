module lm_chip_top_tb();

initial begin
  $dumpfile("lm_chip_top_tb.vcd");
  $dumpvars(0, lm_chip_top_tb);
end

logic clk;
logic rst_n;

logic MISO;
logic MOSI;
logic SCLK;
logic CAPTURE;

logic RDY;
logic VLD;
logic LOAD;
logic DONE;

logic TX0;
logic TX1;
logic TX2;
logic TX3;
logic RX0;
logic RX1;
logic RX2;
logic RX3;

logic TX_ACK;
logic RX_ACK;

logic [3:0] DBG_ADDR;
logic DBG_OUT;

logic [7:0] uio_out;
logic [7:0] uio_oe;

assign DBG_OUT = uio_out[5];

tt_um_lm_chip_top iDUT (
    .ui_in({MOSI, RDY, LOAD, TX_ACK, RX3,RX2,RX1,RX0}),    // Dedicated inputs
    .uo_out({MISO, VLD, DONE, RX_ACK, TX3,TX2,TX1,TX0}),   // Dedicated outputs
    .uio_in({CAPTURE, SCLK, 1'b0, 1'b0, DBG_ADDR}),   // IOs: Input path
    .uio_out(uio_out),  // IOs: Output path
    .uio_oe(uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
    .ena(1'b1),      // always 1 when the design is powered, so you can ignore it
    .clk(clk),      // clock
    .rst_n(rst_n)     // reset_n - low to reset
);

endmodule
