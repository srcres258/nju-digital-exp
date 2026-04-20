/* verilator lint_off WIDTHEXPAND */

/* VGA接口控制器 */

module vga (
    input clk,
    input rst,
    output VGA_HSYNC,
    output VGA_VSYNC,
    output VGA_BLANK_N,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B
);

wire [9:0] h_addr;
wire [9:0] v_addr;
wire [23:0] vga_data;
wire valid;

vga_ctrl my_vga_ctrl(
    .pclk(clk),
    .reset(rst),
    .vga_data(vga_data),
    .h_addr(h_addr),
    .v_addr(v_addr),
    .hsync(VGA_HSYNC),
    .vsync(VGA_VSYNC),
    .valid(valid),
    .vga_r(VGA_R),
    .vga_g(VGA_G),
    .vga_b(VGA_B)
);

assign VGA_BLANK_N = valid;

vmem my_vmem(
    .h_addr(h_addr),
    .v_addr(v_addr[8:0]),
    .vga_data(vga_data)
);

endmodule

/* VGA时序控制器 */
module vga_ctrl (
    input pclk,
    input reset,
    input [23:0] vga_data,
    output [9:0] h_addr,
    output [9:0] v_addr,
    output hsync,
    output vsync,
    output valid,
    output [7:0] vga_r,
    output [7:0] vga_g,
    output [7:0] vga_b
);

// 640x480分辨率下的VGA参数设置
parameter h_frontporch = 96;
parameter h_active = 144;
parameter h_backporch = 784;
parameter h_total = 800;

parameter v_frontporch = 2;
parameter v_active = 35;
parameter v_backporch = 515;
parameter v_total = 525;

// 像素计数值
reg [9:0] x_cnt;
reg [9:0] y_cnt;
wire h_valid;
wire v_valid;

always @(posedge pclk) begin
    if (reset == 1'b1) begin
        x_cnt <= 10'd1;
        y_cnt <= 10'd1;
    end
    else begin
        if (x_cnt == h_total) begin
            x_cnt <= 10'd1;
            if (y_cnt == v_total)
                y_cnt <= 10'd1;
            else
                y_cnt <= y_cnt + 10'd1;
        end
        else begin
            x_cnt <= x_cnt + 10'd1;
        end
    end
end

// 生成同步信号
assign hsync = (x_cnt > h_frontporch);
assign vsync = (y_cnt > v_frontporch);
// 生成消隐信号
assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
assign valid = h_valid & v_valid;
// 计算当前有效像素坐标
assign h_addr = h_valid ? (x_cnt - 10'd145) : 10'd0;
assign v_addr = v_valid ? (y_cnt - 10'd36) : 10'd0;
// 设置输出的颜色值
assign {vga_r, vga_g, vga_b} = vga_data;

endmodule

/* VGA显存模块，列优先存储 */
module vmem (
    input [9:0] h_addr,
    input [8:0] v_addr,
    output [23:0] vga_data
);

reg [23:0] vga_mem [524287:0];

initial begin
    $readmemh("vsrc/vga/vga_image.hex", vga_mem);
end

assign vga_data = vga_mem[{h_addr, v_addr}];

endmodule
