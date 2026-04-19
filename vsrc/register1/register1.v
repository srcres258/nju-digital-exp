/* 1位寄存器 */

module register1 (
    input load, // 加载
    input clk, // 时钟
    input clr, // 清除
    input inp, // 输入
    output reg q // 输出
);
    always @(posedge clk) begin
        if (clr) begin
            q <= 0;
        end
        else if (load) begin
            q <= inp;
        end
    end
endmodule
