"""
本脚本根据给定的数码管位数，自动生成16进制数码管二进制数编码器的case语句。
"""

"""
备注
数码管索引位示意图：
 0
5 1
 6
4 2
 3
"""

SEGS = [
    "7'b0111111", # 0
    "7'b0000110", # 1
    "7'b1011011", # 2
    "7'b1001111", # 3
    "7'b1100110", # 4
    "7'b1101101", # 5
    "7'b1111101", # 6
    "7'b0000111", # 7
    "7'b1111111", # 8
    "7'b1101111", # 9
    "7'b1110111", # A (10)
    "7'b1111100", # b (11)
    "7'b0111001", # C (12)
    "7'b1011110", # d (13)
    "7'b1111001", # E (14)
    "7'b1110001" # F (15)
]

def gen_case_statement(digits: int) -> str:
    bound = 16 ** digits
    result = "case (in)\n"
    for num in range(bound):
        hex_num = hex(num)[2:].upper().rjust(digits, '0')
        result += f"    8'h{hex_num}: begin\n"
        rest_num = num
        for i in range(digits):
            digit = rest_num % 16
            seg = SEGS[digit]
            hex_digit = hex(digit)[2:].upper()
            result += f"        seg{i} <= {seg}; // {hex_digit}\n"
            rest_num //= 16
        result += "    end\n"
    # 缺省状态：所有数码管显示横杠 '-'
    result += "    default: begin // 缺省状态：所有数码管显示横杠 '-'\n"
    for i in range(digits):
        result += f"        seg{i} <= 7'b1000000;\n"
    result += "    end\n"
    result += "endcase\n"
    
    return result

if __name__ == '__main__':
    digits = input("请输入数码管位数：")
    print(gen_case_statement(int(digits)))
