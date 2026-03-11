`default_nettype none
module pulse_generator
(
    input wire rx,
    output wire rx_pulse
);

wire delay;
assign #100ps delay = rx;
assign rx_pulse = rx ^ delay;

endmodule
`default_nettype wire
