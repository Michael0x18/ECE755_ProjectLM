`default_nettype none

/**
 * Top level module to tape out. Instantiates SPI input/output buffers for external communication
 * and connects them to the phy components. Additionally houses test FFs to bring out signals.
 */

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

////////////////////
// Wires and Regs //
////////////////////

logic MISO;
wire MOSI;
wire SCLK;
wire CAPTURE;

wire RDY;
wire VLD;
wire LOAD;
wire DONE;

logic TX0;
logic TX1;
logic TX2;
logic TX3;

wire RX0;
wire RX1;
wire RX2;
wire RX3;

wire TX_ACK;
wire RX_ACK;


wire [3:0] DBG_ADDR;
wire DBG_OUT;

////////////////////////////////////////
// TTSKY130 pins <-> internal signals //
////////////////////////////////////////

assign uo_out[5] = MISO;
assign MOSI = ui_in[7];
assign SCLK = uio_in[6]; assign uio_oe[6] = 1'b0;
assign CAPTURE = uio_in[7]; assign uio_oe[7] = 1'b0;

assign RDY = ui_in[6];
assign uo_out[6] = VLD;
assign LOAD = ui_in[5];
assign uo_out[5] = DONE;

assign uo_out[0] = TX0;
assign uo_out[1] = TX1;
assign uo_out[2] = TX2;
assign uo_out[3] = TX3;

assign RX0 = ui_in[0];
assign RX1 = ui_in[1];
assign RX2 = ui_in[2];
assign RX3 = ui_in[3];

assign TX_ACK = ui_in[4];
assign uo_out[4] = RX_ACK;

assign DBG_ADDR = uio_in[3:0]; assign uio_oe[3:0] = 4'b0;
assign uio_out[5] = DBG_OUT; assign uio_oe[5] = 1'b1;

///////////////////////////
// MODULE INSTANSTIATION //
///////////////////////////


//////////////// SPI UNIT ////////////////////

// Read In: SPI reads in 4 bits at a time (Most Significant Bit read in first)
logic [3:0] SPI_shift_reg;
logic [1:0] SPI_count;  // Counts 0 -> 3
logic [3:0] next_shift;
logic [3:0] tx_in;
assign tx_in = {TX3, TX2, TX1, TX0};

always_comb begin
    next_shift = {SPI_shift_reg[2:0], MOSI};
end
always_ff @(posedge SCLK) begin
    SPI_shift_reg <= next_shift;

    if (SPI_count == 2'd3) begin
        SPI_count <= 0;
        
        // Load SPI_shift_reg into TX after 4 bits recieved
        // Use next_shift so don't have to wait one clk for SPI_shift_reg
        // MSB first (MSB:LSB)
        TX3 <= next_shift[3]; // MSB
        TX2 <= next_shift[2];
        TX1 <= next_shift[1];
        TX0 <= next_shift[0];  // LSB
        
    end else begin
        SPI_count <= SPI_count + 1;
    end
end


// Write out: SPI reads out 4 bits at a time (Most Significant Bit read out first)
logic [3:0] SPI_shift_out_reg;

always_ff @(negedge SCLK) begin
    // Load into shift register when data is valid
    if (VLD) begin
        SPI_shift_out_reg <= {RX3, RX2, RX1, RX0}; // MSB: LSB
    
    // Shift at next clk cycle
    end else begin
        MISO <= SPI_shift_out_reg[3];
        SPI_shift_out_reg <= {SPI_shift_out_reg[2:0], 0};
    end

end
////////////////////////////////////////////////


//////////////// Debug UNIT ////////////////////
// TODO: DEBUG UNIT
////////////////////////////////////////////////

lm_phy_top iPHY #(WIDTH=16) (
	.clk(clk),
	.rst_n_async(rst_n),

	// TX chip side interface
	.tx_in(tx_in),
	.tx_load(LOAD),
	.tx_done(DONE),

	// RX chip side interface
	.rx_out(/* TODO : SPI CONNECTION */),
	.rx_vld(VLD),
	.rx_rdy(RDY),

	// TX off chip interface
	.TX(TX),
	.TX_ACK(TX_ACK),
	
	// TX off chip interface
	.RX(RX),
	.RX_ACK(RX_ACK)
    );

endmodule
`default_nettype wire
