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

logic [3:0] SPI_shift_reg;
logic [1:0] SPI_count;  // Counts 0 -> 3
logic [3:0] next_shift;

// SPI reads in 4 bits at a time (Most Significant Bit read in first)
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


// TODO: Compare sent data to received data

endmodule
`default_nettype wire
