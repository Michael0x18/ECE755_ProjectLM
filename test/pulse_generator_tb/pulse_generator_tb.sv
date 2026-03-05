`timescale 1ps/1ps

module pulse_generator_tb();

initial begin
    $dumpfile("pulse_generator_tb.fst");
    $dumpvars(0, pulse_generator_tb);
    #1;
end

logic clk;
logic rx;

logic delay;

wire rx_pulse;

assign #(5ps) delay = rx;

pulse_generator pulse_generator(.rx(rx), .delay(delay), .rx_pulse(rx_pulse), .clk);

endmodule
