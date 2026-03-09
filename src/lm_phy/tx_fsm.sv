`default_nettype none

module tx_fsm(
    input wire clk,
    input wire rst_n,
    input wire load,
    input wire ack_pulse,
    output reg done,
    output wire shift,
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

reg[5:0] counter; // counter for how many bit groups sent (32 groups of 2 bits = 64 bits total)

///////////////////
// Shift counter //
///////////////////

// Counter triggered on ack, reset on load
always_ff @(posedge ack_pulse, posedge load) begin
  // Start-up reset (mostly for simulation)
  if (~rst_n) begin
    counter <= 5'h1F;
    done <= 1'b0;
  end

  // when `load` is set counter is reset
  else if (load) begin
    counter <= 5'h1F;
    done <= 1'b0;
  end

  // Identical counter and done logic as rx_fsm
  else if (~done) begin
    counter <= counter - 1;
    done <= (counter == 5'h01);
  end

  // Once done is set, it keeps its value until next load (i.e., stops counting)
  else begin
    done <= 1'b1;
  end
end

/////////////////////////////////////
// Behavioral from 'state machine' //
/////////////////////////////////////

// When `load` is set, load_en is enabled so FIFO can parallel load
// ASSUMPTION: load is pulsed or set then reset externally
assign load_en = load;

// When the counter isn't finished, send a shift along with the ack pulse
// ASSUMPTION: ack_pulse is pulsed externally (per its name)
assign shift = done ? 1'b0 : ack_pulse;


endmodule

`default_nettype wire
