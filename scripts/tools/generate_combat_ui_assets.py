#!/usr/bin/env python3
"""Generate first-pass combat UI, arena, and impact effect assets."""

from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
UI_DIR = ROOT / "assets" / "sprites" / "ui"
ARENA_DIR = ROOT / "assets" / "sprites" / "arena"
EFFECTS_DIR = ROOT / "assets" / "sprites" / "effects"


def rgba(hex_code: str, alpha: int = 255) -> tuple[int, int, int, int]:
	hex_code = hex_code.removeprefix("#")
	return (
		int(hex_code[0:2], 16),
		int(hex_code[2:4], 16),
		int(hex_code[4:6], 16),
		alpha,
	)


def lerp_color(
	start: tuple[int, int, int, int],
	end: tuple[int, int, int, int],
	t: float,
) -> tuple[int, int, int, int]:
	return tuple(
		int(round(start[i] + (end[i] - start[i]) * t))
		for i in range(4)
	)


def vertical_gradient(
	size: tuple[int, int],
	top: tuple[int, int, int, int],
	bottom: tuple[int, int, int, int],
) -> Image.Image:
	width, height = size
	image = Image.new("RGBA", size)
	draw = ImageDraw.Draw(image)
	for y in range(height):
		t = 0.0 if height <= 1 else y / float(height - 1)
		draw.line((0, y, width, y), fill=lerp_color(top, bottom, t))
	return image


def add_scanlines(image: Image.Image, opacity: int = 18, step: int = 2) -> None:
	draw = ImageDraw.Draw(image, "RGBA")
	width, height = image.size
	for y in range(0, height, step):
		draw.line((0, y, width, y), fill=(0, 0, 0, opacity))


def add_diagonal_pattern(
	image: Image.Image,
	box: tuple[int, int, int, int],
	color: tuple[int, int, int, int],
	spacing: int = 8,
) -> None:
	draw = ImageDraw.Draw(image, "RGBA")
	left, top, right, bottom = box
	height = bottom - top
	for x in range(left - height, right, spacing):
		draw.line((x, bottom - 1, x + height, top), fill=color, width=1)


def draw_panel_frame(
	image: Image.Image,
	box: tuple[int, int, int, int],
	outer: tuple[int, int, int, int],
	inner: tuple[int, int, int, int],
	bottom_glow: tuple[int, int, int, int],
) -> None:
	draw = ImageDraw.Draw(image, "RGBA")
	left, top, right, bottom = box
	draw.rectangle((left, top, right - 1, bottom - 1), outline=outer, width=1)
	draw.rectangle((left + 1, top + 1, right - 2, bottom - 2), outline=inner, width=1)
	draw.line((left + 2, bottom - 2, right - 3, bottom - 2), fill=bottom_glow, width=1)


def add_corner_brackets(
	image: Image.Image,
	box: tuple[int, int, int, int],
	color: tuple[int, int, int, int],
) -> None:
	draw = ImageDraw.Draw(image, "RGBA")
	left, top, right, bottom = box
	length = 8
	offset = 3
	draw.line((left + offset, top + offset, left + offset + length, top + offset), fill=color)
	draw.line((left + offset, top + offset, left + offset, top + offset + length), fill=color)
	draw.line((right - offset - length, top + offset, right - offset, top + offset), fill=color)
	draw.line((right - offset, top + offset, right - offset, top + offset + length), fill=color)
	draw.line((left + offset, bottom - offset - 1, left + offset + length, bottom - offset - 1), fill=color)
	draw.line((left + offset, bottom - offset - length - 1, left + offset, bottom - offset - 1), fill=color)
	draw.line((right - offset - length, bottom - offset - 1, right - offset, bottom - offset - 1), fill=color)
	draw.line((right - offset, bottom - offset - length - 1, right - offset, bottom - offset - 1), fill=color)


def build_timer_chip() -> Image.Image:
	image = vertical_gradient((120, 28), rgba("#0B1222"), rgba("#17284A"))
	add_diagonal_pattern(image, (3, 3, 117, 25), rgba("#243B67", 90), 7)
	draw = ImageDraw.Draw(image, "RGBA")
	draw.rectangle((4, 4, 115, 8), fill=rgba("#5CD0FF", 70))
	draw.rectangle((4, 19, 115, 22), fill=rgba("#13233F", 120))
	draw_panel_frame(image, (0, 0, 120, 28), rgba("#09111F"), rgba("#3B76D9"), rgba("#64D7FF"))
	add_corner_brackets(image, (0, 0, 120, 28), rgba("#A8E8FF", 180))
	return image


