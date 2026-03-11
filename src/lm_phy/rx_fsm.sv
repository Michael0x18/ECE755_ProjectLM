`default_nettype none
module rx_fsm(
    input wire clk,
    input wire rst_n,
    input wire rdy,
    output reg vld,
    input wire rx_pulse,
    output wire ack_toggle
);

wire clr_vld;
reg[4:0] counter;
wire data_done;
wire rdy_pulse;
wire rdy_delay;

always @(posedge rx_pulse, negedge clr_vld) begin
    if(~rst_n) begin
        counter <= 5'h10;
        vld <= 1'b0;
    end else begin
        counter <= counter - 1;
        vld <= (counter == 5'h1);
    end
end


// TODO replace this with standard cell components
assign #100ps rdy_delay = rdy;
assign rdy_pulse = (rdy & ~rdy_delay);

assign ack_toggle = vld ? rdy_pulse : rx_pulse;

assign clr_vld = rst_n & ~rdy_pulse;

endmodule
`default_nettype wire
