`timescale 1ps/1ps

module pulse_generator_tb();
reg clk;

initial begin
		clk = 0;
    $dumpfile("pulse_generator_tb.vcd");
    $dumpvars(0, pulse_generator_tb);
end

logic rx;

wire rx_pulse;

pulse_generator pulse_generator(.rx(rx), .rx_pulse(rx_pulse));


endmodule
