#!/usr/bin/env python3
"""Draw the sea creature sprite sheets for Ashen Roots.

The engine reads one PNG per enemy as a 4x3 grid of square frames:

    row 0 = idle, row 1 = move, row 2 = attack, 4 frames each.

`_draw_enemy_sprite` derives the frame size from the texture itself
(`width / 4`, `height / 3`), so a 256x192 sheet gives 64x64 frames, matching
every other enemy in the project.

Unlike a downscaled render, every frame here is *drawn* directly in 64x64
space: a spine curve defines the body, a thickness profile gives it volume,
and the shading is quantised into a handful of flat bands. That is what makes
it read as pixel art instead of a blurry photo of a fish, and it lets each
animation frame be genuinely redrawn (the body actually undulates) rather than
squashed.

Usage:
    python3 tools/generate_sea_creature_sprites.py
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ENEMY_DIR = ROOT / "assets" / "textures" / "enemies"

FRAME = 64
COLUMNS = 4
ROWS = 3

TRANSPARENT = (0, 0, 0, 0)
OUTLINE = (7, 16, 20, 255)


def rgba(value: str) -> tuple[int, int, int, int]:
    value = value.lstrip("#")
    return (int(value[0:2], 16), int(value[2:4], 16), int(value[4:6], 16), 255)


class Canvas:
    """A tiny 64x64 pixel buffer with the few operations the art needs."""

    def __init__(self, size: int = FRAME) -> None:
        self.size = size
        self.px: list[list[tuple[int, int, int, int]]] = [
            [TRANSPARENT for _ in range(size)] for _ in range(size)
        ]

    def set(self, x: int, y: int, color: tuple[int, int, int, int]) -> None:
        if 0 <= x < self.size and 0 <= y < self.size:
            self.px[y][x] = color

    def get(self, x: int, y: int) -> tuple[int, int, int, int]:
        if 0 <= x < self.size and 0 <= y < self.size:
            return self.px[y][x]
        return TRANSPARENT

    def filled(self, x: int, y: int) -> bool:
        return self.get(x, y)[3] > 0

    def vline(self, x: int, y0: int, y1: int, color: tuple[int, int, int, int]) -> None:
        for y in range(min(y0, y1), max(y0, y1) + 1):
            self.set(x, y, color)

    def disc(self, cx: int, cy: int, radius: float, color: tuple[int, int, int, int]) -> None:
        r = int(math.ceil(radius))
        for y in range(cy - r, cy + r + 1):
            for x in range(cx - r, cx + r + 1):
                if (x - cx) ** 2 + (y - cy) ** 2 <= radius * radius:
                    self.set(x, y, color)

    def outline(self, color: tuple[int, int, int, int] = OUTLINE) -> None:
        """Wrap the silhouette in a hard one pixel border, like the other art."""
        edges: list[tuple[int, int]] = []
        for y in range(self.size):
            for x in range(self.size):
                if self.filled(x, y):
                    continue
                touching = (
                    self.filled(x - 1, y)
                    or self.filled(x + 1, y)
                    or self.filled(x, y - 1)
                    or self.filled(x, y + 1)
                )
                if touching:
                    edges.append((x, y))
        for x, y in edges:
            self.set(x, y, color)

    def to_image(self) -> Image.Image:
        img = Image.new("RGBA", (self.size, self.size), TRANSPARENT)
        img.putdata([self.px[y][x] for y in range(self.size) for x in range(self.size)])
        return img


def ramp(colors: list[str]) -> list[tuple[int, int, int, int]]:
    return [rgba(c) for c in colors]


# Dark, cold and drowned, but with enough range that the body still reads
# against dark water. Index 0 is the deepest shadow, last is the rim highlight.
LURKER_RAMP = ramp(["#12303a", "#1b4652", "#27606d", "#376F7C", "#4d8f9b", "#79c0c9"])
LEVIATHAN_RAMP = ramp(["#0e2129", "#153541", "#1f4c59", "#2b6373", "#3c8291", "#63aab8"])

LURKER_EYE = rgba("#c8fbff")
LURKER_EYE_CORE = rgba("#4ad6e6")
LEVI_EYE = rgba("#c9f5a8")
LEVI_EYE_CORE = rgba("#6fc94f")
FANG = rgba("#dfeadf")
FANG_SHADE = rgba("#9fb0a6")
MAW = rgba("#160d16")
BARNACLE = rgba("#8d9a92")
BARNACLE_DARK = rgba("#5c6963")


def shade_index(depth: float, bands: int) -> int:
    """Quantise a 0..1 vertical position into flat colour bands."""
    return max(0, min(bands - 1, int(depth * bands)))


def draw_lurker(canvas: Canvas, phase: float, mouth: float, lunge: int) -> None:
    """A lean eel-like predator, head to the right."""
    ramp_colors = LURKER_RAMP
    bands = len(ramp_colors) - 1
    head_x = 55 + lunge
    tail_x = 7 + lunge
    length = head_x - tail_x
    centre_y = 33

    spine: dict[int, float] = {}
    for x in range(tail_x, head_x + 1):
        t = (x - tail_x) / length
        # The tail sweeps far more than the head, which is what sells a swim.
        sweep = (1.0 - t) ** 1.5
        spine[x] = centre_y + math.sin(t * math.tau * 1.15 - phase) * 7.0 * sweep

    def thickness(t: float) -> float:
        # Thin whip of a tail, deepest just behind the skull.
        if t < 0.18:
            return 1.2 + t * 6.0
        if t < 0.72:
            return 2.4 + math.sin((t - 0.18) / 0.54 * math.pi) * 4.4
        return 3.0 + (t - 0.72) / 0.28 * 2.6

    # Body.
    for x in range(tail_x, head_x + 1):
        t = (x - tail_x) / length
        sy = spine[x]
        half = thickness(t)
        top = int(round(sy - half))
        bottom = int(round(sy + half))
        for y in range(top, bottom + 1):
            depth = (y - top) / max(1, bottom - top)
            idx = shade_index(depth, bands)
            canvas.set(x, y, ramp_colors[idx + 1] if depth < 0.22 else ramp_colors[idx])

    # Dorsal spines, spaced out so they stay individually readable.
    for x in range(tail_x + 6, head_x - 12, 4):
        t = (x - tail_x) / length
        sy = spine[x]
        top = int(round(sy - thickness(t)))
        height = 2 + int(2 * math.sin(t * math.pi))
        for i in range(height):
            canvas.set(x, top - 1 - i, ramp_colors[4 if i == 0 else 3])

    # Tail fin: a forked sweep off the back of the spine.
    tail_y = int(round(spine[tail_x]))
    for i in range(7):
        spread = int(i * 1.15)
        canvas.set(tail_x - i, tail_y - spread, ramp_colors[3])
        canvas.set(tail_x - i, tail_y + spread, ramp_colors[3])
        if i > 1:
            canvas.set(tail_x - i, tail_y - spread + 1, ramp_colors[2])
            canvas.set(tail_x - i, tail_y + spread - 1, ramp_colors[2])

    # Pectoral fin, giving the body a sense of a near side.
    fin_x = head_x - 17
    fin_y = int(round(spine[fin_x])) + 4
    for i in range(5):
        canvas.vline(fin_x - i, fin_y, fin_y + 1 + i // 2, ramp_colors[2])

    # Head: a tapering skull that flows out of the body, no boxy add-on.
    head_y = int(round(spine[head_x - 6]))
    skull_back = head_x - 12
    for x in range(skull_back, head_x - 3):
        t = (x - skull_back) / max(1, (head_x - 3) - skull_back)
        half = 5.2 - t * 1.4
        top = int(round(head_y - half))
        bottom = int(round(head_y + half))
        for y in range(top, bottom + 1):
            depth = (y - top) / max(1, bottom - top)
            idx = shade_index(depth, bands)
            canvas.set(x, y, ramp_colors[idx + 1] if depth < 0.25 else ramp_colors[idx])

    # Jaws: two wedges hinged at the back of the skull, opening to the right.
    # Drawing them as slopes instead of a rectangle is what stops the head
    # reading as a grille bolted to the face.
    gape = mouth * 5.0
    hinge_x = head_x - 4
    snout = head_x + 2
    span = max(1, snout - hinge_x)
    for x in range(hinge_x, snout + 1):
        t = (x - hinge_x) / span
        # Upper jaw lifts, lower jaw drops, both tapering to a point.
        up_y = head_y - 1 - int(round(gape * t))
        low_y = head_y + 1 + int(round(gape * t * 1.15))
        thin = 1 if t > 0.65 else 2
        canvas.vline(x, up_y - thin + 1, up_y, ramp_colors[3])
        canvas.vline(x, low_y, low_y + thin - 1, ramp_colors[2])
        # Dark throat between the jaws.
        if low_y - 1 >= up_y + 1:
            canvas.vline(x, up_y + 1, low_y - 1, MAW)

    # Teeth follow the jaw slope, alternating length so they read as fangs.
    for i, x in enumerate(range(hinge_x + 1, snout, 2)):
        t = (x - hinge_x) / span
        up_y = head_y - 1 - int(round(gape * t))
        low_y = head_y + 1 + int(round(gape * t * 1.15))
        if low_y - up_y > 2:
            canvas.set(x, up_y + 1, FANG if i % 2 == 0 else FANG_SHADE)
            canvas.set(x, low_y - 1, FANG_SHADE if i % 2 == 0 else FANG)

    # Gill slit behind the skull adds a second read to an otherwise plain body.
    for i in range(3):
        canvas.set(skull_back - 1 + i % 2, head_y - 2 + i * 2, ramp_colors[1])

    # Eye: the one bright accent, set into the skull rather than floating.
    eye_x = head_x - 9
    eye_y = head_y - 2
    canvas.set(eye_x, eye_y, LURKER_EYE)
    canvas.set(eye_x + 1, eye_y, LURKER_EYE_CORE)
    canvas.set(eye_x, eye_y + 1, LURKER_EYE_CORE)


def draw_leviathan(canvas: Canvas, phase: float, mouth: float, lunge: int) -> None:
    """A bulky drowned hulk, head to the right, far heavier than the lurker."""
    ramp_colors = LEVIATHAN_RAMP
    bands = len(ramp_colors) - 1
    head_x = 58 + lunge
    tail_x = 4 + lunge
    length = head_x - tail_x
    centre_y = 33

    spine: dict[int, float] = {}
    for x in range(tail_x, head_x + 1):
        t = (x - tail_x) / length
        sweep = (1.0 - t) ** 2.0
        spine[x] = centre_y + math.sin(t * math.tau * 0.9 - phase) * 4.5 * sweep

    def thickness(t: float) -> float:
        # Heavy through the shoulders, thick even at the tail root.
        if t < 0.14:
            return 1.8 + t * 12.0
        if t < 0.80:
            return 5.0 + math.sin((t - 0.14) / 0.66 * math.pi) * 10.0
        return 8.0 + (t - 0.80) / 0.20 * 3.0

    for x in range(tail_x, head_x + 1):
        t = (x - tail_x) / length
        sy = spine[x]
        half = thickness(t)
        top = int(round(sy - half))
        bottom = int(round(sy + half))
        for y in range(top, bottom + 1):
            depth = (y - top) / max(1, bottom - top)
            idx = shade_index(depth, bands)
            canvas.set(x, y, ramp_colors[idx + 1] if depth < 0.18 else ramp_colors[idx])

    # Armoured ridge plates along the spine.
    for x in range(tail_x + 8, head_x - 14, 5):
        t = (x - tail_x) / length
        top = int(round(spine[x] - thickness(t)))
        canvas.set(x, top - 1, ramp_colors[4])
        canvas.set(x + 1, top - 1, ramp_colors[3])
        canvas.set(x, top - 2, ramp_colors[3])

    # Barnacle clusters: small light specks that break up the mass.
    for bx, by in [(30, 20), (34, 18), (37, 21), (26, 22), (41, 19)]:
        canvas.set(bx + lunge, by, BARNACLE)
        canvas.set(bx + 1 + lunge, by, BARNACLE_DARK)
        canvas.set(bx + lunge, by + 1, BARNACLE_DARK)

    # Broad tail fluke.
    tail_y = int(round(spine[tail_x]))
    for i in range(8):
        spread = 2 + int(i * 1.5)
        canvas.vline(tail_x - i, tail_y - spread, tail_y - spread + 2, ramp_colors[2])
        canvas.vline(tail_x - i, tail_y + spread - 2, tail_y + spread, ramp_colors[2])
        canvas.vline(tail_x - i, tail_y - 1, tail_y + 1, ramp_colors[3])

    # Pectoral flipper.
    fin_x = head_x - 24
    fin_y = int(round(spine[fin_x])) + 9
    for i in range(7):
        canvas.vline(fin_x - i, fin_y, fin_y + 2 + i // 2, ramp_colors[2])

    # Enormous hinged jaws. Like the lurker these are sloped wedges, not a
    # rectangle, so the head stays part of the body instead of a bolted-on box.
    jaw_y = int(round(spine[head_x - 10]))
    gape = 2.0 + mouth * 11.0
    hinge_x = head_x - 15
    snout = head_x + 1
    span = max(1, snout - hinge_x)
    for x in range(hinge_x, snout + 1):
        t = (x - hinge_x) / span
        up_y = jaw_y - 1 - int(round(gape * t * 0.85))
        low_y = jaw_y + 1 + int(round(gape * t))
        # Jaw bone thickness tapers towards the snout.
        thick = 3 - int(t * 2)
        canvas.vline(x, up_y - thick + 1, up_y, ramp_colors[3])
        canvas.vline(x, low_y, low_y + thick - 1, ramp_colors[2])
        if low_y - 1 >= up_y + 1:
            canvas.vline(x, up_y + 1, low_y - 1, MAW)

    # Interlocking fangs along both jaw lines.
    for i, x in enumerate(range(hinge_x + 1, snout, 2)):
        t = (x - hinge_x) / span
        up_y = jaw_y - 1 - int(round(gape * t * 0.85))
        low_y = jaw_y + 1 + int(round(gape * t))
        if low_y - up_y > 3:
            length = 2 if i % 2 == 0 else 1
            canvas.vline(x, up_y + 1, up_y + length, FANG)
            canvas.vline(x, low_y - length, low_y - 1, FANG_SHADE)

    # Brow ridge over the eyes keeps the skull heavy.
    for x in range(hinge_x - 4, hinge_x + 6):
        canvas.set(x, jaw_y - 7, ramp_colors[4])
        canvas.set(x, jaw_y - 6, ramp_colors[3])

    # Two small sickly eyes tucked under the brow.
    for ex, ey in [(hinge_x - 1, jaw_y - 5), (hinge_x + 3, jaw_y - 5)]:
        canvas.set(ex, ey, LEVI_EYE)
        canvas.set(ex + 1, ey, LEVI_EYE_CORE)


def build_frame(kind: str, phase: float, mouth: float, lunge: int) -> Image.Image:
    canvas = Canvas()
    if kind == "lurker":
        draw_lurker(canvas, phase, mouth, lunge)
    else:
        draw_leviathan(canvas, phase, mouth, lunge)
    canvas.outline()
    return canvas.to_image()


def build_sheet(kind: str) -> Image.Image:
    sheet = Image.new("RGBA", (FRAME * COLUMNS, FRAME * ROWS), TRANSPARENT)

    # Row 0: idle. Gentle undulation, mouth barely parted.
    for i in range(COLUMNS):
        phase = i / COLUMNS * math.tau
        frame = build_frame(kind, phase * 0.6, 0.15, 0)
        sheet.alpha_composite(frame, (i * FRAME, 0))

    # Row 1: move. Full body wave plus a small forward surge.
    for i in range(COLUMNS):
        phase = i / COLUMNS * math.tau
        surge = int(round(math.cos(phase) * 2))
        frame = build_frame(kind, phase, 0.3, surge)
        sheet.alpha_composite(frame, (i * FRAME, FRAME))

    # Row 2: attack. Coil back with the jaw closing, then strike wide open.
    plan = [(-0.5, 0.1, -3), (-0.2, 0.35, -1), (0.4, 1.0, 3), (0.2, 0.8, 2)]
    for i, (phase, mouth, lunge) in enumerate(plan):
        frame = build_frame(kind, phase, mouth, lunge)
        sheet.alpha_composite(frame, (i * FRAME, FRAME * 2))

    return sheet


def write_import_file(png_path: Path) -> None:
    """Godot import settings copied from the other pixel art enemy sheets.

    The `uid` line is deliberately omitted: Godot assigns one on first import.
    """
    import_path = png_path.with_suffix(png_path.suffix + ".import")
    resource = f"res://assets/textures/enemies/{png_path.name}"
    cache = f"res://.godot/imported/{png_path.name}-generated.ctex"
    import_path.write_text(
        "[remap]\n\n"
        'importer="texture"\n'
        'type="CompressedTexture2D"\n'
        f'path="{cache}"\n'
        "metadata={\n"
        '"vram_texture": false\n'
        "}\n\n"
        "[deps]\n\n"
        f'source_file="{resource}"\n'
        f'dest_files=["{cache}"]\n\n'
        "[params]\n\n"
        "compress/mode=0\n"
        "compress/high_quality=false\n"
        "compress/lossy_quality=0.7\n"
        "compress/uastc_level=0\n"
        "compress/rdo_quality_loss=0.0\n"
        "compress/hdr_compression=1\n"
        "compress/normal_map=0\n"
        "compress/channel_pack=0\n"
        "mipmaps/generate=false\n"
        "mipmaps/limit=-1\n"
        "roughness/mode=0\n"
        'roughness/src_normal=""\n'
        "process/channel_remap/red=0\n"
        "process/channel_remap/green=1\n"
        "process/channel_remap/blue=2\n"
        "process/channel_remap/alpha=3\n"
        "process/fix_alpha_border=true\n"
        "process/premult_alpha=false\n"
        "process/normal_map_invert_y=false\n"
        "process/hdr_as_srgb=false\n"
        "process/hdr_clamp_exposure=false\n"
        "process/size_limit=0\n"
        "detect_3d/compress_to=1\n",
        encoding="utf-8",
    )


CREATURES = {"brine_lurker": "lurker", "drowned_leviathan": "leviathan"}


def main() -> int:
    for name, kind in CREATURES.items():
        sheet = build_sheet(kind)
        out_path = ENEMY_DIR / f"{name}.png"
        sheet.save(out_path)
        write_import_file(out_path)
        colors = len({p for p in sheet.getdata() if p[3] > 0})
        print(f"{name}: {sheet.size[0]}x{sheet.size[1]}, {colors} colours -> {out_path.name}")
    print("SEA_CREATURE_SPRITES_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