def build_result_chip() -> Image.Image:
	image = vertical_gradient((380, 38), rgba("#1A1720"), rgba("#2E2530"))
	add_diagonal_pattern(image, (4, 4, 376, 34), rgba("#53415D", 80), 10)
	draw = ImageDraw.Draw(image, "RGBA")
	draw.rectangle((12, 7, 367, 13), fill=rgba("#FFCE67", 65))
	draw.rectangle((20, 24, 359, 28), fill=rgba("#4D3241", 100))
	draw.rectangle((148, 6, 232, 32), outline=rgba("#FFDC8F", 110), width=1)
	draw_panel_frame(image, (0, 0, 380, 38), rgba("#120F15"), rgba("#A55C37"), rgba("#FFCC65"))
	add_corner_brackets(image, (0, 0, 380, 38), rgba("#FFD885", 180))
	return image


def build_hp_under() -> Image.Image:
	image = vertical_gradient((228, 18), rgba("#171B29"), rgba("#2D3449"))
	draw = ImageDraw.Draw(image, "RGBA")
	for x in range(6, 222, 12):
		draw.line((x, 4, x, 13), fill=rgba("#414B66", 110))
	draw_panel_frame(image, (0, 0, 228, 18), rgba("#0B1020"), rgba("#4F5B7F"), rgba("#7B87AE"))
	return image


def build_hp_fill(primary: tuple[int, int, int, int], secondary: tuple[int, int, int, int]) -> Image.Image:
	image = vertical_gradient((228, 18), primary, secondary)
	add_diagonal_pattern(image, (2, 2, 226, 16), rgba("#FFFFFF", 44), 9)
	draw = ImageDraw.Draw(image, "RGBA")
	draw.line((2, 2, 225, 2), fill=rgba("#FFF6E8", 110))
	draw.line((2, 15, 225, 15), fill=rgba("#34202C", 90))
	draw_panel_frame(image, (0, 0, 228, 18), rgba("#3C2433"), rgba("#FFD9C1", 70), rgba("#FFE5C3", 110))
	return image


def build_pause_panel() -> Image.Image:
	image = vertical_gradient((320, 260), rgba("#0A1224"), rgba("#111B34"))
	add_diagonal_pattern(image, (6, 6, 314, 254), rgba("#1A2A4E", 85), 10)
	add_scanlines(image, opacity=12, step=3)
	draw = ImageDraw.Draw(image, "RGBA")
	draw.rectangle((12, 14, 307, 44), fill=rgba("#17335D", 180))
	draw.rectangle((18, 20, 301, 38), fill=rgba("#0F203C", 170))
	draw.line((18, 42, 301, 42), fill=rgba("#FFCB6A", 160), width=1)
	draw.rectangle((22, 58, 298, 240), outline=rgba("#294D85", 150), width=1)
	draw.rectangle((26, 62, 294, 236), outline=rgba("#10213D", 200), width=1)
	draw_panel_frame(image, (0, 0, 320, 260), rgba("#08101E"), rgba("#3780E6"), rgba("#67D9FF"))
	add_corner_brackets(image, (0, 0, 320, 260), rgba("#A9E5FF", 180))
	return image


def build_menu_background() -> Image.Image:
	image = vertical_gradient((1280, 720), rgba("#09111F"), rgba("#101B33"))
	draw = ImageDraw.Draw(image, "RGBA")
	for x in range(0, 1280, 64):
		draw.line((x, 0, x, 720), fill=rgba("#14325C", 36), width=1)
	for y in range(0, 720, 64):
		draw.line((0, y, 1280, y), fill=rgba("#10294D", 28), width=1)
	for x in (140, 356, 922, 1128):
		draw.rectangle((x, 80, x + 2, 640), fill=rgba("#3F7EE0", 38))
	for y in (160, 372, 584):
		draw.rectangle((80, y, 1200, y + 2), fill=rgba("#18345C", 34))
	add_scanlines(image, opacity=10, step=2)
	return image


