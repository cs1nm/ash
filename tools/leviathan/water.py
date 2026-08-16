"""Water surface, foam and the standalone VFX sheets.

All water reuses the creature palette, so no sheet in the pack introduces a
thirteenth colour. Everything is drawn with hard pixels and binary alpha.
"""

from __future__ import annotations

import math
import random

from palette import (
    Canvas, GLOW, GLOW_DEEP, GLOW_HOT, HIDE_DARK, HIDE_MID, MOSS, BONE_DARK,
)

WATER_Y = 132

# Colours the water surface itself uses, so the compositor can tell water
# pixels apart from creature pixels when it clips below the line.
SURFACE_COLORS = {GLOW, GLOW_DEEP, HIDE_MID, HIDE_DARK}


def _rng(*key) -> random.Random:
    return random.Random(hash(key) & 0xFFFFFFFF)


def draw_surface(c: Canvas, phase: float, y: int = WATER_Y, disturb: float = 0.0) -> None:
    """The waterline: a dark band with a lit chop line on top."""
    for x in range(c.w):
        wob = math.sin(x * 0.11 + phase) * 1.6 + math.sin(x * 0.037 - phase * 1.7) * 1.2
        wob += math.sin(x * 0.21 + phase * 2.3) * disturb * 2.5
        top = y + int(round(wob))
        c.set(x, top, GLOW_DEEP if (x + int(phase * 3)) % 7 else GLOW)
        for yy in range(top + 1, min(c.h, top + 5)):
            c.set(x, yy, HIDE_MID)
        for yy in range(min(c.h, top + 5), c.h):
            c.set(x, yy, HIDE_DARK)


def splash(c: Canvas, cx: int, cy: int, t: float, size: float, seed: int = 0) -> None:
    """Expanding ring of droplets. `t` is 0..1 through the effect's life."""
    rng = _rng("splash", seed)
    count = int(size * 1.6)
    for i in range(count):
        ang = rng.uniform(math.pi * 1.04, math.pi * 1.96)
        speed = rng.uniform(0.45, 1.0) * size
        dist = speed * t
        x = int(cx + math.cos(ang) * dist)
        y = int(cy + math.sin(ang) * dist + (t * t) * size * 0.85)
        if t < 0.55:
            col = GLOW_HOT if i % 3 == 0 else GLOW
        else:
            col = GLOW if i % 4 == 0 else GLOW_DEEP
        c.set(x, y, col)
        if i % 5 == 0 and t < 0.7:
            c.set(x, y + 1, col)


