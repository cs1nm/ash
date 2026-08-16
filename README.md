# Ashen Roots Prototype

Open this folder in Godot 4.7 or newer and run `Main.tscn`.

## Controls

- `A` / `D` or arrow keys: move.
- `Space` / `W`: jump.
- Hold `Space` / `W` while in water or lava: swim upward.
- `1`-`5`: select hotbar slot.
- `Tab` / `I`: open or close inventory.
- Mouse wheel: zoom camera in/out slightly.
- Left mouse button: mine target block.
- Right mouse button: place the selected mined block.
- `Z` / `X`: select crafting recipe while inventory is open.
- `C`: craft the selected recipe while inventory is open.
- `E`: equip/use the selected hotbar item while inventory is open.
- `F`: attack with the equipped weapon.
- Right mouse button on a stone altar in caves: awaken Stone Beast.
- Drag an inventory stack onto a hotbar slot to assign that item to the selected bottom hotbar.
- `R`: generate a new random world.
- `F5`: save the world.
- `F9`: load the saved world.
- `F1` or backtick: open the debug console. Use `perception on` to inspect AI vision, noise, memory targets, and states.

## Interface

- Normal gameplay HUD: player HP, current tool, mini-map, and 5 bottom square hotbar slots.
- Inventory screen (`Tab` / `I`): compact slot grid on the left, equipment and icon-based crafting on the right.
- Left-drag an inventory stack to move it; right-drag a stack to split off half.
- Release a dragged stack outside the inventory/crafting UI to throw it into the world as animated loot.
- Equipment slots show weapon, armor, and accessory separately.
- Crafting recipes are shown as compact icons with ready/locked borders and material tooltips.
- Bottom panel: hotbar. The golden border shows the active slot.
- Top-right panel: mini-map.

## What Works Now

- Seed-based 2D world generation.
- Larger seed-based world generation.
- Hills, larger cave networks, trees, roots, ash pockets, ores, underground rooms, shrines, ruins, and loot chests.
- The world is split into 7-9 wide surface biome bands (frost wasteland, marsh, forest, ash desert, ash ruins) with noisy weaving borders; the spawn band is always forest and every biome type appears in each world.
- Neighbouring bands fade into each other across a 24-column zone: the two biomes trade ragged clustered pockets, and the seam itself meanders sideways as it descends, so a border is a chaotic interlocking coastline rather than a straight vertical cut. Biome tinting follows the same blend, so the palette can no longer repaint a hard seam over blended ground, and the tinted crust ends at a wobbling depth instead of a flat line.
- The world does not end in an invisible wall. The last 120 columns on each side bend down into a dead sea roughly 38 tiles deep with a ragged shoreline; layered ash haze hides where the map data stops, and an undertow that strengthens towards the rim pushes the player back inland instead of stopping them dead.
- The dead sea is hunted. Wading at the beach is safe, but the further out you swim the more it spawns: brine lurkers are fast, fragile swarmers, and past the halfway mark drowned leviathans join them, slow and heavy hitters capped at two at a time. They cannot leave the water, so draining a pool beaches and kills them. Their drops, brine scales and leviathan teeth, craft brine mail and the leviathan fang. Both have their own 4x3 pixel art sheets (idle, swim, strike) drawn pixel by pixel by `tools/generate_sea_creature_sprites.py`: a spine curve plus a thickness profile, shaded in flat bands over a 10-13 colour palette with a hard outline, so each frame is genuinely redrawn and the body undulates as it swims.
- Climate opposites stay apart: the ash desert and the frost wasteland are never placed in touching bands, so a world always has a temperate region between the two extremes.
- Surface biomes own their whole topsoil layer, not just the top block: ash desert rests on deep ash sand, frost wasteland on frozen dirt, marsh on mud (with surface ponds and moss rims), ash ruins on rubble. Ash sand can be sifted by hand back into ash.
- Dead bleached trunks dot the ash desert; biome palettes tint the upper crust when digging.
- Biomes now shape the world: forest, ordinary caves, mushroom halls, ash cities, sunken ruins, lava roots, and the glass abyss.
- Each biome has its own blocks, enemy picks, material drops, chest loot, backdrop color/silhouettes, entry sound motif, rare item, and small mining-triggered mini-event.
- Sunken ruins contain water pools; lava-root chambers contain lava lakes.
- Liquids fill blocks partially, in eighths, instead of being all-or-nothing. Pools level out into a flat surface, shallow water is drawn and treated as shallow, and a settled pool goes completely still instead of jittering as tiles trade places. Sideways flow moves half the height difference, so neighbouring tiles converge instead of passing the same drop back and forth. Lava uses a steeper threshold, so it stays lumpy and viscous.
- Water slows movement and drains air while the player's head is submerged. At zero air, drowning damage begins. Ankle-deep water no longer counts as swimming, since only the filled part of a tile is treated as liquid.
- Lava heavily slows movement, deals repeated fire damage, and applies burning.
- The HUD displays remaining air while swimming.
- Diving Charm grants underwater breathing. Ember Ward greatly reduces lava damage.
- Ancient chests open as a container on the right side in place of the mini-map while nearby.
- Copper, iron, ash, ruins, and stations have brighter pixel markings so they are easier to spot.
- Project-local pixel-art PNG textures for world tiles and item icons.
- Larger organic trees with branches and clustered crowns, including rare old trees with wider trunks and multi-direction branches.
- Humanoid placeholder player sprite drawn in pixel-art style with idle, walking, jumping, and falling animation poses.
- Basic player movement and collision.
- Hotbar inventory with placeable items and starter tools.
- Mining and placing blocks within a short range.
- Tree felling: mine the bottom trunk block to break the connected tree and collect its wood/leaves.
- Tool strength, mining speed, and block hardness.
- Crafting stations: workbench, furnace, and anvil.
- Ore smelting into copper and iron bars.
- Weapon, armor, accessory, tool, and class starter recipes.
- Rare materials from roots, ash, and ruin blocks.
- Day/night cycle: day lasts 25 minutes, night lasts 7 minutes 30 seconds.
- First combat loop with surface, cave, and night enemies.
- Damage types: physical, fire, poison, and arcane.
- Status effects: poison, burning, and slow. Active effects are shown near HP.
- New early enemies by zone: cave worm, bat, ash phantom, mushroom beetle, root crawler, and ruin drone.
- Biome enemies include mosslings, spore bats, ash sentinels, drowned guards, ember rootlings, and glass wraiths.
- Class weapon attacks: melee swings, spear reach, bows, hand cannon, spark staff, root spirit, acid flask, and engineer turret fire.
- Animated world loot for mined blocks, felled trees, enemy drops, and rare materials. Items bounce, bob, magnetize toward the player, and show stack counts.
- Loot pickup feed shows recent pickups such as `+ Wood x12` on the lower-right HUD.
- Floating damage numbers and small hit particles.
- Visible attack animations: sword/sickle slash, spear thrust, bow draw, staff flare, cannon recoil, flask throw, and turret muzzle flash.
- Boss health bar appears at the top of the screen while `Heartwood Core` or `Stone Beast` is alive.
- Stone Beast can awaken after enough stone is mined or by activating a stone altar in a cave.
- Defeating Stone Beast unlocks Stoneblood ore veins, Stoneblood recipes, and opens the first path toward the mushroom biome.
- Simple generated sounds for hits, mining, pickups, player damage, shots, and boss arrival.
- Spawn balance now considers day/night, cave depth, and nearby ruins.
- Enemies use perception states instead of knowing the player position automatically: light-sensitive line of sight, per-creature hearing, noise investigation, last-known-position search, return-to-home behavior, and nearby ally alerts.
- Footsteps, jumping and landing, mining, melee swings, shots, turret fire, and explosions create noise with different radii.
- Enemy drops for early progression, plus a first mini-boss after enough enemies are defeated.
- Player health and fall damage.
- Save/load for the current world, inventory, health, and position.
- Chunked visible-world drawing.
- Simple depth/player lighting.
- Mini-map.
- HUD showing seed, target tile, selected item, health, hotbar, and class foundation.
- Class definitions in `data/classes.json`.

