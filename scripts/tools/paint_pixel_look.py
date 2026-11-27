#!/usr/bin/env python3

import math
import struct
import zlib
from pathlib import Path

W = 48
H = 96
SOLE = 95

ELON = "elon_mvsk"
STEVE = "steve_jobz"


def rgb(hex_color):
	value = hex_color.lstrip("#")
	return (int(value[0:2], 16), int(value[2:4], 16), int(value[4:6], 16))


def ramp(*hexes):
	return [rgb(item) for item in hexes]


COAT = ramp("#0c0c10", "#16161e", "#3a3848", "#c8b8a4")
SHIRT = rgb("#101820")
CYAN = rgb("#00AEEF")
CYAN_DEEP = rgb("#0678a8")
ROCKET = ramp("#8a2814", "#FF6A3D", "#ffd0a4")
SKIN = ramp("#7a4636", "#c48468", "#f0c0a4", "#ffe0cc")
HAIR_ELON = ramp("#140e0c", "#3a2820", "#6a5040", "#a08068")
PANTS = ramp("#101018", "#222230", "#3a3a4c")
BOOT = ramp("#0c0c10", "#2a2824", "#6a645c")
TURTLE = ramp("#050505", "#141418", "#32323c", "#d2c8bc")
HAIR_STEVE = ramp("#5a5a60", "#b4b4b8", "#F4F4F4", "#ffffff")
JEANS = ramp("#121820", "#243044", "#3c5068")
SHOE = ramp("#b0b0b4", "#F4F4F4", "#ffffff")
LENS = rgb("#8DD7FF")
LENS_HOT = rgb("#f4fbff")
FRAME = rgb("#121216")
PUPIL = rgb("#1a1210")


class Canvas:
	def __init__(self):
		self.pixels = {}

	def set(self, x, y, color):
		ix = int(round(x))
		iy = int(round(y))
		if ix < 0 or iy < 0 or ix >= W or iy >= H:
			return
		self.pixels[(ix, iy)] = color

	def paint(self, shaded):
		for point, color in shaded.items():
			self.set(point[0], point[1], color)

	def rows(self):
		raw = []
		for y in range(H):
			row = []
			for x in range(W):
				color = self.pixels.get((x, y))
				if color is None:
					row.extend((0, 0, 0, 0))
				else:
					row.extend((color[0], color[1], color[2], 255))
			raw.append(bytes(row))
		return raw


def write_png(path, width, height, rows):
	def chunk(tag, data):
		return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

	raw = b"".join(b"\x00" + row for row in rows)
	png = b"\x89PNG\r\n\x1a\n"
	png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
	png += chunk(b"IDAT", zlib.compress(raw, 9))
	png += chunk(b"IEND", b"")
	Path(path).parent.mkdir(parents=True, exist_ok=True)
	Path(path).write_bytes(png)


def scale_rows(rows, factor, background):
	height = len(rows)
	width = (len(rows[0]) if rows else 0) // 4
	out = []
	for y in range(height):
		src = rows[y]
		line = bytearray()
		for x in range(width):
			pixel = src[x * 4:(x + 1) * 4]
			if pixel[3] < 128:
				pixel = bytes(background) + b"\xff"
			line.extend(pixel * factor)
		out.extend([bytes(line)] * factor)
	return out


def polygon_mask(points):
	if len(points) < 3:
		return set()
	ys = [point[1] for point in points]
	y0 = int(math.floor(min(ys)))
	y1 = int(math.ceil(max(ys)))
	mask = set()
	for y in range(y0, y1 + 1):
		crossings = []
		for index in range(len(points)):
			x1, y1 = points[index]
			x2, y2 = points[(index + 1) % len(points)]
			if y1 == y2:
				continue
			if (y1 <= y < y2) or (y2 <= y < y1):
				t = (y - y1) / (y2 - y1)
				crossings.append(x1 + t * (x2 - x1))
		crossings.sort()
		for index in range(0, len(crossings) - 1, 2):
			left = int(round(crossings[index]))
			right = int(round(crossings[index + 1]))
			for x in range(left, right + 1):
				mask.add((x, y))
	return mask


def ellipse_mask(cx, cy, rx, ry):
	mask = set()
	if rx <= 0 or ry <= 0:
		return mask
	for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
		for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
			nx = (x + 0.5 - cx) / rx
			ny = (y + 0.5 - cy) / ry
			if nx * nx + ny * ny <= 1.0:
				mask.add((x, y))
	return mask


