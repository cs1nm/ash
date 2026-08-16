#!/usr/bin/env python3
"""Turn the leviathan concept render into a game-ready pixel sprite.

The earlier attempts failed in two opposite ways:

  * downscaling the render with a plain resize gave soft, muddy pixels;
  * drawing it from geometric primitives gave flat, toy-like shapes.

The project's own boss art (stone_beast, heartwood_boss) is richly shaded with
800-2600 colours and hard binary alpha, so this keeps the painted detail and
only fixes what actually makes a sprite look cheap:

  1. flood the flat background away from the border, so white highlights
     inside the mouth and on bone survive;
  2. downscale in two steps with a light pre-sharpen, which keeps edges crisp
     instead of smearing them;
  3. snap alpha to 0 or 255 so there is no soft halo;
  4. quantise to a controlled number of tones and re-apply a dark outline.

Usage: python3 tools/leviathan/make_base.py [source.png]
"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
DEFAULT_SRC = HERE / "sources" / "levi_concept.png"
OUT = HERE / "sources" / "leviathan_base_sprite.png"

# Target body length in pixels. The creature is a boss, so it is allowed to be
# far larger than a regular enemy: stone_beast uses a 144x112 frame.
TARGET_W = 150
WHITE_CUTOFF = 228
# The project's small creatures (slime, mossling, cave worm) sit at roughly
# 7-12 meaningful tones. Matching that is what keeps the leviathan in style
# instead of looking like a detailed illustration pasted into the game.
MAX_TONES = 12
OUTLINE = (6, 12, 18, 255)


def strip_background(img: Image.Image) -> Image.Image:
    """Flood fill the flat outer background, keeping enclosed light pixels."""
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


def downscale(img: Image.Image, target_w: int) -> Image.Image:
    """Two-step downscale with a pre-sharpen, so detail survives."""
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
    # Sharpen before shrinking: this is what keeps plates and teeth readable.
    img = ImageEnhance.Sharpness(img).enhance(2.2)
    mid_w = max(target_w, img.width // 2)
    mid_h = max(1, round(img.height * mid_w / img.width))
    img = img.resize((mid_w, mid_h), Image.LANCZOS)
    img = img.filter(ImageFilter.UnsharpMask(radius=1.4, percent=140, threshold=2))
    out_h = max(1, round(img.height * target_w / img.width))
    return img.resize((target_w, out_h), Image.LANCZOS)


def harden(img: Image.Image, tones: int) -> Image.Image:
    """Binary alpha plus a controlled tone count, keeping the painted shading."""
    alpha = img.getchannel("A").point(lambda v: 255 if v >= 128 else 0)
    rgb = img.convert("RGB")
    # Slightly richer contrast reads better once the sprite is small.
    rgb = ImageEnhance.Color(rgb).enhance(1.22)
    rgb = ImageEnhance.Contrast(rgb).enhance(1.14)
    quant = rgb.quantize(colors=tones, method=Image.MEDIANCUT, dither=Image.NONE)
    out = quant.convert("RGBA")
    out.putalpha(alpha)
    # Clear colour data outside the silhouette so nothing bleeds on the edge.
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            if px[x, y][3] == 0:
                px[x, y] = (0, 0, 0, 0)
    return out


def restore_eye_glow(img: Image.Image) -> Image.Image:
    """Re-light the eye after quantisation.

    Every reference creature has exactly one small bright accent (the slime's
    yellow core, the mossling's eyes). Quantising down to ~12 tones tends to
    swallow the leviathan's cyan eye, so it is found and re-lit deliberately.
    """
    px = img.load()
    w, h = img.size
    best = None
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            # cyan-ish: blue and green clearly above red
            if b > r + 28 and g > r + 22 and (g + b) > 150:
                # prefer the candidate furthest right, the head end
                if best is None or x > best[0]:
                    best = (x, y)
    if best is None:
        return img
    ex, ey = best
    for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)):
        px[min(w - 1, ex + dx), min(h - 1, ey + dy)] = (168, 250, 244, 255)
    for dx, dy in ((-1, 0), (2, 0), (0, -1), (0, 2), (2, 1), (-1, 1)):
        nx, ny = ex + dx, ey + dy
        if 0 <= nx < w and 0 <= ny < h and px[nx, ny][3]:
            px[nx, ny] = (63, 214, 216, 255)
    return img


def add_outline(img: Image.Image, color=OUTLINE) -> Image.Image:
    """One pixel dark border, the way the other enemy sheets are finished."""
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
    src = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_SRC
    if not src.exists():
        raise SystemExit(f"missing source render: {src}")
    img = Image.open(src)
    img = strip_background(img)
    img = downscale(img, TARGET_W)
    img = harden(img, MAX_TONES)
    img = restore_eye_glow(img)
    img = add_outline(img)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT)
    colors = len({p for p in img.getdata() if p[3]})
    soft = sum(1 for p in img.getdata() if 0 < p[3] < 255)
    print(f"{OUT.name}: {img.size}, {colors} tones, {soft} soft pixels")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