## Next Good Step

Turn biome materials into a stronger progression ladder: armor sets, class weapons, one mini-boss per biome, and real looping music tracks.

## Art Pipeline

- Tile textures live in `assets/textures/tiles`.
- Item icons live in `assets/textures/items`.
- Regenerate the current placeholder pixel-art pack with:

```bash
node tools/generate_pixel_assets.js
```

These are original generated placeholders meant to be replaced or polished over time, but the game now uses real PNG assets instead of debug rectangles. The current generator avoids hard tile outlines and adds organic noise, cracks, grass variation, ore veins, rough station details, transparent station silhouettes, chest/altar silhouettes, moss, fungal caps, ash brickwork, sunken stone markings, lava-root veins, glass shards, crystals, and exposed-edge chips so the world does not read as a flat square grid. Physics is still grid-based for now; the non-square look is visual.

## Early Progression Test Path

1. Mine wood, dirt, stone, and copper ore.
2. Craft a workbench by selecting the recipe with `Z`/`X`, then pressing `C`.
3. Put the workbench from the hotbar with right mouse button.
4. Stand near it and craft a furnace.
5. Place the furnace, stand near it, and smelt copper bars.
6. Craft an anvil from copper bars and stone.
7. Place the anvil, then craft copper tools, armor, and class weapons.
8. Explore caves and ruins for stone altars, chests, and new enemy drops.
9. Mine about 140 stone blocks or activate a stone altar to awaken Stone Beast.
10. Defeat Stone Beast, then mine Stoneblood ore and craft the Stoneblood pickaxe or Stonebreaker Blade.
11. Push deeper to find mushroom halls, ash cities, sunken ruins, lava roots, and the glass abyss. Watch the HUD biome name and listen for the entry sound cue.
12. Use Drowned Pearls and Sunken Stone to craft the Diving Charm.
13. Use Ember Roots, Night Embers, and Stoneblood Bars to craft the Ember Ward before exploring lava lakes.