def foam_mound(c: Canvas, cx: int, y: int, width: int, height: int) -> None:
    """A raised dome of churned white water, used where the body breaks through."""
    for dx in range(-width, width + 1):
        t = 1.0 - abs(dx) / max(1, width)
        h = int(height * (t ** 0.7))
        x = cx + dx
        for i in range(h):
            col = GLOW_HOT if i >= h - 2 else (GLOW if i > h // 2 else GLOW_DEEP)
            c.set(x, y - i, col)


def build_bite_splash(frames: int, w: int, h: int) -> list[Canvas]:
    """Bite_Splash: 8 frames, 160x128, a hard water burst at the jaws."""
    out = []
    for i in range(frames):
        t = i / (frames - 1)
        c = Canvas(w, h)
        splash(c, w // 2, h - 44, t, 46, seed=11)
        if t < 0.6:
            foam_mound(c, w // 2, h - 40, int(26 * (1 - t)), int(12 * (1 - t)) + 3)
        out.append(c)
    return out


def build_devour_splash(frames: int, w: int, h: int) -> list[Canvas]:
    """Devour_Splash: 12 frames, 384x192, a huge column of water thrown up."""
    out = []
    for i in range(frames):
        t = i / (frames - 1)
        c = Canvas(w, h)
        cx = w // 2
        base = h - 52
        # rising column
        col_h = int(86 * math.sin(min(1.0, t * 1.25) * math.pi * 0.85))
        for dy in range(col_h):
            spread = 5 + int(dy * 0.34) + int(t * 12)
            yy = base - dy
            for dx in range(-spread, spread + 1):
                if abs(dx) > spread - 2:
                    c.set(cx + dx, yy, GLOW_DEEP)
                elif abs(dx) > spread - 5:
                    c.set(cx + dx, yy, GLOW)
                elif dy > col_h - 6:
                    c.set(cx + dx, yy, GLOW_HOT)
        splash(c, cx, base, t, 92, seed=22)
        foam_mound(c, cx, base, int(52 * (1 - t * 0.5)), 10)
        out.append(c)
    return out


def build_tidal_wave(frames: int, w: int, h: int) -> list[Canvas]:
    """Tidal_Wave: 14 frames, 384x192, a wall of water rolling right."""
    out = []
    for i in range(frames):
        t = i / (frames - 1)
        c = Canvas(w, h)
        travel = int(t * (w + 120)) - 60
        crest = 74
        for dx in range(-70, 72):
            x = travel + dx
            if not (0 <= x < w):
                continue
            # steep face forward, long shoulder behind
            if dx > 0:
                prof = math.cos(min(1.0, dx / 46.0) * math.pi * 0.5)
            else:
                prof = 1.0 - min(1.0, -dx / 70.0) ** 1.6
            height = int(crest * max(0.0, prof))
            top = h - 46 - height
            for y in range(top, h - 40):
                d = (y - top) / max(1, (h - 40) - top)
                c.set(x, y, GLOW_HOT if d < 0.10 else (GLOW if d < 0.28 else (HIDE_MID if d < 0.7 else HIDE_DARK)))
            if height > 12:
                c.set(x, top - 1, GLOW_HOT if dx % 3 else GLOW)
        # spray torn off the crest
        splash(c, travel + 20, h - 46 - crest, min(1.0, t * 1.4), 40, seed=33)
        out.append(c)
    return out


def build_sonic_rings(frames: int, w: int, h: int) -> list[Canvas]:
    """Sonic_Rings: 10 frames, 256x192, concentric roar shockwaves."""
    out = []
    for i in range(frames):
        t = i / (frames - 1)
        c = Canvas(w, h)
        cx, cy = w // 2, h // 2 - 8
        for ring in range(3):
            phase = t - ring * 0.22
            if phase <= 0.0:
                continue
            r = phase * (w * 0.52)
            thickness = 3 if phase < 0.5 else 2
            col = GLOW_HOT if phase < 0.35 else (GLOW if phase < 0.7 else GLOW_DEEP)
            steps = max(24, int(r * 3))
            for s in range(steps):
                a = s / steps * math.tau
                # flattened rings read better than circles at this size
                x = int(cx + math.cos(a) * r)
                y = int(cy + math.sin(a) * r * 0.55)
                for k in range(thickness):
                    c.set(x, y + k, col)
        out.append(c)
    return out


def build_tentacles(frames: int, w: int, h: int) -> list[Canvas]:
    """Tentacles: 14 frames, 384x192, dark limbs rising and grasping."""
    out = []
    bases = [(88, 1.35), (150, 1.55), (206, 1.28), (262, 1.62), (312, 1.42)]
    for i in range(frames):
        t = i / (frames - 1)
        c = Canvas(w, h)
        for k, (bx, lean) in enumerate(bases):
            grow = min(1.0, max(0.0, (t - k * 0.05) * 1.7))
            if grow <= 0:
                continue
            length = int(96 * grow)
            curl = math.sin(t * math.pi * 1.2 + k) * 0.5
            x = float(bx)
            y = float(h - 48)
            for s in range(length):
                p = s / max(1, length)
                x += math.cos(-lean + curl * p) * 1.0
                y += math.sin(-lean + curl * p) * 1.0
                thick = max(1, int(4 * (1.0 - p * 0.75)))
                for d in range(-thick, thick + 1):
                    c.set(int(x) + d, int(y), HIDE_DARK if abs(d) == thick else HIDE_MID)
                if s % 9 == 0:
                    c.set(int(x), int(y), MOSS)
            # grasping tip
            c.set(int(x), int(y) - 1, GLOW_DEEP)
        for k, (bx, _l) in enumerate(bases):
            if t > k * 0.05:
                splash(c, bx, h - 46, min(1.0, (t - k * 0.05) * 2.0), 26, seed=40 + k)
        out.append(c)
    return out


def build_death_whirlpool(frames: int, w: int, h: int) -> list[Canvas]:
    """Death_Whirlpool: 14 frames, 384x192, a spiral pulling down and closing."""
    out = []
    for i in range(frames):
        t = i / (frames - 1)
        c = Canvas(w, h)
        cx, cy = w // 2, h - 56
        radius = 108 * (1.0 - t * 0.72)
        for arm in range(3):
            a0 = arm * math.tau / 3 + t * 5.2
            steps = 150
            for s in range(steps):
                p = s / steps
                a = a0 + p * 3.4
                r = radius * (1.0 - p * 0.86)
                x = int(cx + math.cos(a) * r)
                y = int(cy + math.sin(a) * r * 0.42)
                col = GLOW if p < 0.25 else (GLOW_DEEP if p < 0.6 else HIDE_MID)
                c.set(x, y, col)
                if p < 0.18:
                    c.set(x, y + 1, GLOW_HOT if s % 4 == 0 else col)
        # the pit at the centre
        pit = int(16 * (1.0 - t))
        for yy in range(-pit // 2, pit // 2 + 1):
            for xx in range(-pit, pit + 1):
                if xx * xx + (yy * 2.2) ** 2 <= pit * pit:
                    c.set(cx + xx, cy + yy, HIDE_DARK)
        out.append(c)
    return out
