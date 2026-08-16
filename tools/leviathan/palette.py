"""Shared palette and pixel canvas for the Sea Leviathan asset pack.

Everything in the pack draws through this module so the design cannot drift
between animations: one palette, one canvas type, one outline rule.

Palette is 12 colours exactly, as specified:
  near black, dark navy, grey green, swampy teal, bone grey,
  cold cyan / pale turquoise glow, muted dark red for the inner mouth.
Alpha is strictly binary: a pixel is either fully transparent or fully opaque.
"""

from __future__ import annotations

import math

RGBA = tuple[int, int, int, int]

TRANSPARENT: RGBA = (0, 0, 0, 0)


def _c(value: str) -> RGBA:
    value = value.lstrip("#")
    return (int(value[0:2], 16), int(value[2:4], 16), int(value[4:6], 16), 255)


# --- the 12 colour palette -------------------------------------------------
OUTLINE = _c("#05080c")      # near black, silhouette border
HIDE_DARK = _c("#0d1a26")    # dark navy, deepest hide
HIDE_MID = _c("#16303c")     # body midtone
HIDE_LIT = _c("#224a52")     # grey green, lit top of the body
MOSS = _c("#2f6a5f")         # swampy teal, weed and algae
BONE_DARK = _c("#5d6a68")    # shadowed bone plate
BONE = _c("#8e9a92")         # bone grey plates and teeth
GLOW_DEEP = _c("#1c7f86")    # dim gill glow
GLOW = _c("#3fd6d8")         # cold cyan
GLOW_HOT = _c("#a8fbf4")     # pale turquoise highlight
MAW = _c("#3a1418")          # muted dark red, inner mouth
BLOOD = _c("#6e1f22")        # deeper red, throat

PALETTE: tuple[RGBA, ...] = (
    OUTLINE, HIDE_DARK, HIDE_MID, HIDE_LIT, MOSS, BONE_DARK,
    BONE, GLOW_DEEP, GLOW, GLOW_HOT, MAW, BLOOD,
)

# Water is drawn as silhouette-coloured bands, reusing palette entries so the
# VFX sheets never introduce a thirteenth colour.
FOAM = GLOW_HOT
SPRAY = GLOW
WATER_DARK = HIDE_DARK
WATER_MID = HIDE_MID


