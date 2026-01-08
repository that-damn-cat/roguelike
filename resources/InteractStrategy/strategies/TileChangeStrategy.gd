class_name TileChangeStrategy
extends InteractStrategy

@export var tilemap_source_id: int = 0
@export var new_tile_coords: Vector2i = Vector2i(0, 0)

func interact(tilemap: TileMapLayer, tile_position: Vector2i, _actor: Node2D) -> void:
	tilemap.set_cell(tile_position, tilemap_source_id, new_tile_coords)

	if interact_sfx == &"":
		return

	SFXService.play(interact_sfx)
