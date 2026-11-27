#!/usr/bin/env python3

from pathlib import Path

W, H = 24, 48

PALETTE = {
    "block": {
        "elon": {
            "skin": (244, 204, 170),
            "hair": (46, 30, 22),
            "shirt": (16, 16, 22),
            "pants": (52, 52, 62),
            "shoe": (12, 12, 16),
            "eye": (28, 20, 24),
            "stubble": (150, 96, 72),
            "rocket": (236, 236, 242),
            "nosecone": (196, 46, 40),
            "outline": (14, 10, 16),
        },
        "steve": {
            "skin": (236, 196, 164),
            "hair": (176, 176, 184),
            "shirt": (12, 12, 16),
            "pants": (36, 78, 150),
            "shoe": (232, 232, 238),
            "sole": (120, 124, 132),
            "eye": (24, 24, 28),
            "rim": (214, 220, 228),
            "lens": (48, 56, 72),
            "slab": (220, 224, 232),
            "slab_edge": (96, 102, 114),
            "outline": (14, 10, 16),
        },
    },
    "ink": {
        "elon": {
            "skin": (240, 196, 160),
            "skin_d": (188, 132, 102),
            "hair": (40, 26, 18),
            "hair_d": (22, 14, 12),
            "shirt": (28, 28, 36),
            "shirt_d": (10, 10, 14),
            "pants": (64, 64, 76),
            "pants_d": (34, 34, 42),
            "shoe": (16, 16, 20),
            "eye": (22, 16, 18),
            "stubble": (122, 78, 58),
            "rocket": (228, 228, 234),
            "nosecone": (176, 40, 34),
            "outline": (12, 8, 14),
        },
        "steve": {
            "skin": (232, 190, 156),
            "skin_d": (184, 128, 100),
            "hair": (168, 168, 176),
            "hair_d": (112, 112, 122),
            "shirt": (18, 18, 22),
            "shirt_d": (8, 8, 10),
            "rib": (48, 48, 56),
            "pants": (42, 86, 158),
            "pants_d": (24, 52, 108),
            "shoe": (230, 230, 236),
            "sole": (96, 100, 110),
            "eye": (20, 20, 24),
            "rim": (206, 214, 222),
            "lens": (36, 44, 58),
            "slab": (214, 218, 226),
            "slab_edge": (88, 94, 106),
            "outline": (12, 8, 14),
        },
    },
    "ramp": {
        "elon": {
            "skin": (250, 214, 184),
            "skin_m": (226, 170, 132),
            "skin_d": (168, 108, 80),
            "hair": (86, 56, 36),
            "hair_m": (48, 30, 20),
            "hair_d": (24, 14, 12),
            "shirt": (62, 62, 74),
            "shirt_m": (28, 28, 36),
            "shirt_d": (12, 12, 16),
            "pants": (92, 92, 104),
            "pants_m": (54, 54, 64),
            "pants_d": (28, 28, 36),
            "shoe": (36, 36, 42),
            "eye": (36, 24, 28),
            "stubble": (140, 90, 68),
            "rocket": (244, 244, 248),
            "rocket_d": (160, 164, 176),
            "nosecone": (214, 72, 56),
        },
        "steve": {
            "skin": (246, 208, 176),
            "skin_m": (214, 160, 124),
            "skin_d": (160, 104, 78),
            "hair": (196, 196, 204),
            "hair_m": (150, 150, 160),
            "hair_d": (96, 96, 108),
            "shirt": (42, 42, 50),
            "shirt_m": (18, 18, 24),
            "shirt_d": (8, 8, 12),
            "rib": (72, 72, 82),
            "pants": (64, 112, 186),
            "pants_m": (36, 74, 140),
            "pants_d": (20, 44, 96),
            "shoe": (236, 236, 242),
            "sole": (110, 114, 124),
            "eye": (28, 28, 34),
            "rim": (220, 226, 234),
            "lens": (52, 64, 84),
            "slab": (228, 232, 238),
            "slab_d": (140, 146, 158),
        },
    },
}


def blank():
    return [[None for _ in range(W)] for _ in range(H)]


def put(buf, x, y, color):
    if color is None:
        return
    if 0 <= x < W and 0 <= y < H:
        buf[y][x] = color


def rect(buf, x, y, w, h, color):
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            put(buf, xx, yy, color)


