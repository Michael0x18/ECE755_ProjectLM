`timescale 1ps/1ps

module decoder2_4_tb();

initial begin
    $dumpfile("decoder2_4_tb.vcd");
    $dumpvars(0, decoder2_4_tb);
end

wire[1:0] in;
logic[3:0] out;

decoder2_4 decoder2_4(.in(in), .out(out));


endmodule


