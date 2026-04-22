/* verilator lint_off WIDTHEXPAND */
/* verilator lint_off UNOPTFLAT */
/* verilator lint_off UNUSEDSIGNAL */

module vga_input (
    input clk,
    input rst,
    input ps2_clk,
    input ps2_data,
    output VGA_HSYNC,
    output VGA_VSYNC,
    output VGA_BLANK_N,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B
);

wire [9:0] h_addr;
wire [9:0] v_addr;
wire valid;

vga_ctrl my_vga_ctrl(
    .pclk(clk),
    .reset(rst),
    .h_addr(h_addr),
    .v_addr(v_addr),
    .hsync(VGA_HSYNC),
    .vsync(VGA_VSYNC),
    .valid(valid)
);

assign VGA_BLANK_N = valid;

wire [7:0] ps2_scan_data;
wire ps2_ready;
wire key_event;
wire [7:0] key_ascii;
wire key_extended;
wire key_released;
wire ps2_nextdata_n;

ps2_keyboard my_ps2(
    .clk(clk),
    .clrn(~rst),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .data(ps2_scan_data),
    .ready(ps2_ready),
    .nextdata_n(ps2_nextdata_n),
    .overflow()
);

ps2_scancode_decoder my_decoder(
    .clk(clk),
    .ps2_data(ps2_scan_data),
    .ps2_ready(ps2_ready),
    .ps2_nextdata_n(ps2_nextdata_n),
    .key_event(key_event),
    .key_ascii(key_ascii),
    .key_extended(key_extended),
    .key_released(key_released)
);

wire [6:0] cursor_col;
wire [4:0] cursor_row;
wire cursor_blink;
wire buf_wr_en;
wire [6:0] buf_wr_col;
wire [4:0] buf_wr_row;
wire [7:0] buf_wr_data;
wire buf_scroll_en;

terminal_ctrl my_terminal(
    .clk(clk),
    .rst(rst),
    .key_event(key_event),
    .key_ascii(key_ascii),
    .key_extended(key_extended),
    .key_released(key_released),
    .cursor_col(cursor_col),
    .cursor_row(cursor_row),
    .cursor_blink(cursor_blink),
    .buf_wr_en(buf_wr_en),
    .buf_wr_col(buf_wr_col),
    .buf_wr_row(buf_wr_row),
    .buf_wr_data(buf_wr_data),
    .buf_scroll_en(buf_scroll_en)
);

wire [7:0] vga_char;

char_buf my_buf(
    .clk(clk),
    .vga_col(h_addr[9:3]),
    .vga_row(v_addr[8:4]),
    .vga_char(vga_char),
    .wr_en(buf_wr_en),
    .wr_col(buf_wr_col),
    .wr_row(buf_wr_row),
    .wr_data(buf_wr_data),
    .scroll_en(buf_scroll_en)
);

wire [8:0] font_pixels;

font_rom my_font(
    .char_code(vga_char),
    .row(v_addr[3:0]),
    .pixel_row(font_pixels)
);

wire [6:0] vga_char_col = h_addr[9:3];
wire [4:0] vga_char_row = v_addr[8:4];
wire [3:0] pixel_x = h_addr[2:0];

reg font_pixel;
always @(font_pixels or pixel_x) begin
    case (pixel_x)
        4'd0: font_pixel = font_pixels[8];
        4'd1: font_pixel = font_pixels[7];
        4'd2: font_pixel = font_pixels[6];
        4'd3: font_pixel = font_pixels[5];
        4'd4: font_pixel = font_pixels[4];
        4'd5: font_pixel = font_pixels[3];
        4'd6: font_pixel = font_pixels[2];
        4'd7: font_pixel = font_pixels[1];
        4'd8: font_pixel = font_pixels[0];
        default: font_pixel = 1'b0;
    endcase
end

wire show_cursor = (vga_char_col == cursor_col) & (vga_char_row == cursor_row) & cursor_blink;
wire is_white = font_pixel | show_cursor;

