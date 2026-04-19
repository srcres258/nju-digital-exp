`include "mux_key.v"

module mux41_practice (
    input [1:0] x0, // 输入x0
    input [1:0] x1, // 输入x1
    input [1:0] x2, // 输入x2
    input [1:0] x3, // 输入x3
    input [1:0] y, // 控制端y
    output [1:0] f // 输出f
);
    MuxKeyWithDefault #(4, 2, 2) i0 (f, y, 2'b00, {
        2'b00, x0,
        2'b01, x1,
        2'b10, x2,
        2'b11, x3
    });
endmodule