def outline(buf, color, radius=1, neighbors=8):
    height = len(buf)
    width = len(buf[0])
    steps = ((-1, 0), (1, 0), (0, -1), (0, 1))
    if neighbors == 8:
        steps = tuple((dx, dy) for dy in (-1, 0, 1) for dx in (-1, 0, 1) if dx or dy)
    for _ in range(radius):
        marks = []
        for y in range(height):
            for x in range(width):
                if buf[y][x] is not None:
                    continue
                hit = False
                for dx, dy in steps:
                    yy, xx = y + dy, x + dx
                    if 0 <= yy < height and 0 <= xx < width and buf[yy][xx] is not None:
                        hit = True
                        break
                if hit:
                    marks.append((x, y))
        for x, y in marks:
            buf[y][x] = color


def scale2(small):
    buf = blank()
    for y, row in enumerate(small):
        for x, color in enumerate(row):
            if color is None:
                continue
            for dy in (0, 1):
                for dx in (0, 1):
                    buf[y * 2 + dy][x * 2 + dx] = color
    return buf


def darken_where_below_or_left_is_empty(buf):
    original = [row[:] for row in buf]
    for y in range(H):
        for x in range(W):
            color = original[y][x]
            if color is None:
                continue
            below = original[y + 1][x] if y + 1 < H else None
            left = original[y][x - 1] if x - 1 >= 0 else None
            if below is None or left is None:
                r, g, b = color
                buf[y][x] = (int(r * 0.72), int(g * 0.72), int(b * 0.72))


def _stance(stride):
    if stride > 0:
        return 4, 15
    if stride < 0:
        return 14, 5
    return 7, 13


def _small():
    return [[None for _ in range(12)] for _ in range(24)]


def _sput(buf, x, y, color):
    if color is None:
        return
    if 0 <= x < len(buf[0]) and 0 <= y < len(buf):
        buf[y][x] = color


def _srect(buf, x, y, w, h, color):
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            _sput(buf, xx, yy, color)


def _elon_block(pal, bob, stride, arm, blink):
    buf = _small()
    y = 0 if bob >= 0 else -1
    _srect(buf, 3, 2 + y, 6, 7, pal["skin"])
    _srect(buf, 3, 1 + y, 5, 3, pal["hair"])
    _srect(buf, 2, 3 + y, 2, 4, pal["hair"])
    _sput(buf, 8, 4 + y, pal["skin"])
    if blink:
        _sput(buf, 7, 5 + y, pal["eye"])
    else:
        _sput(buf, 7, 4 + y, pal["eye"])
        _sput(buf, 7, 5 + y, pal["eye"])
    _sput(buf, 7, 7 + y, pal["stubble"])
    _srect(buf, 4, 9 + y, 2, 1, pal["skin"])
    _srect(buf, 3, 10 + y, 5, 5, pal["shirt"])
    _srect(buf, 2, 11 + y, 2, 3, pal["shirt"])
    if arm == 0:
        _srect(buf, 8, 11 + y, 1, 4, pal["skin"])
    elif arm == 1:
        _srect(buf, 8, 10 + y, 2, 2, pal["skin"])
    else:
        _srect(buf, 8, 11 + y, 2, 1, pal["skin"])
        _srect(buf, 10, 10 + y, 2, 1, pal["rocket"])
        _sput(buf, 11, 10 + y, pal["nosecone"])
    back_x = 2 - max(stride, 0)
    front_x = 7 + max(stride, 0)
    if stride < 0:
        back_x = 5
        front_x = 3
    lift = 1 if stride else 0
    _srect(buf, back_x, 15 + y + lift, 2, 6 - lift, pal["pants"])
    _srect(buf, front_x, 15 + y, 2, 6, pal["pants"])
    _srect(buf, back_x, 21 + y, 2, 2, pal["shoe"])
    _srect(buf, front_x, 21 + y, 2, 2, pal["shoe"])
    outline(buf, pal["outline"], 1, neighbors=4)
    return scale2(buf)


