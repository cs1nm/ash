#!/usr/bin/env python3
"""Build the Sea Leviathan asset pack for Ashen Roots.

Approach
--------
The creature itself is a single hand-detailed sprite (see make_base.py), in the
same richly shaded style as the project's own bosses. Animation is done by
cutting that sprite into parts and posing them per frame:

    head + jaw + body + tail

The lower jaw really rotates about its hinge, the body flexes, and the whole
animal rises out of the water. That keeps the painted detail identical in every
frame while still giving real motion, which is exactly what a downscaled render
or a set of drawn primitives could not do.

Water, foam and the standalone VFX are drawn procedurally on top.

Outputs, under assets/textures/enemies/leviathan/:
  * 12 animation spritesheets, horizontal, frames left to right
  * 6 VFX spritesheets
  * previews/*.gif for every animation and effect, plus preview_all.gif
  * leviathan_base.png, leviathan.json, README.txt

Usage: python3 tools/leviathan/build_leviathan.py
"""

from __future__ import annotations

import json
import math
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from PIL import Image  # noqa: E402

from palette import Canvas  # noqa: E402
import water  # noqa: E402

ROOT = HERE.parents[1]
OUT_DIR = ROOT / "assets" / "textures" / "enemies" / "leviathan"
SPRITE = HERE / "sources" / "leviathan_base_sprite.png"

W, H = 256, 192
WIDE_W, WIDE_H = 384, 192
WATER_Y = 132
ANCHOR = (128, 132)

# Where to cut the base sprite. Measured from the rendered sprite: the jaw
# hinge sits just behind the eye, the neck a little further back.
# Read off the sprite: the jaw hinge sits at x~0.72, the mouth line at y~0.50.
# The cut starts a little behind the hinge so the jaw stays attached when it
# rotates instead of tearing away from the skull.
JAW_CUT_X = 0.700
JAW_CUT_Y = 0.560
HEAD_CUT_X = 0.520
JAW_PIVOT = (0.715, 0.575)


def load_parts() -> dict[str, Image.Image]:
    """Cut the base sprite into head, jaw, body and tail."""
    if not SPRITE.exists():
        raise SystemExit(f"missing base sprite: {SPRITE}\nrun tools/leviathan/make_base.py first")
    base = Image.open(SPRITE).convert("RGBA")
    w, h = base.size
    jx, jy = int(w * JAW_CUT_X), int(h * JAW_CUT_Y)
    hx = int(w * HEAD_CUT_X)

    jaw = Image.new("RGBA", base.size, (0, 0, 0, 0))
    jaw.paste(base.crop((jx, jy, w, h)), (jx, jy))

    rest = base.copy()
    px = rest.load()
    for y in range(jy, h):
        for x in range(jx, w):
            px[x, y] = (0, 0, 0, 0)

    head = Image.new("RGBA", base.size, (0, 0, 0, 0))
    head.paste(rest.crop((hx, 0, w, h)), (hx, 0))

    body = Image.new("RGBA", base.size, (0, 0, 0, 0))
    body.paste(rest.crop((0, 0, hx, h)), (0, 0))

    return {"base": base, "head": head, "jaw": jaw, "body": body}


PARTS = load_parts()
BASE_W, BASE_H = PARTS["base"].size


def rotate_about(img: Image.Image, pivot: tuple[float, float], deg: float) -> Image.Image:
    """Rotate keeping the canvas, about a pivot given in pixels."""
    if abs(deg) < 0.01:
        return img
    return img.rotate(deg, resample=Image.NEAREST, center=pivot)


