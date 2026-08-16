#!/usr/bin/env python3
"""Build the Heartwood Boss animation pack for Ashen Roots.

The creature is one hand-tuned sprite (see make_base.py). Animation re-poses
that sprite per frame instead of redrawing it, so bark, crown, roots and the
glowing heart stay pixel-identical across the whole pack while the motion is
real: the trunk sways and leans, the body crouches and rises, the heart pulses
and flares, and roots, seeds, flowers and dust are drawn on top.

Canvas is 128x144 with anchor [64,137] as specified: the anchor is the point on
the ground between the roots. Wide attacks use 224x144 with the same anchor, so
a wide frame drops in without shifting the creature.

Outputs to assets/textures/enemies/anims/heartwood_boss/:
  * one horizontal spritesheet per animation and effect
  * heartwood_boss_anim.json in the engine's own pack format
  * previews/*.gif plus preview_all.gif
  * README.txt

Usage: python3 tools/heartwood/build_heartwood.py
"""

from __future__ import annotations

import json
import math
import random
import sys
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
SPRITE = HERE / "sources" / "heartwood_base.png"
OUT_DIR = ROOT / "assets" / "textures" / "enemies" / "anims" / "heartwood_boss"

W, H = 128, 144
WIDE_W, WIDE_H = 224, 144
ANCHOR = (64, 137)

C_DARKEST = (0x1B, 0x21, 0x18, 255)
C_DARK = (0x2C, 0x36, 0x22, 255)
C_MOSS = (0x46, 0x50, 0x2D, 255)
C_BARK_DARK = (0x65, 0x52, 0x37, 255)
C_BARK = (0x80, 0x5F, 0x3C, 255)
C_BARK_LIT = (0xA7, 0x7C, 0x48, 255)
C_TAN = (0xD1, 0xA6, 0x5B, 255)
C_LEAF = (0x86, 0xB8, 0x5B, 255)
C_LEAF_LIT = (0xB9, 0xE0, 0x78, 255)
C_GLOW = (0xF4, 0xD9, 0x78, 255)
PALETTE = {C_DARKEST, C_DARK, C_MOSS, C_BARK_DARK, C_BARK, C_BARK_LIT,
           C_TAN, C_LEAF, C_LEAF_LIT, C_GLOW}

HEART_TONES = {C_GLOW[:3], C_LEAF_LIT[:3], C_LEAF[:3]}


def load_sprite() -> Image.Image:
    if not SPRITE.exists():
        raise SystemExit(f"missing base sprite: {SPRITE}\n"
                         "run tools/heartwood/make_base.py first")
    return Image.open(SPRITE).convert("RGBA")


BASE = load_sprite()
BW, BH = BASE.size