def capsule_mask(x0, y0, x1, y1, radius):
	mask = set()
	length = math.hypot(x1 - x0, y1 - y0)
	steps = max(1, int(length * 2))
	pad = int(radius) + 2
	for step in range(steps + 1):
		t = step / steps
		cx = x0 + (x1 - x0) * t
		cy = y0 + (y1 - y0) * t
		for y in range(int(cy) - pad, int(cy) + pad + 1):
			for x in range(int(cx) - pad, int(cx) + pad + 1):
				if _segment_distance(x + 0.5, y + 0.5, x0, y0, x1, y1) <= radius:
					mask.add((x, y))
	return mask


def _segment_distance(px, py, x0, y0, x1, y1):
	dx = x1 - x0
	dy = y1 - y0
	length_sq = dx * dx + dy * dy
	if length_sq <= 0.0001:
		return math.hypot(px - x0, py - y0)
	t = max(0.0, min(1.0, ((px - x0) * dx + (py - y0) * dy) / length_sq))
	return math.hypot(px - (x0 + dx * t), py - (y0 + dy * t))


def line_points(x0, y0, x1, y1):
	points = []
	ix0, iy0 = int(round(x0)), int(round(y0))
	ix1, iy1 = int(round(x1)), int(round(y1))
	dx = abs(ix1 - ix0)
	dy = -abs(iy1 - iy0)
	sx = 1 if ix0 < ix1 else -1
	sy = 1 if iy0 < iy1 else -1
	err = dx + dy
	while True:
		points.append((ix0, iy0))
		if ix0 == ix1 and iy0 == iy1:
			break
		e2 = 2 * err
		if e2 >= dy:
			err += dy
			ix0 += sx
		if e2 <= dx:
			err += dx
			iy0 += sy
	return points


def shade(mask, colors):
	if not mask:
		return {}
	ys = [point[1] for point in mask]
	xs = [point[0] for point in mask]
	y_min, y_max = min(ys), max(ys)
	x_min, x_max = min(xs), max(xs)
	span_y = max(1, y_max - y_min)
	span_x = max(1, x_max - x_min)
	painted = {}
	for x, y in mask:
		up = (x, y - 1) not in mask
		left = (x - 1, y) not in mask
		down = (x, y + 1) not in mask
		right = (x + 1, y) not in mask
		if up and left:
			band = 3
		elif up or left:
			band = 2
		elif down or right:
			band = 0
		else:
			vertical = (y - y_min) / span_y
			horizontal = (x - x_min) / span_x
			if vertical > 0.62 or horizontal > 0.72:
				band = 0
			elif vertical < 0.34 and horizontal < 0.45:
				band = 2
			else:
				band = 1
		if len(colors) == 3 and band == 3:
			band = 2
		painted[(x, y)] = colors[min(band, len(colors) - 1)]
	return painted


def lean_point(x, y, origin_x, origin_y, degrees):
	angle = math.radians(degrees)
	dx = x - origin_x
	dy = y - origin_y
	cos_a = math.cos(angle)
	sin_a = math.sin(angle)
	return (origin_x + dx * cos_a - dy * sin_a, origin_y + dx * sin_a + dy * cos_a)


def bone(origin, degrees, length):
	angle = math.radians(degrees)
	return (origin[0] + math.sin(angle) * length, origin[1] + math.cos(angle) * length)


def pose(
	bob=0,
	lean=0,
	sway=0,
	front_thigh=6,
	front_knee=8,
	back_thigh=-8,
	back_knee=6,
	front_upper=6,
	front_bend=8,
	back_upper=-12,
	back_bend=-10,
	breath=0,
	fist=False,
	head_extra=0,
):
	return {
		"bob": bob,
		"lean": lean,
		"sway": sway,
		"front_thigh": front_thigh,
		"front_knee": front_knee,
		"back_thigh": back_thigh,
		"back_knee": back_knee,
		"front_upper": front_upper,
		"front_bend": front_bend,
		"back_upper": back_upper,
		"back_bend": back_bend,
		"breath": breath,
		"fist": fist,
		"head_extra": head_extra,
	}


IDLE = [
	pose(bob=0, sway=0, breath=0),
	pose(bob=-1, sway=0, breath=1, front_upper=8, back_upper=-10),
	pose(bob=-1, sway=1, breath=1, front_upper=12, back_upper=-8),
	pose(bob=0, sway=1, breath=0, front_upper=11, back_upper=-14),
]

