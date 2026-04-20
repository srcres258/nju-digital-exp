"""将图片文件转换为VGA显存的hex文件，用于$readmemh加载。"""
import sys
from PIL import Image


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input_image> <output_hex>")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    img = Image.open(input_path).convert("RGB")
    img_w, img_h = img.size

    vga_w, vga_h = 640, 480
    rows_per_col = 512

    x_offset = (vga_w - img_w) // 2
    y_offset = (vga_h - img_h) // 2

    pixels = img.load()

    with open(output_path, "w") as f:
        for h in range(vga_w):
            for v in range(rows_per_col):
                if v < vga_h and x_offset <= h < x_offset + img_w and y_offset <= v < y_offset + img_h:
                    r, g, b = pixels[h - x_offset, v - y_offset]
                else:
                    r, g, b = 0, 0, 0
                f.write(f"{r:02x}{g:02x}{b:02x}\n")


if __name__ == "__main__":
    main()
