/*
实验验收内容
上板验收: 实现单个按键的ASCII码显示

    七段数码管低两位显示当前按键的键码，中间两位显示对应的ASCII码
    （转换可以考虑自行设计一个ROM并初始化）。只需完成字符和数字键的输入，
    不需要实现组合键和小键盘。

    当按键松开时，七段数码管的低四位全灭。

    七段数码管的高两位显示按键的总次数。按住不放只算一次按键。
    只考虑顺序按下和放开的情况，不考虑同时按多个键的情况。
*/

// 键盘控制器
/*
以下为接收键盘数据的Verilog HDL代码，此代码只负责接收键盘送来的数据，
如何识别出按下的到底是什么按键由其他模块来处理。
*/
module ps2_keyboard (
    input clk,
    input clrn,
    input ps2_clk,
    input ps2_data,
    output [7:0] data,
    output reg ready,
    input nextdata_n
    output reg overflow // fifo overflow
);
    // internal signal, for test
    reg [9:0] buffer; // ps2_data bits
    reg [7:0] fifo [7:0]; // data fifo
    reg [2:0] w_ptr, r_ptr; // fifo write and read pointers
    reg [3:0] count; // count ps2_data bits
    // detect falling edge of ps2_clk
    reg [2:0] ps2_clk_sync;

    always @(posedge clk) begin
        ps2_clk_sync <= { ps2_clk_sync[1:0], ps2_clk };
    end

    wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

    always @(posedge clk) begin
        if (clrn == 0) begin // reset
            count <= 0;
            w_ptr <= 0;
            r_ptr <= 0;
            overflow <= 0;
            ready <= 0;
        end
        else begin
            if (ready) begin // read to output next data
                if (nextdata_n == 1'b0) begin // read next data
                    r_ptr <= r_ptr + 3'b1;
                    if (w_ptr == r_ptr + 1'b1) begin // empty
                        ready <= 1'b0;
                    end
                end
            end
            if (sampling) begin
                if (count == 4'd10) begin
                    if (
                        buffer[0] == 0 && // start bit
                        ps2_data && // stop bit
                        ^buffer[9:1] // odd parity
                    ) begin
                        fifo[w_ptr] <= buffer[8:1]; // kbd scan code
                        w_ptr <= w_ptr + 3'b1;
                        ready <= 1'b1;
                        overflow <= overflow | (r_ptr == w_ptr + 3'b1);
                    end
                    count <= 0; // for next
                end
                else begin
                    buffer[count] <= ps2_data; // store ps2_data
                    count <= count + 3'b1;
                end
            end
        end
    end

    assign data = fifo[r_ptr]; // always set output data
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

// 将键码转化为ASCII码的ROM
module keyboard_code_to_ascii_rom (
    input [7:0] keyboard_code, // 键码
    output reg [7:0] ascii // ASCII码
);
    always @(keyboard_code) begin
        //todo
    end
endmodule

// 主模块
module ps2_keyboard (
    input clk, // 时钟
    input ps2_clk, // PS/2 时钟
    input ps2_data, // PS/2 数据
    output [6:0] seg3, // 低3位数码管（显示ASCII码）
    output [6:0] seg2, // 低2位数码管（显示ASCII码）
    output [6:0] seg1, // 低1位数码管（显示键码）
    output [6:0] seg0 // 低0位数码管（显示键码）
);
    wire [7:0] keyboard_code, ascii;

    keyboard_code_to_ascii_rom rom(
        .keyboard_code(keyboard_code),
        .ascii(ascii)
    );

    ps2_keyboard keyboard(
        .clk(clk),
        .clrn(1),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .data(keyboard_code)
    );

    seg16_8 seg0( // 显示键码
        .in(keyboard_code),
        .seg1(seg1),
        .seg0(seg0)
    );

    seg16_8 seg1( // 显示ASCII码
        .in(ascii),
        .seg1(seg3),
        .seg0(seg2)
    );
endmodule
