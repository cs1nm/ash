#!/usr/bin/env python3
"""Turn the Heartwood Boss concept render into a game-ready pixel sprite.

Same approach that worked for the leviathan: keep the painted silhouette, but
force it down to the game's own detail level instead of resizing softly.

  1. flood the flat background away from the border only, so light pixels
     enclosed by the body survive;
  2. pre-sharpen, then downscale in two steps so edges stay crisp;
  3. snap alpha to 0 or 255, no soft halo;
  4. snap every colour to the brief's exact 10 colour palette;
  5. re-light the chest heart, which quantisation otherwise flattens;
  6. re-apply a hard dark outline.

Usage: python3 tools/heartwood/make_base.py
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter

HERE = Path(__file__).resolve().parent
SRC = HERE / "sources" / "concept.png"
OUT = HERE / "sources" / "heartwood_base.png"

# Body height asked for in the brief, inside a 128x144 canvas. The width is
# capped too: the concept is wider than it is tall, and at 112 tall it came out
# 136 wide, which the 128 canvas clipped on both sides.
TARGET_H = 112
MAX_W = 116
WHITE_CUTOFF = 228

# The exact palette from the brief. Nothing else may appear in the sprite.
PALETTE_HEX = [
    "1B2118", "2C3622", "46502D", "655237", "805F3C",
    "A77C48", "D1A65B", "86B85B", "B9E078", "F4D978",
]
PALETTE = [tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) for h in PALETTE_HEX]
OUTLINE = (0x1B, 0x21, 0x18, 255)
HEART_CORE = (0xF4, 0xD9, 0x78, 255)
HEART_MID = (0xB9, 0xE0, 0x78, 255)
HEART_RIM = (0x86, 0xB8, 0x5B, 255)


def strip_background(img: Image.Image) -> Image.Image:
    img = img.convert("RGBA")
    w, h = img.size
    px = img.load()

    def is_bg(x: int, y: int) -> bool:
        r, g, b, a = px[x, y]
        return a > 0 and r >= WHITE_CUTOFF and g >= WHITE_CUTOFF and b >= WHITE_CUTOFF

    stack = [(x, 0) for x in range(w)] + [(x, h - 1) for x in range(w)]
    stack += [(0, y) for y in range(h)] + [(w - 1, y) for y in range(h)]
    seen = set()
    while stack:
        x, y = stack.pop()
        if (x, y) in seen or not (0 <= x < w and 0 <= y < h):
            continue
        seen.add((x, y))
        if not is_bg(x, y):
            continue
        px[x, y] = (0, 0, 0, 0)
        stack += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    return img


def downscale(img: Image.Image, target_h: int) -> Image.Image:
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
    img = ImageEnhance.Sharpness(img).enhance(2.2)
    mid_h = max(target_h, img.height // 2)
    mid_w = max(1, round(img.width * mid_h / img.height))
    img = img.resize((mid_w, mid_h), Image.LANCZOS)
    img = img.filter(ImageFilter.UnsharpMask(radius=1.4, percent=140, threshold=2))
    out_w = max(1, round(img.width * target_h / img.height))
    if out_w > MAX_W:
        # Too wide for the canvas: fit to width instead and accept a shorter body.
        target_h = max(1, round(target_h * MAX_W / out_w))
        out_w = MAX_W
    return img.resize((out_w, target_h), Image.LANCZOS)


def snap_to_palette(img: Image.Image) -> Image.Image:
    """Force every pixel onto the brief's palette; binary alpha."""
    alpha = img.getchannel("A").point(lambda v: 255 if v >= 128 else 0)
    rgb = img.convert("RGB")
    rgb = ImageEnhance.Color(rgb).enhance(1.15)
    rgb = ImageEnhance.Contrast(rgb).enhance(1.10)
    src = rgb.load()
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    dst = out.load()
    amask = alpha.load()
    cache: dict[tuple[int, int, int], tuple[int, int, int]] = {}
    for y in range(img.height):
        for x in range(img.width):
            if amask[x, y] == 0:
                continue
            key = src[x, y]
            best = cache.get(key)
            if best is None:
                r, g, b = key
                best = min(PALETTE, key=lambda c: (c[0] - r) ** 2 + (c[1] - g) ** 2 + (c[2] - b) ** 2)
                cache[key] = best
            dst[x, y] = (*best, 255)
    return out


def relight_heart(img: Image.Image) -> Image.Image:
    """Make the chest heart glow.

    Quantising to ten colours flattens the heart into plain leaf green, but it
    is the creature's whole read: the boss is named after it and phase two is
    signalled by it brightening. It is found by looking for the green mass in
    the middle of the torso and re-lit with a hot core.
    """
    px = img.load()
    w, h = img.size
    x0, x1 = int(w * 0.34), int(w * 0.66)
    y0, y1 = int(h * 0.30), int(h * 0.62)
    greens = {HEART_RIM[:3], HEART_MID[:3], (0x46, 0x50, 0x2D)}
    found = [(x, y) for y in range(y0, y1) for x in range(x0, x1)
             if px[x, y][3] and px[x, y][:3] in greens]
    if not found:
        return img
    cx = sum(p[0] for p in found) // len(found)
    cy = sum(p[1] for p in found) // len(found)
    # Radius scales with how big the heart actually came out, so it reads as a
    # lit core with a falloff rather than a flat green patch.
    radius = max(3.0, (len(found) ** 0.5) * 0.62)
    for x, y in found:
        d = ((x - cx) ** 2 + ((y - cy) * 1.10) ** 2) ** 0.5
        if d <= radius * 0.45:
            px[x, y] = HEART_CORE
        elif d <= radius * 0.80:
            px[x, y] = HEART_MID
        else:
            px[x, y] = HEART_RIM
    # Bleed a little light onto the bark around the heart, the way a lamp would.
    dark_bark = {(0x1B, 0x21, 0x18), (0x2C, 0x36, 0x22), (0x46, 0x50, 0x2D), (0x65, 0x52, 0x37)}
    for y in range(max(0, cy - int(radius) - 3), min(h, cy + int(radius) + 4)):
        for x in range(max(0, cx - int(radius) - 3), min(w, cx + int(radius) + 4)):
            if not px[x, y][3] or px[x, y][:3] in (HEART_CORE[:3], HEART_MID[:3], HEART_RIM[:3]):
                continue
            d = ((x - cx) ** 2 + ((y - cy) * 1.10) ** 2) ** 0.5
            if d <= radius + 2.5 and px[x, y][:3] in dark_bark:
                px[x, y] = (0x80, 0x5F, 0x3C, 255)
    return img


def add_outline(img: Image.Image, color=OUTLINE) -> Image.Image:
    out = Image.new("RGBA", (img.width + 2, img.height + 2), (0, 0, 0, 0))
    out.alpha_composite(img, (1, 1))
    px = out.load()
    edges = []
    for y in range(out.height):
        for x in range(out.width):
            if px[x, y][3]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < out.width and 0 <= ny < out.height and px[nx, ny][3]:
                    edges.append((x, y))
                    break
    for x, y in edges:
        px[x, y] = color
    return out


def main() -> int:
    if not SRC.exists():
        raise SystemExit(f"missing concept render: {SRC}")
    img = Image.open(SRC)
    img = strip_background(img)
    img = downscale(img, TARGET_H)
    img = snap_to_palette(img)
    img = relight_heart(img)
    img = add_outline(img)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT)
    tones = {p for p in img.getdata() if p[3]}
    print(f"{OUT.name}: {img.size}, {len(tones)} tones")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
