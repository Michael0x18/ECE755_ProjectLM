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
module rx_fsm #(WIDTH=64) (
    input  wire clk,
    input  wire rst_n,
    input  wire rdy,
    output reg  vld,
    input  wire rx_pulse,
    output wire ack_toggle
);

  wire clr_vld;
  reg [$clog2(WIDTH):0] counter;
  wire data_done;
  wire rdy_pulse;
  reg rdy_delay;

  //ERROR: when rdy_pulse is sent, causes block to evaluate. 
  //rst_n is not true, hence causes it to decrement EVEN THOUGH 
  //a signal has not been recieved. 
  //solution: replace reset conditin with ~clr_vld?
  always @(posedge rx_pulse, negedge clr_vld) begin
    if (~clr_vld) begin
      counter <= WIDTH;
      vld <= 1'b0;
    end else begin
      counter <= counter - 1;
      vld <= (counter == 5'h1);
    end
  end

  reg[1:0] rdy_ff;
  // Flop rdy
  always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
      rdy_ff <= 2'b0;
    end else begin
      rdy_ff <= {rdy_ff[0], rdy};
    end
  end
  wire rdy_posedge;
  assign rdy_posedge = (rdy_ff[0] & ~rdy_ff[1]);
  pos_pulse_generator rdy_pulse_gen(.rx(rdy_posedge), .rx_pulse(rdy_pulse));

  assign ack_toggle = (vld||counter==WIDTH) ? rdy_pulse : rx_pulse;

  assign clr_vld = rst_n & ~rdy_pulse;

endmodule
`default_nettype wire
