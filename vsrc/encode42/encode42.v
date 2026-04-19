/* 4-2编码器（匹配模式） */

// module encode42 (
//     input [3:0] x,
//     input en,
//     output reg [1:0] y
// );
//     always @(x or en) begin
//         if (en) begin
//             case (x)
//                 4'b0001: y = 2'b00;
//                 4'b0010: y = 2'b01;
//                 4'b0100: y = 2'b10;
//                 4'b1000: y = 2'b11;
//                 default: y = 2'b00;
//             endcase
//         end
//         else begin
//             y = 2'b00;
//         end
//     end
// endmodule

/* 4-2编码器（优先模式） */

/*
优先编码器允许同时在几个输入端有输入信号，即输入不止一个 1 ，编码器按输入信号排定的优先顺序，
只对同时输入的几个信号中优先权最高的一个进行编码。
*/

module encode42 (
    input [3:0] x,
    input en,
    output reg [1:0] y
);
    integer i;

    always @(x or en) begin
        if (en) begin
            y = 0;
            for (i = 0; i <= 3; i = i + 1) begin
                if (x[i] == 1) begin
                    y = i[1:0];
                end
            end
        end
        else begin
            y = 0;
        end
    end
endmodule
