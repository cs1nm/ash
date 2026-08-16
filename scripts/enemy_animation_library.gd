extends RefCounted
class_name EnemyAnimationLibrary


static func load_visual_variant(
	variant_type: String,
	base_type: String,
	texture_path: String,
	animation_json_path: String,
	enemy_textures: Dictionary,
	sprite_specs: Dictionary,
	ground_anchors: Dictionary,
	animation_textures: Dictionary,
	animation_specs: Dictionary,
	pack_specs: Dictionary
) -> void:
	var texture := load_png_texture(texture_path)
	if texture == null or not sprite_specs.has(base_type):
		return
	enemy_textures[variant_type] = texture
	sprite_specs[variant_type] = (sprite_specs[base_type] as Dictionary).duplicate(true)
	var base_spec: Dictionary = sprite_specs[variant_type]
	var frame_size: Vector2i = base_spec.get("frame", Vector2i(32, 32))
	var idle_row := int(base_spec.get("idle_row", 0))
	var idle_frames := int(base_spec.get("idle_frames", 1))
	ground_anchors[variant_type] = opaque_bottom_anchor(
		texture,
		frame_size.x,
		frame_size.y,
		idle_frames,
		idle_row * frame_size.y
	)
	load_pack(
		variant_type,
		animation_json_path,
		animation_textures,
		animation_specs,
		pack_specs,
		ground_anchors
	)


static func load_pack(
	enemy_type: String,
	json_path: String,
	animation_textures: Dictionary,
	animation_specs: Dictionary,
	pack_specs: Dictionary,
	ground_anchors: Dictionary
) -> void:
	if not FileAccess.file_exists(json_path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(json_path))
	if not parsed is Dictionary:
		push_warning("Invalid enemy animation metadata: %s" % json_path)
		return
	var pack: Dictionary = parsed
	var animations: Dictionary = pack.get("animations", {})
	var textures: Dictionary = {}
	var specs: Dictionary = {}
	var pack_dir := json_path.get_base_dir()
	for state_key in animations:
		var state := str(state_key)
		var metadata: Dictionary = animations[state_key]
		var filename := str(metadata.get("file", ""))
		if filename.is_empty():
			continue
		var texture := load_png_texture(pack_dir.path_join(filename))
		if texture == null:
			push_warning("Missing enemy animation texture: %s" % filename)
			continue
		textures[state] = texture
		specs[state] = metadata.duplicate(true)
	if textures.is_empty():
		return
	animation_textures[enemy_type] = textures
	animation_specs[enemy_type] = specs
	pack_specs[enemy_type] = pack.duplicate(true)
	if not textures.has("idle"):
		return
	var idle_spec: Dictionary = specs.get("idle", {})
	var idle_texture: Texture2D = textures["idle"]
	var idle_frames := maxi(1, int(idle_spec.get("frames", 1)))
	var idle_frame_width := maxi(1, int(idle_texture.get_width() / idle_frames))
	var pack_anchor: Variant = pack.get("anchor", null)
	if pack_anchor is Dictionary:
		ground_anchors[enemy_type] = float((pack_anchor as Dictionary).get("y", idle_texture.get_height()))
	else:
		ground_anchors[enemy_type] = opaque_bottom_anchor(
			idle_texture,
			idle_frame_width,
			idle_texture.get_height(),
			idle_frames
		)


static func load_png_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	return ResourceLoader.load(path) as Texture2D


static func opaque_bottom_anchor(
	texture: Texture2D,
	frame_width: int,
	frame_height: int,
	frame_count: int,
	source_y := 0
) -> float:
	var image := texture.get_image()
	if image == null or image.is_empty():
		return float(frame_height)
	var bottom := -1
	var safe_frames := maxi(1, mini(frame_count, int(image.get_width() / maxi(1, frame_width))))
	for frame_index in range(safe_frames):
		var source_x := frame_index * frame_width
		for y in range(frame_height):
			for x in range(frame_width):
				if image.get_pixel(source_x + x, source_y + y).a > 0.04:
					bottom = maxi(bottom, y)
	return float(bottom + 1) if bottom >= 0 else float(frame_height)