# Locate the heart once, so every animation lights the same pixels.
def find_heart(img: Image.Image) -> tuple[int, int]:
    px = img.load()
    pts = [(x, y) for y in range(int(BH * 0.30), int(BH * 0.62))
           for x in range(int(BW * 0.34), int(BW * 0.66))
           if px[x, y][3] and px[x, y][:3] in HEART_TONES]
    if not pts:
        return BW // 2, BH // 2
    return (sum(p[0] for p in pts) // len(pts), sum(p[1] for p in pts) // len(pts))


HEART = find_heart(BASE)


def rng_for(*key) -> random.Random:
    return random.Random(hash(key) & 0xFFFFFFFF)


def pose(lean: float = 0.0, crouch: int = 0, sink: int = 0,
         heart: float = 1.0, crack: float = 0.0, squash: float = 0.0) -> Image.Image:
    """Return the creature posed for one frame.

    lean   - degrees the whole trunk tilts, positive leans right
    crouch - pixels the body drops, roots stay planted
    sink   - pixels the body sinks into the ground (spawn / death)
    heart  - 0 dark .. 1 normal .. >1 flaring
    crack  - 0..1 phase two bark splitting
    squash - vertical squash for weight, 0 none
    """
    img = BASE.copy()

    if heart != 1.0 or crack > 0.0:
        px = img.load()
        cx, cy = HEART
        radius = 9.0 + crack * 4.0
        for y in range(max(0, cy - 14), min(BH, cy + 15)):
            for x in range(max(0, cx - 14), min(BW, cx + 15)):
                if not px[x, y][3]:
                    continue
                d = ((x - cx) ** 2 + ((y - cy) * 1.1) ** 2) ** 0.5
                cur = px[x, y][:3]
                if cur in HEART_TONES:
                    if heart <= 0.05:
                        px[x, y] = C_MOSS
                    elif heart < 0.6:
                        px[x, y] = C_LEAF if d > radius * 0.4 else C_LEAF_LIT
                    elif heart > 1.3:
                        px[x, y] = C_GLOW if d <= radius * 0.75 else C_LEAF_LIT
                    # heart == 1.0 leaves the base sprite untouched
                elif heart > 1.25 and d <= radius and cur in (C_BARK_DARK[:3], C_MOSS[:3]):
                    # Flaring light spills onto the bark around the heart.
                    px[x, y] = C_BARK_LIT

    if crack > 0.0:
        # Splitting bark: bright fissures radiating from the heart.
        px = img.load()
        cx, cy = HEART
        r = rng_for("crack")
        for i in range(7):
            ang = r.uniform(0, math.tau)
            length = int((10 + i * 3) * crack)
            for s in range(length):
                x = int(cx + math.cos(ang) * (6 + s))
                y = int(cy + math.sin(ang) * (6 + s) * 0.9)
                if 0 <= x < BW and 0 <= y < BH and px[x, y][3]:
                    px[x, y] = C_GLOW if s < 2 else (C_TAN if s < length * 0.6 else C_BARK_LIT)

    if squash > 0.0:
        nh = max(1, int(BH * (1.0 - squash)))
        nw = max(1, int(BW * (1.0 + squash * 0.5)))
        img = img.resize((nw, nh), Image.NEAREST)

    if abs(lean) > 0.01:
        img = img.rotate(lean, resample=Image.NEAREST,
                         center=(img.width * 0.5, img.height * 0.92),
                         expand=False)
    return img


def frame(canvas_size=(W, H), **kw) -> Image.Image:
    """Compose one animation frame with the creature standing on the anchor."""
    cw, ch = canvas_size
    out = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    crouch = kw.pop("crouch", 0)
    sink = kw.pop("sink", 0)
    sprite = pose(crouch=crouch, sink=sink, **kw)
    x = ANCHOR[0] - sprite.width // 2
    y = ANCHOR[1] - sprite.height + crouch + sink
    out.alpha_composite(sprite, (x, y))
    if sink > 0:
        # Everything below the ground line is underground.
        px = out.load()
        for yy in range(ANCHOR[1] + 1, ch):
            for xx in range(cw):
                px[xx, yy] = (0, 0, 0, 0)
    return out


# ---------------------------------------------------------------- effects ---

def ground_dust(img: Image.Image, cx: int, t: float, spread: int, seed: int) -> None:
    """Dust and debris kicked up along the ground line."""
    px = img.load()
    r = rng_for("dust", seed)
    for i in range(int(spread * 0.9)):
        ang = r.uniform(math.pi * 1.05, math.pi * 1.95)
        dist = r.uniform(0.3, 1.0) * spread * t
        x = int(cx + math.cos(ang) * dist)
        y = int(ANCHOR[1] + math.sin(ang) * dist * 0.5 + t * t * 6)
        if 0 <= x < img.width and 0 <= y < img.height:
            px[x, y] = C_BARK_LIT if i % 3 else C_TAN


def roots_burst(img: Image.Image, cx: int, t: float, count: int, reach: int, seed: int) -> None:
    """Roots tearing up out of the ground."""
    px = img.load()
    r = rng_for("roots", seed)
    for k in range(count):
        side = -1 if k % 2 == 0 else 1
        base_x = cx + side * int(reach * (0.25 + 0.75 * (k // 2) / max(1, count // 2)))
        grow = max(0.0, min(1.0, (t - k * 0.05) * 1.6))
        if grow <= 0:
            continue
        height = int(30 * grow)
        curl = r.uniform(-0.35, 0.35)
        x, y = float(base_x), float(ANCHOR[1])
        for s in range(height):
            p = s / max(1, height)
            x += math.sin(curl * p * 3.0) * 0.8
            y -= 1.0
            thick = max(1, int(3 * (1 - p * 0.7)))
            for d in range(-thick, thick + 1):
                xx, yy = int(x) + d, int(y)
                if 0 <= xx < img.width and 0 <= yy < img.height:
                    px[xx, yy] = C_DARK if abs(d) == thick else C_BARK_DARK
        tipx, tipy = int(x), int(y)
        if 0 <= tipx < img.width and 0 <= tipy < img.height:
            px[tipx, tipy] = C_TAN


def leaves(img: Image.Image, cx: int, cy: int, t: float, count: int, seed: int) -> None:
    px = img.load()
    r = rng_for("leaf", seed)
    for i in range(count):
        ang = r.uniform(0, math.tau)
        dist = r.uniform(0.4, 1.0) * 34 * t
        x = int(cx + math.cos(ang) * dist)
        y = int(cy + math.sin(ang) * dist * 0.7 + t * 14)
        if 0 <= x < img.width and 0 <= y < img.height:
            px[x, y] = C_LEAF_LIT if i % 2 else C_LEAF


def glow_ring(img: Image.Image, cx: int, cy: int, radius: float, color) -> None:
    px = img.load()
    steps = max(20, int(radius * 4))
    for s in range(steps):
        a = s / steps * math.tau
        x = int(cx + math.cos(a) * radius)
        y = int(cy + math.sin(a) * radius * 0.55)
        if 0 <= x < img.width and 0 <= y < img.height:
            px[x, y] = color


# ------------------------------------------------------------ animations ---

def a_spawn():
    out = []
    for i in range(14):
        t = i / 13
        e = t * t * (3 - 2 * t)
        f = frame(sink=int((1 - e) * 108), heart=0.15 + e * 0.85,
                  lean=math.sin(t * 6) * 2.0 * (1 - e))
        ground_dust(f, ANCHOR[0], min(1.0, t * 1.5), 44, 1)
        if t > 0.25:
            roots_burst(f, ANCHOR[0], (t - 0.25) / 0.75, 4, 34, 2)
        out.append(f)
    return out


def a_idle():
    out = []
    for i in range(10):
        t = i / 10
        s = math.sin(t * math.tau)
        out.append(frame(lean=s * 1.6, crouch=int(abs(s) * 2),
                         heart=1.0 + 0.35 * s))
    return out


def a_move():
    out = []
    for i in range(12):
        t = i / 12
        s = math.sin(t * math.tau)
        step = math.sin(t * math.tau * 2)
        f = frame(lean=s * 3.2, crouch=int(abs(step) * 3), heart=1.0 + 0.2 * s)
        if abs(step) > 0.7:
            ground_dust(f, ANCHOR[0] + int(s * 14), 0.5, 18, 3 + i)
        out.append(f)
    return out


def a_phase_2():
    out = []
    for i in range(14):
        t = i / 13
        flare = min(1.0, t * 1.6)
        f = frame(lean=math.sin(t * 14) * 3.5 * (1 - t * 0.5),
                  crouch=int(math.sin(t * math.pi) * -4),
                  heart=1.0 + flare * 0.9, crack=flare)
        if t > 0.35:
            glow_ring(f, HEART[0] + ANCHOR[0] - BW // 2,
                      ANCHOR[1] - BH + HEART[1], (t - 0.35) * 70, C_GLOW)
        leaves(f, ANCHOR[0], ANCHOR[1] - 70, t, 10, 4)
        out.append(f)
    return out


def a_hurt():
    out = []
    for i in range(5):
        t = i / 4
        f = frame(lean=-4.0 * (1 - t), crouch=int(4 * (1 - t)),
                  heart=0.5 + t * 0.5)
        leaves(f, ANCHOR[0], ANCHOR[1] - 60, 0.3 + t * 0.5, 6, 5)
        out.append(f)
    return out


def a_stunned():
    out = []
    for i in range(6):
        t = i / 6
        s = math.sin(t * math.tau)
        f = frame(lean=s * 5.0, crouch=6, heart=0.45 + 0.15 * abs(s))
        # Dazed motes circling the crown.
        for k in range(3):
            a = t * math.tau + k * (math.tau / 3)
            x = int(ANCHOR[0] + math.cos(a) * 20)
            y = int(ANCHOR[1] - BH - 4 + math.sin(a) * 5)
            if 0 <= x < f.width and 0 <= y < f.height:
                f.load()[x, y] = C_TAN
        out.append(f)
    return out


def a_branch_sweep():
    out = []
    for i in range(12):
        if i < 6:
            t = i / 5
            f = frame(lean=-10.0 * t, crouch=int(t * 4), heart=1.0 + t * 0.3)
        elif i < 9:
            t = (i - 6) / 2
            f = frame(lean=-10.0 + 26.0 * t, crouch=2, heart=1.35)
            ground_dust(f, ANCHOR[0] + int(20 + t * 24), 0.5 + t * 0.5, 34, 6)
        else:
            t = (i - 9) / 2
            f = frame(lean=16.0 * (1 - t), crouch=int(2 * (1 - t)), heart=1.15)
        out.append(f)
    return out


def a_root_burst():
    out = []
    for i in range(14):
        t = i / 13
        if i < 7:
            k = i / 6
            f = frame(crouch=int(k * 8), lean=0.0, heart=1.0 + k * 0.5)
        else:
            k = (i - 7) / 6
            f = frame(crouch=int(8 * (1 - k)), lean=0.0, heart=1.5 - k * 0.4)
            roots_burst(f, ANCHOR[0], min(1.0, k * 1.4), 6, 50, 7)
            ground_dust(f, ANCHOR[0], min(1.0, k * 1.3), 52, 8)
        out.append(f)
    return out


def a_seed_shot():
    out = []
    for i in range(12):
        t = i / 11
        if i < 6:
            k = i / 5
            f = frame(lean=-6.0 * k, crouch=int(k * 3), heart=1.0 + k * 0.45)
        else:
            k = (i - 6) / 5
            f = frame(lean=-6.0 + 8.0 * k, crouch=int(3 * (1 - k)), heart=1.45 - k * 0.4)
            if i >= 6:
                # Seed leaving the raised arm.
                sx = 96 + int(k * 22)
                sy = 60 - int(k * 6)
                px = f.load()
                for dx in range(-2, 3):
                    for dy in range(-2, 3):
                        if dx * dx + dy * dy <= 4 and 0 <= sx + dx < f.width and 0 <= sy + dy < f.height:
                            px[sx + dx, sy + dy] = C_TAN if dx * dx + dy * dy > 1 else C_GLOW
        out.append(f)
    return out


def a_summon():
    out = []
    for i in range(14):
        t = i / 13
        if i < 8:
            k = i / 7
            f = frame(crouch=int(k * 6), lean=0.0, heart=1.0 + k * 0.55)
        else:
            k = (i - 8) / 5
            f = frame(crouch=int(6 * (1 - k)), heart=1.55 - k * 0.45)
            # The ground splits open in two places and light pours out.
            for side in (-1, 1):
                cx = ANCHOR[0] + side * 34
                width = int(12 * min(1.0, k * 1.5))
                px = f.load()
                for dx in range(-width, width + 1):
                    x = cx + dx
                    if 0 <= x < f.width:
                        px[x, ANCHOR[1]] = C_GLOW if abs(dx) < width // 2 else C_TAN
                        if ANCHOR[1] - 1 >= 0 and abs(dx) < width // 2:
                            px[x, ANCHOR[1] - 1] = C_LEAF_LIT
                roots_burst(f, cx, k, 2, 14, 9 + side)
        out.append(f)
    return out


def a_poison_flowers():
    out = []
    for i in range(15):
        t = i / 14
        if i < 9:
            k = i / 8
            f = frame(lean=4.0 * k, crouch=int(k * 4), heart=1.0 + k * 0.4)
        else:
            k = (i - 9) / 5
            f = frame(lean=4.0 * (1 - k), crouch=int(4 * (1 - k)), heart=1.4 - k * 0.35)
            # Flowers opening along the ground.
            r = rng_for("flower")
            for fi in range(5):
                fx = ANCHOR[0] + r.randint(-52, 52)
                grow = max(0.0, min(1.0, (k - fi * 0.08) * 2.0))
                if grow <= 0:
                    continue
                px = f.load()
                stem = int(8 * grow)
                for s in range(stem):
                    y = ANCHOR[1] - s
                    if 0 <= fx < f.width and 0 <= y < f.height:
                        px[fx, y] = C_MOSS
                head = ANCHOR[1] - stem
                for dx in range(-2, 3):
                    for dy in range(-2, 1):
                        x, y = fx + dx, head + dy
                        if 0 <= x < f.width and 0 <= y < f.height and abs(dx) + abs(dy) <= 3:
                            px[x, y] = C_LEAF_LIT if abs(dx) + abs(dy) < 2 else C_LEAF
        out.append(f)
    return out


def a_heal():
    out = []
    for i in range(16):
        t = i / 15
        f = frame(crouch=int(math.sin(t * math.pi) * -5),
                  heart=1.0 + math.sin(min(1.0, t * 1.25) * math.pi) * 1.0)
        # Light rising out of the ground into the chest.
        hx = ANCHOR[0]
        hy = ANCHOR[1] - BH + HEART[1]
        px = f.load()
        r = rng_for("heal")
        for k in range(14):
            phase = (t * 1.6 + k * 0.07) % 1.0
            x = hx + r.randint(-30, 30)
            y = int(ANCHOR[1] - phase * (ANCHOR[1] - hy))
            if 0 <= x < f.width and 0 <= y < f.height:
                px[x, y] = C_GLOW if phase > 0.55 else C_LEAF_LIT
        if t > 0.55:
            glow_ring(f, hx, hy, (t - 0.55) * 46, C_LEAF_LIT)
        out.append(f)
    return out


def a_death():
    out = []
    for i in range(20):
        t = i / 19
        heart = max(0.0, 1.0 - t * 1.6)
        lean = t * t * 46.0
        f = frame(lean=lean, crouch=int(t * 10), heart=heart,
                  crack=max(0.0, 0.6 - t))
        if t < 0.6:
            leaves(f, ANCHOR[0], ANCHOR[1] - 70, t * 1.4, 14, 11)
        ground_dust(f, ANCHOR[0], min(1.0, t * 1.2), 50, 12)
        out.append(f)
    return out


# ---------------------------------------------------------------- vfx ------

def v_root_vfx(n=10, cw=WIDE_W, ch=WIDE_H):
    out = []
    for i in range(n):
        t = i / (n - 1)
        f = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
        roots_burst(f, cw // 2, t, 8, 84, 20)
        ground_dust(f, cw // 2, t, 72, 21)
        out.append(f)
    return out


def v_seed_projectile(n=6, cw=32, ch=32):
    out = []
    for i in range(n):
        t = i / (n - 1)
        f = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
        px = f.load()
        cx, cy = cw // 2, ch // 2
        spin = t * math.tau
        for dx in range(-4, 5):
            for dy in range(-4, 5):
                d = (dx * dx + dy * dy) ** 0.5
                if d <= 3.2:
                    px[cx + dx, cy + dy] = C_TAN if d > 1.8 else C_GLOW
        # little trailing leaves
        for k in range(3):
            a = spin + k * (math.tau / 3)
            x, y = int(cx + math.cos(a) * 6), int(cy + math.sin(a) * 5)
            if 0 <= x < cw and 0 <= y < ch:
                px[x, y] = C_LEAF_LIT
        out.append(f)
    return out


def v_seed_impact(n=8, cw=48, ch=48):
    out = []
    for i in range(n):
        t = i / (n - 1)
        f = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
        cx, cy = cw // 2, ch // 2
        glow_ring(f, cx, cy, 3 + t * 17, C_GLOW if t < 0.5 else C_LEAF)
        leaves(f, cx, cy, t, 10, 22)
        out.append(f)
    return out


def v_poison_cloud(n=12, cw=96, ch=64):
    out = []
    for i in range(n):
        t = i / (n - 1)
        f = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
        px = f.load()
        r = rng_for("cloud")
        for k in range(90):
            ang = r.uniform(0, math.tau)
            dist = r.uniform(0.2, 1.0) * (10 + t * 32)
            x = int(cw // 2 + math.cos(ang) * dist)
            y = int(ch - 12 + math.sin(ang) * dist * 0.45 - t * 10)
            if 0 <= x < cw and 0 <= y < ch:
                px[x, y] = C_LEAF if (k + i) % 3 else C_MOSS
        out.append(f)
    return out


def v_flower_spawn(n=8, cw=48, ch=48):
    out = []
    for i in range(n):
        t = i / (n - 1)
        f = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
        px = f.load()
        cx, base = cw // 2, ch - 4
        stem = int(16 * t)
        for s in range(stem):
            px[cx, base - s] = C_MOSS
        head = base - stem
        petal = int(5 * t)
        for dx in range(-petal, petal + 1):
            for dy in range(-petal, 1):
                if abs(dx) + abs(dy) <= petal + 1:
                    x, y = cx + dx, head + dy
                    if 0 <= x < cw and 0 <= y < ch:
                        px[x, y] = C_LEAF_LIT if abs(dx) + abs(dy) < petal else C_LEAF
        out.append(f)
    return out


def v_death_vfx(n=14, cw=WIDE_W, ch=WIDE_H):
    out = []
    for i in range(n):
        t = i / (n - 1)
        f = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
        ground_dust(f, cw // 2, min(1.0, t * 1.2), 96, 23)
        leaves(f, cw // 2, ch - 70, t, 30, 24)
        if t < 0.35:
            glow_ring(f, cw // 2, ch - 60, t * 60, C_GLOW)
        out.append(f)
    return out


# ------------------------------------------------------------------ build --

SPEC = [
    ("spawn", a_spawn, 10, False, [], [], (W, H)),
    ("idle", a_idle, 6, True, [], [], (W, H)),
    ("move", a_move, 8, True, [], [], (W, H)),
    ("phase_2", a_phase_2, 10, False, [], [], (W, H)),
    ("hurt", a_hurt, 12, False, [], [], (W, H)),
    ("stunned", a_stunned, 6, True, [], [], (W, H)),
    ("attack_1", a_branch_sweep, 11, False, [7, 8], [], (W, H)),
    ("attack_2", a_root_burst, 11, False, [8], [], (W, H)),
    ("attack_3", a_seed_shot, 12, False, [], [7], (W, H)),
    ("attack_4", a_summon, 10, False, [], [], (W, H)),
    ("attack_5", a_poison_flowers, 11, False, [], [9], (W, H)),
    ("attack_6", a_heal, 10, False, [], [], (W, H)),
    ("death", a_death, 8, False, [], [], (W, H)),
]

VFX = [
    ("root_vfx", v_root_vfx, 10, 11),
    ("seed_projectile", v_seed_projectile, 6, 12),
    ("seed_impact", v_seed_impact, 8, 14),
    ("flower_spawn", v_flower_spawn, 8, 11),
    ("poison_cloud", v_poison_cloud, 12, 10),
    ("death_vfx", v_death_vfx, 14, 8),
]


def sheet(frames: list[Image.Image]) -> Image.Image:
    fw, fh = frames[0].size
    img = Image.new("RGBA", (fw * len(frames), fh), (0, 0, 0, 0))
    for i, f in enumerate(frames):
        img.alpha_composite(f, (i * fw, 0))
    return img


def enforce(img: Image.Image, name: str) -> None:
    """Binary alpha and nothing outside the brief's palette."""
    px = img.load()
    stray = {}
    for y in range(img.height):
        for x in range(img.width):
            p = px[x, y]
            if p[3] == 0:
                continue
            if p[3] != 255:
                px[x, y] = (p[0], p[1], p[2], 255)
                p = px[x, y]
            if p not in PALETTE:
                stray[p] = stray.get(p, 0) + 1
                best = min(PALETTE, key=lambda c: (c[0] - p[0]) ** 2 + (c[1] - p[1]) ** 2 + (c[2] - p[2]) ** 2)
                px[x, y] = best
    if stray:
        total = sum(stray.values())
        print(f"  {name}: snapped {total} off-palette pixels")


def save_gif(frames: list[Image.Image], path: Path, fps: int) -> None:
    backed = []
    for f in frames:
        bg = Image.new("RGBA", f.size, (18, 26, 20, 255))
        bg.alpha_composite(f)
        backed.append(bg.convert("P", palette=Image.ADAPTIVE, colors=32))
    backed[0].save(path, save_all=True, append_images=backed[1:],
                   duration=int(1000 / fps), loop=0, disposal=2)


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    gif_dir = OUT_DIR / "previews"
    gif_dir.mkdir(exist_ok=True)

    animations: dict = {}
    preview: list[Image.Image] = []

    for name, builder, fps, loop, hits, projectiles, size in SPEC:
        frames = builder()
        img = sheet(frames)
        enforce(img, name)
        fname = f"heartwood_{name}.png"
        img.save(OUT_DIR / fname)
        save_gif(frames, gif_dir / f"{name}.gif", fps)
        preview.extend(frames)
        entry = {"file": fname, "frames": len(frames), "fps": fps, "loop": loop}
        if hits:
            entry["hit_frames"] = [h - 1 for h in hits]
        if projectiles:
            entry["projectile_frames"] = [p - 1 for p in projectiles]
        if name == "attack_3":
            entry["projectile_spawn"] = [96, 60]
        if name == "attack_4":
            entry["summon_frames"] = [7]
        if name == "attack_6":
            entry["heal_frames"] = [9]
        animations[name] = entry
        print(f"{name:16s} {len(frames):2d}f {fps:2d}fps {frames[0].size}")

    for name, builder, count, fps in VFX:
        frames = builder()
        img = sheet(frames)
        enforce(img, name)
        fname = f"heartwood_{name}.png"
        img.save(OUT_DIR / fname)
        save_gif(frames, gif_dir / f"{name}.gif", fps)
        animations[name] = {"file": fname, "frames": len(frames),
                            "fps": fps, "loop": False}
        print(f"{name:16s} {len(frames):2d}f {fps:2d}fps {frames[0].size}")

    save_gif(preview, gif_dir / "preview_all.gif", 10)

    pack = {
        "frame_size": [W, H],
        "wide_frame_size": [WIDE_W, WIDE_H],
        "facing": "right",
        "anchor": {"x": ANCHOR[0], "y": ANCHOR[1]},
        "frame_indexing": "0-based",
        "ground_clearance": 0,
        "state_fallbacks": {
            "attack_1": "attack_1", "attack_2": "attack_1",
            "attack_3": "attack_1", "attack_4": "attack_1",
            "attack_5": "attack_1", "attack_6": "idle",
            "phase_2": "idle", "stunned": "idle", "spawn": "idle",
        },
        "animations": animations,
    }
    (OUT_DIR / "heartwood_boss_anim.json").write_text(
        json.dumps(pack, indent=2) + "\n", encoding="utf-8")

    readme = f"""Heartwood Boss animation pack - Ashen Roots
===========================================

A massive ancient walking tree: gnarled trunk, root legs, heavy branch arms,
and a glowing amber-green heart in the chest. Phase two cracks the bark and
the heart flares.

Format
------
Frame size   : {W}x{H} (wide effects {WIDE_W}x{WIDE_H}, same anchor)
Anchor       : {ANCHOR[0]},{ANCHOR[1]} - the ground between the roots
Body height  : about 112 px
Sheets       : horizontal, frames left to right
Alpha        : binary only, 0 or 255
Palette      : exactly the 10 colours from the brief
Facing       : right

Animations
----------
""" + "\n".join(
        f"{n:16s} {len(b()):2d} frames  {f:2d} fps  loop={str(l).lower():5s}"
        f"  hit={str(h) if h else '-':<8} proj={str(p) if p else '-'}"
        for n, b, f, l, h, p, _s in SPEC
    ) + """

Effects
-------
""" + "\n".join(f"{n:16s} {c:2d} frames  {f:2d} fps" for n, _b, c, f in VFX) + """

Notes
-----
Frame numbers in the brief were 1-based; the JSON stores them 0-based because
that is what the engine's animation pack loader expects.

Regenerate
----------
    python3 tools/heartwood/make_base.py       # concept -> base sprite
    python3 tools/heartwood/build_heartwood.py # base sprite -> full pack
"""
    (OUT_DIR / "README.txt").write_text(readme, encoding="utf-8")
    print(f"\nwrote {len(SPEC)} animations and {len(VFX)} effects -> {OUT_DIR}")
    print("HEARTWOOD_PACK_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
