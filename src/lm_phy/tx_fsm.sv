`default_nettype none
//////////////// Notes ////////////////////////
//
///////////Behavior///////////
//tx_fsm controls how the transmit shift regiter behaves; ie, when to send,
//shift out values, how many times to shift out (32 times, 2 bits each, 64
//total)
//
///////// IO Details /////////////
//clk: synchronous clock of the sender side
//
//load_clk (comes from top level): gated clock signal base on digital clock
//(clk) and the load_en signal
//
//rst_n: asynchronous reset signal
//
//load: load signal itself
//
//ack_pulse (comes from top level): acknowledge signal from the rx side saying "hey, i got what you transmitted"
//
//done: output signal saying "hey, i've transmitted all 32 packets"
//
//shift: muxed ack_pulse; if not done with 32 packets, send the ack_pulse, if
//done shifting, send 0
//
//send_data: ???
//
//load_en: flopped load signal

module tx_fsm(
    input wire clk,
    input wire load_clk,
    input wire rst_n,
    input wire load,
    input wire ack_pulse,
    output reg done,
    output wire shift,
    output wire send_data,
    output wire load_en
);

/* 
Comments are going to contain my assumptions/thoughts while writing this.
If anything is wrong, please feel free to change the code and the comment.

Additionally, please document any changes, as any assumptions of mine that
were wrong may also be wrong by others viewing our presentations.
*/

////////////////////
// Wires and Regs //
////////////////////

reg[4:0] counter; // counter for how many bit groups sent (32 groups of 2 bits = 64 bits total)

reg load_flop; // register to hold the load value on clock edge
reg load_edge; // register for holding previous value of load, for edge detection

reg loaded; // register for containing loaded state

/////////////////////////
// Load Edge Detection //
/////////////////////////

always_ff @(posedge clk, negedge rst_n) begin
  if (~rst_n) begin
    load_flop <= 1'b0;
    load_edge <= 1'b0;
  end

  else begin
    load_flop <= load;
    load_edge <= load_flop;
  end
end

// load_en (load clock) is enabled synchronously to clock
assign load_en = load_flop;

// SR latch for 'is loaded' signal. Set on negedge, reset on help low
// Note: sets when load_flop is low AND load_edge was detected; i.e, only at
// a negedge? 
// resets when load_edge is 0
// so... a 1 clock cycle pulse relative to the synchornous clock?
sr load_SR(.S(~load_flop & load_edge), .R(~load_edge), .Q(loaded), .Q_n());

///////////////////
// Shift counter //
///////////////////

wire fsm_clk;

//dictates when the fsm should update/evaluate. only when the load_clk (top
//level) is true OR when an ack_pulse is recieved
assign fsm_clk = load_clk | ack_pulse;

// Counter triggered on ack, reset on load
always_ff @(posedge fsm_clk, negedge rst_n) begin
  // Start-up reset (mostly for simulation)
  if (~rst_n) begin
    counter <= 5'h1F;
    done <= 1'b0;
  end

  // when `load` is set, reset the counter and done state
  else if (load_flop) begin
    counter <= 5'h1F;
    done <= 1'b0;
  end

  // Identical counter and done logic as rx_fsm
  else if (~done) begin
    counter <= counter - 1;
    done <= (counter == 5'h00);
  end

  // Once done is set, it keeps its value until next load (i.e., stops counting)
  else if (done) begin
    done <= 1'b1;
  end
end

/////////////////////////////////////
// Behavioral from 'state machine' //
/////////////////////////////////////

// When the counter isn't finished, send a shift along with the ack pulse
// ASSUMPTION: ack_pulse is pulsed externally (per its name)
assign shift = done ? 1'b0 : ack_pulse;

assign send_data = (loaded | ack_pulse) & ~done;

endmodule
`default_nettype wire
