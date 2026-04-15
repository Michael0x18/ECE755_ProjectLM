`timescale 1ps / 1ps

module lm_SPI_tb();
localparam WIDTH = 16;

  initial begin
    $dumpfile("lm_SPI_tb.vcd");
    $dumpvars(0, lm_SPI_tb);
  end

  wire clk;
  wire rst_n;
  wire [WIDTH-1:0] tx_data, rx_data;
  wire MOSI_async, MISO, SCLK_async, rx_capture;

lm_SPI #(WIDTH) iDUT (
  .clk,
  .rst_n,
  .MOSI_async,
  .MISO,
  .SCLK_async,
  .tx_data,
  .rx_capture,
  .rx_data
);

endmodule


