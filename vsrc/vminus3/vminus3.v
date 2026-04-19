module vminus3 (
    input clk,
    input en,
    output reg [2:0] out_q
);
    always @(posedge clk) begin
        if (en) begin
            out_q <= out_q - 1;
        end
        else begin
            out_q <= 0;
        end
    end
endmodule
