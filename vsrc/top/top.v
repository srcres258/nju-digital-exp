// 简单组合逻辑电路

module top (
    input a,
    input b,
    input c,
    output y
);
    assign y = ~a & ~b & ~c | a & ~b & ~c | a & ~b & c;
endmodule
