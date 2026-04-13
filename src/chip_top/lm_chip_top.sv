`default_nettype none

/**
 * Top level module to tape out. Instantiates SPI input/output buffers for external communication
 * and connects them to the phy components. Additionally houses test FFs to bring out signals.
 */
module tt_um_lm_chip_top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

////////////////////
// Wires and Regs //
////////////////////

(*DONT_TOUCH*)logic MISO;
(*DONT_TOUCH*)wire MOSI;
(*DONT_TOUCH*)wire SCLK;
(*DONT_TOUCH*)wire CAPTURE;
(*DONT_TOUCH*)
(*DONT_TOUCH*)wire RDY;
(*DONT_TOUCH*)wire VLD;
(*DONT_TOUCH*)wire LOAD;
(*DONT_TOUCH*)wire DONE;
(*DONT_TOUCH*)
(*DONT_TOUCH*)logic [3:0] TX;
(*DONT_TOUCH*)
(*DONT_TOUCH*)wire [3:0] RX;
(*DONT_TOUCH*)
(*DONT_TOUCH*)wire TX_ACK;
(*DONT_TOUCH*)wire RX_ACK;
(*DONT_TOUCH*)
(*DONT_TOUCH*)wire [3:0] DBG_ADDR;
(*DONT_TOUCH*)wire DBG_OUT;

////////////////////////////////////////
// TTSKY130 pins <-> internal signals //
////////////////////////////////////////

assign uo_out[7] = MISO;
assign MOSI = ui_in[7];
assign SCLK = uio_in[6]; assign uio_oe[6] = 1'b0;
assign CAPTURE = uio_in[7]; assign uio_oe[7] = 1'b0;

assign RDY = ui_in[6];
assign uo_out[6] = VLD;
assign LOAD = ui_in[5];
assign uo_out[5] = DONE;

assign uo_out[0] = TX[0];
assign uo_out[1] = TX[1];
assign uo_out[2] = TX[2];
assign uo_out[3] = TX[3];

assign RX[0] = ui_in[0];
assign RX[1] = ui_in[1];
assign RX[2] = ui_in[2];
assign RX[3] = ui_in[3];

assign TX_ACK = ui_in[4];
assign uo_out[4] = RX_ACK;

assign DBG_ADDR = uio_in[3:0]; assign uio_oe[3:0] = 4'b0;
assign uio_out[5] = DBG_OUT; assign uio_oe[5] = 1'b1;

///////////////////////////
// MODULE INSTANSTIATION //
///////////////////////////

///////////// Reset Syncronizer //////////////

wire rst_n_sync;
reset_sync u_rst_sync(.clk(clk), .rst_n_async(rst_n), .rst_n(rst_n_sync));

//////////////// SPI UNIT ////////////////////

wire [15:0] rx_data, tx_data;

(*DONT_TOUCH*)lm_SPI #(16) iSPI (
    .clk(clk),
    .rst_n(rst_n_sync),

    .MOSI_async(MOSI),
    .MISO(MISO),
    .SCLK_async(SCLK),

    .tx_data(tx_data),

    .send_rx(DONE),
    .rx_data(rx_data)
);

////////////////////////////////////////////////


//////////////// DEBUG UNIT ////////////////////
// TODO: DEBUG UNIT
////////////////////////////////////////////////

///////////// UNASSIGNED PORTS /////////////////
// Delete any assign statements here as needed
// This is just required for yosys to complete
////////////////////////////////////////////////

assign uio_out[4:0] = 5'b0;
assign uio_out[7:6] = 2'b0;
assign uio_oe[4] = 1'b0;
assign DBG_OUT = 1'b0;

/////////////////// LM PHY /////////////////////

lm_phy_top #(16) iPHY (
	.clk(clk),
	.rst_n(rst_n_sync),

	// TX chip side interface
	.tx_in(tx_data),
	.tx_load(LOAD),
	.tx_done(DONE),

	// RX chip side interface
	.rx_out(rx_data),
	.rx_vld(VLD),
	.rx_rdy(RDY),

	// TX off chip interface
	.TX(TX),
	.TX_ACK(TX_ACK),
	
	// TX off chip interface
	.RX(RX),
	.RX_ACK(RX_ACK)
);

////////////////////////////////////////////////

endmodule
`default_nettype wire
