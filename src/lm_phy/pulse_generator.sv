`default_nettype none
module pulse_generator
(
    input wire rx,
    output wire rx_pulse
);

reg delay;
buf #(100ps, 100ps) buffer(delay, rx);

assign rx_pulse = rx ^ delay;

endmodule
`default_nettype wire
