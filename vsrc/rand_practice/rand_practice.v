/*
实验验收内容
上板实验: 实现一个8-3优先编码器并在七段数码管上显示

功能描述

查找8-3优先编码器相关原理和实现方法，实现一个8-3编码器，完成8-3编码器的设计、功能仿真和硬件实现。

输入一个8位二进制数，对此8位二进制数进行高位优先编码成一个3位二进制值，并根据是否有输入增加一位输入指示位，
即8个输入全0时指示位为0，有任何一个输入为1时指示位为1。编码器的使能端可选实现。
将此编码结果及指示位以二进制形式显示在四个发光二极管LED上。
再将此结果跟据七段数码管的显示进行译码，将二进制的优先编码结果以十进制的形式显示在数码管上。
*/

// 8位右移移位寄存器
module lfsr_8r (
    input load, // 加载
    input clr, // 清零
    input clk, // 时钟
    input [7:0] in, // 输入
    output reg [7:0] out // 输出
);
    always @(posedge load or posedge clr or posedge clk) begin
        if (load) begin
            out <= in;
        end
        else if (clr) begin
            out <= 8'b00000000;
        end
        else if (clk) begin
            // 计算新位：
            // x8 = x4 ^ x3 ^ x2 ^ x0
            out <= { out[4] ^ out[3] ^ out[2] ^ out[0], out[7:1] }; // 右移，并设定最高位为新位
        end
    end
endmodule