WALK = [
	pose(bob=0, sway=-1, front_thigh=32, front_knee=10, back_thigh=-28, back_knee=6, front_upper=-18, front_bend=-24, back_upper=22, back_bend=12),
	pose(bob=1, sway=0, front_thigh=14, front_knee=38, back_thigh=-8, back_knee=18, front_upper=-6, front_bend=-8, back_upper=12, back_bend=8),
	pose(bob=-1, sway=1, front_thigh=-8, front_knee=16, back_thigh=18, back_knee=34, front_upper=8, front_bend=10, back_upper=-4, back_bend=-6),
	pose(bob=0, sway=1, front_thigh=-30, front_knee=8, back_thigh=30, back_knee=12, front_upper=24, front_bend=14, back_upper=-20, back_bend=-22),
	pose(bob=1, sway=0, front_thigh=-10, front_knee=20, back_thigh=12, back_knee=40, front_upper=14, front_bend=8, back_upper=-8, back_bend=-10),
	pose(bob=-1, sway=-1, front_thigh=10, front_knee=30, back_thigh=-6, back_knee=14, front_upper=-4, front_bend=4, back_upper=6, back_bend=4),
]

LIGHT = [
	pose(bob=0, lean=-6, sway=-1, front_upper=-46, front_bend=-36, back_upper=8, back_bend=6, front_thigh=10, back_thigh=-4),
	pose(bob=-1, lean=8, sway=-2, front_upper=74, front_bend=6, back_upper=-28, back_bend=-8, front_thigh=16, front_knee=6, fist=True),
	pose(bob=0, lean=5, sway=-1, front_upper=68, front_bend=4, back_upper=-16, back_bend=-6, fist=True),
	pose(bob=0, lean=1, sway=0, front_upper=36, front_bend=18, back_upper=-8, fist=False),
]

JUMP = [
	pose(bob=2, lean=4, sway=1, front_thigh=36, front_knee=48, back_thigh=24, back_knee=40, front_upper=-20, front_bend=-16, back_upper=-36, back_bend=-20),
	pose(bob=-3, lean=-2, sway=-2, front_thigh=108, front_knee=78, back_thigh=96, back_knee=70, front_upper=46, front_bend=10, back_upper=-20, back_bend=8, head_extra=-1),
	pose(bob=-2, lean=2, sway=-3, front_thigh=100, front_knee=64, back_thigh=138, back_knee=96, front_upper=28, front_bend=20, back_upper=18, back_bend=12, head_extra=-1),
]

HIT = [
	pose(bob=0, lean=-12, sway=3, front_upper=-24, front_bend=20, back_upper=-40, back_bend=-16, front_thigh=8, back_thigh=-14, head_extra=1),
	pose(bob=1, lean=-18, sway=5, front_upper=-10, front_bend=28, back_upper=-56, back_bend=-10, front_thigh=4, front_knee=16, back_thigh=-6, head_extra=2),
]


def _head_points(cx, cy, kind):
	if kind == ELON:
		local = [
			(-8, -1), (-9, -8), (-5, -13), (1, -15), (7, -12), (9, -7),
			(12, -5), (15, -3), (12, -1), (13, 2), (10, 4), (5, 7), (0, 8), (-6, 5),
		]
	else:
		local = [
			(-7, 0), (-8, -6), (-3, -12), (3, -13), (8, -9), (10, -5),
			(12, -3), (10, -1), (11, 2), (8, 4), (3, 7), (-2, 7), (-6, 4),
		]
	return [(cx + dx, cy + dy) for dx, dy in local]


def _hair_points(cx, cy, kind):
	if kind == ELON:
		local = [
			(-14, 0), (-16, -8), (-12, -15), (-6, -19), (1, -20), (8, -16),
			(12, -10), (9, -6), (3, -9), (-4, -8), (-10, -3), (-13, 2),
		]
	else:
		local = [
			(-6, -2), (-7, -8), (-2, -12), (4, -12), (8, -8), (6, -4),
			(1, -5), (-4, -3),
		]
	return [(cx + dx, cy + dy) for dx, dy in local]


def _coat_points(back_shoulder, front_shoulder, hip, sway, breath):
	bx, by = back_shoulder
	fx, fy = front_shoulder
	hx, hy = hip
	return [
		(bx - 4, by - 2),
		(fx + 5 + breath, fy - 1),
		(hx + 12 + sway, hy + 14),
		(hx + 14 + sway, hy + 22),
		(hx + 4 + sway, hy + 24),
		(hx - 16 + sway, hy + 23),
		(hx - 15 + sway * 0.3, hy + 6),
	]