def pose_creature(gape: float, flex: float, scale: float = 1.0) -> Image.Image:
    """Compose head + rotated jaw + flexed body into one image."""
    canvas = Image.new("RGBA", (BASE_W, BASE_H), (0, 0, 0, 0))

    body = PARTS["body"]
    if abs(flex) > 0.01:
        body = body.rotate(flex * 5.0, resample=Image.NEAREST,
                           center=(BASE_W * 0.62, BASE_H * 0.55))
    canvas.alpha_composite(body)

    pivot = (BASE_W * JAW_PIVOT[0], BASE_H * JAW_PIVOT[1])
    jaw = rotate_about(PARTS["jaw"], pivot, -gape * 19.0)
    canvas.alpha_composite(jaw)
    canvas.alpha_composite(PARTS["head"])

    if scale != 1.0:
        nw, nh = max(1, round(BASE_W * scale)), max(1, round(BASE_H * scale))
        canvas = canvas.resize((nw, nh), Image.NEAREST)
    return canvas


def frame(gape: float, rise: float, flex: float, x: int = 150, y: int = 96,
          scale: float = 1.0, surface_phase: float = 0.0, disturb: float = 0.4,
          size: tuple[int, int] = (W, H), water_on: bool = True,
          submerge: float = 0.0) -> Canvas:
    """One creature frame composited over the water surface."""
    c = Canvas(*size)
    if water_on:
        water.draw_surface(c, surface_phase, disturb=disturb)
    sprite = pose_creature(gape, flex, scale)
    # rise lifts the animal; submerge sinks it below the waterline
    top = int(y - rise * 30.0 + submerge * 70.0)
    left = int(x - sprite.width * 0.62)
    img = c.to_image()
    img.alpha_composite(sprite, (left, top))
    # Nothing shows below the waterline: depth swallows it.
    px = img.load()
    for yy in range(WATER_Y + 3, size[1]):
        for xx in range(size[0]):
            r, g, b, a = px[xx, yy]
            if a and (r, g, b, a) not in water.SURFACE_COLORS:
                px[xx, yy] = (0, 0, 0, 0)
    out = Canvas(*size)
    out.px = [[px[x, y] for x in range(size[0])] for y in range(size[1])]
    if water_on:
        # redraw the surface line on top so the body is cut by the water
        tmp = Canvas(*size)
        water.draw_surface(tmp, surface_phase, disturb=disturb)
        for yy in range(WATER_Y - 2, size[1]):
            for xx in range(size[0]):
                p = tmp.get(xx, yy)
                if p[3] and yy > WATER_Y - 1:
                    out.set(xx, yy, p)
    return out


def sheet(frames: list[Canvas]) -> Image.Image:
    fw, fh = frames[0].w, frames[0].h
    img = Image.new("RGBA", (fw * len(frames), fh), (0, 0, 0, 0))
    for i, c in enumerate(frames):
        img.alpha_composite(c.to_image(), (i * fw, 0))
    return img


# --------------------------------------------------------------------------
# Animations
# --------------------------------------------------------------------------

def anim_idle() -> list[Canvas]:
    out = []
    for i in range(8):
        t = i / 8
        bob = math.sin(t * math.tau)
        out.append(frame(gape=0.04, rise=0.10 + bob * 0.03, flex=bob * 0.25,
                         y=96 + int(bob * 2), surface_phase=t * math.tau,
                         disturb=0.2, submerge=0.30))
    return out


def anim_patrol() -> list[Canvas]:
    out = []
    for i in range(10):
        t = i / 10
        bob = math.sin(t * math.tau)
        c = frame(gape=0.06, rise=0.14, flex=bob, x=150 + int(math.cos(t * math.tau) * 4),
                  y=94 + int(bob * 3), surface_phase=t * math.tau * 1.4,
                  disturb=0.6, submerge=0.24)
        for k in range(5):
            water.splash(c, 70 - k * 14, WATER_Y - 1, 0.3 + 0.1 * k, 12, seed=70 + k)
        out.append(c)
    return out


def anim_detect() -> list[Canvas]:
    out = []
    for i in range(6):
        t = i / 5
        out.append(frame(gape=0.05 + t * 0.15, rise=0.10 + t * 0.20, flex=t * 0.4,
                         y=96 - int(t * 4), surface_phase=t * 3.0,
                         disturb=0.4 + t, submerge=0.30 - t * 0.16))
    return out


