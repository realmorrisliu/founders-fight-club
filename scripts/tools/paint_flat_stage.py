#!/usr/bin/env python3

import struct
import zlib
from pathlib import Path


def rgb(hex_color):
	value = hex_color.lstrip("#")
	return (int(value[0:2], 16), int(value[2:4], 16), int(value[4:6], 16))


SKY = [
	rgb("#070b18"),
	rgb("#0c1428"),
	rgb("#142038"),
	rgb("#1c2c4a"),
	rgb("#243656"),
]
BUILDING = [rgb("#101624"), rgb("#1a2436"), rgb("#121820")]
WINDOW = rgb("#8DD7FF")
WARM = rgb("#c47a4a")
DECK = [rgb("#141820"), rgb("#2a3140"), rgb("#4a5568"), rgb("#8a94a4")]
LIP = rgb("#00AEEF")
EDGE = rgb("#10141c")


def blank(width, height, color):
	return [[color for _ in range(width)] for _ in range(height)]


def fill_rect(pixels, x, y, w, h, color):
	height = len(pixels)
	width = len(pixels[0]) if height else 0
	for yy in range(max(0, y), min(height, y + h)):
		for xx in range(max(0, x), min(width, x + w)):
			pixels[yy][xx] = color


def _windows(pixels, x, y, w, h, gap_x, gap_y, ox, oy, lit):
	for wy in range(y + 8 + oy, y + h - 8, gap_y):
		for wx in range(x + 4 + ox, x + w - 5, gap_x):
			if (wx + wy) % lit != 0:
				continue
			color = WARM if (wx // gap_x) % 5 == 0 else rgb("#2a4a62")
			fill_rect(pixels, wx, wy, 2, 3, color)


def _tower(pixels, x, ground, w, h, color, roof, windows):
	fill_rect(pixels, x, ground - h, w, h, color)
	fill_rect(pixels, x, ground - h, w, 2, rgb("#2c3548"))
	if roof == "step":
		fill_rect(pixels, x + w // 5, ground - h - 18, w * 3 // 5, 18, color)
		fill_rect(pixels, x + w // 3, ground - h - 34, w // 3, 16, rgb("#0c1018"))
	elif roof == "peak":
		for row in range(16):
			inset = row
			fill_rect(pixels, x + inset, ground - h - 16 + row, w - inset * 2, 1, color)
	elif roof == "tank":
		fill_rect(pixels, x + w // 3, ground - h - 22, w // 3, 16, rgb("#1a222e"))
		fill_rect(pixels, x + w // 3 - 2, ground - h - 24, w // 3 + 4, 3, rgb("#3a4454"))
		fill_rect(pixels, x + w // 2, ground - h - 36, 2, 12, rgb("#2c3548"))
	elif roof == "antenna":
		mast_x = x + w // 2
		fill_rect(pixels, mast_x, ground - h - 26, 2, 26, rgb("#8a94a4"))
		fill_rect(pixels, mast_x - 1, ground - h - 26, 5, 2, rgb("#c8d0dc"))
	if windows:
		_windows(pixels, x, ground - h, w, h, windows[0], windows[1], windows[2], windows[3], windows[4])


def paint_sky():
	width, height = 960, 540
	pixels = blank(width, height, SKY[0])
	bands = (0, 90, 180, 270, 360, height)
	for index in range(5):
		fill_rect(pixels, 0, bands[index], width, bands[index + 1] - bands[index], SKY[index])
	far = rgb("#0c1018")
	mid = rgb("#141c2c")
	near = rgb("#1c2636")
	# Far layer sits higher and darker. Mid and near overlap it with different roofs.
	for spec in (
		(30, 90, 70, far, "flat", None),
		(140, 50, 110, far, "peak", None),
		(230, 120, 60, far, "flat", None),
		(400, 70, 90, far, "antenna", None),
		(520, 140, 50, far, "flat", None),
		(700, 80, 100, far, "step", None),
		(860, 60, 70, far, "flat", None),
	):
		_tower(pixels, spec[0], 250, spec[1], spec[2], spec[3], spec[4], spec[5])
	for spec in (
		(60, 64, 140, mid, "step", (14, 18, 2, 4, 7)),
		(180, 100, 90, mid, "flat", (16, 22, 6, 0, 5)),
		(310, 48, 170, mid, "antenna", (12, 16, 0, 2, 9)),
		(430, 88, 120, mid, "tank", (18, 20, 4, 6, 6)),
		(560, 70, 150, mid, "peak", (14, 18, 2, 2, 8)),
		(680, 110, 80, mid, "flat", (20, 24, 8, 4, 4)),
		(820, 76, 130, mid, "step", (14, 18, 0, 0, 7)),
	):
		_tower(pixels, spec[0], 340, spec[1], spec[2], spec[3], spec[4], spec[5])
	for spec in (
		(20, 80, 160, near, "flat", (18, 22, 4, 2, 11)),
		(150, 46, 210, near, "antenna", (12, 20, 2, 0, 13)),
		(250, 130, 100, near, "tank", (22, 26, 6, 4, 5)),
		(420, 60, 180, near, "step", (14, 18, 0, 2, 9)),
		(530, 96, 140, near, "peak", (16, 20, 4, 0, 8)),
		(670, 54, 200, near, "flat", (12, 16, 2, 6, 10)),
		(780, 120, 110, near, "step", (20, 24, 8, 2, 6)),
	):
		_tower(pixels, spec[0], 430, spec[1], spec[2], spec[3], spec[4], spec[5])
	fill_rect(pixels, 0, 430, width, height - 430, rgb("#10141c"))
	return pixels


def _slab(pixels, lamps):
	height = len(pixels)
	width = len(pixels[0])
	fill_rect(pixels, 0, 0, width, 5, DECK[2])
	fill_rect(pixels, 0, 0, width, 1, DECK[3])
	for x in range(0, width, 19):
		fill_rect(pixels, x, 2, 1, 3, EDGE)
	fill_rect(pixels, 0, 5, width, 2, DECK[1])
	for x in lamps:
		if 1 <= x < width - 2:
			fill_rect(pixels, x, 5, 2, 2, LIP)
	plate = DECK[0]
	seam = EDGE
	for x in range(width):
		panel = (x // 24) % 2
		tone = DECK[1] if panel else plate
		for y in range(8, height - 2):
			pixels[y][x] = seam if x % 24 == 0 else tone
		if x % 24 == 8:
			pixels[12][x] = DECK[3]
			pixels[13][x] = DECK[3]
	fill_rect(pixels, 0, height - 2, width, 2, EDGE)


def paint_deck():
	pixels = blank(380, 36, DECK[0])
	_slab(pixels, (36, 148, 260, 340))
	return pixels


def paint_platform():
	pixels = blank(72, 16, DECK[0])
	_slab(pixels, (30,))
	return pixels


def write_png(path, pixels):
	height = len(pixels)
	width = len(pixels[0]) if height else 0

	def chunk(tag, data):
		return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

	raw = b"".join(b"\x00" + bytes(channel for pixel in row for channel in (pixel[0], pixel[1], pixel[2], 255)) for row in pixels)
	png = b"\x89PNG\r\n\x1a\n"
	png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
	png += chunk(b"IDAT", zlib.compress(raw, 9))
	png += chunk(b"IEND", b"")
	Path(path).parent.mkdir(parents=True, exist_ok=True)
	Path(path).write_bytes(png)


def main():
	out = Path("assets/sprites/flat_stage")
	write_png(out / "sky.png", paint_sky())
	write_png(out / "deck.png", paint_deck())
	write_png(out / "platform.png", paint_platform())
	print("wrote %s" % out)


if __name__ == "__main__":
	main()
