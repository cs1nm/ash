"""The Sea Leviathan itself.

`draw_leviathan` is the single source of truth for the creature's design.
Every animation calls it with a different `Pose`, so the head shape, plate
layout, eye position, tooth rows, barnacles, harpoons and glowing gills are
identical in every frame of the pack. A pose only changes placement, jaw
rotation, how far the animal has risen out of the water and the swim phase.

Construction notes:
  * silhouettes are Catmull-Rom curves filled by scanline, so the outline is
    organic instead of stepping like stacked rectangles;
  * shading is three flat bands, no gradients;
  * the lower jaw is genuinely rotated about the hinge, which is what makes
    the bite read as a bite;
  * everything is then wrapped in a single hard outline.
"""

from __future__ import annotations

import math
from dataclasses import dataclass

from palette import (
    BLOOD, BONE, BONE_DARK, Canvas, GLOW, GLOW_DEEP, GLOW_HOT, HIDE_DARK,
    HIDE_LIT, HIDE_MID, MAW, MOSS, fill_polygon, shade_polygon,
)

# Waterline row inside a 256x192 frame. Anchor [128, 132] is the point on the
# water surface directly under the head.
WATER_Y = 132
ANCHOR = (128, 132)

SKULL_LEN = 82


@dataclass
class Pose:
    head_x: int = 176          # snout tip x
    head_y: int = 108          # jaw hinge height
    gape: float = 0.0          # 0 closed .. 1 fully open
    rise: float = 0.0          # 0 submerged .. 1 reared out of the water
    body_phase: float = 0.0    # swim undulation
    eye_glow: float = 0.6      # 0 dark .. 1 blazing
    lean: float = 0.0          # snout pitch, negative points up
    submerged_only: bool = False
    show_body: bool = True


