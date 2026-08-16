#!/usr/bin/env python3
"""Offline check for the surface biome band layout in scripts/main.gd.

This is a faithful port of `_build_surface_biome_map` / `_assign_band_biomes`
so the layout guarantees can be verified over tens of thousands of seeds
without launching Godot. It checks that every world:

* contains all five biome types,
* pins the spawn band to the forest,
* never repeats the same biome in two touching bands,
* never puts the ash desert next to the frost wasteland,
* keeps every band width inside the min/max range.

It also cross-checks `_rebuild_border_metadata` against a brute-force nearest
seam search on synthetic biome maps.

Usage: python3 tools/simulate_biome_bands.py [seed_count]
"""

from __future__ import annotations

import random
import sys

WORLD_WIDTH = 1280
SURFACE_BAND_MIN_WIDTH = 120
SURFACE_BAND_MAX_WIDTH = 210
SURFACE_BAND_LAYOUT_ATTEMPTS = 4000
SURFACE_BAND_BIOMES = [
    "frost_wasteland",
    "marsh",
    "ash_desert",
    "ash_ruins",
    "forest",
]
SURFACE_BAND_FALLBACK_ORDER = [
    "frost_wasteland",
    "marsh",
    "ash_desert",
    "ash_ruins",
]


class Rng:
    """PCG32, the generator behind Godot's RandomNumberGenerator."""

    MULT = 6364136223846793005
    INC = 1442695040888963407
    MASK = (1 << 64) - 1

    def __init__(self, seed: int) -> None:
        self.state = 0
        self.inc = self.INC
        self._seed(seed)

    def _seed(self, seed: int) -> None:
        self.state = 0
        self._next()
        self.state = (self.state + (seed & self.MASK)) & self.MASK
        self._next()

    def _next(self) -> int:
        old = self.state
        self.state = (old * self.MULT + (self.inc | 1)) & self.MASK
        xorshifted = (((old >> 18) ^ old) >> 27) & 0xFFFFFFFF
        rot = (old >> 59) & 31
        return ((xorshifted >> rot) | (xorshifted << ((-rot) & 31))) & 0xFFFFFFFF

    def randi_range(self, from_value: int, to_value: int) -> int:
        span = to_value - from_value + 1
        return from_value + self._bounded(span)

    def _bounded(self, bound: int) -> int:
        # Godot uses the bounded-rand rejection loop from PCG.
        threshold = (-bound) % bound
        while True:
            value = self._next()
            if value >= threshold:
                return value % bound


def biomes_conflict(first: str, second: str) -> bool:
    if first == "ash_desert" and second == "frost_wasteland":
        return True
    return first == "frost_wasteland" and second == "ash_desert"


def band_assignment_is_valid(band_biomes: list[str], spawn_band: int) -> bool:
    for i, current in enumerate(band_biomes):
        if i == spawn_band and current != "forest":
            return False
        if i == 0:
            continue
        previous = band_biomes[i - 1]
        if previous == current:
            return False
        if biomes_conflict(previous, current):
            return False
    return True


def fallback_band_biomes(band_count: int, spawn_band: int) -> list[str]:
    band_biomes: list[str] = []
    cycle_index = 0
    for i in range(band_count):
        if i == spawn_band:
            band_biomes.append("forest")
            continue
        order = SURFACE_BAND_FALLBACK_ORDER
        band_biomes.append(order[cycle_index % len(order)])
        cycle_index += 1
    return band_biomes


def assign_band_biomes(band_count: int, spawn_band: int, rng: Rng) -> tuple[list[str], bool]:
    for _attempt in range(SURFACE_BAND_LAYOUT_ATTEMPTS):
        pool = [biome for biome in SURFACE_BAND_BIOMES if biome != "forest"]
        while len(pool) < band_count - 1:
            pool.append(SURFACE_BAND_BIOMES[rng.randi_range(0, len(SURFACE_BAND_BIOMES) - 1)])
        for i in range(len(pool) - 1, 0, -1):
            swap_index = rng.randi_range(0, i)
            pool[i], pool[swap_index] = pool[swap_index], pool[i]
        band_biomes: list[str] = []
        pool_index = 0
        for i in range(band_count):
            if i == spawn_band:
                band_biomes.append("forest")
                continue
            band_biomes.append(pool[pool_index])
            pool_index += 1
        if band_assignment_is_valid(band_biomes, spawn_band):
            return band_biomes, False
    return fallback_band_biomes(band_count, spawn_band), True


