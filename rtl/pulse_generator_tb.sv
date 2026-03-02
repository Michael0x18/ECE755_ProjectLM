`timescale 1ps/1ps
module tb_pulse_generator();

reg rx;
wire delay;
wire rx_pulse;
assign #(5ps) delay = rx;

pulse_generator pulse_generator(.rx(rx), .delay(delay), .rx_pulse(rx_pulse));

initial begin;
    rx = 0;
    #(20ps);

    rx = 1;
    #(20ps);

    rx = 0;
    #(20ps);

    rx = 1;
    #(20ps);

    $stop;

end


endmodule