def _boot_mask(ankle_x, ankle_y):
	return polygon_mask([
		(ankle_x - 3, ankle_y - 2),
		(ankle_x + 4, ankle_y - 3),
		(ankle_x + 8, ankle_y),
		(ankle_x + 8, ankle_y + 3),
		(ankle_x - 4, ankle_y + 3),
		(ankle_x - 4, ankle_y),
	])


def _stamp_line(canvas, x0, y0, x1, y1, color):
	for x, y in line_points(x0, y0, x1, y1):
		canvas.set(x, y, color)


def _draw_leg(canvas, hip, thigh_deg, knee_deg, colors, boot_colors, thigh_len, shin_len):
	knee = bone(hip, thigh_deg, thigh_len)
	shin_deg = thigh_deg - knee_deg
	ankle = bone(knee, shin_deg, shin_len)
	canvas.paint(shade(capsule_mask(hip[0], hip[1], knee[0], knee[1], 2.7), colors))
	canvas.paint(shade(capsule_mask(knee[0], knee[1], ankle[0], ankle[1], 2.25), colors))
	canvas.paint(shade(_boot_mask(ankle[0], ankle[1]), boot_colors))
	return ankle


def _draw_arm(canvas, shoulder, upper_deg, bend_deg, sleeve, skin, fist, upper_len, fore_len):
	elbow = bone(shoulder, upper_deg, upper_len)
	hand = bone(elbow, upper_deg + bend_deg, fore_len)
	canvas.paint(shade(capsule_mask(shoulder[0], shoulder[1], elbow[0], elbow[1], 2.05), sleeve))
	canvas.paint(shade(capsule_mask(elbow[0], elbow[1], hand[0], hand[1], 1.7), sleeve))
	radius = 2.7 if fist else 2.0
	canvas.paint(shade(ellipse_mask(hand[0], hand[1], radius, radius - 0.15), skin))
	return hand


def _draw_face(canvas, cx, cy, kind):
	eye_x = int(round(cx + (6 if kind == ELON else 5)))
	eye_y = int(round(cy - 2))
	if kind == STEVE:
		for y in range(eye_y - 3, eye_y + 3):
			for x in range(eye_x - 4, eye_x + 4):
				edge = abs(x - eye_x) == 3 or abs(y - eye_y) >= 2
				canvas.set(x, y, FRAME if edge else LENS)
		canvas.set(eye_x - 6, eye_y, FRAME)
		canvas.set(eye_x - 7, eye_y + 1, FRAME)
		canvas.set(eye_x - 8, eye_y + 2, FRAME)
		canvas.set(eye_x, eye_y, PUPIL)
		canvas.set(eye_x + 1, eye_y, PUPIL)
		canvas.set(eye_x - 1, eye_y - 1, LENS_HOT)
		canvas.set(eye_x + 2, eye_y - 1, LENS_HOT)
	else:
		canvas.set(eye_x, eye_y, PUPIL)
		canvas.set(eye_x + 1, eye_y, PUPIL)
		canvas.set(eye_x, eye_y + 1, PUPIL)
		canvas.set(eye_x - 1, eye_y, SKIN[3])
		canvas.set(eye_x, eye_y - 2, HAIR_ELON[1])
		canvas.set(eye_x + 1, eye_y - 2, HAIR_ELON[1])
		canvas.set(eye_x + 2, eye_y - 2, HAIR_ELON[2])
	nose_x = int(round(cx + (13 if kind == ELON else 11)))
	nose_y = int(round(cy - 1))
	canvas.set(nose_x, nose_y, SKIN[2])
	canvas.set(nose_x, nose_y + 1, SKIN[0])
	mouth_x = int(round(cx + 9))
	mouth_y = int(round(cy + 3))
	canvas.set(mouth_x, mouth_y, SKIN[0])
	canvas.set(mouth_x + 1, mouth_y, rgb("#a05858") if kind == ELON else SKIN[0])
	canvas.set(int(round(cx - 6)), int(round(cy + 1)), SKIN[1])
	canvas.set(int(round(cx - 6)), int(round(cy + 2)), SKIN[0])
	canvas.set(int(round(cx - 5)), int(round(cy + 2)), SKIN[2])
	canvas.set(int(round(cx + 2)), int(round(cy + 6)), SKIN[0])
	canvas.set(int(round(cx + 3)), int(round(cy + 6)), SKIN[0])


