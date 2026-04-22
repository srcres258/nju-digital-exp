#!/usr/bin/env python3
import sys

def parse_bdf(filename):
    chars = {}
    with open(filename, 'r') as f:
        lines = f.readlines()

    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if line.startswith('STARTCHAR'):
            encoding = None
            bbx_w = bbx_h = bbx_xoff = bbx_yoff = 0
            dwidth = 9
            bitmap = []
            i += 1
            while i < len(lines):
                line = lines[i].strip()
                if line.startswith('ENCODING'):
                    encoding = int(line.split()[1])
                elif line.startswith('DWIDTH'):
                    dwidth = int(line.split()[1])
                elif line.startswith('BBX'):
                    parts = line.split()
                    bbx_w = int(parts[1])
                    bbx_h = int(parts[2])
                    bbx_xoff = int(parts[3])
                    bbx_yoff = int(parts[4])
                elif line == 'BITMAP':
                    i += 1
                    for j in range(bbx_h):
                        if i + j < len(lines):
                            bitmap.append(int(lines[i + j].strip(), 16))
                        else:
                            bitmap.append(0)
                    i += bbx_h - 1
                    break
                elif line == 'ENDCHAR':
                    break
                i += 1

            if encoding is not None and 0 <= encoding <= 255:
                chars[encoding] = {
                    'bbx_w': bbx_w,
                    'bbx_h': bbx_h,
                    'bbx_xoff': bbx_xoff,
                    'bbx_yoff': bbx_yoff,
                    'dwidth': dwidth,
                    'bitmap': bitmap,
                }
        i += 1
    return chars

FONT_ASCENT = 12
CELL_ROWS = 16
PIXEL_WIDTH = 9

def char_to_rows(info):
    rows = [0] * CELL_ROWS
    if info is None:
        return rows

    bbx_h = info['bbx_h']
    bbx_w = info['bbx_w']
    bbx_xoff = info['bbx_xoff']
    bbx_yoff = info['bbx_yoff']
    bitmap = info['bitmap']

    row_start = FONT_ASCENT - bbx_h - bbx_yoff

    bytes_per_row = (bbx_w + 7) // 8

    for r in range(bbx_h):
        target = row_start + r
        if 0 <= target < CELL_ROWS:
            if r < len(bitmap):
                val = bitmap[r]
            else:
                val = 0
            shift = PIXEL_WIDTH - bbx_w - bbx_xoff
            if shift < 0:
                shift = 0
            pixel_val = (val >> (bytes_per_row * 8 - bbx_w)) & ((1 << bbx_w) - 1)
            pixel_val = pixel_val << shift
            pixel_val = pixel_val & ((1 << PIXEL_WIDTH) - 1)
            rows[target] = pixel_val

    return rows

def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input.bdf> <output.hex>")
        sys.exit(1)

    chars = parse_bdf(sys.argv[1])

    with open(sys.argv[2], 'w') as f:
        for code in range(256):
            info = chars.get(code)
            rows = char_to_rows(info)
            for row in rows:
                f.write(f'{row:03x}\n')

if __name__ == '__main__':
    main()