def anim_emerge() -> list[Canvas]:
    out = []
    for i in range(10):
        t = i / 9
        e = t * t * (3 - 2 * t)
        c = frame(gape=0.15 + e * 0.5, rise=e * 0.9, flex=-e * 0.5,
                  y=96 - int(e * 8), surface_phase=t * 4.0,
                  disturb=1.0 + e, submerge=0.30 * (1 - e))
        water.foam_mound(c, 128, WATER_Y + 1, int(62 * (1 - e * 0.35)), int(10 + 18 * e))
        water.splash(c, 132, WATER_Y - 6, min(1.0, t * 1.3), 78, seed=90)
        out.append(c)
    return out


def anim_bite() -> list[Canvas]:
    out = []
    for i in range(12):
        if i < 5:
            t = i / 4
            c = frame(gape=0.2 + t * 0.8, rise=0.8, flex=-0.5 - t * 0.3,
                      x=142 - int(t * 6), y=90, surface_phase=i * 0.5, disturb=1.2)
        elif i == 5:
            c = frame(gape=1.0, rise=0.9, flex=0.3, x=178, y=92,
                      surface_phase=3.0, disturb=1.6)
        elif i in (6, 7):
            c = frame(gape=0.7 if i == 6 else 0.3, rise=0.85, flex=0.7,
                      x=192, y=94, surface_phase=3.5, disturb=1.8)
            water.splash(c, 206, WATER_Y - 10, 0.35 + (i - 6) * 0.3, 60, seed=100 + i)
        else:
            t = (i - 8) / 3
            c = frame(gape=0.25 * (1 - t), rise=0.85 - t * 0.6, flex=0.5 - t,
                      x=int(192 - t * 44), y=94 - int(t * 2),
                      surface_phase=4.0 + t, disturb=1.4 - t)
        out.append(c)
    return out


def anim_devour() -> list[Canvas]:
    out = []
    for i in range(14):
        if i < 6:
            t = i / 5
            c = frame(gape=0.1, rise=0.16 * (1 - t), flex=t * 0.6,
                      y=96 + int(t * 20), surface_phase=t * 2,
                      disturb=0.9 - t * 0.6, submerge=0.30 + t * 0.7)
        elif i < 9:
            t = (i - 6) / 2
            c = frame(gape=0.55 + t * 0.45, rise=0.3 + t * 0.8, flex=-0.8,
                      y=96 - int(t * 22), surface_phase=3.0, disturb=1.8,
                      submerge=0.6 * (1 - t))
            water.splash(c, 150, WATER_Y - 8, min(1.0, 0.3 + t), 90, seed=120)
            water.foam_mound(c, 150, WATER_Y + 1, 56, 20)
        else:
            t = (i - 9) / 4
            c = frame(gape=0.85 - t * 0.6, rise=1.0 - t * 0.95, flex=-0.6 + t,
                      y=88 + int(t * 30), surface_phase=4.0 + t,
                      disturb=1.6 - t, submerge=t * 0.8)
            water.splash(c, 150, WATER_Y - 2, 0.4 + t * 0.6, 60, seed=130)
        out.append(c)
    return out


def anim_tail_wave() -> list[Canvas]:
    out = []
    for i in range(14):
        t = i / 13
        swing = math.sin(t * math.pi)
        c = frame(gape=0.15 + 0.2 * swing, rise=0.25 + 0.4 * swing,
                  flex=-1.4 * swing, y=96 - int(swing * 6),
                  surface_phase=t * 5, disturb=0.8 + swing,
                  submerge=0.24 * (1 - swing))
        if i >= 5:
            k = (i - 5) / 8
            water.foam_mound(c, 56 + int(k * 26), WATER_Y + 1, 42, int(8 + 24 * k))
            water.splash(c, 64, WATER_Y - 12, min(1.0, k * 1.3), 56, seed=140)
        out.append(c)
    return out


