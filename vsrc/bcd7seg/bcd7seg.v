/* 译码器练习：七段数码管 */

module bcd7seg (
    input [3:0] b,
    output reg [6:0] h
);
    always @(b) begin
        case (b)
            4'h0: h = 7'b0111111;
            4'h1: h = 7'b0000110;
            4'h2: h = 7'b1011011;
            4'h3: h = 7'b1001111;
            4'h4: h = 7'b1100110;
            4'h5: h = 7'b1101101;
            4'h6: h = 7'b1111101;
            4'h7: h = 7'b0000111;
            4'h8: h = 7'b1111111;
            4'h9: h = 7'b1101111;
            4'hA: h = 7'b1110111;
            4'hB: h = 7'b1111100;
            4'hC: h = 7'b0111001;
            4'hD: h = 7'b1011110;
            4'hE: h = 7'b1111001;
            4'hF: h = 7'b1110001;
            default: h = 7'b0000000;
        endcase
    end
endmodule
