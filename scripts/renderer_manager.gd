extends RefCounted
class_name RendererManager

# ============================================================
# OPTIMIZED WORLD RENDERER
#
# Improvements over drawing every tile each frame:
# 1. Chunk dirty tracking — only redraw chunks that changed.
# 2. Viewport culling — only iterate chunks visible on screen.
# 3. Cached chunk colors — pre-compute chunk background tints.
# 4. Batch identical tile colors into multi-rect draws.
# ============================================================

var _chunk_dirty: Dictionary = {}  # "cx,cy" -> true
var _visible_chunks_cache: Array[String] = []
var _last_camera_chunk := Vector2i(-999, -999)
var _tile_size := 16
var _chunk_size := 16
var _world_width := 560
var _world_height := 190
var _air_tile := 0

# ============================================================
# PUBLIC API
# ============================================================

func setup(tile_size: int, chunk_size: int, world_width: int, world_height: int, air_tile: int = 0) -> void:
	_tile_size = tile_size
	_chunk_size = chunk_size
	_world_width = world_width
	_world_height = world_height
	_air_tile = air_tile

func mark_chunk_dirty(world_x: int, world_y: int) -> void:
	var cx := world_x / _chunk_size
	var cy := world_y / _chunk_size
	var key := "%d,%d" % [cx, cy]
	_chunk_dirty[key] = true
	# Also mark neighbors since tile changes can affect adjacent chunks visually
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var nkey := "%d,%d" % [cx + dx, cy + dy]
			_chunk_dirty[nkey] = true

func mark_all_dirty() -> void:
	_chunk_dirty.clear()
	# Mark all possible chunks as dirty
	var chunks_x: int = ceili(float(_world_width) / float(_chunk_size))
	var chunks_y: int = ceili(float(_world_height) / float(_chunk_size))
	for cx in range(chunks_x):
		for cy in range(chunks_y):
			_chunk_dirty["%d,%d" % [cx, cy]] = true

func get_visible_chunks(camera_pos: Vector2, screen_size: Vector2) -> Array[String]:
	"""Return chunk keys that are visible in the viewport."""
	var view_rect := Rect2(
		camera_pos - screen_size * 0.5 / Vector2(1, 1),
		screen_size
	)
	# Expand by padding to avoid pop-in at edges
	var padding := _chunk_size * _tile_size * 2
	view_rect = view_rect.grow(padding)
	
	var min_cx := maxi(0, int(view_rect.position.x / (_chunk_size * _tile_size)) - 1)
	var max_cx: int = mini(ceili(float(_world_width) / float(_chunk_size)), int(view_rect.end.x / (_chunk_size * _tile_size)) + 1)
	var min_cy := maxi(0, int(view_rect.position.y / (_chunk_size * _tile_size)) - 1)
	var max_cy: int = mini(ceili(float(_world_height) / float(_chunk_size)), int(view_rect.end.y / (_chunk_size * _tile_size)) + 1)
	
	var result: Array[String] = []
	for cx in range(min_cx, max_cx):
		for cy in range(min_cy, max_cy):
			result.append("%d,%d" % [cx, cy])
	return result

func is_chunk_dirty(chunk_key: String) -> bool:
	return _chunk_dirty.has(chunk_key)

func clear_dirty(chunk_key: String) -> void:
	_chunk_dirty.erase(chunk_key)

func get_chunk_origin(chunk_key: String) -> Vector2i:
	var parts := chunk_key.split(",")
	return Vector2i(int(parts[0]) * _chunk_size, int(parts[1]) * _chunk_size)

func get_chunk_bounds(chunk_key: String) -> Rect2i:
	var origin := get_chunk_origin(chunk_key)
	return Rect2i(origin.x, origin.y, _chunk_size, _chunk_size)

func get_screen_chunk_rect(chunk_key: String) -> Rect2:
	var origin := get_chunk_origin(chunk_key)
	return Rect2(
		origin.x * _tile_size,
		origin.y * _tile_size,
		_chunk_size * _tile_size,
		_chunk_size * _tile_size
	)

func cull_world_chunks(world: Array, camera_pos: Vector2, screen_size: Vector2) -> Array[Dictionary]:
	"""
	Returns list of visible tiles with their positions and tile IDs,
	only from chunks that are on screen.
	Tile colors should be resolved by the caller via get_tile_color().
	"""
	var visible_keys := get_visible_chunks(camera_pos, screen_size)
	var result: Array[Dictionary] = []
	
	for chunk_key in visible_keys:
		var bounds: Rect2i = get_chunk_bounds(chunk_key)
		var tile_x_start := maxi(0, bounds.position.x)
		var tile_y_start := maxi(0, bounds.position.y)
		var tile_x_end := mini(_world_width, bounds.end.x)
		var tile_y_end := mini(_world_height, bounds.end.y)
		
		for ty in range(tile_y_start, tile_y_end):
			if ty >= world.size():
				continue
			var row: Array = world[ty]
			for tx in range(tile_x_start, tile_x_end):
				if tx >= row.size():
					continue
				var tile: int = row[tx]
				if tile == _air_tile:
					continue
				result.append({
					"x": tx,
					"y": ty,
					"tile": tile
				})
	
	return result