def _steve_block(pal, bob, stride, arm, blink):
    buf = _small()
    y = 1 if bob >= 0 else 0
    _srect(buf, 3, 3 + y, 6, 6, pal["skin"])
    _srect(buf, 2, 5 + y, 2, 3, pal["hair"])
    _srect(buf, 3, 8 + y, 3, 1, pal["hair"])
    if blink:
        _srect(buf, 7, 5 + y, 2, 1, pal["rim"])
    else:
        _srect(buf, 6, 5 + y, 3, 3, pal["rim"])
        _sput(buf, 7, 6 + y, pal["lens"])
        _sput(buf, 7, 6 + y, pal["eye"])
    _srect(buf, 4, 9 + y, 4, 1, pal["shirt"])
    _srect(buf, 3, 10 + y, 5, 5, pal["shirt"])
    _srect(buf, 2, 11 + y, 2, 3, pal["shirt"])
    if arm == 0:
        _srect(buf, 8, 11 + y, 1, 4, pal["shirt"])
    elif arm == 1:
        _srect(buf, 8, 10 + y, 2, 2, pal["shirt"])
    else:
        _srect(buf, 8, 11 + y, 2, 1, pal["shirt"])
        _srect(buf, 10, 9 + y, 2, 3, pal["slab"])
        _sput(buf, 10, 11 + y, pal["slab_edge"])
        _sput(buf, 11, 11 + y, pal["slab_edge"])
    back_x = 2 - max(stride, 0)
    front_x = 7 + max(stride, 0)
    if stride < 0:
        back_x = 5
        front_x = 3
    lift = 1 if stride else 0
    _srect(buf, back_x, 15 + y + lift, 2, 5 - lift, pal["pants"])
    _srect(buf, front_x, 15 + y, 2, 6, pal["pants"])
    _srect(buf, back_x, 20 + y, 2, 1, pal["shoe"])
    _srect(buf, back_x, 21 + y, 2, 1, pal["sole"])
    _srect(buf, front_x, 20 + y, 2, 1, pal["shoe"])
    _srect(buf, front_x, 21 + y, 2, 1, pal["sole"])
    outline(buf, pal["outline"], 1, neighbors=4)
    return scale2(buf)


def draw_elon(style, pose):
    pal = PALETTE[style]["elon"]
    buf = blank()
    bob = pose.get("bob", 0)
    stride = pose.get("stride", 0)
    arm = pose.get("arm", 0)
    blink = pose.get("blink", False)
    if style == "block":
        return _elon_block(pal, bob, stride, arm, blink)
    else:
        skin = pal["skin"]
        skin_d = pal.get("skin_d", skin)
        hair = pal["hair"]
        hair_d = pal.get("hair_d", pal.get("hair_m", hair))
        shirt = pal["shirt"]
        shirt_d = pal.get("shirt_d", pal.get("shirt_m", shirt))
        pants = pal["pants"]
        pants_d = pal.get("pants_d", pal.get("pants_m", pants))
        y = bob
        rect(buf, 9, 3 + y, 9, 11, skin)
        rect(buf, 8, 4 + y, 2, 8, skin_d)
        rect(buf, 10, 2 + y, 6, 3, hair)
        rect(buf, 8, 3 + y, 3, 6, hair)
        rect(buf, 8, 8 + y, 2, 3, hair_d)
        put(buf, 16, 6 + y, skin)
        put(buf, 17, 7 + y, skin)
        if not blink:
            rect(buf, 15, 7 + y, 2, 2, pal["eye"])
        else:
            rect(buf, 15, 8 + y, 2, 1, pal["eye"])
        put(buf, 15, 11 + y, pal["stubble"])
        put(buf, 14, 12 + y, pal["stubble"])
        put(buf, 16, 12 + y, pal["stubble"])
        rect(buf, 11, 13 + y, 3, 3, skin)
        rect(buf, 10, 14 + y, 1, 2, skin_d)
        rect(buf, 8, 16 + y, 9, 13, shirt)
        rect(buf, 8, 16 + y, 2, 13, shirt_d)
        rect(buf, 8, 27 + y, 9, 2, shirt_d)
        rect(buf, 5, 17 + y, 3, 9, shirt_d)
        if arm == 0:
            rect(buf, 16, 18 + y, 3, 10, skin)
            rect(buf, 16, 18 + y, 1, 10, skin_d)
        elif arm == 1:
            rect(buf, 15, 15 + y, 4, 4, skin)
        else:
            rect(buf, 16, 17 + y, 5, 3, skin)
            rect(buf, 20, 16 + y, 3, 2, pal["rocket"])
            rect(buf, 22, 16 + y, 2, 2, pal["nosecone"])
        back_x, front_x = _stance(stride)
        leg_y = 29 + y
        lift = 2 if stride else 0
        rect(buf, back_x, leg_y + lift, 3, 14 - lift, pants_d)
        rect(buf, front_x, leg_y, 3, 15, pants)
        put(buf, 17, 7 + y, skin)
        put(buf, 18, 8 + y, skin)
        rect(buf, back_x, 42 + y, 4, 4, pal["shoe"])
        rect(buf, front_x, 43 + y, 5, 4, pal["shoe"])
        if style == "ink":
            outline(buf, pal["outline"], 1)
        else:
            darken_where_below_or_left_is_empty(buf)
    return buf


