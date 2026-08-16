const fs = require("fs");
const path = require("path");
const { PNG } = require("pngjs");

const root = path.resolve(__dirname, "..");
const tileDir = path.join(root, "assets", "textures", "tiles");
const itemDir = path.join(root, "assets", "textures", "items");

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function hex(value) {
  const clean = value.replace("#", "");
  return [0, 2, 4].map((i) => parseInt(clean.slice(i, i + 2), 16));
}

function mix(a, b, t) {
  return a.map((v, i) => Math.max(0, Math.min(255, Math.round(v + (b[i] - v) * t))));
}

function shade(color, amount) {
  return mix(color, amount > 0 ? [255, 255, 255] : [0, 0, 0], Math.abs(amount));
}

function seedFor(name) {
  let h = 2166136261;
  for (let i = 0; i < name.length; i++) {
    h ^= name.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  return h >>> 0;
}

function rng(seed) {
  let s = seed >>> 0;
  return () => {
    s = Math.imul(1664525, s) + 1013904223;
    return ((s >>> 0) / 4294967296);
  };
}

function png(w, h) {
  const image = new PNG({ width: w, height: h });
  for (let i = 0; i < image.data.length; i += 4) image.data[i + 3] = 0;
  return image;
}

function set(image, x, y, color, alpha = 255) {
  if (x < 0 || y < 0 || x >= image.width || y >= image.height) return;
  const i = (image.width * y + x) << 2;
  image.data[i] = color[0];
  image.data[i + 1] = color[1];
  image.data[i + 2] = color[2];
  image.data[i + 3] = alpha;
}

function rect(image, x, y, w, h, color, alpha = 255) {
  for (let yy = y; yy < y + h; yy++) for (let xx = x; xx < x + w; xx++) set(image, xx, yy, color, alpha);
}

function line(image, x1, y1, x2, y2, color) {
  const dx = Math.abs(x2 - x1), sx = x1 < x2 ? 1 : -1;
  const dy = -Math.abs(y2 - y1), sy = y1 < y2 ? 1 : -1;
  let err = dx + dy, x = x1, y = y1;
  while (true) {
    set(image, x, y, color);
    if (x === x2 && y === y2) break;
    const e2 = 2 * err;
    if (e2 >= dy) { err += dy; x += sx; }
    if (e2 <= dx) { err += dx; y += sy; }
  }
}

function outline(image, x, y, w, h, color) {
  line(image, x, y, x + w - 1, y, color);
  line(image, x, y + h - 1, x + w - 1, y + h - 1, color);
  line(image, x, y, x, y + h - 1, color);
  line(image, x + w - 1, y, x + w - 1, y + h - 1, color);
}

function softEdgeNoise(image, base, rand) {
  for (let i = 0; i < 18; i++) {
    const side = Math.floor(rand() * 4);
    const x = side === 0 ? 0 : side === 1 ? 15 : Math.floor(rand() * 16);
    const y = side === 2 ? 0 : side === 3 ? 15 : Math.floor(rand() * 16);
    set(image, x, y, shade(base, rand() > 0.5 ? 0.16 : -0.24));
  }
  for (let i = 0; i < 10; i++) {
    const x = Math.floor(rand() * 15);
    const y = Math.floor(rand() * 15);
    set(image, x, y, shade(base, rand() > 0.45 ? 0.2 : -0.22));
  }
}

function save(image, file) {
  ensureDir(path.dirname(file));
  image.pack().pipe(fs.createWriteStream(file));
}

function makeTile(name, baseHex, kind, accentHex) {
  const image = png(16, 16);
  const base = hex(baseHex);
  const accent = accentHex ? hex(accentHex) : shade(base, 0.35);
  const rand = rng(seedFor(`tile-${name}`));
  if (kind !== "station" && kind !== "heart" && kind !== "chest" && kind !== "altar" && kind !== "plant" && kind !== "water" && kind !== "lava") {
    for (let y = 0; y < 16; y++) {
      for (let x = 0; x < 16; x++) {
        const noise = Math.floor(rand() * 39) - 20;
        const edge = x === 0 || x === 15 || y === 0 || y === 15 ? -5 : 0;
        const top = y < 3 ? 10 : 0;
        set(image, x, y, shade(base, (noise + edge + top) / 140));
      }
    }
  }
  if (kind === "water") {
    for (let y = 0; y < 16; y++) {
      for (let x = 0; x < 16; x++) {
        const wave = Math.sin((x + y * 0.7) * 0.9) * 0.12;
        set(image, x, y, shade(base, wave), 150 + y * 4);
      }
    }
    line(image, 0, 2, 9, 2, shade(accent, 0.28));
    line(image, 6, 6, 15, 6, accent);
    line(image, 1, 11, 7, 11, shade(accent, -0.08));
  } else if (kind === "lava") {
    for (let y = 0; y < 16; y++) {
      for (let x = 0; x < 16; x++) {
        const hot = Math.sin(x * 0.8 + y * 0.55) * 0.16;
        set(image, x, y, shade(base, hot), 235);
      }
    }
    line(image, 0, 3, 12, 3, accent);
    line(image, 5, 4, 15, 4, shade(accent, 0.25));
    line(image, 1, 10, 9, 10, shade(accent, -0.12));
    rect(image, 10, 12, 4, 2, shade(base, -0.28));
  } else if (kind === "grass") {
    for (let x = 0; x < 16; x++) {
      const h = 2 + Math.floor(rand() * 3);
      rect(image, x, 0, 1, h, shade(accent, rand() > 0.5 ? 0.12 : -0.08));
      if (rand() > 0.7) set(image, x, h, shade(accent, -0.18));
    }
    for (let x = 0; x < 16; x += 2) line(image, x, 3, Math.max(0, x - 1 + Math.floor(rand() * 3)), Math.max(0, 3 - Math.floor(rand() * 4)), shade(accent, 0.25));
  } else if (kind === "ore") {
    for (let i = 0; i < 6; i++) {
      const x = 2 + Math.floor(rand() * 11);
      const y = 2 + Math.floor(rand() * 11);
      line(image, x, y, Math.min(15, x + 1 + Math.floor(rand() * 4)), Math.min(15, y + Math.floor(rand() * 3) - 1), rand() > 0.35 ? accent : shade(accent, 0.35));
      if (rand() > 0.55) set(image, x, y + 1, shade(accent, 0.28));
    }
  } else if (kind === "moss") {
    for (let x = 0; x < 16; x++) {
      rect(image, x, 0, 1, 2 + Math.floor(rand() * 3), shade(accent, rand() > 0.5 ? 0.18 : -0.12));
    }
    for (let i = 0; i < 12; i++) set(image, Math.floor(rand() * 16), Math.floor(rand() * 16), shade(accent, rand() > 0.45 ? 0.25 : -0.18));
  } else if (kind === "mushroom") {
    for (let i = 0; i < 11; i++) {
      const x = 2 + Math.floor(rand() * 12);
      const y = 3 + Math.floor(rand() * 10);
      rect(image, x, y, 2, 2, rand() > 0.45 ? accent : shade(accent, 0.28));
    }
  } else if (kind === "plant") {
    rect(image, 7, 7, 2, 8, shade(base, -0.2));
    rect(image, 4, 4, 8, 5, base);
    rect(image, 5, 3, 6, 2, shade(base, 0.22));
    set(image, 6, 5, accent, 230);
    set(image, 10, 5, shade(accent, 0.24), 230);
    set(image, 8, 4, shade(accent, 0.35), 240);
  } else if (kind === "brick") {
    for (const y of [4, 10]) line(image, 0, y, 15, y, shade(base, -0.28));
    for (const x of [5, 11]) line(image, x, 0, x, 15, shade(base, -0.2));
    line(image, 2, 2, 13, 2, shade(accent, 0.05));
    set(image, 7, 7, accent, 160);
  } else if (kind === "coral") {
    for (let i = 0; i < 6; i++) line(image, 2 + Math.floor(rand() * 12), 13, 3 + Math.floor(rand() * 12), 4 + Math.floor(rand() * 7), shade(accent, rand() > 0.5 ? 0.2 : -0.1));
    for (let i = 0; i < 8; i++) set(image, Math.floor(rand() * 16), Math.floor(rand() * 16), shade(base, rand() > 0.5 ? 0.18 : -0.22));
  } else if (kind === "rootfire") {
    for (let i = 0; i < 5; i++) line(image, Math.floor(rand() * 16), 15, Math.floor(rand() * 16), Math.floor(rand() * 8), shade(base, -0.2));
    line(image, 2, 13, 14, 3, accent);
    line(image, 5, 15, 13, 7, shade(accent, 0.25));
  } else if (kind === "glass") {
    line(image, 3, 13, 13, 3, shade(accent, 0.35));
    line(image, 5, 4, 11, 14, shade(accent, -0.08));
    for (let i = 0; i < 9; i++) set(image, Math.floor(rand() * 16), Math.floor(rand() * 16), shade(accent, rand() > 0.5 ? 0.35 : -0.16), 210);
  } else if (kind === "crystal") {
    rect(image, 6, 3, 4, 11, accent);
    rect(image, 4, 7, 8, 5, shade(base, 0.12));
    line(image, 6, 3, 9, 3, shade(accent, 0.35));
    line(image, 5, 13, 10, 13, shade(base, -0.3));
  } else if (kind === "wood") {
    for (const x of [4, 8, 12]) line(image, x, 0, x + Math.floor(rand() * 3) - 1, 15, shade(base, -0.24));
    for (const y of [4, 10]) line(image, 2, y, 13, y + 1, shade(base, 0.2));
  } else if (kind === "leaves") {
    for (let i = 0; i < 22; i++) set(image, Math.floor(rand() * 16), Math.floor(rand() * 16), shade(base, rand() > 0.5 ? 0.25 : -0.18));
  } else if (kind === "ruin") {
    line(image, 0, 4, 15, 4, shade(base, -0.25));
    line(image, 0, 10, 15, 10, shade(base, -0.25));
    line(image, 5, 0, 5, 15, shade(base, -0.15));
    line(image, 11, 0, 11, 15, shade(base, -0.15));
    line(image, 2, 2, 13, 2, shade(accent, 0.08));
    line(image, 3, 13, 13, 12, shade(accent, -0.1));
  } else if (kind === "chest") {
    rect(image, 2, 6, 12, 7, shade(base, -0.2));
    rect(image, 3, 4, 10, 4, base);
    rect(image, 3, 11, 10, 2, shade(base, -0.42));
    line(image, 4, 5, 11, 5, shade(base, 0.32));
    line(image, 2, 8, 13, 8, shade(base, -0.34));
    rect(image, 7, 7, 2, 3, accent);
    set(image, 4, 10, shade(base, 0.15));
    set(image, 11, 6, shade(base, 0.22));
  } else if (kind === "altar") {
    rect(image, 3, 10, 10, 3, shade(base, -0.32));
    rect(image, 4, 8, 8, 3, shade(base, -0.12));
    rect(image, 6, 4, 4, 5, shade(base, 0.16));
    line(image, 4, 8, 11, 8, shade(base, 0.28));
    rect(image, 7, 5, 2, 6, accent);
    set(image, 6, 3, shade(accent, 0.35), 210);
    set(image, 9, 3, shade(accent, 0.2), 190);
    set(image, 2, 12, shade(base, -0.45));
    set(image, 13, 12, shade(base, -0.45));
  } else if (kind === "station") {
    rect(image, 3, 6, 10, 8, shade(base, -0.12));
    rect(image, 5, 4, 6, 3, shade(base, 0.08));
    line(image, 4, 5, 12, 5, shade(base, 0.32));
    line(image, 3, 13, 12, 13, shade(base, -0.28));
    rect(image, 5, 7, 6, 3, accent);
    set(image, 2, 8, shade(base, -0.2));
    set(image, 13, 9, shade(base, -0.25));
  } else if (kind === "heart") {
    rect(image, 5, 2, 6, 12, shade(base, -0.25));
    rect(image, 3, 5, 10, 6, shade(base, -0.16));
    line(image, 5, 2, 10, 2, accent);
    line(image, 3, 5, 3, 10, shade(accent, -0.12));
    rect(image, 7, 4, 2, 8, shade(accent, 0.25));
    line(image, 5, 6, 11, 6, shade(accent, 0.45));
    line(image, 5, 10, 11, 10, shade(accent, -0.2));
  } else {
    for (let i = 0; i < 5; i++) line(image, 1 + Math.floor(rand() * 13), 2 + Math.floor(rand() * 12), 2 + Math.floor(rand() * 13), 2 + Math.floor(rand() * 12), shade(base, -0.25));
  }
  if (kind !== "station" && kind !== "heart" && kind !== "chest" && kind !== "altar" && kind !== "plant" && kind !== "water" && kind !== "lava") softEdgeNoise(image, base, rand);
  return image;
}

function makeItem(name, baseHex) {
  const image = png(24, 24);
  const base = hex(baseHex), dark = shade(base, -0.42), light = shade(base, 0.42), wood = hex("8b5a2b");
  if (name === "sapling") {
    rect(image, 11, 10, 3, 11, wood);
    rect(image, 6, 6, 7, 6, base);
    rect(image, 12, 4, 6, 7, light);
    set(image, 8, 5, shade(light, 0.12));
    set(image, 16, 8, shade(base, -0.18));
  } else if (name === "torch") {
    rect(image, 11, 8, 3, 12, wood);
    rect(image, 9, 5, 7, 4, base);
    set(image, 11, 2, light);
    set(image, 12, 3, shade(light, 0.18));
    set(image, 10, 4, shade(base, 0.22));
  } else if (name.includes("pearl")) {
    rect(image, 8, 8, 8, 8, shade(base, -0.18));
    rect(image, 9, 7, 7, 7, light);
    set(image, 11, 9, shade(light, 0.2));
  } else if (name.includes("charm") || name.includes("ward")) {
    rect(image, 10, 4, 4, 4, light);
    line(image, 8, 7, 12, 20, dark);
    line(image, 16, 7, 12, 20, dark);
    rect(image, 8, 8, 9, 8, base);
    rect(image, 10, 10, 5, 4, light);
  } else if (name.includes("lens")) {
    rect(image, 6, 8, 12, 8, dark);
    rect(image, 8, 6, 8, 12, base);
    rect(image, 10, 8, 4, 8, light);
  } else if (name.includes("spore") || name.includes("glowcap")) {
    rect(image, 7, 10, 10, 7, base);
    rect(image, 9, 6, 6, 5, shade(base, 0.22));
    set(image, 9, 9, light);
    set(image, 14, 11, shade(base, -0.18));
    set(image, 11, 14, shade(light, 0.15));
  } else if (name.includes("ichor") || name.includes("ember")) {
    rect(image, 8, 7, 8, 10, base);
    rect(image, 10, 5, 4, 3, light);
    set(image, 9, 16, shade(base, -0.2));
    set(image, 15, 13, shade(base, 0.18));
  } else if (name === "beast_core" || name === "heartwood_core") {
    rect(image, 7, 7, 10, 10, dark);
    rect(image, 9, 5, 6, 14, base);
    rect(image, 10, 8, 4, 7, light);
    set(image, 8, 6, shade(light, 0.12));
    set(image, 15, 16, shade(base, -0.28));
  } else if (name === "ancient_chest") {
    rect(image, 5, 9, 14, 8, dark);
    rect(image, 6, 7, 12, 5, base);
    rect(image, 11, 11, 3, 4, light);
    line(image, 6, 10, 18, 10, shade(base, -0.25));
  } else if (name === "stone_altar") {
    rect(image, 5, 14, 14, 4, dark);
    rect(image, 7, 10, 10, 4, base);
    rect(image, 10, 5, 4, 8, light);
    set(image, 11, 4, shade(light, 0.2), 220);
  } else if (name.includes("pickaxe")) {
    rect(image, 4, 6, 13, 3, light); rect(image, 15, 8, 4, 3, base); rect(image, 9, 9, 4, 12, wood);
  } else if (["sword", "spear", "sickle"].some((s) => name.includes(s))) {
    rect(image, 11, 2, 3, 14, light); rect(image, 10, 4, 5, 4, base); rect(image, 7, 15, 11, 3, dark); rect(image, 10, 17, 5, 5, wood);
  } else if (name.includes("bow")) {
    line(image, 8, 4, 6, 12, base); line(image, 6, 12, 8, 20, base); line(image, 16, 5, 16, 19, light); rect(image, 9, 11, 8, 2, dark);
  } else if (["shield", "armor"].some((s) => name.includes(s))) {
    rect(image, 7, 3, 11, 12, base); rect(image, 9, 14, 7, 6, dark); rect(image, 10, 6, 5, 6, light);
    line(image, 7, 3, 17, 4, shade(base, 0.22));
    line(image, 8, 18, 16, 19, shade(base, -0.35));
  } else if (name.includes("staff") || name.includes("rod")) {
    rect(image, 11, 4, 3, 17, wood); rect(image, 8, 2, 9, 7, base); rect(image, 10, 4, 5, 3, light);
  } else if (name.includes("turret") || name.includes("cannon")) {
    rect(image, 5, 9, 12, 7, base); rect(image, 15, 10, 7, 3, light); rect(image, 8, 16, 7, 5, dark);
  } else if (["bar", "ore", "shard", "core", "glass", "ash", "root", "stone", "brick", "fiber", "crystal", "relic"].some((s) => name.includes(s))) {
    rect(image, 5, 8, 13, 9, dark); rect(image, 7, 5, 9, 7, base); rect(image, 12, 12, 7, 4, light);
  } else if (["workbench", "furnace", "anvil", "heart"].some((s) => name.includes(s))) {
    rect(image, 5, 6, 14, 12, base); rect(image, 7, 8, 10, 5, light); rect(image, 6, 18, 3, 4, dark); rect(image, 15, 18, 3, 4, dark);
  } else {
    rect(image, 6, 6, 13, 13, base); rect(image, 9, 9, 7, 7, light);
  }
  set(image, 5, 19, shade(base, -0.35), 180);
  set(image, 18, 4, shade(base, 0.2), 220);
  return image;
}

function colorForItem(item) {
  const colors = { sapling: "63a75e", diving: "69b9d0", ward: "ee6f46", abyss: "b8f4ff", drowned: "7bc8d2", sunken: "4e8a94", glowcap: "88ffd8", moss: "5c9a63", stoneblood: "6fb3a2", beast: "8fbfaf", spore: "65b47d", ichor: "b6e35f", ember: "ee6f46", badge: "d7b66a", torch: "ffb34a", copper: "c97a45", iron: "c9c6b7", ash: "9b7bd8", memory: "9b7bd8", root: "8a6638", spark: "ffcf5f", fire: "ffcf5f", ruin: "81759a", cannon: "81759a", wood: "a66a35", workbench: "a66a35", stone: "69717c", furnace: "69717c", anvil: "69717c", dirt: "7a4a2a", leaf: "4a7b50", heart: "ff7da1", pearl: "d8ffff" };
  for (const key of Object.keys(colors)) if (item.includes(key)) return colors[key];
  return "7fb6d6";
}

function main() {
  ensureDir(tileDir); ensureDir(itemDir);
  const tiles = {
    grass: ["4f9f5f", "grass", "68c870"], dirt: ["7a4a2a", "earth"], stone: ["60646f", "stone"], copper: ["665b5c", "ore", "e18a4a"],
    iron: ["626872", "ore", "e3e0cf"], ash: ["4b4a54", "ore", "a987ff"], root: ["8d6939", "wood", "b98b4b"], wood: ["9a6132", "wood"],
    leaves: ["4a7b50", "leaves"], ruin: ["746b83", "ruin", "b9a7db"], workbench: ["a0703f", "station", "d69b55"], furnace: ["3d4650", "station", "ff7d3b"],
    anvil: ["485468", "station", "b8c5d7"], turret: ["748c9c", "station", "c8eef2"], heart: ["6e3146", "heart", "ff7da1"],
    chest: ["b98746", "chest", "f2d47b"], stone_altar: ["7f7368", "altar", "b7f3dc"], stoneblood: ["56666a", "ore", "8df0d0"],
    moss: ["426f47", "moss", "7dcc72"], mushroom_soil: ["5f4d70", "mushroom", "d38acc"], glow_mushroom: ["5aa086", "plant", "88ffd8"],
    ash_brick: ["5d5562", "brick", "c0a6c8"], sunken_stone: ["3f6974", "coral", "7bc8d2"], lava_root: ["a04431", "rootfire", "ff7d3b"],
    glass_stone: ["2d6570", "glass", "b8f4ff"], abyss_crystal: ["3c7890", "crystal", "d8ffff"],
    water: ["327d9b", "water", "8ed9ee"], lava: ["e64b24", "lava", "ffd05b"],
    sapling: ["63a75e", "plant", "98dd78"],
  };
  for (const [name, spec] of Object.entries(tiles)) save(makeTile(name, spec[0], spec[1], spec[2]), path.join(tileDir, `${name}.png`));
  const items = ["dirt","stone","copper_ore","iron_ore","ash","root","wood","leaf","sapling","ruin_brick","copper_bar","iron_bar","ash_glass","root_core","spark_shard","memory_shard","world_memory","wild_ichor","night_ember","heartwood_core","ancient_chest","torch","stone_altar","stoneblood_ore","stoneblood_bar","beast_core","mushroom_spore","moss_fiber","glowcap","ash_city_brick","sunken_stone","drowned_pearl","ash_relic","ember_root","glass_shard","abyss_crystal","abyss_lens","diving_charm","ember_ward","stoneblood_pickaxe","stonebreaker_blade","workbench","furnace","anvil","settlement_heart","wooden_pickaxe","copper_pickaxe","iron_pickaxe","ash_pickaxe","builder_hammer","wooden_sword","copper_sword","iron_spear","wooden_shield","copper_shield","wooden_bow","copper_bow","fire_arrows","hand_cannon","spark_staff","root_spirit_rod","acid_flasks","small_turret","ash_sickle","copper_armor","iron_armor","ash_charm","root_ring","wild_badge"];
  for (const item of items) save(makeItem(item, colorForItem(item)), path.join(itemDir, `${item}.png`));
}

main();
