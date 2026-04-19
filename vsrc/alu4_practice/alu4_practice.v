module alu4_practice (
    input func_btn,
    input [3:0] a,
    input [3:0] b,
    output reg [2:0] func,
    output [3:0] y
);
    initial begin
        func = 3'b000;
    end

    always @(posedge func_btn) begin
        if (func == 3'b111) begin
            func = 3'b000;
        end
        else begin
            func = func + 1;
        end
    end

    alu4 alu4(
        .func(func),
        .a(a),
        .b(b),
        .y(y)
    );
endmodule
