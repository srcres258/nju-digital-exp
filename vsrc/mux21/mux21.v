/* 普通建模方式描述2选1选择器 */

// module mux21 (
//     // 声明3个wire型输入变量a,b,s,其宽度为1位。
//     input a,
//     input b,
//     input s,

//     // 声明1个wire型输出变量y,其宽度为1位。
//     output y
// );

//     assign y = (~s & a) | (s & b); // 实现电路的逻辑功能。
    
// endmodule

/* 结构化建模方式描述2选1选择器 */

// // 与门模块
// module my_and (
//     input a,
//     input b,
//     output c
// );
//     assign c = a & b;
// endmodule

// // 或门模块
// module my_or (
//     input a,
//     input b,
//     output c
// );
//     assign c = a | b;
// endmodule

// // 非门模块
// module my_not (
//     input a,
//     output b
// );
//     assign b = ~a;
// endmodule

// // 2选1选择器模块
// module mux21 (
//     input a,
//     input b,
//     input s,
//     output y
// );
//     wire l, r, s_n; // 内部网线声明

//     // 实例化非门，实现~s
//     my_not i1(.a(s), .b(s_n));
//     // 实例化与门，实现(~s & a)
//     my_and i2(.a(s_n), .b(a), .c(l));
//     // 实例化与门，实现(s & b)
//     my_and i3(.a(s), .b(b), .c(r));
//     // 实例化或门，实现(~s & a) | (s & b)
//     my_or i4(.a(l), .b(r), .c(y));
// endmodule

/* 行为建模方式描述2选1选择器 */

// module mux21 (
//     input a,
//     input b,
//     input s,
//     output reg y // y在always块中被赋值，一定要声明为reg型的变量。
// );
//     always @(*) begin
//         if (s) begin
//             y = b;
//         end
//         else begin
//             y = a;
//         end
//     end
// endmodule

/* 使用选择器模板实现2选1选择器 */

`include "mux_key.v"

module mux21 (
    input a,
    input b,
    input s,
    output y
);
    MuxKey #(2, 1, 1) i0 (y, s, {
        1'b0, a,
        1'b1, b
    });
endmodule
