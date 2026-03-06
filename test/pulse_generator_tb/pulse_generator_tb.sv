`timescale 1ps/1ps

module pulse_generator_tb();

initial begin
    $dumpfile("pulse_generator_tb.vcd");
    $dumpvars(0, pulse_generator_tb);
    // #1;
end

logic clk;
logic rx;

wire rx_pulse;

pulse_generator pulse_generator(.rx(rx), .clk(clk), .rx_pulse(rx_pulse));


endmodule