def anim_roar() -> list[Canvas]:
    out = []
    for i in range(12):
        t = i / 11
        pulse = abs(math.sin(t * math.pi * 2.5))
        c = frame(gape=0.5 + 0.45 * pulse, rise=0.78, flex=-0.6,
                  y=88, surface_phase=t * 4, disturb=1.0 + pulse)
        if i >= 4:
            k = (i - 4) / 7
            for ring in range(2):
                rp = k - ring * 0.3
                if rp <= 0:
                    continue
                r = rp * 92
                for s in range(46):
                    a = -math.pi / 2 + (s / 46 - 0.5) * math.pi * 1.6
                    x = int(196 + math.cos(a) * r)
                    y = int(100 + math.sin(a) * r * 0.62)
                    c.set(x, y, water.GLOW_HOT if rp < 0.4 else water.GLOW_DEEP)
        out.append(c)
    return out


def anim_tentacles() -> list[Canvas]:
    out = []
    for i in range(14):
        t = i / 13
        c = frame(gape=0.1 + 0.3 * math.sin(t * math.pi), rise=0.14,
                  flex=t * 0.5, surface_phase=t * 3, disturb=0.9 + t,
                  submerge=0.28)
        for k, bx in enumerate((52, 86, 198, 232)):
            grow = min(1.0, max(0.0, (t - k * 0.06) * 1.7))
            if grow <= 0:
                continue
            length = int(72 * grow)
            x, y = float(bx), float(WATER_Y - 2)
            lean = 1.35 + k * 0.06
            curl = math.sin(t * math.pi * 1.2 + k) * 0.5
            for s in range(length):
                pr = s / max(1, length)
                x += math.cos(-lean + curl * pr)
                y += math.sin(-lean + curl * pr)
                thick = max(1, int(3 * (1 - pr * 0.7)))
                for d in range(-thick, thick + 1):
                    c.set(int(x) + d, int(y),
                          water.HIDE_DARK if abs(d) == thick else water.HIDE_MID)
            c.set(int(x), int(y) - 1, water.GLOW_DEEP)
            water.splash(c, bx, WATER_Y - 1, min(1.0, grow * 1.5), 22, seed=150 + k)
        out.append(c)
    return out


def anim_hurt() -> list[Canvas]:
    out = []
    for i in range(4):
        t = i / 3
        c = frame(gape=0.55 * (1 - t) + 0.1, rise=0.72, flex=-0.4 + t * 0.5,
                  x=146 - int((1 - t) * 6), y=90 + int((1 - t) * 3),
                  surface_phase=t * 3, disturb=1.4)
        water.splash(c, 140, WATER_Y - 14, 0.3 + t * 0.5, 46, seed=160)
        out.append(c)
    return out


def anim_enraged() -> list[Canvas]:
    out = []
    for i in range(8):
        t = i / 8
        pulse = abs(math.sin(t * math.pi * 2))
        c = frame(gape=0.35 + 0.5 * pulse, rise=0.88, flex=-0.7 + pulse * 0.6,
                  y=86, surface_phase=t * 6, disturb=1.8 + pulse)
        for k in range(9):
            water.splash(c, 30 + k * 24, WATER_Y - 2, (t + k * 0.1) % 1.0, 20, seed=170 + k)
        out.append(c)
    return out


def anim_death() -> list[Canvas]:
    out = []
    for i in range(18):
        t = i / 17
        sink = t ** 1.4
        c = frame(gape=max(0.05, 0.6 - t * 0.55), rise=max(0.0, 0.8 - sink * 0.9),
                  flex=-0.5 + t * 1.2, y=88 + int(sink * 26),
                  surface_phase=t * 3, disturb=max(0.0, 1.4 - t * 1.4),
                  submerge=sink * 0.9)
        if t < 0.5:
            water.splash(c, 150, WATER_Y - 8, t * 2, 62, seed=180)
        out.append(c)
    return out


