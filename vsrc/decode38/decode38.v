/* verilator lint_off WIDTHEXPAND */

/* 3-8译码器 */

module decode38 (
    input [2:0] x,
    input en,
    output reg [7:0] y
);
    integer i;

    always @(x or en) begin
        if (en) begin
            // 利用一个for循环语句来实现3-8译码器
            for (i = 0; i <= 7; i = i + 1) begin
                if (x == i) begin
                    y[i] = 1;
                end
                else begin
                    y[i] = 0;
                end
            end
        end
        else begin
            y = 8'b00000000;
        end
    end
endmodule
