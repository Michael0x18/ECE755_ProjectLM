`default_nettype none
//TODO: add some delay lol so it doesn't
module sr(input wire S, input wire R, output wire Q, output wire Q_n);
    nor #(1ps,1ps)n1(Q, R, Q_n);
    nor #(1ps,1ps)n2(Q_n, S, Q);
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