SPEC = [
    ("Idle_Submerged", anim_idle, 6, True, [], [], None),
    ("Patrol_Swim", anim_patrol, 8, True, [], [], None),
    ("Detect", anim_detect, 10, False, [], [], None),
    ("Emerge", anim_emerge, 12, False, [], [], None),
    ("Attack_1_Bite", anim_bite, 14, False, [7, 8], [],
     {"name": "Bite_Splash", "frame": 6, "pos": [206, 130]}),
    ("Attack_2_Devour", anim_devour, 12, False, [9], [],
     {"name": "Devour_Splash", "frame": 7, "pos": [150, 132]}),
    ("Attack_3_Tail_Wave", anim_tail_wave, 11, False, [8], [8],
     {"name": "Tidal_Wave", "frame": 6, "pos": [56, 132]}),
    ("Attack_4_Deep_Roar", anim_roar, 10, False, [7], [],
     {"name": "Sonic_Rings", "frame": 5, "pos": [196, 100]}),
    ("Attack_5_Depth_Tentacles", anim_tentacles, 11, False, [9], [],
     {"name": "Tentacles", "frame": 4, "pos": [128, 132]}),
    ("Hurt", anim_hurt, 14, False, [], [], None),
    ("Enraged", anim_enraged, 10, True, [], [], None),
    ("Death", anim_death, 8, False, [], [],
     {"name": "Death_Whirlpool", "frame": 8, "pos": [128, 136]}),
]

VFX_SPEC = [
    ("Bite_Splash", water.build_bite_splash, 8, 160, 128, 16, [80, 96]),
    ("Devour_Splash", water.build_devour_splash, 12, WIDE_W, WIDE_H, 14, [192, 150]),
    ("Tidal_Wave", water.build_tidal_wave, 14, WIDE_W, WIDE_H, 11, [192, 150]),
    ("Sonic_Rings", water.build_sonic_rings, 10, W, H, 12, [128, 88]),
    ("Tentacles", water.build_tentacles, 14, WIDE_W, WIDE_H, 11, [192, 150]),
    ("Death_Whirlpool", water.build_death_whirlpool, 14, WIDE_W, WIDE_H, 10, [192, 150]),
]


def save_gif(frames: list[Image.Image], path: Path, fps: int) -> None:
    backed = []
    for f in frames:
        bg = Image.new("RGBA", f.size, (10, 20, 28, 255))
        bg.alpha_composite(f)
        backed.append(bg.convert("P", palette=Image.ADAPTIVE, colors=128))
    backed[0].save(path, save_all=True, append_images=backed[1:],
                   duration=int(1000 / fps), loop=0, disposal=2)