def draw_steve(style, pose):
    pal = PALETTE[style]["steve"]
    buf = blank()
    bob = pose.get("bob", 0)
    stride = pose.get("stride", 0)
    arm = pose.get("arm", 0)
    blink = pose.get("blink", False)
    if style == "block":
        return _steve_block(pal, bob, stride, arm, blink)
    else:
        skin = pal["skin"]
        skin_d = pal.get("skin_d", skin)
        hair = pal["hair"]
        hair_d = pal.get("hair_d", pal.get("hair_m", hair))
        shirt = pal["shirt"]
        shirt_d = pal.get("shirt_d", pal.get("shirt_m", shirt))
        pants = pal["pants"]
        pants_d = pal.get("pants_d", pal.get("pants_m", pants))
        y = bob + 1
        rect(buf, 9, 4 + y, 9, 11, skin)
        rect(buf, 8, 6 + y, 3, 7, hair)
        rect(buf, 8, 12 + y, 6, 2, hair_d)
        rect(buf, 9, 5 + y, 2, 3, skin_d)
        if not blink:
            rect(buf, 14, 8 + y, 4, 4, pal["lens"])
            for px, py in ((14, 8), (15, 8), (16, 8), (17, 8), (14, 11), (15, 11), (16, 11), (17, 11), (14, 9), (14, 10), (17, 9), (17, 10)):
                put(buf, px, py + y, pal["rim"])
            put(buf, 15, 9 + y, pal["eye"])
            put(buf, 16, 10 + y, pal["eye"])
        else:
            rect(buf, 14, 9 + y, 4, 1, pal["rim"])
        rect(buf, 9, 14 + y, 8, 15, shirt)
        rect(buf, 10, 13 + y, 5, 2, shirt)
        if "rib" in pal:
            rect(buf, 11, 14 + y, 4, 1, pal["rib"])
        rect(buf, 9, 14 + y, 2, 15, shirt_d)
        rect(buf, 6, 16 + y, 3, 10, shirt_d)
        if arm == 0:
            rect(buf, 16, 17 + y, 3, 11, shirt)
            rect(buf, 16, 17 + y, 1, 11, shirt_d)
        elif arm == 1:
            rect(buf, 15, 14 + y, 4, 4, shirt)
        else:
            rect(buf, 16, 16 + y, 4, 3, shirt)
            rect(buf, 19, 14 + y, 4, 7, pal["slab"])
            rect(buf, 19, 20 + y, 4, 1, pal.get("slab_edge", pal.get("slab_d")))
        back_x, front_x = _stance(stride)
        lift = 2 if stride else 0
        rect(buf, back_x, 29 + y + lift, 3, 13 - lift, pants_d)
        rect(buf, front_x, 29 + y, 3, 14, pants)
        rect(buf, back_x, 41 + y, 4, 3, pal["shoe"])
        rect(buf, back_x, 44 + y, 4, 2, pal["sole"])
        rect(buf, front_x, 42 + y, 5, 3, pal["shoe"])
        rect(buf, front_x, 45 + y, 5, 2, pal["sole"])
        if style == "ink":
            outline(buf, pal["outline"], 1)
        else:
            darken_where_below_or_left_is_empty(buf)
    return buf


POSES = {
    "idle_0": {"bob": 0, "stride": 0, "arm": 0, "blink": False},
    "idle_1": {"bob": 0, "stride": 0, "arm": 0, "blink": True},
    "walk_0": {"bob": 0, "stride": 1, "arm": 0, "blink": False},
    "walk_1": {"bob": -1, "stride": 0, "arm": 1, "blink": False},
    "walk_2": {"bob": 0, "stride": -1, "arm": 0, "blink": False},
    "walk_3": {"bob": -1, "stride": 0, "arm": 0, "blink": False},
    "light_0": {"bob": 0, "stride": 0, "arm": 1, "blink": False},
    "light_1": {"bob": 0, "stride": 1, "arm": 2, "blink": False},
    "light_2": {"bob": 1, "stride": 0, "arm": 2, "blink": False},
}


def to_image(buf, scale):
    from PIL import Image
    img = Image.new("RGBA", (W * scale, H * scale), (0, 0, 0, 0))
    px = img.load()
    for y in range(H):
        for x in range(W):
            color = buf[y][x]
            if color is None:
                continue
            for dy in range(scale):
                for dx in range(scale):
                    px[x * scale + dx, y * scale + dy] = (*color, 255)
    return img