def build_menu_panel(size: tuple[int, int], accent: tuple[int, int, int, int]) -> Image.Image:
	image = vertical_gradient(size, rgba("#0B1528"), rgba("#111E38"))
	add_diagonal_pattern(image, (4, 4, size[0] - 4, size[1] - 4), rgba("#18335F", 78), 10)
	draw = ImageDraw.Draw(image, "RGBA")
	draw.rectangle((14, 14, size[0] - 15, 44), fill=rgba("#132847", 185))
	draw.line((18, 42, size[0] - 19, 42), fill=accent, width=1)
	draw_panel_frame(image, (0, 0, size[0], size[1]), rgba("#08101E"), rgba("#346FCB"), accent)
	add_corner_brackets(image, (0, 0, size[0], size[1]), rgba("#A9E5FF", 168))
	return image


def build_menu_slot_card() -> Image.Image:
	image = vertical_gradient((116, 38), rgba("#111C31"), rgba("#162440"))
	add_diagonal_pattern(image, (3, 3, 113, 35), rgba("#1F416F", 54), 9)
	draw = ImageDraw.Draw(image, "RGBA")
	draw.rectangle((4, 4, 31, 33), outline=rgba("#5FA2FF", 128), width=1)
	draw.line((36, 30, 108, 30), fill=rgba("#2F4E79", 108), width=1)
	draw_panel_frame(image, (0, 0, 116, 38), rgba("#0A1222"), rgba("#2E5EAF"), rgba("#6BD4FF"))
	return image


def build_hud_panel(size: tuple[int, int], accent: tuple[int, int, int, int]) -> Image.Image:
	image = vertical_gradient(size, rgba("#0A1326"), rgba("#111B34"))
	add_diagonal_pattern(image, (3, 3, size[0] - 3, size[1] - 3), rgba("#173258", 74), 9)
	draw = ImageDraw.Draw(image, "RGBA")
	draw.rectangle((10, 10, size[0] - 11, 30), fill=rgba("#13233F", 170))
	draw.line((14, 28, size[0] - 15, 28), fill=accent, width=1)
	draw_panel_frame(image, (0, 0, size[0], size[1]), rgba("#08101E"), rgba("#346FCB"), accent)
	return image


def build_hud_card(size: tuple[int, int], accent: tuple[int, int, int, int]) -> Image.Image:
	image = vertical_gradient(size, rgba("#10192D"), rgba("#16233E"))
	add_diagonal_pattern(image, (3, 3, size[0] - 3, size[1] - 3), rgba("#1C3A64", 66), 8)
	draw = ImageDraw.Draw(image, "RGBA")
	draw.rectangle((8, 8, size[0] - 9, 26), fill=rgba("#13233F", 155))
	draw.line((10, 24, size[0] - 11, 24), fill=accent, width=1)
	draw_panel_frame(image, (0, 0, size[0], size[1]), rgba("#08101E"), rgba("#2C5DAE"), accent)
	return image


