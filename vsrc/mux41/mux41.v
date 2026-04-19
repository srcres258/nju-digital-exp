/* 使用case语句实现4选1选择器 */

// module mux41 (
//     input [3:0] a,
//     input [1:0] s,
//     output reg y
// );
//     always @(s or a) begin
//         case (s)
//             0: y = a[0];
//             1: y = a[1];
//             2: y = a[2];
//             3: y = a[3];
//             default: y = 1'b0;
//         endcase
//     end
// endmodule

/* 使用选择器模板实现4选1选择器 */

`include "mux_key.v" // 选择器模板

module mux41 (
    input [3:0] a,
    input [1:0] s,
    output y
);
    MuxKeyWithDefault #(4, 2, 1) i0 (y, s, 1'b0, {
        2'b00, a[0],
        2'b01, a[1],
        2'b10, a[2],
        2'b11, a[3]
    });
endmodule
