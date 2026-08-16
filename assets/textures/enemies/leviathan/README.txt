Sea Leviathan asset pack - Ashen Roots
======================================

World-edge guardian. Rises from the deep and kills anything trying to swim
past the border of the map.

Format
------
Frame size   : 256x192 (wide effects 384x192)
Anchor       : 128,132 - the water surface under the head
Waterline    : y=132
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
Idle_Submerged              8 frames   6 fps  loop=true   hit=-
Patrol_Swim                10 frames   8 fps  loop=true   hit=-
Detect                      6 frames  10 fps  loop=false  hit=-
Emerge                     10 frames  12 fps  loop=false  hit=-
Attack_1_Bite              12 frames  14 fps  loop=false  hit=[7, 8]
Attack_2_Devour            14 frames  12 fps  loop=false  hit=[9]
Attack_3_Tail_Wave         14 frames  11 fps  loop=false  hit=[8]
Attack_4_Deep_Roar         12 frames  10 fps  loop=false  hit=[7]
Attack_5_Depth_Tentacles   14 frames  11 fps  loop=false  hit=[9]
Hurt                        4 frames  14 fps  loop=false  hit=-
Enraged                     8 frames  10 fps  loop=true   hit=-
Death                      18 frames   8 fps  loop=false  hit=-

Effects
-------
Bite_Splash             8 frames  16 fps  160x128  anchor 80,96
Devour_Splash          12 frames  14 fps  384x192  anchor 192,150
Tidal_Wave             14 frames  11 fps  384x192  anchor 192,150
Sonic_Rings            10 frames  12 fps  256x192  anchor 128,88
Tentacles              14 frames  11 fps  384x192  anchor 192,150
Death_Whirlpool        14 frames  10 fps  384x192  anchor 192,150

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