static func animation_spec(animation_specs: Dictionary, enemy_type: String, state: String) -> Dictionary:
	var type_specs: Dictionary = animation_specs.get(enemy_type, {})
	return type_specs.get(state, {})


static func visual_state(
	animation_textures: Dictionary,
	pack_specs: Dictionary,
	enemy_type: String,
	requested_state: String
) -> String:
	var animation_sets: Dictionary = animation_textures.get(enemy_type, {})
	if animation_sets.has(requested_state):
		return requested_state
	var pack: Dictionary = pack_specs.get(enemy_type, {})
	var state_fallbacks: Dictionary = pack.get("state_fallbacks", {})
	var fallback_state := str(state_fallbacks.get(requested_state, requested_state))
	return fallback_state if animation_sets.has(fallback_state) else requested_state


static func ground_clearance(pack_specs: Dictionary, enemy_type: String) -> float:
	var pack: Dictionary = pack_specs.get(enemy_type, {})
	return maxf(0.0, float(pack.get("ground_clearance", 0.0)))


static func animation_anchor(pack_specs: Dictionary, enemy_type: String, frame_size: Vector2) -> Vector2:
	var pack: Dictionary = pack_specs.get(enemy_type, {})
	var anchor: Variant = pack.get("anchor", null)
	if anchor is Dictionary:
		var anchor_data: Dictionary = anchor
		return Vector2(float(anchor_data.get("x", frame_size.x * 0.5)), float(anchor_data.get("y", frame_size.y)))
	return frame_size * 0.5


static func state_anchor(
	animation_specs: Dictionary,
	pack_specs: Dictionary,
	enemy_type: String,
	state: String,
	frame_size: Vector2
) -> Vector2:
	var state_spec := animation_spec(animation_specs, enemy_type, state)
	var anchor: Variant = state_spec.get("anchor", null)
	if anchor is Dictionary:
		var anchor_data: Dictionary = anchor
		return Vector2(float(anchor_data.get("x", frame_size.x * 0.5)), float(anchor_data.get("y", frame_size.y * 0.5)))
	return animation_anchor(pack_specs, enemy_type, frame_size)


static func attack_event_key(state_spec: Dictionary) -> String:
	if state_spec.has("projectile_frames"):
		return "projectile_frames"
	if state_spec.has("summon_frames"):
		return "summon_frames"
	if state_spec.has("laser_start_frames"):
		return "laser_start_frames"
	return "hit_frames"


static func duration(animation_specs: Dictionary, enemy_type: String, state: String, fallback: float) -> float:
	var state_spec := animation_spec(animation_specs, enemy_type, state)
	if state_spec.is_empty():
		return fallback
	var fps := maxf(1.0, float(state_spec.get("fps", 1.0)))
	return float(maxi(1, int(state_spec.get("frames", 1)))) / fps


static func event_time(
	animation_specs: Dictionary,
	enemy_type: String,
	state: String,
	event_key: String,
	fallback: float
) -> float:
	var state_spec := animation_spec(animation_specs, enemy_type, state)
	var event_frames: Array = state_spec.get(event_key, [])
	if event_frames.is_empty():
		return fallback
	return float(int(event_frames[0])) / maxf(1.0, float(state_spec.get("fps", 1.0)))


static func attack_recovery(
	animation_specs: Dictionary,
	enemy_type: String,
	attack_index: int
) -> float:
	var state := "attack_%d" % attack_index
	var state_spec := animation_spec(animation_specs, enemy_type, state)
	var event_key := attack_event_key(state_spec)
	var impact_time := event_time(animation_specs, enemy_type, state, event_key, 0.0)
	return maxf(0.08, duration(animation_specs, enemy_type, state, 0.24) - impact_time)