class Canvas:
    """Small fixed-size pixel buffer with hard edges and binary alpha."""

    def __init__(self, width: int, height: int) -> None:
        self.w = width
        self.h = height
        self.px: list[list[RGBA]] = [[TRANSPARENT] * width for _ in range(height)]

    # -- primitives ---------------------------------------------------------
    def set(self, x: int, y: int, color: RGBA) -> None:
        if 0 <= x < self.w and 0 <= y < self.h and color[3]:
            self.px[y][x] = color

    def get(self, x: int, y: int) -> RGBA:
        if 0 <= x < self.w and 0 <= y < self.h:
            return self.px[y][x]
        return TRANSPARENT

    def filled(self, x: int, y: int) -> bool:
        return self.get(x, y)[3] > 0

    def vline(self, x: int, y0: int, y1: int, color: RGBA) -> None:
        for y in range(min(y0, y1), max(y0, y1) + 1):
            self.set(x, y, color)

    def hline(self, y: int, x0: int, x1: int, color: RGBA) -> None:
        for x in range(min(x0, x1), max(x0, x1) + 1):
            self.set(x, y, color)

    def rect(self, x0: int, y0: int, x1: int, y1: int, color: RGBA) -> None:
        for y in range(min(y0, y1), max(y0, y1) + 1):
            self.hline(y, x0, x1, color)

    def disc(self, cx: int, cy: int, radius: float, color: RGBA) -> None:
        r = int(math.ceil(radius))
        rr = radius * radius
        for y in range(cy - r, cy + r + 1):
            for x in range(cx - r, cx + r + 1):
                if (x - cx) ** 2 + (y - cy) ** 2 <= rr:
                    self.set(x, y, color)

    def line(self, x0: int, y0: int, x1: int, y1: int, color: RGBA) -> None:
        """Integer Bresenham line, so diagonals stay crisp."""
        dx = abs(x1 - x0)
        dy = -abs(y1 - y0)
        sx = 1 if x0 < x1 else -1
        sy = 1 if y0 < y1 else -1
        err = dx + dy
        while True:
            self.set(x0, y0, color)
            if x0 == x1 and y0 == y1:
                return
            e2 = 2 * err
            if e2 >= dy:
                err += dy
                x0 += sx
            if e2 <= dx:
                err += dx
                y0 += sy

    # -- finishing ----------------------------------------------------------
    def outline(self, color: RGBA = OUTLINE) -> None:
        """One pixel hard border around the whole silhouette."""
        edges = []
        for y in range(self.h):
            row = self.px[y]
            for x in range(self.w):
                if row[x][3]:
                    continue
                if (
                    self.filled(x - 1, y) or self.filled(x + 1, y)
                    or self.filled(x, y - 1) or self.filled(x, y + 1)
                ):
                    edges.append((x, y))
        for x, y in edges:
            self.set(x, y, color)

    def clip_below(self, y_limit: int) -> None:
        """Erase everything strictly below a row (used for the waterline)."""
        for y in range(max(0, y_limit), self.h):
            self.px[y] = [TRANSPARENT] * self.w

    def to_image(self):
        from PIL import Image

        img = Image.new("RGBA", (self.w, self.h), TRANSPARENT)
        img.putdata([self.px[y][x] for y in range(self.h) for x in range(self.w)])
        return img


def assert_palette(img, allow_extra: int = 0) -> None:
    """Guard: binary alpha and nothing outside the 12 colour palette."""
    allowed = set(PALETTE)
    seen = set()
    for pixel in img.getdata():
        if pixel[3] == 0:
            continue
        if pixel[3] != 255:
            raise AssertionError(f"non binary alpha: {pixel}")
        seen.add(pixel)
    stray = seen - allowed
    if len(stray) > allow_extra:
        raise AssertionError(f"colours outside palette: {sorted(stray)[:6]}")


def fill_polygon(c: "Canvas", points: list[tuple[float, float]], color: RGBA) -> None:
    """Scanline polygon fill, integer output so edges stay hard."""
    if len(points) < 3:
        return
    ys = [p[1] for p in points]
    y0 = max(0, int(math.floor(min(ys))))
    y1 = min(c.h - 1, int(math.ceil(max(ys))))
    n = len(points)
    for y in range(y0, y1 + 1):
        cuts = []
        sy = y + 0.5
        for i in range(n):
            ax, ay = points[i]
            bx, by = points[(i + 1) % n]
            if (ay <= sy < by) or (by <= sy < ay):
                t = (sy - ay) / (by - ay)
                cuts.append(ax + t * (bx - ax))
        cuts.sort()
        for i in range(0, len(cuts) - 1, 2):
            for x in range(int(math.floor(cuts[i] + 0.5)), int(math.floor(cuts[i + 1] + 0.5)) + 1):
                c.set(x, y, color)


def shade_polygon(c: "Canvas", points: list[tuple[float, float]],
                  top_color: RGBA, mid_color: RGBA, low_color: RGBA) -> None:
    """Fill a polygon with three flat horizontal bands of shading."""
    ys = [p[1] for p in points]
    y0, y1 = min(ys), max(ys)
    span = max(1.0, y1 - y0)
    tmp = Canvas(c.w, c.h)
    fill_polygon(tmp, points, top_color)
    for y in range(c.h):
        d = (y - y0) / span
        col = top_color if d < 0.30 else (mid_color if d < 0.66 else low_color)
        for x in range(c.w):
            if tmp.filled(x, y):
                c.set(x, y, col)
