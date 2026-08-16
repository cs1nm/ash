from __future__ import annotations

import hashlib
import random
from pathlib import Path
from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
TILE_DIR = ROOT / "assets" / "textures" / "tiles"
ITEM_DIR = ROOT / "assets" / "textures" / "items"


def hex_to_rgb(value: str) -> tuple[int, int, int]:
    value = value.strip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))


def mix(a: tuple[int, int, int], b: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return tuple(max(0, min(255, int(a[i] + (b[i] - a[i]) * t))) for i in range(3))


def shade(color: tuple[int, int, int], amount: float) -> tuple[int, int, int]:
    target = (255, 255, 255) if amount > 0 else (0, 0, 0)
    return mix(color, target, abs(amount))


def seeded(name: str) -> random.Random:
    seed = int(hashlib.sha256(name.encode("utf-8")).hexdigest()[:12], 16)
    return random.Random(seed)


def save(img: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)


def make_tile(name: str, base_hex: str, kind: str = "stone", accent_hex: str | None = None) -> Image.Image:
    rng = seeded("tile-" + name)
    base = hex_to_rgb(base_hex)
    accent = hex_to_rgb(accent_hex) if accent_hex else shade(base, 0.35)
    img = Image.new("RGBA", (16, 16), (*base, 255))
    px = img.load()

    for y in range(16):
        for x in range(16):
            n = rng.randint(-20, 18)
            edge = -14 if x in (0, 15) or y in (0, 15) else 0
            top = 10 if y < 3 else 0
            color = shade(base, (n + edge + top) / 140.0)
            px[x, y] = (*color, 255)

    draw = ImageDraw.Draw(img)
    if kind == "grass":
        draw.rectangle((0, 0, 15, 3), fill=(*accent, 255))
        for x in range(0, 16, 2):
            h = rng.randint(1, 4)
            draw.line((x, 3, x + rng.choice([-1, 0, 1]), 3 - h), fill=(*shade(accent, 0.2), 255))
    elif kind == "ore":
        for _ in range(8):
            x = rng.randint(2, 13)
            y = rng.randint(2, 13)
            w = rng.randint(1, 3)
            h = rng.randint(1, 3)
            draw.rectangle((x, y, min(15, x + w), min(15, y + h)), fill=(*accent, 255))
            if rng.random() < 0.45:
                draw.point((min(15, x + w), y), fill=(*shade(accent, 0.45), 255))
    elif kind == "wood":
        for x in (4, 8, 12):
            draw.line((x, 0, x + rng.choice([-1, 0, 1]), 15), fill=(*shade(base, -0.22), 255))
        for y in (4, 10):
            draw.arc((2, y - 3, 13, y + 5), 0, 180, fill=(*shade(base, 0.22), 255))
    elif kind == "leaves":
        for _ in range(18):
            x = rng.randint(0, 15)
            y = rng.randint(0, 15)
            draw.point((x, y), fill=(*shade(base, rng.choice([0.24, -0.18])), 255))
    elif kind == "frost":
        # Sparse single-pixel rime flecks: frozen dirt stays a soil tile, not a
        # snow block with holes in it.
        for _ in range(16):
            x = rng.randint(1, 14)
            y = rng.randint(2, 15)
            draw.point((x, y), fill=(*shade(accent, rng.choice([0.0, -0.12])), 255))
            if rng.random() < 0.4:
                draw.point((min(15, x + 1), y), fill=(*shade(accent, -0.28), 255))
    elif kind == "ruin":
        for y in (4, 10):
            draw.line((0, y, 15, y), fill=(*shade(base, -0.28), 255))
        for x in (5, 11):
            draw.line((x, 0, x, 15), fill=(*shade(base, -0.18), 255))
        draw.rectangle((2, 2, 13, 13), outline=(*accent, 255))
    elif kind == "station":
        draw.rectangle((2, 4, 13, 13), fill=(*shade(base, -0.12), 255), outline=(*shade(base, 0.32), 255))
        draw.rectangle((4, 6, 11, 9), fill=(*accent, 255))
        draw.line((3, 14, 13, 14), fill=(*shade(base, -0.35), 255))
    elif kind == "heart":
        draw.rectangle((1, 1, 14, 14), fill=(*shade(base, -0.25), 255), outline=(*accent, 255))
        draw.rectangle((6, 3, 9, 12), fill=(*shade(accent, 0.25), 255))
        draw.rectangle((4, 5, 11, 10), outline=(*shade(accent, 0.45), 255))
    else:
        for _ in range(5):
            x = rng.randint(1, 13)
            y = rng.randint(2, 13)
            draw.line((x, y, min(15, x + rng.randint(1, 4)), min(15, y + rng.randint(-1, 2))), fill=(*shade(base, -0.25), 255))

    draw.rectangle((0, 0, 15, 15), outline=(*shade(base, -0.42), 255))
    return img


def rect(draw: ImageDraw.ImageDraw, xy: tuple[int, int, int, int], color: tuple[int, int, int]) -> None:
    draw.rectangle(xy, fill=(*color, 255))


def make_item(name: str, base_hex: str) -> Image.Image:
    base = hex_to_rgb(base_hex)
    img = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    dark = shade(base, -0.42)
    light = shade(base, 0.42)
    wood = hex_to_rgb("8b5a2b")

    if "pickaxe" in name:
        rect(draw, (4, 6, 16, 8), light)
        rect(draw, (15, 8, 19, 11), base)
        rect(draw, (9, 9, 12, 20), wood)
        rect(draw, (8, 18, 13, 21), shade(wood, -0.2))
    elif any(part in name for part in ["sword", "spear", "sickle"]):
        rect(draw, (11, 2, 13, 15), light)
        rect(draw, (10, 4, 14, 7), base)
        rect(draw, (7, 15, 17, 17), dark)
        rect(draw, (10, 17, 14, 22), wood)
    elif "bow" in name:
        draw.arc((5, 3, 18, 21), 80, 280, fill=(*base, 255), width=3)
        draw.line((15, 5, 15, 20), fill=(*light, 255), width=1)
        rect(draw, (8, 11, 17, 12), dark)
    elif any(part in name for part in ["shield", "armor"]):
        rect(draw, (7, 3, 17, 14), base)
        rect(draw, (9, 14, 15, 20), dark)
        rect(draw, (10, 6, 14, 11), light)
        draw.rectangle((6, 2, 18, 20), outline=(*shade(base, -0.55), 255))
    elif "staff" in name or "rod" in name:
        rect(draw, (11, 4, 13, 21), wood)
        rect(draw, (8, 2, 16, 8), base)
        rect(draw, (10, 4, 14, 6), light)
    elif "turret" in name or "cannon" in name:
        rect(draw, (5, 9, 16, 15), base)
        rect(draw, (15, 10, 22, 13), light)
        rect(draw, (8, 16, 14, 20), dark)
    elif any(part in name for part in ["bar", "ore", "shard", "core", "glass", "ash", "root", "stone", "brick"]):
        rect(draw, (5, 8, 17, 16), dark)
        rect(draw, (7, 5, 15, 11), base)
        rect(draw, (12, 12, 18, 15), light)
    elif any(part in name for part in ["workbench", "furnace", "anvil", "heart"]):
        rect(draw, (5, 6, 18, 17), base)
        rect(draw, (7, 8, 16, 12), light)
        rect(draw, (6, 18, 8, 21), dark)
        rect(draw, (15, 18, 17, 21), dark)
    else:
        rect(draw, (6, 6, 18, 18), base)
        rect(draw, (9, 9, 15, 15), light)

    return img


def main() -> None:
    tiles = {
        "grass": ("4f9f5f", "grass", "68c870"),
        "dirt": ("7a4a2a", "earth", None),
        "stone": ("60646f", "stone", None),
        "copper": ("665b5c", "ore", "e18a4a"),
        "iron": ("626872", "ore", "e3e0cf"),
        "ash": ("4b4a54", "ore", "a987ff"),
        "root": ("8d6939", "wood", "b98b4b"),
        "wood": ("9a6132", "wood", None),
        "leaves": ("4a7b50", "leaves", None),
        "ruin": ("746b83", "ruin", "b9a7db"),
        "workbench": ("a0703f", "station", "d69b55"),
        "furnace": ("3d4650", "station", "ff7d3b"),
        "anvil": ("485468", "station", "b8c5d7"),
        "turret": ("748c9c", "station", "c8eef2"),
        "heart": ("6e3146", "heart", "ff7da1"),
        # Surface biome topsoils.
        "ash_sand": ("c9b591", "earth", None),
        "frozen_dirt": ("5d7083", "frost", "cfe4f2"),
        "mud": ("4f3d2a", "earth", None),
        "rubble": ("77695c", "stone", None),
    }
    for name, (base, kind, accent) in tiles.items():
        save(make_tile(name, base, kind, accent), TILE_DIR / f"{name}.png")

    # Topsoil tiles ship variants so large excavated areas do not look tiled.
    variant_tiles = {
        "ash_sand": ("c9b591", "earth", None),
        "frozen_dirt": ("5d7083", "frost", "cfe4f2"),
        "mud": ("4f3d2a", "earth", None),
        "rubble": ("77695c", "stone", None),
    }
    for name, (base, kind, accent) in variant_tiles.items():
        for index in range(1, 4):
            save(make_tile(f"{name}_{index}", base, kind, accent), TILE_DIR / f"{name}_{index}.png")

    item_colors = {
        # Specific ids come first: the first containing key wins below, and
        # e.g. "frozen_dirt" would otherwise be shadowed by "dirt".
        "ash_sand": "c9b591",
        "frozen_dirt": "8fa3b8",
        "mud": "6b5340",
        "rubble": "8d7f72",
        "wood": "a66a35",
        "dirt": "7a4a2a",
        "stone": "69717c",
        "copper": "c97a45",
        "iron": "c9c6b7",
        "ash": "9b7bd8",
        "root": "8a6638",
        "spark": "ffcf5f",
        "ruin": "81759a",
        "default": "7fb6d6",
    }
    item_names = [
        "dirt", "stone", "copper_ore", "iron_ore", "ash", "root", "wood", "leaf", "ruin_brick",
        "ash_sand", "frozen_dirt", "mud", "rubble",
        "copper_bar", "iron_bar", "ash_glass", "root_core", "spark_shard", "memory_shard", "world_memory",
        "workbench", "furnace", "anvil", "settlement_heart", "wooden_pickaxe", "copper_pickaxe",
        "iron_pickaxe", "ash_pickaxe", "builder_hammer", "wooden_sword", "copper_sword", "iron_spear",
        "wooden_shield", "copper_shield", "wooden_bow", "copper_bow", "fire_arrows", "hand_cannon",
        "spark_staff", "root_spirit_rod", "acid_flasks", "small_turret", "ash_sickle", "copper_armor",
        "iron_armor", "ash_charm", "root_ring",
    ]
    for item in item_names:
        key = next((k for k in item_colors if k != "default" and k in item), "default")
        save(make_item(item, item_colors[key]), ITEM_DIR / f"{item}.png")


if __name__ == "__main__":
    main()
