`default_nettype none
module pulse_generator
(
    input wire rx,
    input wire delay,
    output wire rx_pulse
);

assign rx_pulse = rx ^ delay;

endmodule
`default_nettype wire