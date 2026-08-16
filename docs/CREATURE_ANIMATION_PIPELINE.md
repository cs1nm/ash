# Creature animation pipeline

All animation textures are separate horizontal PNG strips with transparent backgrounds.
Every creature faces right; Godot flips it for left-facing movement.

## Regular enemy files

For each regular enemy:

```text
<enemy>_idle.png       # 4 frames
<enemy>_move.png       # 4–6 frames
<enemy>_attack_1.png   # 5–8 frames
<enemy>_attack_2.png   # 5–8 frames
<enemy>_attack_3.png   # 5–8 frames when needed
<enemy>_hurt.png       # 2–3 frames
<enemy>_death.png      # 6–10 frames
```

Examples:

```text
wild_slime_idle.png
wild_slime_move.png
wild_slime_attack_1.png
wild_slime_attack_2.png
wild_slime_hurt.png
wild_slime_death.png

mossling_idle.png
mossling_move.png
mossling_attack_1.png
mossling_attack_2.png
mossling_hurt.png
mossling_death.png
```

## Boss files

```text
<boss>_idle.png
<boss>_move.png
<boss>_spawn.png
<boss>_phase_2.png
<boss>_attack_1.png
...
<boss>_attack_6.png
<boss>_hurt.png
<boss>_death.png
```

Boss attacks use 8–12 frames, spawn/phase change use 8–12 frames, and death uses 12–16 frames.

## Animation timing convention

Every attack strip includes three beats:

1. **Telegraph / preparation** — frames 0–35%.
2. **Impact / projectile release / dash** — frames 35–60%.
3. **Recovery** — frames 60–100%.

Gameplay damage must be triggered at the impact frame, not on the first frame.

## Planned production order

1. Forest: Wild Slime, Mossling, Root Crawler.
2. Common caves: Cave Worm, Bat, Cave Husk.
3. Mushroom Halls: Spore Bat, Mushroom Beetle.
4. Ash City: Ash Phantom, Ash Wisp, Ash Sentinel, Ruin Drone.
5. Sunken Ruins, Lava Roots, Glass Abyss.
6. Stone Beast and Heartwood Core.

The gameplay definitions live in `data/enemy_combat_specs.json`.