def contact(scale=6, path="/tmp/looks/contact.png"):
    looks = ["block", "ink", "ramp"]
    names = list(POSES)
    pad = 8
    cell_w = W * scale
    cell_h = H * scale
    label_h = 28
    cols = len(names)
    rows = len(looks) * 2
    sheet = Image.new(
        "RGBA",
        (cols * (cell_w + pad) + pad, rows * (cell_h + pad + label_h) + pad),
        (32, 28, 36, 255),
    )
    from PIL import Image, ImageDraw, ImageFont
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    row = 0
    for look in looks:
        for who, drawer in (("elon", draw_elon), ("steve", draw_steve)):
            for col, name in enumerate(names):
                buf = drawer(look, POSES[name])
                img = to_image(buf, scale)
                x = pad + col * (cell_w + pad)
                y = pad + row * (cell_h + pad + label_h)
                sheet.paste(img, (x, y + label_h), img)
                draw.text((x, y + 4), f"{look} {who} {name}", fill=(240, 230, 210), font=font)
            row += 1
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    sheet.save(path)
    print("wrote %s %s" % (path, sheet.size))


CHARACTERS = (
    ("elon_mvsk", draw_elon),
    ("steve_jobz", draw_steve),
)
AUTHORED = (
    ("idle", ("idle_0", "idle_1")),
    ("walk", ("walk_0", "walk_1", "walk_2", "walk_3")),
    ("light", ("light_0", "light_1", "light_2")),
)
LOOKS = ("block", "ink", "ramp")


def _legend(palette):
    letter_of = {}
    lines = []
    alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    for key in palette:
        color = palette[key]
        if color in letter_of:
            continue
        if len(letter_of) >= len(alphabet):
            raise SystemExit("palette needs more letters")
        letter = alphabet[len(letter_of)]
        letter_of[color] = letter
        lines.append("color %s %02X%02X%02X" % (letter, color[0], color[1], color[2]))
    return letter_of, lines


def _rows(buf, letter_of):
    rows = []
    for row in buf:
        chars = []
        for color in row:
            if color is None:
                chars.append(".")
                continue
            if color not in letter_of:
                raise SystemExit("pixel color missing from palette: %s" % (color,))
            chars.append(letter_of[color])
        line = "".join(chars)
        if len(line) != W:
            raise SystemExit("row width %d" % len(line))
        rows.append(line)
    if len(rows) != H:
        raise SystemExit("frame height %d" % len(rows))
    return rows


def _legend_for_frames(palette, frames):
    letter_of, lines = _legend(palette)
    alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    for _anim_name, buf in frames:
        for row in buf:
            for color in row:
                if color is None or color in letter_of:
                    continue
                if len(letter_of) >= len(alphabet):
                    raise SystemExit("palette needs more letters")
                letter = alphabet[len(letter_of)]
                letter_of[color] = letter
                lines.append("color %s %02X%02X%02X" % (letter, color[0], color[1], color[2]))
    return letter_of, lines


def emit_frames(path: Path) -> None:
    lines = []
    for look in LOOKS:
        for character_id, drawer in CHARACTERS:
            palette = PALETTE[look]["elon" if character_id == "elon_mvsk" else "steve"]
            frames = []
            for anim_name, pose_names in AUTHORED:
                for pose_name in pose_names:
                    frames.append((anim_name, drawer(look, POSES[pose_name])))
            letter_of, legend = _legend_for_frames(palette, frames)
            lines.append("look %s" % look)
            lines.append("character %s" % character_id)
            lines.extend(legend)
            for anim_name, buf in frames:
                lines.append("anim %s" % anim_name)
                lines.append("frame")
                lines.extend(_rows(buf, letter_of))
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n")
    print("wrote %s (%d lines)" % (path, len(lines)))


def main() -> None:
    import sys
    root = Path(__file__).resolve().parents[2]
    frames = root / "assets/sprites/character_looks/frames.txt"
    contact_path = ""
    args = sys.argv[1:]
    index = 0
    while index < len(args):
        if args[index] == "--contact" and index + 1 < len(args):
            contact_path = args[index + 1]
            index += 2
            continue
        if args[index] == "--frames" and index + 1 < len(args):
            frames = Path(args[index + 1])
            index += 2
            continue
        raise SystemExit("unknown argument %s" % args[index])
    emit_frames(frames)
    if contact_path:
        contact(path=contact_path)


if __name__ == "__main__":
    main()
