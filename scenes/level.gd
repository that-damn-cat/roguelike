class_name Level
extends TileMapLayer

func is_tile_walkable(target_tile: Vector2i) -> bool:
	if not _is_tile_data_valid(target_tile):
		return(false)

	var walkable = _fetch_tile_data(target_tile, "walkable")

	return(walkable or walkable == null)

func is_tile_interactable(target_tile: Vector2i) -> bool:
	if not _is_tile_data_valid(target_tile):
		return(false)

	var interactable = _fetch_tile_data(target_tile, "interactable")

	if interactable == null:
		interactable = false

	return(interactable)

func get_interact_strategy(target_tile: Vector2i) -> InteractStrategy:
	if not _is_tile_data_valid(target_tile):
		return(Constants.NULL_INTERACTION)

	if not is_tile_interactable(target_tile):
		return(Constants.NULL_INTERACTION)

	var strategy = _fetch_tile_data(target_tile, "interact_strategy")

	if strategy == null or not strategy is InteractStrategy:
		push_warning("Tile at %s has invalid interact_strategy" % target_tile)
		return(Constants.NULL_INTERACTION)

	return(strategy)

func interact_with(target_tile: Vector2i, actor: Node2D) -> void:
	var interaction_strategy := get_interact_strategy(target_tile)
	interaction_strategy.interact(self, target_tile, actor)

func get_tilemap_position(global_pos: Vector2) -> Vector2i:
	var tilemap_local: Vector2 = to_local(global_pos)
	return(local_to_map(tilemap_local))

func _is_tile_data_valid(target_tile: Vector2i) -> bool:
	var tile_data: TileData = get_cell_tile_data(target_tile)

	if tile_data == null:
		push_warning("No Tile Data at %s" % target_tile)
		return(false)

	return(true)

func _fetch_tile_data(target_tile: Vector2i, data_name: String) -> Variant:
	var tile_data: TileData = get_cell_tile_data(target_tile)

	if tile_data == null:
		return(null)

	if not tile_data.has_custom_data(data_name):
		push_warning("Tile missing %s data at %s" % [data_name, target_tile])
		return(null)

	return(tile_data.get_custom_data(data_name))
