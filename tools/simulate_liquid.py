#!/usr/bin/env python3
"""Offline check for the partial-fill liquid simulation in scripts/liquid_sim.gd.

Faithful port of `_try_spread_liquid` and its helpers so the two properties
that matter can be verified without launching Godot:

* volume is conserved exactly (no liquid is created or destroyed), and
* pools reach a still state instead of oscillating forever, which is the
  "jittering water" bug the fill levels were added to fix.

The old whole-block behaviour is included as a baseline so the difference is
measurable rather than a claim.

Usage: python3 tools/simulate_liquid.py
"""

from __future__ import annotations

AIR = 0
STONE = 3
WATER = 27
LAVA = 28

LEVEL_MAX = 8
MIN_EQUALIZE_DIFFERENCE = 2
LAVA_EQUALIZE_DIFFERENCE = 3


class LiquidSim:
    """Port of the GDScript simulation, minus the queue/culling bookkeeping."""

    def __init__(self, world: list[list[int]], partial: bool = True) -> None:
        self.world = world
        self.partial = partial
        self.levels: dict[tuple[int, int], int] = {}
        self.flow_tick = 0
        for y, row in enumerate(world):
            for x, tile in enumerate(row):
                if tile in (WATER, LAVA):
                    self.levels[(x, y)] = LEVEL_MAX

    # -- helpers -----------------------------------------------------------
    def tile_at(self, x: int, y: int) -> int:
        if y < 0 or y >= len(self.world):
            return STONE
        row = self.world[y]
        if x < 0 or x >= len(row):
            return STONE
        return row[x]

    def level_at(self, x: int, y: int) -> int:
        return self.levels.get((x, y), LEVEL_MAX)

    def total_volume(self) -> int:
        return sum(self.levels.values())

    def transfer(self, sx: int, sy: int, tx: int, ty: int, tile: int, amount: int) -> int:
        source_level = self.level_at(sx, sy)
        moved = min(amount, source_level)
        target_level = self.level_at(tx, ty) if self.tile_at(tx, ty) == tile else 0
        moved = min(moved, LEVEL_MAX - target_level)
        if moved <= 0:
            return 0
        remaining = source_level - moved
        if remaining > 0:
            self.levels[(sx, sy)] = remaining
        else:
            self.world[sy][sx] = AIR
            self.levels.pop((sx, sy), None)
        self.world[ty][tx] = tile
        self.levels[(tx, ty)] = target_level + moved
        return 2

    def solidify(self, sx: int, sy: int, tx: int, ty: int) -> int:
        self.world[sy][sx] = STONE
        self.world[ty][tx] = STONE
        self.levels.pop((sx, sy), None)
        self.levels.pop((tx, ty), None)
        return 2

    @staticmethod
    def opposite(a: int, b: int) -> bool:
        return (a == WATER and b == LAVA) or (a == LAVA and b == WATER)

    # -- the rule under test ----------------------------------------------
    def spread(self, x: int, y: int) -> int:
        tile = self.tile_at(x, y)
        if tile not in (WATER, LAVA):
            return 0
        if tile == LAVA and (self.flow_tick + abs(x * 17 + y * 31)) % 3 != 0:
            return 0
        level = self.level_at(x, y)
        if level <= 0:
            return 0

        below = self.tile_at(x, y + 1)
        if self.opposite(tile, below):
            return self.solidify(x, y, x, y + 1)
        if below == AIR or below == tile:
            below_level = 0 if below == AIR else self.level_at(x, y + 1)
            if not self.partial:
                # Legacy behaviour: whole blocks only move into empty air.
                if below == AIR:
                    return self.transfer(x, y, x, y + 1, tile, LEVEL_MAX)
            else:
                free = LEVEL_MAX - below_level
                if free > 0:
                    return self.transfer(x, y, x, y + 1, tile, min(level, free))

        first_dir = -1 if (self.flow_tick + x + y) % 2 == 0 else 1
        for direction in (first_dir, -first_dir):
            dx, dy = x + direction, y + 1
            diagonal = self.tile_at(dx, dy)
            if self.opposite(tile, diagonal):
                return self.solidify(x, y, dx, dy)
            if diagonal != AIR and diagonal != tile:
                continue
            diagonal_level = 0 if diagonal == AIR else self.level_at(dx, dy)
            if diagonal_level >= LEVEL_MAX:
                continue
            under = self.tile_at(dx, dy + 1)
            under_has_room = under == tile and self.level_at(dx, dy + 1) < LEVEL_MAX
            if under == AIR or under_has_room:
                if not self.partial:
                    if diagonal == AIR:
                        return self.transfer(x, y, dx, dy, tile, LEVEL_MAX)
                    continue
                return self.transfer(x, y, dx, dy, tile, min(level, LEVEL_MAX - diagonal_level))

        threshold = LAVA_EQUALIZE_DIFFERENCE if tile == LAVA else MIN_EQUALIZE_DIFFERENCE
        for direction in (first_dir, -first_dir):
            sx, sy = x + direction, y
            side = self.tile_at(sx, sy)
            if self.opposite(tile, side):
                return self.solidify(x, y, sx, sy)
            if side != AIR and side != tile:
                continue
            side_level = 0 if side == AIR else self.level_at(sx, sy)
            if not self.partial:
                # Legacy behaviour: move a whole block sideways whenever the
                # target is air and has support underneath. This is exactly
                # what makes a full pool jitter forever.
                if side == AIR and self.tile_at(sx, sy + 1) != AIR:
                    return self.transfer(x, y, sx, sy, tile, LEVEL_MAX)
                continue
            difference = level - side_level
            if difference >= threshold:
                amount = min(max(1, difference // 2), LEVEL_MAX - side_level)
                if amount > 0:
                    return self.transfer(x, y, sx, sy, tile, amount)
            elif difference == 1 and tile != LAVA:
                # Keep draining a long wedge whose slope carries on descending,
                # instead of letting it freeze as a staircase.
                beyond = self.tile_at(sx + direction, sy)
                if beyond == tile and self.level_at(sx + direction, sy) < side_level:
                    return self.transfer(x, y, sx, sy, tile, 1)
        return 0

    def step(self) -> int:
        self.flow_tick += 1
        changed = 0
        # Bottom-up sweep, mirroring how the queue drains in practice.
        positions = sorted(self.levels.keys(), key=lambda p: (-p[1], p[0]))
        for x, y in positions:
            if (x, y) in self.levels:
                changed += self.spread(x, y)
        return changed


def make_pool(width: int, height: int, water_rows: int, floor_gap: int = 0) -> list[list[int]]:
    world = [[AIR for _ in range(width)] for _ in range(height)]
    for x in range(width):
        world[height - 1][x] = STONE
    for x in (0, width - 1):
        for y in range(height):
            world[y][x] = STONE
    for row in range(water_rows):
        y = height - 2 - row - floor_gap
        for x in range(1, width - 1):
            world[y][x] = WATER
    return world


def make_uneven_pond() -> list[list[int]]:
    """Pond with a stepped bed and an open shore, like the reported screenshot."""
    world = [[AIR for _ in range(26)] for _ in range(12)]
    for x in range(26):
        world[11][x] = STONE
    for x in (0, 25):
        for y in range(12):
            world[y][x] = STONE
    for x in range(1, 9):
        world[10][x] = STONE
    for x in range(17, 25):
        world[10][x] = STONE
        world[9][x] = STONE
    for y in range(6, 10):
        for x in range(1, 20):
            if world[y][x] == AIR:
                world[y][x] = WATER
    return world


def run_until_still(sim: LiquidSim, max_steps: int = 4000) -> tuple[int, bool]:
    """Return (steps_taken, settled)."""
    for step in range(max_steps):
        if sim.step() == 0:
            return step + 1, True
    return max_steps, False


def surface_profile(sim: LiquidSim, width: int) -> list[float]:
    """Total liquid per column, in blocks."""
    profile = []
    for x in range(width):
        total = sum(level for (lx, _ly), level in sim.levels.items() if lx == x)
        profile.append(total / LEVEL_MAX)
    return profile


def main() -> int:
    failures = 0

    # 1. A filled pool must settle and keep its volume.
    width, height = 24, 12
    world = make_pool(width, height, water_rows=4)
    sim = LiquidSim(world, partial=True)
    start_volume = sim.total_volume()
    steps, settled = run_until_still(sim)
    end_volume = sim.total_volume()
    print(f"pool 24x12, 4 rows of water: settled={settled} after {steps} steps")
    print(f"  volume {start_volume} -> {end_volume}")
    if not settled:
        print("  FAIL: pool never stopped moving (this is the jitter bug)")
        failures += 1
    if start_volume != end_volume:
        print("  FAIL: volume changed")
        failures += 1
    profile = surface_profile(sim, width)
    interior = profile[1:-1]
    spread = max(interior) - min(interior)
    print(f"  column fill spread across the pool: {spread:.3f} blocks")
    if spread > 0.30:
        print("  FAIL: surface is not level")
        failures += 1

    # 2. The legacy whole-block rule, for comparison.
    legacy = LiquidSim(make_pool(width, height, water_rows=4), partial=False)
    legacy_steps, legacy_settled = run_until_still(legacy, max_steps=600)
    label = "settled" if legacy_settled else "STILL MOVING (jitter)"
    print(f"legacy whole-block rule: {label} after {legacy_steps} steps")

    # 3. An uneven pour must level out.
    world = [[AIR for _ in range(20)] for _ in range(14)]
    for x in range(20):
        world[13][x] = STONE
    for x in (0, 19):
        for y in range(14):
            world[y][x] = STONE
    for y in range(6, 13):
        for x in range(1, 6):
            world[y][x] = WATER
    tall = LiquidSim(world, partial=True)
    tall_volume = tall.total_volume()
    tall_steps, tall_settled = run_until_still(tall)
    print(f"uneven pour: settled={tall_settled} after {tall_steps} steps")
    if not tall_settled:
        print("  FAIL: uneven pour never settled")
        failures += 1
    if tall.total_volume() != tall_volume:
        print(f"  FAIL: volume {tall_volume} -> {tall.total_volume()}")
        failures += 1
    tall_profile = surface_profile(tall, 20)[1:-1]
    tall_spread = max(tall_profile) - min(tall_profile)
    print(f"  column fill spread after settling: {tall_spread:.3f} blocks")
    if tall_spread > 1.30:
        print("  FAIL: pour did not level out")
        failures += 1

    # 4. A single drop must come to rest rather than sliding forever.
    world = [[AIR for _ in range(11)] for _ in range(6)]
    for x in range(11):
        world[5][x] = STONE
    world[4][5] = WATER
    drop = LiquidSim(world, partial=True)
    drop_steps, drop_settled = run_until_still(drop, max_steps=500)
    print(f"single drop: settled={drop_settled} after {drop_steps} steps")
    if not drop_settled:
        print("  FAIL: a lone drop kept sliding (the exact jitter symptom)")
        failures += 1
    if drop.total_volume() != LEVEL_MAX:
        print("  FAIL: drop volume changed")
        failures += 1

    # 5. The reported bug: a pond with an uneven bed and an open shore, the
    #    shape from the screenshot. Under the old rule the surface tiles kept
    #    trading places forever; with fill levels the pond has to come to rest.
    pond = LiquidSim(make_uneven_pond(), partial=True)
    pond_volume = pond.total_volume()
    pond_steps, pond_settled = run_until_still(pond, max_steps=3000)
    print(f"uneven pond with open shore: settled={pond_settled} after {pond_steps} steps")
    if not pond_settled:
        print("  FAIL: pond kept jittering")
        failures += 1
    if pond.total_volume() != pond_volume:
        print(f"  FAIL: volume {pond_volume} -> {pond.total_volume()}")
        failures += 1
    legacy_pond = LiquidSim(make_uneven_pond(), partial=False)
    legacy_pond_steps, legacy_pond_settled = run_until_still(legacy_pond, max_steps=1500)
    state = "settled" if legacy_pond_settled else "STILL MOVING (jitter)"
    print(f"  legacy rule on the same shape: {state} after {legacy_pond_steps} steps")
    if legacy_pond_settled:
        print("  NOTE: legacy settled here too; see the lone-drop case for the jitter")

    # 6. Water meeting lava still turns to stone.
    world = [[AIR for _ in range(5)] for _ in range(5)]
    for x in range(5):
        world[4][x] = STONE
    world[2][2] = WATER
    world[3][2] = LAVA
    reaction = LiquidSim(world, partial=True)
    for _ in range(6):
        reaction.step()
    if world[2][2] != STONE or world[3][2] != STONE:
        print(f"  FAIL: water/lava did not solidify ({world[2][2]}, {world[3][2]})")
        failures += 1
    else:
        print("water + lava -> stone: ok")

    if failures:
        print(f"\n{failures} FAILURE(S)")
        return 1
    print("\nLIQUID_SIM_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