def check(img: Image.Image, name: str) -> None:
    soft = sum(1 for p in img.getdata() if 0 < p[3] < 255)
    if soft:
        raise AssertionError(f"{name}: {soft} soft alpha pixels")


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    gif_dir = OUT_DIR / "previews"
    gif_dir.mkdir(exist_ok=True)

    meta: dict = {
        "name": "Sea Leviathan",
        "id": "sea_leviathan",
        "description": ("Ancient world-edge guardian. Rises from the deep to kill "
                        "anything trying to swim past the border of the map."),
        "frame_size": [W, H],
        "wide_frame_size": [WIDE_W, WIDE_H],
        "anchor": list(ANCHOR),
        "anchor_note": "point on the water surface directly under the head",
        "waterline_y": WATER_Y,
        "alpha": "binary",
        "facing": "right",
        "animations": {}, "vfx": {}, "combat": {}, "behavior": {},
    }
    all_preview: list[Image.Image] = []

    for name, builder, fps, loop, hits, projectiles, vfx in SPEC:
        frames = builder()
        img = sheet(frames)
        check(img, name)
        img.save(OUT_DIR / f"{name}.png")
        images = [c.to_image() for c in frames]
        save_gif(images, gif_dir / f"{name}.gif", fps)
        all_preview.extend(images)
        entry = {
            "file": f"{name}.png", "frames": len(frames), "fps": fps, "loop": loop,
            "frame_size": [frames[0].w, frames[0].h], "anchor": list(ANCHOR),
            "hit_frames": hits, "projectile_frames": projectiles,
        }
        if vfx:
            entry["vfx"] = {"name": vfx["name"], "spawn_frame": vfx["frame"],
                            "spawn_pos": vfx["pos"]}
        meta["animations"][name] = entry
        print(f"{name:26s} {len(frames):2d}f {fps:2d}fps")

    for name, builder, count, fw, fh, fps, anchor in VFX_SPEC:
        frames = builder(count, fw, fh)
        img = sheet(frames)
        check(img, name)
        img.save(OUT_DIR / f"VFX_{name}.png")
        save_gif([c.to_image() for c in frames], gif_dir / f"VFX_{name}.gif", fps)
        meta["vfx"][name] = {"file": f"VFX_{name}.png", "frames": count, "fps": fps,
                             "frame_size": [fw, fh], "anchor": anchor, "loop": False}
        print(f"VFX {name:22s} {count:2d}f {fps:2d}fps")

    base = frame(gape=0.55, rise=0.8, flex=-0.4, y=88, disturb=0.8)
    base.to_image().save(OUT_DIR / "leviathan_base.png")
    save_gif(all_preview, gif_dir / "preview_all.gif", 12)

    meta["combat"] = {
        "max_hp": 500, "hp_note": "five times the player's 100 HP",
        "damage_per_hit": 20,
        "damage_note": "five hits to kill a full health player, never a one shot",
        "invulnerable": True,
        "invulnerable_note": ("cannot be defeated by ordinary weapons; damage is "
                              "refused until leviathan_story_unlocked is set"),
        "story_flag": "leviathan_story_unlocked", "knockback": 340.0,
        "attacks": {
            "Attack_1_Bite": {"range_px": 210, "cooldown": 3.4, "damage": 20},
            "Attack_2_Devour": {"range_px": 150, "cooldown": 9.0, "damage": 20,
                                "note": "finisher used past the border"},
            "Attack_3_Tail_Wave": {"range_px": 320, "cooldown": 6.0, "damage": 12,
                                   "note": "pushes the target back toward the map"},
            "Attack_4_Deep_Roar": {"range_px": 380, "cooldown": 7.5, "damage": 8,
                                   "status": ["stun", "slow"]},
            "Attack_5_Depth_Tentacles": {"range_px": 260, "cooldown": 8.0,
                                         "damage": 14, "status": ["root"]},
        },
    }
    meta["behavior"] = {
        "stages": [
            {"name": "warning", "trigger": "player enters the edge water",
             "shows": "eyes under the surface and a distant roar"},
            {"name": "push_back", "trigger": "player keeps swimming out",
             "shows": "Attack_3_Tail_Wave shoves the player inland"},
            {"name": "hunt", "trigger": "player ignores the warning",
             "shows": "Emerge, then bite, roar and tentacle attacks"},
            {"name": "execute", "trigger": "player crosses the border",
             "shows": "Attack_2_Devour"},
        ],
        "notes": ["attacks must read as lethal without any UI warning",
                  "most of the body always stays hidden under the water"],
    }
    (OUT_DIR / "leviathan.json").write_text(json.dumps(meta, indent=2) + "\n",
                                            encoding="utf-8")

    # ------------------------------------------------------------------
    # Engine-native pack. _load_enemy_animation_pack expects a flat
    # {frame_size, facing, anchor, animations{state:{file,frames,fps,loop}}}
    # document with lowercase state keys, so the descriptive pack above is
    # mirrored into the shape the game already knows how to read. No engine
    # change is needed: the leviathan loads exactly like the bat or the slime.
    # ------------------------------------------------------------------
    state_map = {
        "Idle_Submerged": "idle",
        "Patrol_Swim": "move",
        "Detect": "detect",
        "Emerge": "emerge",
        "Attack_1_Bite": "attack_1",
        "Attack_2_Devour": "attack_2",
        "Attack_3_Tail_Wave": "attack_3",
        "Attack_4_Deep_Roar": "attack_4",
        "Attack_5_Depth_Tentacles": "attack_5",
        "Hurt": "hurt",
        "Enraged": "enraged",
        "Death": "death",
    }
    engine_anims: dict = {}
    for src, state in state_map.items():
        e = meta["animations"][src]
        entry = {"file": e["file"], "frames": e["frames"], "fps": e["fps"],
                 "loop": e["loop"]}
        if e["hit_frames"]:
            # The engine counts frames from zero; the brief numbered them from one.
            entry["hit_frames"] = [h - 1 for h in e["hit_frames"]]
        engine_anims[state] = entry
    engine_pack = {
        "frame_size": [W, H],
        "facing": "right",
        "anchor": {"x": ANCHOR[0], "y": ANCHOR[1]},
        "frame_indexing": "0-based",
        "ground_clearance": 0,
        "state_fallbacks": {
            "attack_1": "attack_1", "attack_2": "attack_1",
            "attack_3": "attack_1", "attack_4": "attack_1",
            "attack_5": "attack_1", "detect": "idle",
            "emerge": "move", "enraged": "move", "death": "hurt",
        },
        "animations": engine_anims,
    }
    (OUT_DIR / "leviathan_anim.json").write_text(
        json.dumps(engine_pack, indent=2) + "\n", encoding="utf-8")
    print("wrote leviathan_anim.json (engine format)")


    readme = f"""Sea Leviathan asset pack - Ashen Roots
======================================

World-edge guardian. Rises from the deep and kills anything trying to swim
past the border of the map.

Format
------
Frame size   : {W}x{H} (wide effects {WIDE_W}x{WIDE_H})
Anchor       : {ANCHOR[0]},{ANCHOR[1]} - the water surface under the head
Waterline    : y={WATER_Y}
Sheets       : horizontal, frames left to right
Alpha        : binary only, 0 or 255
Facing       : right

Art
---
The creature is one detailed sprite in the same richly shaded style as the
project's own bosses, cut into head / jaw / body and re-posed per frame. The
lower jaw genuinely rotates about its hinge and the body flexes, so the
painted detail is identical in every frame while the motion is real.

Animations
----------
""" + "\n".join(
        f"{n:26s} {len(b()):2d} frames  {f:2d} fps  loop={str(l).lower():5s}"
        f"  hit={h if h else '-'}" for n, b, f, l, h, _p, _v in SPEC
    ) + """

Effects
-------
""" + "\n".join(
        f"{n:22s} {c:2d} frames  {fps:2d} fps  {fw}x{fh}  anchor {a[0]},{a[1]}"
        for n, _b, c, fw, fh, fps, a in VFX_SPEC
    ) + """

Combat
------
Max HP         : 500 (five times the player's 100)
Damage per hit : 20 - five hits kill a full health player, never a one shot
Defeat         : impossible with ordinary weapons. Damage is refused until the
                 story flag 'leviathan_story_unlocked' is set; only then does
                 the Death animation become reachable.

Behaviour
---------
1. warning   - player enters the edge water: eyes glow, distant roar
2. push_back - player keeps going: Tail Wave shoves them back inland
3. hunt      - warning ignored: Emerge, then bite / roar / tentacles
4. execute   - player crosses the border: Devour

Regenerate
----------
    python3 tools/leviathan/make_base.py        # concept render -> base sprite
    python3 tools/leviathan/build_leviathan.py  # base sprite -> full pack
"""
    (OUT_DIR / "README.txt").write_text(readme, encoding="utf-8")
    print(f"\nwrote {len(SPEC)} animations, {len(VFX_SPEC)} effects -> {OUT_DIR}")
    print("LEVIATHAN_PACK_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