def _draw_rocket(canvas, hip, sway):
	hx, hy = hip
	ox = int(round(hx - 18 + sway))
	oy = int(round(hy + 10))
	for dy, row in enumerate((
		"...ww...",
		"..wRRw..",
		".wRHHRw.",
		"wRHWHHRw",
		".wRHHRw.",
		"..wRRw..",
		"...hh...",
		"..h..h..",
	)):
		for dx, cell in enumerate(row):
			if cell == ".":
				continue
			color = {"h": ROCKET[1], "H": ROCKET[0], "W": ROCKET[2], "w": ROCKET[1], "R": ROCKET[0]}[cell]
			canvas.set(ox + dx, oy + dy, color)


def _draw_phone(canvas, hand):
	hx, hy = int(round(hand[0])) - 1, int(round(hand[1])) - 3
	for y in range(7):
		for x in range(4):
			screen = 1 <= y <= 4 and 1 <= x <= 2
			canvas.set(hx + x, hy + y, LENS_HOT if screen and y == 2 else CYAN if screen else rgb("#141820"))


def _draw_arc(canvas, shoulder):
	sx, sy = shoulder
	for step in range(10):
		t = step / 9
		x = sx + 1 + t * 14
		y = sy + 8 - math.sin(t * math.pi) * 9
		color = LENS_HOT if step in (4, 5) else LENS
		canvas.set(x, y, color)
		canvas.set(x, y + 1, CYAN_DEEP if step not in (4, 5) else LENS)


def paint_frame(kind, frame_pose):
	canvas = Canvas()
	elon = kind == ELON
	hip_x = 18 if elon else 22
	hip_y = 64 + frame_pose["bob"]
	hip = (hip_x, hip_y)
	lean = frame_pose["lean"]
	sway = frame_pose["sway"]
	breath = frame_pose["breath"]
	front_shoulder = lean_point(hip_x + 2, hip_y - 28, hip_x, hip_y, lean)
	back_shoulder = lean_point(hip_x - 4, hip_y - 26, hip_x, hip_y, lean)
	head = lean_point(hip_x + (2 if elon else 1), hip_y - 42 + frame_pose["head_extra"], hip_x, hip_y, lean)

	sleeve = COAT if elon else TURTLE
	_draw_arm(
		canvas, back_shoulder, frame_pose["back_upper"], frame_pose["back_bend"],
		sleeve, SKIN, False, 9, 8,
	)
	leg_colors = PANTS if elon else JEANS
	boot_colors = BOOT if elon else SHOE
	_draw_leg(
		canvas, (hip_x - 2, hip_y), frame_pose["back_thigh"], frame_pose["back_knee"],
		leg_colors, boot_colors, 15, 14,
	)

	if elon:
		coat = _coat_points(back_shoulder, front_shoulder, hip, sway, breath)
		coat_mask = polygon_mask(coat)
		canvas.paint(shade(coat_mask, COAT))
		hx, hy = hip
		fold_a = lean_point(hx - 8 + sway, hy - 6, hip_x, hip_y, lean * 0.25)
		fold_b = lean_point(hx - 4 + sway, hy + 14, hip_x, hip_y, lean * 0.25)
		for x, y in line_points(fold_a[0], fold_a[1], fold_b[0], fold_b[1]):
			if (x, y) in coat_mask:
				canvas.set(x, y, COAT[0])
		slit_x = int(round(front_shoulder[0] - 1))
		for y in range(int(front_shoulder[1]) + 2, int(hip_y - 2)):
			canvas.set(slit_x, y, CYAN_DEEP)
			canvas.set(slit_x + 1, y, SHIRT)
			canvas.set(slit_x + 2, y, CYAN)
		lamp_x = int(round(front_shoulder[0] + 1))
		lamp_y = int(round(front_shoulder[1] + 8))
		canvas.set(lamp_x, lamp_y, CYAN)
		canvas.set(lamp_x, lamp_y + 1, CYAN_DEEP)
		for x, y in list(coat_mask):
			if y == max(point[1] for point in coat_mask) and x % 4 == 0:
				canvas.set(x, y + 1, COAT[1])
		_draw_rocket(canvas, hip, sway)
	else:
		collar = polygon_mask([
			(back_shoulder[0] - 1, back_shoulder[1] + 1),
			(front_shoulder[0] + 2 + breath, front_shoulder[1]),
			(front_shoulder[0] + 1, hip_y + 2),
			(back_shoulder[0] + 1, hip_y + 1),
		])
		canvas.paint(shade(collar, TURTLE))
		ridge_y = int(round(head[1] + 9))
		for x in range(int(head[0] - 4), int(head[0] + 5)):
			canvas.set(x, ridge_y, TURTLE[2])
			canvas.set(x, ridge_y + 1, TURTLE[0])

	_draw_leg(
		canvas, (hip_x + 3, hip_y), frame_pose["front_thigh"], frame_pose["front_knee"],
		leg_colors, boot_colors, 15, 14,
	)
	hand = _draw_arm(
		canvas, front_shoulder, frame_pose["front_upper"], frame_pose["front_bend"],
		sleeve, SKIN, frame_pose["fist"], 10, 9,
	)
	if elon and not frame_pose["fist"] and frame_pose["front_upper"] < 40:
		_draw_phone(canvas, hand)
	if not elon and frame_pose["front_upper"] < 50:
		_draw_arc(canvas, front_shoulder)

	canvas.paint(shade(polygon_mask(_head_points(head[0], head[1], kind)), SKIN))
	neck_top = (head[0] - 1, head[1] + 7)
	neck_mask = capsule_mask(neck_top[0], neck_top[1], (front_shoulder[0] + back_shoulder[0]) * 0.5, front_shoulder[1], 3.3)
	canvas.paint(shade(neck_mask, TURTLE if not elon else SKIN))
	if not elon:
		for x, y in neck_mask:
			if y < head[1] + 10:
				canvas.set(x, y, TURTLE[1] if (x + y) % 2 == 0 else TURTLE[0])
	canvas.paint(shade(polygon_mask(_hair_points(head[0], head[1], kind)), HAIR_ELON if elon else HAIR_STEVE))
	if elon:
		for dx, dy in ((-1, -18), (2, -17), (6, -14), (-10, -12)):
			canvas.set(head[0] + dx, head[1] + dy, HAIR_ELON[2])
	_draw_face(canvas, head[0], head[1], kind)
	return canvas


