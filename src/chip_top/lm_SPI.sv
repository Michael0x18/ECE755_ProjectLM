`default_nettype none

module lm_SPI #(parameter WIDTH = 64) (
  // clock and active low reset
  input wire clk,
  input wire rst_n,

  // Standard SPI signals
  input wire MOSI_async,
  output reg MISO,
  input wire SCLK_async,

  // TX related signals
  output reg [WIDTH-1:0] tx_data,   // Holds tx_data to be sent to lm_TOP

  // RX related signals
  input wire rx_capture,            // Asserted by lm_TOP to initiate MISO line
  input wire [WIDTH-1:0] rx_data    // Holds rx_data to be sent out of board
);

reg SCLK_flop, SCLK, SCLK_ff;
reg MOSI_flop, MOSI;

always @(posedge clk, negedge rst_n) begin
  if (~rst_n) begin
    SCLK_flop <= 1'b0;
    SCLK <= 1'b0;
    SCLK_ff <= 1'b0;

    MOSI_flop <= 1'b0;
    MOSI <= 1'b0;
  end else begin
    SCLK_flop <= SCLK_async;
    SCLK <= SCLK_flop;
    SCLK_ff <= SCLK;

    MOSI_flop <= MOSI_async;
    MOSI <= MOSI_flop;
  end
end

wire SCLK_edge;

assign SCLK_edge = SCLK ^ SCLK_ff;

typedef enum logic { IDLE, WORKING } state_t;

/////////////////////
// TX buffer logic //
/////////////////////

state_t tx_state, tx_nxt_state;

always @(posedge clk, negedge rst_n) begin
  if (~rst_n) begin
    tx_state <= IDLE;
  end
  else begin
    tx_state <= tx_nxt_state;
  end
end

wire tx_full;
reg tx_shift;
reg [$clog2(WIDTH):0] tx_bit_cnt;

always @* begin
  tx_nxt_state = tx_state;
  tx_shift = 1'b0;

  case (tx_state)
    IDLE : begin
      if (SCLK_edge) tx_nxt_state = WORKING;
    end
    WORKING : begin
			tx_shift = 1'b1;
			if (SCLK_edge) tx_nxt_state = IDLE;
    end
  endcase
end

always @(posedge clk, negedge rst_n) begin
  if (~rst_n) begin
		tx_bit_cnt <= '0;
    tx_data <= '0;
  end
  else if (SCLK_edge & tx_shift) begin
		if (tx_full) tx_bit_cnt <= '0;
		else begin
			tx_data <= {MOSI, tx_data[WIDTH-1:1]};
			tx_bit_cnt <= tx_bit_cnt + 1;
		end
  end
end

assign tx_full = (tx_bit_cnt == WIDTH);


/////////////////////
// RX buffer logic //
/////////////////////

state_t rx_state, rx_nxt_state;

reg [WIDTH-1:0] rx_buf;

always @(posedge clk, negedge rst_n) begin
  if (~rst_n) begin
    rx_state <= IDLE;
  end
  else begin
    rx_state <= rx_nxt_state;
  end
end

wire rx_empty;
reg rx_shift;
reg [$clog2(WIDTH):0] rx_bit_cnt;

always @* begin
  rx_nxt_state = rx_state;
  rx_shift = 1'b0;

  case (rx_state)
    IDLE : begin
			if (SCLK_edge) begin 
				rx_shift = 1'b1;
				rx_nxt_state = WORKING;
			end
    end
    WORKING : begin
			if (SCLK_edge) rx_nxt_state = IDLE;
    end
  endcase
end

always @(posedge clk, negedge rst_n) begin
  if (~rst_n) begin
		rx_buf <= '0;
		rx_bit_cnt <= '0;
		MISO <= '0;
  end
	else if (rx_capture) begin
		rx_buf <= rx_data;
	end
  else if (SCLK_edge & rx_shift) begin
		if (rx_empty) rx_bit_cnt <= '0;
		else begin
			MISO <= rx_buf[0];
    	rx_buf <= {1'b0, rx_buf[WIDTH-1:1]};
			rx_bit_cnt <= rx_bit_cnt + 1;
		end
  end
end

assign rx_empty = (rx_bit_cnt == WIDTH);

endmodule

`default_nettype wire
