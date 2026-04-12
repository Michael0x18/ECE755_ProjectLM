`default_nettype none
//TODO: add some delay lol so it doesn't
module sr(input wire S, input wire R, output reg Q, output reg Q_n);
    // nor #(1ps)n1(Q, R, Q_n);
    // nor #(1ps)n2(Q_n, S, Q);
		always @(S, R) begin
			if (R) begin
				Q <= 1'b0;
				Q_n <= 1'b1;
			end else if (S) begin
				Q <= 1'b1;
				Q_n <= 1'b0;
			end
		end
//             ___
// S ----------\  \           _
//              )  )o------+--Q
//          ---/__/       /
//          |______      /
//            _____\____/
//           /      \
//          /  ___   \
//         ----\  \   \
//              )  )o--+------Q
// R ----------/__/       
//
endmodule
`default_nettype wire
