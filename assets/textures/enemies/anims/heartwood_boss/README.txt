Heartwood Boss animation pack - Ashen Roots
===========================================

A massive ancient walking tree: gnarled trunk, root legs, heavy branch arms,
and a glowing amber-green heart in the chest. Phase two cracks the bark and
the heart flares.

Format
------
Frame size   : 128x144 (wide effects 224x144, same anchor)
Anchor       : 64,137 - the ground between the roots
Body height  : about 112 px
Sheets       : horizontal, frames left to right
Alpha        : binary only, 0 or 255
Palette      : exactly the 10 colours from the brief
Facing       : right

Animations
----------
spawn            14 frames  10 fps  loop=false  hit=-        proj=-
idle             10 frames   6 fps  loop=true   hit=-        proj=-
move             12 frames   8 fps  loop=true   hit=-        proj=-
phase_2          14 frames  10 fps  loop=false  hit=-        proj=-
hurt              5 frames  12 fps  loop=false  hit=-        proj=-
stunned           6 frames   6 fps  loop=true   hit=-        proj=-
attack_1         12 frames  11 fps  loop=false  hit=[7, 8]   proj=-
attack_2         14 frames  11 fps  loop=false  hit=[8]      proj=-
attack_3         12 frames  12 fps  loop=false  hit=-        proj=[7]
attack_4         14 frames  10 fps  loop=false  hit=-        proj=-
attack_5         15 frames  11 fps  loop=false  hit=-        proj=[9]
attack_6         16 frames  10 fps  loop=false  hit=-        proj=-
death            20 frames   8 fps  loop=false  hit=-        proj=-

Effects
-------
root_vfx         10 frames  11 fps
seed_projectile   6 frames  12 fps
seed_impact       8 frames  14 fps
flower_spawn      8 frames  11 fps
poison_cloud     12 frames  10 fps
death_vfx        14 frames   8 fps

Notes
-----
Frame numbers in the brief were 1-based; the JSON stores them 0-based because
that is what the engine's animation pack loader expects.

Regenerate
----------
    python3 tools/heartwood/make_base.py       # concept -> base sprite
    python3 tools/heartwood/build_heartwood.py # base sprite -> full pack