def build_band_layout(seed: int) -> tuple[list[str], list[int], int, bool]:
    rng = Rng(seed + 9127)
    band_count = rng.randi_range(7, 9)
    average_width = WORLD_WIDTH // band_count
    widths: list[int] = []
    width_sum = 0
    for _i in range(band_count):
        width = min(
            max(
                rng.randi_range(average_width - 40, average_width + 40),
                SURFACE_BAND_MIN_WIDTH,
            ),
            SURFACE_BAND_MAX_WIDTH,
        )
        widths.append(width)
        width_sum += width
    adjust_index = 0
    guard = 0
    while width_sum != WORLD_WIDTH:
        guard += 1
        if guard > 1_000_000:
            raise RuntimeError(f"width adjustment did not converge for seed {seed}")
        if width_sum < WORLD_WIDTH and widths[adjust_index] < SURFACE_BAND_MAX_WIDTH:
            widths[adjust_index] += 1
            width_sum += 1
        elif width_sum > WORLD_WIDTH and widths[adjust_index] > SURFACE_BAND_MIN_WIDTH:
            widths[adjust_index] -= 1
            width_sum -= 1
        adjust_index = (adjust_index + 1) % band_count
    band_ends: list[int] = []
    covered = 0
    for width in widths:
        covered += width
        band_ends.append(covered)
    spawn_x = WORLD_WIDTH // 2
    spawn_band = len(band_ends) - 1
    for i, end in enumerate(band_ends):
        start = 0 if i == 0 else band_ends[i - 1]
        if start <= spawn_x < end:
            spawn_band = i
            break
    band_biomes, used_fallback = assign_band_biomes(len(band_ends), spawn_band, rng)
    return band_biomes, widths, spawn_band, used_fallback


SURFACE_BORDER_BLEND = 24


def rebuild_border_metadata(surface_biomes: list[str]) -> tuple[list[int], list[str]]:
    """Port of `_rebuild_border_metadata`."""
    width = len(surface_biomes)
    distances = [width] * width
    neighbors = [""] * width
    if width == 0:
        return distances, neighbors
    seams = [x for x in range(1, width) if surface_biomes[x] != surface_biomes[x - 1]]
    for seam in seams:
        left_biome = surface_biomes[seam - 1]
        right_biome = surface_biomes[seam]
        for offset in range(SURFACE_BORDER_BLEND):
            left_x = seam - 1 - offset
            if left_x >= 0 and offset < distances[left_x]:
                distances[left_x] = offset
                neighbors[left_x] = right_biome
            right_x = seam + offset
            if right_x < width and offset < distances[right_x]:
                distances[right_x] = offset
                neighbors[right_x] = left_biome
    return distances, neighbors


def check_border_metadata(rounds: int = 400) -> None:
    """Brute-force cross-check of the seam distance/neighbour arrays."""
    rng = random.Random(20240729)
    for _round in range(rounds):
        width = rng.randint(2, 160)
        biomes = [rng.choice(SURFACE_BAND_BIOMES) for _ in range(width)]
        distances, neighbors = rebuild_border_metadata(biomes)
        seams = [x for x in range(1, width) if biomes[x] != biomes[x - 1]]
        for x in range(width):
            best_distance = width
            best_neighbor = ""
            for seam in seams:
                # Columns left of the seam are at seam - 1 - offset, columns
                # right of it at seam + offset.
                distance = seam - 1 - x if x < seam else x - seam
                other = biomes[seam] if x < seam else biomes[seam - 1]
                if distance < best_distance:
                    best_distance = distance
                    best_neighbor = other
            if best_distance >= SURFACE_BORDER_BLEND:
                assert distances[x] >= SURFACE_BORDER_BLEND, (
                    f"column {x} was marked as a border column by mistake"
                )
                continue
            assert distances[x] == best_distance, (
                f"column {x}: distance {distances[x]} != {best_distance}"
            )
            assert neighbors[x] == best_neighbor, (
                f"column {x}: neighbour {neighbors[x]!r} != {best_neighbor!r}"
            )
            assert neighbors[x] != biomes[x], f"column {x}: neighbour equals own biome"


def main() -> int:
    seed_count = int(sys.argv[1]) if len(sys.argv) > 1 else 50_000
    fallback_count = 0
    band_count_histogram: dict[int, int] = {}
    biome_totals: dict[str, int] = {biome: 0 for biome in SURFACE_BAND_BIOMES}
    for seed in range(seed_count):
        band_biomes, widths, spawn_band, used_fallback = build_band_layout(seed)
        if used_fallback:
            fallback_count += 1
        band_count_histogram[len(band_biomes)] = band_count_histogram.get(len(band_biomes), 0) + 1
        for biome in band_biomes:
            biome_totals[biome] += 1
        assert sum(widths) == WORLD_WIDTH, f"seed {seed}: bands do not cover the world"
        for width in widths:
            assert SURFACE_BAND_MIN_WIDTH <= width <= SURFACE_BAND_MAX_WIDTH, (
                f"seed {seed}: band width {width} is out of range"
            )
        assert band_biomes[spawn_band] == "forest", f"seed {seed}: spawn band is not forest"
        missing = set(SURFACE_BAND_BIOMES) - set(band_biomes)
        assert not missing, f"seed {seed}: missing biomes {sorted(missing)}"
        for i in range(1, len(band_biomes)):
            previous = band_biomes[i - 1]
            current = band_biomes[i]
            assert previous != current, f"seed {seed}: repeated band {current} at {i}"
            assert not biomes_conflict(previous, current), (
                f"seed {seed}: {previous} touches {current} at band {i}"
            )
    check_border_metadata()
    print(f"seeds checked: {seed_count}")
    print(f"band count histogram: {dict(sorted(band_count_histogram.items()))}")
    print(f"biome band totals: {dict(sorted(biome_totals.items()))}")
    print(f"fallback layouts used: {fallback_count}")
    print("BIOME_BAND_LAYOUT_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