CLIPS = {
	"idle": IDLE,
	"walk": WALK,
	"light": LIGHT,
	"jump": JUMP,
	"hit": HIT,
}


def main():
	import argparse
	parser = argparse.ArgumentParser()
	parser.add_argument("--out", default="assets/sprites/pixel_look")
	parser.add_argument("--sheet", default="")
	args = parser.parse_args()
	out = Path(args.out)
	frames = []
	for kind in (ELON, STEVE):
		for clip_name, clip in CLIPS.items():
			for index, frame_pose in enumerate(clip):
				canvas = paint_frame(kind, frame_pose)
				path = out / kind / ("%s_%d.png" % (clip_name, index))
				write_png(path, W, H, canvas.rows())
				if args.sheet:
					frames.append((kind, clip_name, index, canvas.rows()))
	if args.sheet:
		sheet = Path(args.sheet)
		_write_sheet(sheet / "sheet_dark.png", frames, (18, 22, 34))
		_write_sheet(sheet / "sheet_gray.png", frames, (168, 168, 172))
	print("wrote frames under %s" % out)


def _write_sheet(path, frames, background):
	scale = 4
	pad = 6
	cell_w = W * scale
	cell_h = H * scale
	columns = 10
	rows_n = math.ceil(len(frames) / columns)
	width = columns * (cell_w + pad) + pad
	height = rows_n * (cell_h + pad) + pad
	pixels = [[background for _ in range(width)] for _ in range(height)]
	for index, (_kind, _clip, _frame, rows) in enumerate(frames):
		col = index % columns
		row = index // columns
		origin_x = pad + col * (cell_w + pad)
		origin_y = pad + row * (cell_h + pad)
		for y in range(H):
			src = rows[y]
			for x in range(W):
				pixel = src[x * 4:(x + 1) * 4]
				color = background if pixel[3] < 128 else (pixel[0], pixel[1], pixel[2])
				for sy in range(scale):
					for sx in range(scale):
						pixels[origin_y + y * scale + sy][origin_x + x * scale + sx] = color
	raw_rows = []
	for y in range(height):
		row = bytearray()
		for color in pixels[y]:
			row.extend((color[0], color[1], color[2], 255))
		raw_rows.append(bytes(row))
	write_png(path, width, height, raw_rows)


if __name__ == "__main__":
	main()