// 8位二进制数数码管编码器（编码成两位16进制）
module seg16_8 (
    input [7:0] in, // 输入
    output reg [6:0] seg1, // 输出高位数码管
    output reg [6:0] seg0 // 输出低位数码管
);
    always @(in) begin
        /*
        数码管索引位示意图：
         0
        5 1
         6
        4 2
         3
        */

        case (in)
            8'h00: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b0111111; // 0
            end
            8'h01: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b0111111; // 0
            end
            8'h02: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b0111111; // 0
            end
            8'h03: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b0111111; // 0
            end
            8'h04: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b0111111; // 0
            end
            8'h05: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b0111111; // 0
            end
            8'h06: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b0111111; // 0
            end
            8'h07: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b0111111; // 0
            end
            8'h08: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b0111111; // 0
            end
            8'h09: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b0111111; // 0
            end
            8'h0A: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b0111111; // 0
            end
            8'h0B: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b0111111; // 0
            end
            8'h0C: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b0111111; // 0
            end
            8'h0D: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b0111111; // 0
            end
            8'h0E: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b0111111; // 0
            end
            8'h0F: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b0111111; // 0
            end
            8'h10: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b0000110; // 1
            end
            8'h11: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b0000110; // 1
            end
            8'h12: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b0000110; // 1
            end
            8'h13: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b0000110; // 1
            end
            8'h14: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b0000110; // 1
            end
            8'h15: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b0000110; // 1
            end
            8'h16: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b0000110; // 1
            end
            8'h17: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b0000110; // 1
            end
            8'h18: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b0000110; // 1
            end
            8'h19: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b0000110; // 1
            end
            8'h1A: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b0000110; // 1
            end
            8'h1B: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b0000110; // 1
            end
            8'h1C: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b0000110; // 1
            end
            8'h1D: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b0000110; // 1
            end
            8'h1E: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b0000110; // 1
            end
            8'h1F: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b0000110; // 1
            end
            8'h20: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b1011011; // 2
            end
            8'h21: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b1011011; // 2
            end
            8'h22: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b1011011; // 2
            end
            8'h23: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b1011011; // 2
            end
            8'h24: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b1011011; // 2
            end
            8'h25: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b1011011; // 2
            end
            8'h26: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b1011011; // 2
            end
            8'h27: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b1011011; // 2
            end
            8'h28: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b1011011; // 2
            end
            8'h29: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b1011011; // 2
            end
            8'h2A: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b1011011; // 2
            end
            8'h2B: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b1011011; // 2
            end
            8'h2C: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b1011011; // 2
            end
            8'h2D: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b1011011; // 2
            end
            8'h2E: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b1011011; // 2
            end
            8'h2F: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b1011011; // 2
            end
            8'h30: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b1001111; // 3
            end
            8'h31: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b1001111; // 3
            end
            8'h32: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b1001111; // 3
            end
            8'h33: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b1001111; // 3
            end
            8'h34: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b1001111; // 3
            end
            8'h35: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b1001111; // 3
            end
            8'h36: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b1001111; // 3
            end
            8'h37: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b1001111; // 3
            end
            8'h38: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b1001111; // 3
            end
            8'h39: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b1001111; // 3
            end
            8'h3A: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b1001111; // 3
            end
            8'h3B: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b1001111; // 3
            end
            8'h3C: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b1001111; // 3
            end
            8'h3D: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b1001111; // 3
            end
            8'h3E: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b1001111; // 3
            end
            8'h3F: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b1001111; // 3
            end
            8'h40: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b1100110; // 4
            end
            8'h41: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b1100110; // 4
            end
            8'h42: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b1100110; // 4
            end
            8'h43: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b1100110; // 4
            end
            8'h44: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b1100110; // 4
            end
            8'h45: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b1100110; // 4
            end
            8'h46: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b1100110; // 4
            end
            8'h47: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b1100110; // 4
            end
            8'h48: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b1100110; // 4
            end
            8'h49: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b1100110; // 4
            end
            8'h4A: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b1100110; // 4
            end
            8'h4B: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b1100110; // 4
            end
            8'h4C: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b1100110; // 4
            end
            8'h4D: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b1100110; // 4
            end
            8'h4E: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b1100110; // 4
            end
            8'h4F: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b1100110; // 4
            end
            8'h50: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b1101101; // 5
            end
            8'h51: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b1101101; // 5
            end
            8'h52: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b1101101; // 5
            end
            8'h53: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b1101101; // 5
            end
            8'h54: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b1101101; // 5
            end
            8'h55: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b1101101; // 5
            end
            8'h56: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b1101101; // 5
            end
            8'h57: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b1101101; // 5
            end
            8'h58: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b1101101; // 5
            end
            8'h59: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b1101101; // 5
            end
            8'h5A: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b1101101; // 5
            end
            8'h5B: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b1101101; // 5
            end
            8'h5C: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b1101101; // 5
            end
            8'h5D: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b1101101; // 5
            end
            8'h5E: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b1101101; // 5
            end
            8'h5F: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b1101101; // 5
            end
            8'h60: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b1111101; // 6
            end
            8'h61: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b1111101; // 6
            end
            8'h62: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b1111101; // 6
            end
            8'h63: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b1111101; // 6
            end
            8'h64: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b1111101; // 6
            end
            8'h65: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b1111101; // 6
            end
            8'h66: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b1111101; // 6
            end
            8'h67: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b1111101; // 6
            end
            8'h68: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b1111101; // 6
            end
            8'h69: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b1111101; // 6
            end
            8'h6A: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b1111101; // 6
            end
            8'h6B: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b1111101; // 6
            end
            8'h6C: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b1111101; // 6
            end
            8'h6D: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b1111101; // 6
            end
            8'h6E: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b1111101; // 6
            end
            8'h6F: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b1111101; // 6
            end
            8'h70: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b0000111; // 7
            end
            8'h71: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b0000111; // 7
            end
            8'h72: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b0000111; // 7
            end
            8'h73: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b0000111; // 7
            end
            8'h74: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b0000111; // 7
            end
            8'h75: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b0000111; // 7
            end
            8'h76: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b0000111; // 7
            end
            8'h77: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b0000111; // 7
            end
            8'h78: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b0000111; // 7
            end
            8'h79: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b0000111; // 7
            end
            8'h7A: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b0000111; // 7
            end
            8'h7B: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b0000111; // 7
            end
            8'h7C: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b0000111; // 7
            end
            8'h7D: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b0000111; // 7
            end
            8'h7E: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b0000111; // 7
            end
            8'h7F: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b0000111; // 7
            end
            8'h80: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b1111111; // 8
            end
            8'h81: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b1111111; // 8
            end
            8'h82: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b1111111; // 8
            end
            8'h83: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b1111111; // 8
            end
            8'h84: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b1111111; // 8
            end
            8'h85: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b1111111; // 8
            end
            8'h86: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b1111111; // 8
            end
            8'h87: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b1111111; // 8
            end
            8'h88: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b1111111; // 8
            end
            8'h89: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b1111111; // 8
            end
            8'h8A: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b1111111; // 8
            end
            8'h8B: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b1111111; // 8
            end
            8'h8C: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b1111111; // 8
            end
            8'h8D: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b1111111; // 8
            end
            8'h8E: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b1111111; // 8
            end
            8'h8F: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b1111111; // 8
            end
            8'h90: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b1101111; // 9
            end
            8'h91: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b1101111; // 9
            end
            8'h92: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b1101111; // 9
            end
            8'h93: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b1101111; // 9
            end
            8'h94: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b1101111; // 9
            end
            8'h95: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b1101111; // 9
            end
            8'h96: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b1101111; // 9
            end
            8'h97: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b1101111; // 9
            end
            8'h98: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b1101111; // 9
            end
            8'h99: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b1101111; // 9
            end
            8'h9A: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b1101111; // 9
            end
            8'h9B: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b1101111; // 9
            end
            8'h9C: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b1101111; // 9
            end
            8'h9D: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b1101111; // 9
            end
            8'h9E: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b1101111; // 9
            end
            8'h9F: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b1101111; // 9
            end
            8'hA0: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b1110111; // A
            end
            8'hA1: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b1110111; // A
            end
            8'hA2: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b1110111; // A
            end
            8'hA3: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b1110111; // A
            end
            8'hA4: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b1110111; // A
            end
            8'hA5: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b1110111; // A
            end
            8'hA6: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b1110111; // A
            end
            8'hA7: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b1110111; // A
            end
            8'hA8: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b1110111; // A
            end
            8'hA9: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b1110111; // A
            end
            8'hAA: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b1110111; // A
            end
            8'hAB: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b1110111; // A
            end
            8'hAC: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b1110111; // A
            end
            8'hAD: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b1110111; // A
            end
            8'hAE: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b1110111; // A
            end
            8'hAF: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b1110111; // A
            end
            8'hB0: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b1111100; // B
            end
            8'hB1: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b1111100; // B
            end
            8'hB2: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b1111100; // B
            end
            8'hB3: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b1111100; // B
            end
            8'hB4: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b1111100; // B
            end
            8'hB5: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b1111100; // B
            end
            8'hB6: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b1111100; // B
            end
            8'hB7: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b1111100; // B
            end
            8'hB8: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b1111100; // B
            end
            8'hB9: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b1111100; // B
            end
            8'hBA: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b1111100; // B
            end
            8'hBB: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b1111100; // B
            end
            8'hBC: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b1111100; // B
            end
            8'hBD: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b1111100; // B
            end
            8'hBE: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b1111100; // B
            end
            8'hBF: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b1111100; // B
            end
            8'hC0: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b0111001; // C
            end
            8'hC1: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b0111001; // C
            end
            8'hC2: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b0111001; // C
            end
            8'hC3: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b0111001; // C
            end
            8'hC4: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b0111001; // C
            end
            8'hC5: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b0111001; // C
            end
            8'hC6: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b0111001; // C
            end
            8'hC7: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b0111001; // C
            end
            8'hC8: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b0111001; // C
            end
            8'hC9: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b0111001; // C
            end
            8'hCA: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b0111001; // C
            end
            8'hCB: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b0111001; // C
            end
            8'hCC: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b0111001; // C
            end
            8'hCD: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b0111001; // C
            end
            8'hCE: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b0111001; // C
            end
            8'hCF: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b0111001; // C
            end
            8'hD0: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b1011110; // D
            end
            8'hD1: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b1011110; // D
            end
            8'hD2: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b1011110; // D
            end
            8'hD3: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b1011110; // D
            end
            8'hD4: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b1011110; // D
            end
            8'hD5: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b1011110; // D
            end
            8'hD6: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b1011110; // D
            end
            8'hD7: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b1011110; // D
            end
            8'hD8: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b1011110; // D
            end
            8'hD9: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b1011110; // D
            end
            8'hDA: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b1011110; // D
            end
            8'hDB: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b1011110; // D
            end
            8'hDC: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b1011110; // D
            end
            8'hDD: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b1011110; // D
            end
            8'hDE: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b1011110; // D
            end
            8'hDF: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b1011110; // D
            end
            8'hE0: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b1111001; // E
            end
            8'hE1: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b1111001; // E
            end
            8'hE2: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b1111001; // E
            end
            8'hE3: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b1111001; // E
            end
            8'hE4: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b1111001; // E
            end
            8'hE5: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b1111001; // E
            end
            8'hE6: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b1111001; // E
            end
            8'hE7: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b1111001; // E
            end
            8'hE8: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b1111001; // E
            end
            8'hE9: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b1111001; // E
            end
            8'hEA: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b1111001; // E
            end
            8'hEB: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b1111001; // E
            end
            8'hEC: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b1111001; // E
            end
            8'hED: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b1111001; // E
            end
            8'hEE: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b1111001; // E
            end
            8'hEF: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b1111001; // E
            end
            8'hF0: begin
                seg0 <= 7'b0111111; // 0
                seg1 <= 7'b1110001; // F
            end
            8'hF1: begin
                seg0 <= 7'b0000110; // 1
                seg1 <= 7'b1110001; // F
            end
            8'hF2: begin
                seg0 <= 7'b1011011; // 2
                seg1 <= 7'b1110001; // F
            end
            8'hF3: begin
                seg0 <= 7'b1001111; // 3
                seg1 <= 7'b1110001; // F
            end
            8'hF4: begin
                seg0 <= 7'b1100110; // 4
                seg1 <= 7'b1110001; // F
            end
            8'hF5: begin
                seg0 <= 7'b1101101; // 5
                seg1 <= 7'b1110001; // F
            end
            8'hF6: begin
                seg0 <= 7'b1111101; // 6
                seg1 <= 7'b1110001; // F
            end
            8'hF7: begin
                seg0 <= 7'b0000111; // 7
                seg1 <= 7'b1110001; // F
            end
            8'hF8: begin
                seg0 <= 7'b1111111; // 8
                seg1 <= 7'b1110001; // F
            end
            8'hF9: begin
                seg0 <= 7'b1101111; // 9
                seg1 <= 7'b1110001; // F
            end
            8'hFA: begin
                seg0 <= 7'b1110111; // A
                seg1 <= 7'b1110001; // F
            end
            8'hFB: begin
                seg0 <= 7'b1111100; // B
                seg1 <= 7'b1110001; // F
            end
            8'hFC: begin
                seg0 <= 7'b0111001; // C
                seg1 <= 7'b1110001; // F
            end
            8'hFD: begin
                seg0 <= 7'b1011110; // D
                seg1 <= 7'b1110001; // F
            end
            8'hFE: begin
                seg0 <= 7'b1111001; // E
                seg1 <= 7'b1110001; // F
            end
            8'hFF: begin
                seg0 <= 7'b1110001; // F
                seg1 <= 7'b1110001; // F
            end
            default: begin // 缺省状态：所有数码管显示横杠 '-'
                seg0 <= 7'b1000000;
                seg1 <= 7'b1000000;
            end
        endcase
    end
endmodule

// 主模块
module rand_practice (
    input load, // 加载
    input clr, // 清零
    input clk, // 时钟
    input [7:0] in, // 输入
    output [6:0] seg1, // 输出高位数码管
    output [6:0] seg0 // 输出低位数码管
);
    wire [7:0] out;
    wire [6:0] seg1_tmp;
    wire [6:0] seg0_tmp;

    // 因为NVBoard上显示数码管的信号是取反显示的，
    // 所以为了更加直观演示这里取反输出。
    assign seg1 = ~seg1_tmp;
    assign seg0 = ~seg0_tmp;

    lfsr_8r lfsr(
        .load(load),
        .clr(clr),
        .clk(clk),
        .in(in),
        .out(out)
    );

    seg16_8 seg(
        .in(out),
        .seg1(seg1_tmp),
        .seg0(seg0_tmp)
    );
endmodule