def draw_city_layer(
	draw: ImageDraw.ImageDraw,
	rng: random.Random,
	width: int,
	baseline: int,
	building_color: tuple[int, int, int, int],
	window_color: tuple[int, int, int, int],
	width_range: tuple[int, int],
	height_range: tuple[int, int],
	window_rate: float,
) -> None:
	x = -12
	while x < width + 24:
		building_w = rng.randint(*width_range)
		building_h = rng.randint(*height_range)
		y = baseline - building_h
		draw.rectangle((x, y, x + building_w - 1, baseline), fill=building_color)
		if rng.random() < 0.35:
			roof_w = max(8, building_w // 3)
			roof_h = rng.randint(6, 14)
			roof_x = x + rng.randint(2, max(2, building_w - roof_w - 2))
			draw.rectangle((roof_x, y - roof_h, roof_x + roof_w, y), fill=building_color)
		for window_x in range(x + 4, x + building_w - 4, 5):
			for window_y in range(y + 6, baseline - 4, 7):
				if rng.random() < window_rate:
					draw.rectangle((window_x, window_y, window_x + 1, window_y + 2), fill=window_color)
		x += building_w - rng.randint(3, 8)


def build_arena_background() -> Image.Image:
	image = vertical_gradient((960, 540), rgba("#588FCA"), rgba("#E3BE95"))
	draw = ImageDraw.Draw(image, "RGBA")
	for y in range(305, 420):
		alpha = int(55 * (1.0 - abs(y - 360) / 115.0))
		draw.line((0, y, 960, y), fill=(255, 236, 210, max(alpha, 0)))
	draw.ellipse((650, 56, 745, 151), fill=rgba("#F5E9C4", 38))
	rng = random.Random(17)
	draw_city_layer(draw, rng, 960, 280, rgba("#44527A"), rgba("#FDF3BC"), (20, 54), (28, 98), 0.18)
	draw_city_layer(draw, rng, 960, 320, rgba("#23365E"), rgba("#FFF3B7"), (24, 62), (46, 122), 0.12)
	draw.rectangle((0, 320, 959, 539), fill=rgba("#203052", 28))
	for x in (134, 412, 706):
		draw.rectangle((x, 176, x + 24, 188), fill=rgba("#59C5FF", 105))
		draw.rectangle((x + 4, 180, x + 20, 184), fill=rgba("#0A1932", 140))
	add_scanlines(image, opacity=10, step=2)
	return image


def build_arena_floor() -> Image.Image:
	image = vertical_gradient((960, 220), rgba("#5E5A6B"), rgba("#111528"))
	draw = ImageDraw.Draw(image, "RGBA")
	draw.rectangle((0, 0, 959, 22), fill=rgba("#383849", 185))
	for y in range(0, 220, 20):
		draw.line((0, y, 960, y), fill=rgba("#272A3B", 170), width=1)
	for x in range(0, 960, 40):
		draw.line((x, 0, x, 220), fill=rgba("#2F3144", 165), width=1)
	for y in range(110, 220, 2):
		alpha = min(70, (y - 110) // 2)
		draw.line((0, y, 960, y), fill=(0, 0, 0, alpha))
	draw.line((480, 0, 480, 220), fill=rgba("#D1C16A", 195), width=2)
	draw.line((481, 0, 481, 220), fill=rgba("#FFF2A7", 120), width=1)
	add_scanlines(image, opacity=8, step=2)
	return image


def build_circle_icon(
	size: int,
	ring: tuple[int, int, int, int],
	center_fill: tuple[int, int, int, int],
	spokes: list[tuple[tuple[int, int], tuple[int, int], tuple[int, int, int, int]]],
) -> Image.Image:
	image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
	draw = ImageDraw.Draw(image, "RGBA")
	draw.ellipse((1, 1, size - 2, size - 2), outline=ring, width=1)
	draw.ellipse((7, 7, size - 8, size - 8), fill=center_fill)
	for start, end, color in spokes:
		draw.line((*start, *end), fill=color, width=1)
	return image


def build_guided_icon() -> Image.Image:
	image = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
	draw = ImageDraw.Draw(image, "RGBA")
	draw.ellipse((3, 3, 20, 20), outline=rgba("#77D8FF"), width=1)
	draw.line((12, 5, 12, 19), fill=rgba("#D5F6FF"), width=1)
	draw.line((5, 12, 19, 12), fill=rgba("#D5F6FF"), width=1)
	draw.ellipse((9, 9, 14, 14), fill=rgba("#FFD36E"))
	return image


def build_story_icon() -> Image.Image:
	image = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
	draw = ImageDraw.Draw(image, "RGBA")
	draw.rectangle((4, 5, 19, 18), outline=rgba("#FFD88A"), width=1)
	draw.line((8, 9, 15, 9), fill=rgba("#FFF2C9"), width=1)
	draw.line((8, 12, 15, 12), fill=rgba("#FFF2C9"), width=1)
	draw.line((8, 15, 13, 15), fill=rgba("#FFF2C9"), width=1)
	draw.polygon([(16, 5), (19, 8), (19, 5)], fill=rgba("#FFD88A"))
	return image


def build_versus_icon() -> Image.Image:
	image = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
	draw = ImageDraw.Draw(image, "RGBA")
	draw.line((4, 6, 10, 18), fill=rgba("#FF8B74"), width=2)
	draw.line((20, 6, 14, 18), fill=rgba("#6ACDFF"), width=2)
	draw.line((10, 18, 14, 18), fill=rgba("#FFF1C8"), width=1)
	return image


def build_training_icon() -> Image.Image:
	image = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
	draw = ImageDraw.Draw(image, "RGBA")
	draw.rectangle((4, 6, 19, 17), outline=rgba("#8DDEFF"), width=1)
	draw.line((8, 10, 15, 10), fill=rgba("#D9F8FF"), width=1)
	draw.line((8, 13, 12, 13), fill=rgba("#D9F8FF"), width=1)
	draw.rectangle((10, 18, 13, 20), fill=rgba("#8DDEFF"))
	return image


def build_classic_icon() -> Image.Image:
	image = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
	draw = ImageDraw.Draw(image, "RGBA")
	draw.rectangle((4, 7, 19, 16), outline=rgba("#FFD07A"), width=1)
	draw.rectangle((7, 9, 9, 11), fill=rgba("#FFF2CF"))
	draw.rectangle((11, 9, 13, 11), fill=rgba("#FFF2CF"))
	draw.rectangle((15, 9, 17, 13), fill=rgba("#FFD07A"))
	return image


def build_modern_icon() -> Image.Image:
	image = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
	draw = ImageDraw.Draw(image, "RGBA")
	draw.rounded_rectangle((4, 6, 19, 17), radius=4, outline=rgba("#77D8FF"), width=1)
	draw.ellipse((7, 9, 10, 12), fill=rgba("#DDF9FF"))
	draw.ellipse((13, 9, 16, 12), fill=rgba("#DDF9FF"))
	draw.line((10, 15, 13, 15), fill=rgba("#FFD36E"), width=1)
	return image


def build_slot_icon(slot_key: str) -> Image.Image:
	image = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
	draw = ImageDraw.Draw(image, "RGBA")
	match slot_key:
		case "signature_a":
			draw.ellipse((3, 3, 20, 20), outline=rgba("#FF8F73"), width=1)
			draw.line((8, 18, 12, 6), fill=rgba("#FFF1C9"), width=1)
			draw.line((12, 6, 16, 18), fill=rgba("#FFF1C9"), width=1)
			draw.line((9, 13, 15, 13), fill=rgba("#FF8F73"), width=1)
		case "signature_b":
			draw.ellipse((3, 3, 20, 20), outline=rgba("#77D8FF"), width=1)
			draw.arc((6, 5, 18, 17), start=270, end=90, fill=rgba("#DDF9FF"), width=1)
			draw.line((9, 12, 15, 12), fill=rgba("#77D8FF"), width=1)
			draw.line((9, 16, 15, 16), fill=rgba("#77D8FF"), width=1)
		case "signature_c":
			draw.ellipse((3, 3, 20, 20), outline=rgba("#A8B1FF"), width=1)
			draw.arc((7, 7, 17, 17), start=30, end=330, fill=rgba("#E1E5FF"), width=1)
			draw.line((12, 6, 12, 18), fill=rgba("#A8B1FF"), width=1)
		case "ultimate":
			draw.polygon(regular_star_points((12, 12), 9, 4, 5), fill=rgba("#FFD36E", 220))
			draw.ellipse((8, 8, 15, 15), fill=rgba("#FFF7DE"))
		case "item":
			draw.rectangle((6, 5, 17, 18), outline=rgba("#70F0B7"), width=1)
			draw.rectangle((8, 7, 15, 16), fill=rgba("#CBFFE6", 80))
			draw.line((8, 10, 15, 10), fill=rgba("#70F0B7"), width=1)
		case "passive":
			draw.ellipse((4, 4, 19, 19), outline=rgba("#C9A6FF"), width=1)
			draw.line((12, 6, 12, 18), fill=rgba("#F3E8FF"), width=1)
			draw.line((6, 12, 18, 12), fill=rgba("#F3E8FF"), width=1)
			draw.ellipse((10, 10, 13, 13), fill=rgba("#C9A6FF"))
	return image


def regular_star_points(
	center: tuple[int, int],
	outer_radius: int,
	inner_radius: int,
	spokes: int,
) -> list[tuple[float, float]]:
	points: list[tuple[float, float]] = []
	cx, cy = center
	for index in range(spokes * 2):
		angle = -math.pi / 2.0 + index * math.pi / float(spokes)
		radius = outer_radius if index % 2 == 0 else inner_radius
		points.append((cx + math.cos(angle) * radius, cy + math.sin(angle) * radius))
	return points


def build_counter_spark(frame: int) -> Image.Image:
	image = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
	draw = ImageDraw.Draw(image, "RGBA")
	outer_r = [14, 11, 8, 5][frame]
	inner_r = [5, 4, 3, 2][frame]
	glow_r = [11, 9, 6, 3][frame]
	draw.polygon(regular_star_points((16, 16), outer_r, inner_r, 8), fill=rgba("#FFB63E", 210))
	draw.ellipse((16 - glow_r, 16 - glow_r, 16 + glow_r, 16 + glow_r), outline=rgba("#FFE6A5", 140), width=1)
	for dx, dy, color in [
		(-outer_r, 0, rgba("#FFF0C8", 180)),
		(outer_r, 0, rgba("#FFF0C8", 180)),
		(0, -outer_r, rgba("#FFF0C8", 180)),
		(0, outer_r, rgba("#FFF0C8", 180)),
	]:
		draw.line((16, 16, 16 + dx, 16 + dy), fill=color, width=1)
	draw.ellipse((13, 13, 19, 19), fill=rgba("#FFF8E3", 235))
	return image


def build_guard_spark(frame: int) -> Image.Image:
	image = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
	draw = ImageDraw.Draw(image, "RGBA")
	ring_r = [11, 9, 7, 4][frame]
	cross_r = [10, 8, 6, 3][frame]
	draw.ellipse((16 - ring_r, 16 - ring_r, 16 + ring_r, 16 + ring_r), outline=rgba("#8EE6FF", 180), width=1)
	draw.line((16 - cross_r, 16, 16 + cross_r, 16), fill=rgba("#D6F7FF", 220), width=1)
	draw.line((16, 16 - cross_r, 16, 16 + cross_r), fill=rgba("#D6F7FF", 220), width=1)
	diag = max(2, cross_r - 2)
	draw.line((16 - diag, 16 - diag, 16 + diag, 16 + diag), fill=rgba("#6BCBFF", 160), width=1)
	draw.line((16 - diag, 16 + diag, 16 + diag, 16 - diag), fill=rgba("#6BCBFF", 160), width=1)
	draw.ellipse((14, 14, 18, 18), fill=rgba("#F5FFFF", 210))
	return image


def save(image: Image.Image, path: Path) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	image.save(path)
	print(f"wrote {path.relative_to(ROOT)}")


def main() -> None:
	save(build_menu_background(), UI_DIR / "menu_bg.png")
	save(build_menu_panel((360, 680), rgba("#69D8FF")), UI_DIR / "menu_center_panel.png")
	save(build_menu_panel((280, 396), rgba("#69D8FF")), UI_DIR / "menu_summary_panel.png")
	save(build_menu_panel((430, 220), rgba("#FFD36E")), UI_DIR / "menu_overlay_panel.png")
	save(build_menu_slot_card(), UI_DIR / "menu_slot_card.png")
	save(build_timer_chip(), UI_DIR / "hud_timer_chip.png")
	save(build_result_chip(), UI_DIR / "hud_result_chip.png")
	save(build_hp_under(), UI_DIR / "hp_under.png")
	save(build_hp_fill(rgba("#FF7466"), rgba("#C94850")), UI_DIR / "hp_fill_p1.png")
	save(build_hp_fill(rgba("#52C7FF"), rgba("#2C73E4")), UI_DIR / "hp_fill_p2.png")
	save(build_pause_panel(), UI_DIR / "hud_pause_panel.png")
	save(build_hud_panel((336, 196), rgba("#69D8FF")), UI_DIR / "hud_training_panel.png")
	save(build_hud_panel((392, 110), rgba("#FFD36E")), UI_DIR / "hud_onboarding_panel.png")
	save(build_hud_panel((556, 298), rgba("#69D8FF")), UI_DIR / "hud_round_tuning_panel.png")
	save(build_hud_card((248, 170), rgba("#FFD36E")), UI_DIR / "hud_choice_card.png")
	save(build_guided_icon(), UI_DIR / "icon_guided.png")
	save(build_story_icon(), UI_DIR / "icon_story.png")
	save(build_versus_icon(), UI_DIR / "icon_versus.png")
	save(build_training_icon(), UI_DIR / "icon_training.png")
	save(build_classic_icon(), UI_DIR / "icon_classic.png")
	save(build_modern_icon(), UI_DIR / "icon_modern.png")
	for slot_key in ["signature_a", "signature_b", "signature_c", "ultimate", "item", "passive"]:
		save(build_slot_icon(slot_key), UI_DIR / f"icon_{slot_key}.png")
	save(build_arena_background(), ARENA_DIR / "arena_bg.png")
	save(build_arena_floor(), ARENA_DIR / "arena_floor.png")
	for frame in range(4):
		save(build_counter_spark(frame), EFFECTS_DIR / f"counter_spark_{frame}.png")
		save(build_guard_spark(frame), EFFECTS_DIR / f"guard_spark_{frame}.png")


if __name__ == "__main__":
	main()
