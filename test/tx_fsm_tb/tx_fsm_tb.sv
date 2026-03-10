`timescale 1ps/1ps

module tx_fsm_tb();

initial begin
    $dumpfile("tx_fsm_tb.vcd");
    $dumpvars(0, tx_fsm_tb);
end

logic clk, load_clk, rst_n, load, ack_pulse, done, shift, send_data, load_en;

tx_fsm tx_fsm(.*);

endmodule