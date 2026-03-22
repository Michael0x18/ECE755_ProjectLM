//NOTE: upon reset (either via rst_n or clr_vld), vld is set to 0.  
//after this, ack_toggle is ONLY sent via rx_pulse. 
//clr_vld s asserted on a rdy_pulse from synchronous circuit
//ignores rdy_pulse in that case. 
//
//NOTE: ready is a handshake signal paired with valid
//- turn it on
//- able to accept data
//- ready is a **clear valid signal**
//**RX will always come out of the reset condition BEFORE TX**
//the initial ack pulse is wrong lol
//
//To indicate to the TX side that "hey, im listening", 
//TODO: add parameterization to change bit width
`default_nettype none
module rx_fsm (
    input  wire clk,
    input  wire rst_n,
    input  wire rdy,
    output reg  vld,
    input  wire rx_pulse,
    output wire ack_toggle
);

  wire clr_vld;
  reg [4:0] counter;
  wire data_done;
  wire rdy_pulse;
  reg rdy_delay;

  //ERROR: when rdy_pulse is sent, causes block to evaluate. 
  //rst_n is not true, hence causes it to decrement EVEN THOUGH 
  //a signal has not been recieved. 
  //solution: replace reset conditin with ~clr_vld?
  always @(posedge rx_pulse, negedge clr_vld) begin
    if (~clr_vld) begin
      counter <= 5'h10;
      vld <= 1'b0;
    end else begin
      counter <= counter - 1;
      vld <= (counter == 5'h1);
    end
  end

  //maybe send a fixed-time pulse on the negative edge of rdy_pulse? 
  //1) rdy is asserted
  //2) generates a fixed-length pulse (rdy_pulse). 
  //3) at the negedge of rdy_pulse, *then* send out the actual one?
  reg rdy_pulse_delay;
  always@(rdy_pulse)
    rdy_pulse_delay<=#10ps rdy_pulse;


  // TODO replace this with standard cell components
  // TODO; replace this with a delay line
  //assign #100ps rdy_delay = rdy;
  always @(rdy, negedge rst_n) begin
    if (~rst_n) rdy_delay <= 1'b0;
    else rdy_delay <= #10ps rdy;
  end
  assign rdy_pulse = (rdy & ~rdy_delay);
  //NOTE: causes an error if rx_pulse arrives too EARLY
  //i.e, while rdy_pulse s still high, rx_pulse arrives, causing rdy_pulse to
  //be one continuous pulse instead of 2; misses transmission, STALLS!
  //assume that rx_pulse WILL arrive ONLY after rdy_pulse de-asserts? 

  assign ack_toggle = (vld||counter==5'h10) ? rdy_pulse_delay : rx_pulse;

  assign clr_vld = rst_n & ~rdy_pulse;

endmodule
`default_nettype wire