assign {VGA_R, VGA_G, VGA_B} = (valid & is_white) ? 24'hFFFFFF : 24'h000000;

endmodule

module vga_ctrl (
    input pclk,
    input reset,
    output [9:0] h_addr,
    output [9:0] v_addr,
    output hsync,
    output vsync,
    output valid
);

parameter h_frontporch = 96;
parameter h_active = 144;
parameter h_backporch = 784;
parameter h_total = 800;

parameter v_frontporch = 2;
parameter v_active = 35;
parameter v_backporch = 515;
parameter v_total = 525;

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

assign hsync = (x_cnt > h_frontporch);
assign vsync = (y_cnt > v_frontporch);
assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
assign valid = h_valid & v_valid;
assign h_addr = h_valid ? (x_cnt - 10'd145) : 10'd0;
assign v_addr = v_valid ? (y_cnt - 10'd36) : 10'd0;

endmodule

module font_rom (
    input [7:0] char_code,
    input [3:0] row,
    output [8:0] pixel_row
);

reg [11:0] font [0:4095];

initial begin
    $readmemh("vsrc/vga_input/font.hex", font);
end

assign pixel_row = font[{char_code, row}][11:3];

endmodule

module char_buf (
    input clk,
    input [6:0] vga_col,
    input [4:0] vga_row,
    output [7:0] vga_char,
    input wr_en,
    input [6:0] wr_col,
    input [4:0] wr_row,
    input [7:0] wr_data,
    input scroll_en
);

reg [7:0] charmem [0:2099];
integer i;

always @(posedge clk) begin
    if (scroll_en) begin
        for (i = 0; i < 2030; i = i + 1)
            charmem[i] <= charmem[i + 70];
        for (i = 2030; i < 2100; i = i + 1)
            charmem[i] <= 8'd0;
    end
    else if (wr_en) begin
        charmem[wr_row * 70 + wr_col] <= wr_data;
    end
end

assign vga_char = charmem[vga_row * 70 + vga_col];

endmodule

module ps2_keyboard (
    input clk,
    input clrn,
    input ps2_clk,
    input ps2_data,
    output [7:0] data,
    output reg ready,
    input nextdata_n,
    output reg overflow
);
    reg [9:0] buffer;
    reg [7:0] fifo [7:0];
    reg [2:0] w_ptr, r_ptr;
    reg [3:0] count;
    reg [2:0] ps2_clk_sync;

    always @(posedge clk) begin
        ps2_clk_sync <= { ps2_clk_sync[1:0], ps2_clk };
    end

    wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

    always @(posedge clk) begin
        if (clrn == 0) begin
            count <= 0;
            w_ptr <= 0;
            r_ptr <= 0;
            overflow <= 0;
            ready <= 0;
        end
        else begin
            if (ready) begin
                if (nextdata_n == 1'b0) begin
                    r_ptr <= r_ptr + 3'b1;
                    if (w_ptr == r_ptr + 1'b1) begin
                        ready <= 1'b0;
                    end
                end
            end
            if (sampling) begin
                if (count == 4'd10) begin
                    if (
                        buffer[0] == 0 &&
                        ps2_data &&
                        ^buffer[9:1]
                    ) begin
                        fifo[w_ptr] <= buffer[8:1];
                        w_ptr <= w_ptr + 3'b1;
                        ready <= 1'b1;
                        overflow <= overflow | (r_ptr == w_ptr + 3'b1);
                    end
                    count <= 0;
                end
                else begin
                    buffer[count] <= ps2_data;
                    count <= count + 3'b1;
                end
            end
        end
    end

    assign data = fifo[r_ptr];
endmodule

module ps2_scancode_decoder (
    input clk,
    input [7:0] ps2_data,
    input ps2_ready,
    output reg ps2_nextdata_n,
    output reg key_event,
    output reg [7:0] key_ascii,
    output reg key_extended,
    output reg key_released
);

localparam S_IDLE    = 3'd0;
localparam S_MAKE    = 3'd1;
localparam S_BREAK   = 3'd2;
localparam S_EXT     = 3'd3;
localparam S_EXT_BRK = 3'd4;

reg [2:0] state;
reg shift_held;

always @(posedge clk) begin
    ps2_nextdata_n <= 1'b1;
    key_event <= 1'b0;

    case (state)
        S_IDLE: begin
            if (ps2_ready) begin
                ps2_nextdata_n <= 1'b0;
                if (ps2_data == 8'hF0)
                    state <= S_BREAK;
                else if (ps2_data == 8'hE0)
                    state <= S_EXT;
                else begin
                    state <= S_MAKE;
                    key_extended <= 1'b0;
                    key_released <= 1'b0;
                    key_ascii <= scan_to_ascii(ps2_data, shift_held);
                    if (ps2_data == 8'h12 || ps2_data == 8'h59)
                        shift_held <= 1'b1;
                    else
                        key_event <= 1'b1;
                end
            end
        end
        S_MAKE: begin
            if (ps2_ready) begin
                ps2_nextdata_n <= 1'b0;
                if (ps2_data == 8'hF0)
                    state <= S_BREAK;
                else if (ps2_data == 8'hE0)
                    state <= S_EXT;
                else begin
                    key_extended <= 1'b0;
                    key_released <= 1'b0;
                    key_ascii <= scan_to_ascii(ps2_data, shift_held);
                    if (ps2_data == 8'h12 || ps2_data == 8'h59)
                        shift_held <= 1'b1;
                    else
                        key_event <= 1'b1;
                end
            end
        end
        S_BREAK: begin
            if (ps2_ready) begin
                ps2_nextdata_n <= 1'b0;
                if (ps2_data == 8'h12 || ps2_data == 8'h59)
                    shift_held <= 1'b0;
                state <= S_IDLE;
            end
        end
        S_EXT: begin
            if (ps2_ready) begin
                ps2_nextdata_n <= 1'b0;
                if (ps2_data == 8'hF0)
                    state <= S_EXT_BRK;
                else begin
                    state <= S_MAKE;
                    key_extended <= 1'b1;
                    key_released <= 1'b0;
                    key_ascii <= ext_scan_to_ascii(ps2_data);
                    key_event <= 1'b1;
                end
            end
        end
        S_EXT_BRK: begin
            if (ps2_ready) begin
                ps2_nextdata_n <= 1'b0;
                state <= S_IDLE;
            end
        end
        default: state <= S_IDLE;
    endcase
end

function [7:0] scan_to_ascii;
    input [7:0] scan;
    input shft;
    case (scan)
        8'h1C: scan_to_ascii = shft ? 8'h41 : 8'h61;
        8'h32: scan_to_ascii = shft ? 8'h42 : 8'h62;
        8'h21: scan_to_ascii = shft ? 8'h43 : 8'h63;
        8'h23: scan_to_ascii = shft ? 8'h44 : 8'h64;
        8'h24: scan_to_ascii = shft ? 8'h45 : 8'h65;
        8'h2B: scan_to_ascii = shft ? 8'h46 : 8'h66;
        8'h34: scan_to_ascii = shft ? 8'h47 : 8'h67;
        8'h33: scan_to_ascii = shft ? 8'h48 : 8'h68;
        8'h43: scan_to_ascii = shft ? 8'h49 : 8'h69;
        8'h3B: scan_to_ascii = shft ? 8'h4A : 8'h6A;
        8'h42: scan_to_ascii = shft ? 8'h4B : 8'h6B;
        8'h4B: scan_to_ascii = shft ? 8'h4C : 8'h6C;
        8'h3A: scan_to_ascii = shft ? 8'h4D : 8'h6D;
        8'h31: scan_to_ascii = shft ? 8'h4E : 8'h6E;
        8'h44: scan_to_ascii = shft ? 8'h4F : 8'h6F;
        8'h4D: scan_to_ascii = shft ? 8'h50 : 8'h70;
        8'h15: scan_to_ascii = shft ? 8'h51 : 8'h71;
        8'h2D: scan_to_ascii = shft ? 8'h52 : 8'h72;
        8'h1B: scan_to_ascii = shft ? 8'h53 : 8'h73;
        8'h2C: scan_to_ascii = shft ? 8'h54 : 8'h74;
        8'h3C: scan_to_ascii = shft ? 8'h55 : 8'h75;
        8'h2A: scan_to_ascii = shft ? 8'h56 : 8'h76;
        8'h1D: scan_to_ascii = shft ? 8'h57 : 8'h77;
        8'h22: scan_to_ascii = shft ? 8'h58 : 8'h78;
        8'h35: scan_to_ascii = shft ? 8'h59 : 8'h79;
        8'h1A: scan_to_ascii = shft ? 8'h5A : 8'h7A;
        8'h45: scan_to_ascii = shft ? 8'h29 : 8'h30;
        8'h16: scan_to_ascii = shft ? 8'h21 : 8'h31;
        8'h1E: scan_to_ascii = shft ? 8'h40 : 8'h32;
        8'h26: scan_to_ascii = shft ? 8'h23 : 8'h33;
        8'h25: scan_to_ascii = shft ? 8'h24 : 8'h34;
        8'h2E: scan_to_ascii = shft ? 8'h25 : 8'h35;
        8'h36: scan_to_ascii = shft ? 8'h5E : 8'h36;
        8'h3D: scan_to_ascii = shft ? 8'h26 : 8'h37;
        8'h3E: scan_to_ascii = shft ? 8'h2A : 8'h38;
        8'h46: scan_to_ascii = shft ? 8'h28 : 8'h39;
        8'h5A: scan_to_ascii = 8'h0D;
        8'h66: scan_to_ascii = 8'h08;
        8'h0D: scan_to_ascii = 8'h09;
        8'h29: scan_to_ascii = 8'h20;
        8'h76: scan_to_ascii = 8'h1B;
        8'h54: scan_to_ascii = shft ? 8'h7B : 8'h5B;
        8'h5B: scan_to_ascii = shft ? 8'h7D : 8'h5D;
        8'h4E: scan_to_ascii = shft ? 8'h5F : 8'h2D;
        8'h55: scan_to_ascii = shft ? 8'h2B : 8'h3D;
        8'h0E: scan_to_ascii = shft ? 8'h7E : 8'h60;
        8'h4C: scan_to_ascii = shft ? 8'h3A : 8'h3B;
        8'h52: scan_to_ascii = shft ? 8'h22 : 8'h27;
        8'h41: scan_to_ascii = shft ? 8'h3C : 8'h2C;
        8'h49: scan_to_ascii = shft ? 8'h3E : 8'h2E;
        8'h4A: scan_to_ascii = shft ? 8'h3F : 8'h2F;
        8'h5D: scan_to_ascii = shft ? 8'h7C : 8'h5C;
        default: scan_to_ascii = 8'h00;
    endcase
endfunction

function [7:0] ext_scan_to_ascii;
    input [7:0] scan;
    case (scan)
        8'h75: ext_scan_to_ascii = 8'h11;
        8'h72: ext_scan_to_ascii = 8'h12;
        8'h6B: ext_scan_to_ascii = 8'h13;
        8'h74: ext_scan_to_ascii = 8'h14;
        default: ext_scan_to_ascii = 8'h00;
    endcase
endfunction

endmodule

module terminal_ctrl (
    input clk,
    input rst,
    input key_event,
    input [7:0] key_ascii,
    input key_extended,
    input key_released,
    output [6:0] cursor_col,
    output [4:0] cursor_row,
    output cursor_blink,
    output reg buf_wr_en,
    output reg [6:0] buf_wr_col,
    output reg [4:0] buf_wr_row,
    output reg [7:0] buf_wr_data,
    output reg buf_scroll_en
);

reg [6:0] cur_col;
reg [4:0] cur_row;
reg [25:0] blink_cnt;
reg at_line_start;

assign cursor_col = cur_col;
assign cursor_row = cur_row;
assign cursor_blink = blink_cnt[25];

localparam S_NORM    = 2'd0;
localparam S_PROMPT1 = 2'd1;
localparam S_PROMPT2 = 2'd2;
reg [1:0] write_state;
reg [7:0] pending_char;

always @(posedge clk) begin
    if (rst) begin
        cur_col <= 7'd0;
        cur_row <= 5'd0;
        blink_cnt <= 26'd0;
        at_line_start <= 1'b1;
        buf_wr_en <= 1'b0;
        buf_scroll_en <= 1'b0;
        write_state <= S_NORM;
        pending_char <= 8'h00;
    end
    else begin
        blink_cnt <= blink_cnt + 26'd1;
        buf_wr_en <= 1'b0;
        buf_scroll_en <= 1'b0;

        case (write_state)
            S_NORM: begin
                if (key_event && !key_released) begin
                    case (key_ascii)
                        8'h0D: begin
                            cur_col <= 7'd0;
                            if (cur_row == 5'd29)
                                buf_scroll_en <= 1'b1;
                            else
                                cur_row <= cur_row + 5'd1;
                            at_line_start <= 1'b1;
                        end
                        8'h08: begin
                            if (cur_col > 7'd0) begin
                                cur_col <= cur_col - 7'd1;
                                buf_wr_en <= 1'b1;
                                buf_wr_col <= cur_col - 7'd1;
                                buf_wr_row <= cur_row;
                                buf_wr_data <= 8'h20;
                            end
                        end
                        8'h11: begin
                            if (cur_row > 5'd0)
                                cur_row <= cur_row - 5'd1;
                        end
                        8'h12: begin
                            if (cur_row < 5'd29)
                                cur_row <= cur_row + 5'd1;
                        end
                        8'h13: begin
                            if (cur_col > 7'd0)
                                cur_col <= cur_col - 7'd1;
                        end
                        8'h14: begin
                            if (cur_col < 7'd69)
                                cur_col <= cur_col + 7'd1;
                        end
                        default: begin
                            if (key_ascii >= 8'h20 && key_ascii <= 8'h7E) begin
                                if (at_line_start) begin
                                    buf_wr_en <= 1'b1;
                                    buf_wr_col <= 7'd0;
                                    buf_wr_row <= cur_row;
                                    buf_wr_data <= 8'h3E;
                                    write_state <= S_PROMPT1;
                                    pending_char <= key_ascii;
                                end
                                else begin
                                    buf_wr_en <= 1'b1;
                                    buf_wr_col <= cur_col;
                                    buf_wr_row <= cur_row;
                                    buf_wr_data <= key_ascii;
                                    if (cur_col == 7'd69) begin
                                        cur_col <= 7'd0;
                                        if (cur_row == 5'd29)
                                            buf_scroll_en <= 1'b1;
                                        else
                                            cur_row <= cur_row + 5'd1;
                                        at_line_start <= 1'b1;
                                    end
                                    else begin
                                        cur_col <= cur_col + 7'd1;
                                    end
                                end
                            end
                        end
                    endcase
                end
            end
            S_PROMPT1: begin
                buf_wr_en <= 1'b1;
                buf_wr_col <= 7'd1;
                buf_wr_row <= cur_row;
                buf_wr_data <= 8'h20;
                write_state <= S_PROMPT2;
            end
            S_PROMPT2: begin
                buf_wr_en <= 1'b1;
                buf_wr_col <= 7'd2;
                buf_wr_row <= cur_row;
                buf_wr_data <= pending_char;
                cur_col <= 7'd3;
                at_line_start <= 1'b0;
                write_state <= S_NORM;
            end
            default: write_state <= S_NORM;
        endcase
    end
end

endmodule
