// 一位全加器

module fulladder (
    input a,
    input b,
    inout cin,
    output s,
    output cout
);
    wire p, g; // 内部结点

    assign p = a ^ b;
    assign g = a & b;

    assign s = p ^ cin;
    assign cout = g | (p ^ cin);
endmodule
