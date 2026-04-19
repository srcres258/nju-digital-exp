/*
实验验收内容
上板实验: 实现一个8-3优先编码器并在七段数码管上显示
*/

// 七段数码管（只编码0-7）
module bcd7seg (
    input [2:0] b,
    output reg [6:0] h
);
    always @(b) begin
        case (b)
            3'h0: h = 7'b0111111;
            3'h1: h = 7'b0000110;
            3'h2: h = 7'b1011011;
            3'h3: h = 7'b1001111;
            3'h4: h = 7'b1100110;
            3'h5: h = 7'b1101101;
            3'h6: h = 7'b1111101;
            3'h7: h = 7'b0000111;
            default: h = 7'b0000000;
        endcase
    end
endmodule

// 8-3优先编码器
module encode83 (
    input [7:0] x,
    input en,
    output reg [2:0] y
);
    always @(x or en) begin
        if (en) begin
            casez (x)
                8'b1zzzzzzz: y = 3'd7;
                8'b01zzzzzz: y = 3'd6;
                8'b001zzzzz: y = 3'd5;
                8'b0001zzzz: y = 3'd4;
                8'b00001zzz: y = 3'd3;
                8'b000001zz: y = 3'd2;
                8'b0000001z: y = 3'd1;
                8'b00000001: y = 3'd0;
                default: y = 3'd0;
            endcase
        end
        else begin
            y = 3'd0;
        end
    end
endmodule

// 主模块
module encode83_seg (
    input [7:0] x,
    input en,
    output reg [6:0] h
);
    wire [2:0] y;

    encode83 encode83(
        .x(x),
        .en(en),
        .y(y)
    );

    bcd7seg bcd7seg(
        .b(y),
        .h(h)
    );
endmodule
