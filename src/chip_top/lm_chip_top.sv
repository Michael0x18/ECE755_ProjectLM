`default_nettype none
module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

wire MOSI;
wire SCLK;
wire MISO;
wire CAPTURE;
wire RDY;
wire VLD;
wire LOAD;
wire DONE;

wire TX0;
wire TX1;
wire TX2;
wire TX3;

wire RX0;
wire RX1;
wire RX2;
wire RX3;

wire TX_ACK;
wire RX_ACK;

endmodule
`default_nettype wire
