/*
实验验收内容
上板实验: 实现一个带有逻辑运算的简单ALU
设计一个能实现如下功能的4位带符号位的 补码 ALU
*/

module alu4 (
    input [2:0] func, // 功能选择
    input [3:0] a, // 输入A（已转化为补码）
    input [3:0] b, // 输入B（已转化为补码）
    output reg [3:0] y // 输出
);
    reg [3:0] b_comp;

    always @(func or a or b) begin
        case (func)
            3'b000: begin
                // 加法
                // A+B

                y = a + b;
            end

            3'b001: begin
                // 减法cd
                // A-B

                y = a - b;
            end

            3'b010: begin
                // 对A取反
                // Not A

                y = ~a;
            end

            3'b011: begin
                // 与
                // A and B

                y = a & b;
            end

            3'b100: begin
                // 或
                // A or B

                y = a | b;
            end

            3'b101: begin
                // 异或
                // A xor B

                y = a ^ b;
            end

            3'b110: begin
                // 比较大小
                // If A<B then out=1; else out=0;

                y = ($signed(a) < $signed(b)) ? 1 : 0;
            end

            3'b111: begin
                // 判断相等
                // If A==B then out=1; else out=0;

                y = (a == b) ? 1 : 0;
            end

            default: y = 4'b0000; // 默认输出0
        endcase
    end
endmodule
