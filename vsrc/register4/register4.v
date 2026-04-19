/* 4位寄存器 */

module register4 (
    input load, // 加载
    input clr, // 清零
    input clk, // 时钟
    input [3:0] d, // 数据输入
    output reg [3:0] q // 数据输出
);
    always @(posedge clk) begin
        if (clr) begin
            q <= 0;
        end
        else if (load) begin
            q <= d;
        end
    end
endmodule