def curve(points: list[tuple[float, float]], n: int = 24) -> list[tuple[float, float]]:
    """Catmull-Rom spline through the control points."""
    out: list[tuple[float, float]] = []
    p = [points[0]] + list(points) + [points[-1]]
    for i in range(len(p) - 3):
        p0, p1, p2, p3 = p[i], p[i + 1], p[i + 2], p[i + 3]
        for s in range(n):
            t = s / n
            t2, t3 = t * t, t * t * t
            x = 0.5 * ((2 * p1[0]) + (-p0[0] + p2[0]) * t
                       + (2 * p0[0] - 5 * p1[0] + 4 * p2[0] - p3[0]) * t2
                       + (-p0[0] + 3 * p1[0] - 3 * p2[0] + p3[0]) * t3)
            y = 0.5 * ((2 * p1[1]) + (-p0[1] + p2[1]) * t
                       + (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * t2
                       + (-p0[1] + 3 * p1[1] - 3 * p2[1] + p3[1]) * t3)
            out.append((x, y))
    out.append(points[-1])
    return out


def rotate(points, ox: float, oy: float, angle: float):
    ca, sa = math.cos(angle), math.sin(angle)
    return [(ox + (x - ox) * ca - (y - oy) * sa,
             oy + (x - ox) * sa + (y - oy) * ca) for x, y in points]


def _lift(pose: Pose) -> int:
    return int(round(pose.rise * 26.0))


def draw_body(c: Canvas, pose: Pose) -> None:
    """Humped back, tail fluke, plates, barnacles, harpoons and weed."""
    if not pose.show_body:
        return
    lift = _lift(pose)
    hin = pose.head_x - SKULL_LEN
    base_y = pose.head_y + 16 - lift
    tail_x = hin - 118

    # The trunk is a shoulder mass welded to the skull, and behind it the body
    # arcs clear of the water as a separate coil before diving again. Two
    # humps with water between them read as a sea serpent; one long slab reads
    # as a raft.
    water_line = WATER_Y

    def shoulder(t: float) -> tuple[float, float]:
        """Top of the shoulder hump, 0 at its rear, 1 where it meets the skull."""
        x = hin - 56 + t * 56
        wave = math.sin(t * 2.2 - pose.body_phase) * 3.0 * (1.0 - t)
        half = 4.0 + math.sin(min(1.0, t * 1.15) * math.pi * 0.80) * 30.0
        return x, base_y + wave - half

    upper = [shoulder(i / 20) for i in range(21)]
    lower = [(x, water_line + 4) for x, _y in upper]
    shade_polygon(c, curve(upper) + list(reversed(lower)),
                  HIDE_LIT, HIDE_MID, HIDE_DARK)

    def coil(t: float) -> tuple[float, float]:
        """A second hump further back, breaking the surface on its own."""
        x = tail_x + t * 58
        wave = math.sin(t * 2.6 - pose.body_phase * 1.3) * 3.0
        half = math.sin(t * math.pi) * 22.0
        return x, base_y + 6 + wave - half

    ctop = [coil(i / 18) for i in range(19)]
    cbot = [(x, water_line + 4) for x, _y in ctop]
    shade_polygon(c, curve(ctop) + list(reversed(cbot)),
                  HIDE_LIT, HIDE_MID, HIDE_DARK)

    def back(t: float) -> tuple[float, float]:
        """Shared accessor so plates and barnacles sit on the visible humps."""
        return coil(t / 0.55) if t < 0.55 else shoulder((t - 0.55) / 0.45)

    # Tail fluke lifting out of the water beyond the rear coil.
    fx, fy = tail_x - 2, base_y - 4
    shade_polygon(c, curve([
        (fx + 4, fy + 12), (fx - 10, fy - 6), (fx - 22, fy - 16),
        (fx - 16, fy + 4), (fx - 26, fy + 18), (fx - 6, fy + 16), (fx + 4, fy + 12),
    ]), HIDE_MID, HIDE_MID, HIDE_DARK)

    # Ridge plates along the spine.
    for i in range(8):
        t = 0.08 + i * 0.115
        if t > 0.98:
            break
        x, y = back(t)
        h = 4 + (i % 2)
        fill_polygon(c, [(x - 3, y + 2), (x, y - h), (x + 3, y + 2)], BONE_DARK)
        fill_polygon(c, [(x - 1, y + 2), (x, y - h + 1), (x + 1, y + 2)], BONE)

    # Barnacles, fixed body-relative spots.
    for t, dy in ((0.22, 7), (0.38, 11), (0.62, 8), (0.76, 14), (0.88, 9)):
        x, y = back(t)
        yy = int(y + dy)
        c.set(int(x), yy, BONE)
        c.set(int(x) + 1, yy, BONE_DARK)
        c.set(int(x), yy + 1, BONE_DARK)

    # Broken harpoons with frayed ropes.
    for t, ang in ((0.30, -1.05), (0.68, -1.32), (0.84, -0.92)):
        x, y = back(t)
        x, y = int(x), int(y)
        dx, dy = int(math.cos(ang) * 16), int(math.sin(ang) * 16)
        c.line(x, y, x + dx, y + dy, BONE_DARK)
        c.line(x + 1, y, x + dx + 1, y + dy, BONE_DARK)
        c.set(x + dx, y + dy, BONE)
        c.set(x + dx - 2, y + dy + 3, BONE)
        c.set(x + dx + 2, y + dy + 3, BONE)
        for k in range(1, 5):
            c.set(x + dx + k, y + dy + 4 + k, MOSS)

    # Seaweed streaming off the back.
    for t in (0.26, 0.66, 0.86):
        x, y = back(t)
        for k in range(7):
            c.set(int(x) - k // 2 - 1, int(y) - k, MOSS)


def draw_head(c: Canvas, pose: Pose) -> None:
    """Long predatory skull with a genuinely hinged lower jaw."""
    lift = _lift(pose)
    hx = pose.head_x
    hy = pose.head_y - lift + int(round(pose.lean * -8))
    hin = hx - SKULL_LEN
    ang = pose.gape * 0.42
    pivot = (float(hin), float(hy + 6))

    # ---- upper skull: heavy brow sloping into a long tapering snout.
    skull = curve([
        (hin - 18, hy + 9), (hin - 12, hy - 6), (hin + 2, hy - 17),
        (hin + 20, hy - 21), (hin + 42, hy - 19), (hin + 62, hy - 13),
        (hin + 80, hy - 6), (hx + 10, hy - 1),
        (hx + 9, hy + 3), (hin + 56, hy + 2), (hin + 22, hy + 3),
        (hin - 4, hy + 6), (hin - 18, hy + 9),
    ])
    shade_polygon(c, skull, HIDE_LIT, HIDE_MID, HIDE_DARK)

    # ---- upper tooth row hanging from the lip line.
    for i in range(6, 80, 7):
        t = i / SKULL_LEN
        x = hin + i
        ly = hy + 2 - 3 * t
        ln = 7 if (i // 7) % 2 == 0 else 5
        fill_polygon(c, [(x - 2, ly - 2), (x + 2, ly - 2), (x, ly + ln)], BONE)

    # ---- lower jaw, rotated about the hinge.
    jaw = curve([
        (hin - 8, hy + 4), (hin + 6, hy + 3), (hin + 38, hy + 4),
        (hin + 64, hy + 5), (hx + 8, hy + 6),
        (hx + 5, hy + 12), (hin + 46, hy + 16), (hin + 8, hy + 16),
        (hin - 8, hy + 13),
    ])
    shade_polygon(c, rotate(jaw, pivot[0], pivot[1], ang),
                  HIDE_MID, HIDE_MID, HIDE_DARK)

    def jaw_edge(i: int) -> tuple[float, float]:
        lx, ly = hin + i, hy + 4
        return rotate([(lx, ly)], pivot[0], pivot[1], ang)[0]

    # ---- throat between the two jaw lines.
    for i in range(0, SKULL_LEN):
        t = i / SKULL_LEN
        up = hy + 2 - 3 * t
        rx, ry = jaw_edge(i)
        if ry - up > 2:
            for y in range(int(up) + 2, int(ry)):
                c.set(int(rx), y, BLOOD if y - up < 5 else MAW)

    # ---- lower tooth row following the rotated jaw.
    for i in range(6, 80, 7):
        rx, ry = jaw_edge(i)
        ln = 6 if (i // 7) % 2 else 4
        fill_polygon(c, [(rx - 2, ry + 2), (rx + 2, ry + 2), (rx, ry - ln)], BONE_DARK)

    # ---- stone bone plates over the skull.
    for k, t in enumerate((0.10, 0.28, 0.46, 0.64)):
        x = hin + t * SKULL_LEN
        by = hy - 10 - 14 * math.sin(min(1.0, t * 1.5) * 2.2)
        w = 8 - k
        fill_polygon(c, [(x - w, by + 7), (x - w + 2, by),
                         (x + w - 2, by), (x + w, by + 7)], BONE_DARK)
        c.line(int(x - w + 2), int(by), int(x + w - 2), int(by), BONE)
        c.set(int(x), int(by + 4), BONE)

    # ---- glowing gill rakes.
    for i in range(4):
        gx = hin - 10 + i * 4
        c.vline(gx, hy - 4, hy + 10, GLOW_DEEP)
        c.vline(gx, hy - 1, hy + 6, GLOW)
        if pose.eye_glow > 0.5:
            c.set(gx, hy + 2, GLOW_HOT)

    # ---- eye: small, deep under the brow.
    ex = int(hin + SKULL_LEN * 0.32)
    ey = int(hy - 14)
    c.rect(ex - 2, ey - 2, ex + 3, ey + 2, HIDE_DARK)
    if pose.eye_glow > 0.75:
        eye_col, halo = GLOW_HOT, GLOW
    elif pose.eye_glow > 0.35:
        eye_col, halo = GLOW, GLOW_DEEP
    else:
        eye_col, halo = GLOW_DEEP, None
    c.rect(ex, ey, ex + 1, ey, eye_col)
    if halo:
        c.set(ex - 1, ey, halo)
        c.set(ex + 2, ey, halo)

    # ---- seaweed hanging from the jaw.
    for i in range(3):
        rx, ry = jaw_edge(20 + i * 22)
        for k in range(4 + i * 2):
            c.set(int(rx) + k // 3, int(ry) + 12 + k, MOSS)


def draw_leviathan(c: Canvas, pose: Pose) -> None:
    draw_body(c, pose)
    draw_head(c, pose)
    if pose.submerged_only:
        c.clip_below(WATER_Y)
    c.outline()
