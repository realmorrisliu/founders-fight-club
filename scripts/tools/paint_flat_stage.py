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


def paint_sky():
	width, height = 960, 540
	pixels = blank(width, height, SKY[0])
	bands = (0, 70, 150, 240, 340, height)
	for index in range(5):
		fill_rect(pixels, 0, bands[index], width, bands[index + 1] - bands[index], SKY[index])
	buildings = (
		(20, 70, 150, 0), (96, 46, 200, 1), (150, 90, 120, 2), (250, 54, 180, 0),
		(320, 80, 90, 1), (410, 40, 220, 2), (460, 96, 140, 0), (570, 60, 190, 1),
		(640, 84, 110, 2), (740, 50, 210, 0), (800, 70, 160, 1), (880, 60, 130, 2),
	)
	ground = 430
	for x, w, h, shade in buildings:
		fill_rect(pixels, x, ground - h, w, h, BUILDING[shade])
		fill_rect(pixels, x, ground - h, w, 3, DECK[2] if shade == 0 else BUILDING[0])
		for wy in range(ground - h + 12, ground - 10, 14):
			for wx in range(x + 6, x + w - 6, 10):
				color = WARM if (wx + wy) % 30 == 0 else WINDOW
				fill_rect(pixels, wx, wy, 3, 4, color)
	fill_rect(pixels, 0, ground, width, height - ground, rgb("#10141c"))
	return pixels


def paint_deck():
	width, height = 380, 36
	pixels = blank(width, height, DECK[0])
	fill_rect(pixels, 0, 0, width, 6, DECK[2])
	fill_rect(pixels, 0, 0, width, 2, DECK[3])
	fill_rect(pixels, 0, 6, width, 1, LIP)
	for x in range(0, width, 38):
		fill_rect(pixels, x, 8, 2, height - 10, EDGE)
	for y in range(10, height, 8):
		tone = DECK[1] if (y // 8) % 2 == 0 else DECK[0]
		fill_rect(pixels, 0, y, width, 4, tone)
	fill_rect(pixels, 0, height - 3, width, 3, EDGE)
	return pixels


def paint_platform():
	width, height = 72, 16
	pixels = blank(width, height, DECK[0])
	fill_rect(pixels, 0, 0, width, 4, DECK[2])
	fill_rect(pixels, 0, 0, width, 1, DECK[3])
	fill_rect(pixels, 0, 4, width, 1, LIP)
	fill_rect(pixels, 0, 6, width, height - 6, DECK[1])
	fill_rect(pixels, 0, height - 2, width, 2, EDGE)
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
