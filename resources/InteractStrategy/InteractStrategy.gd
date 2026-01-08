@abstract class_name InteractStrategy
extends Resource

@export var interact_sfx: StringName

@abstract func interact(tilemap: TileMapLayer, tile_position: Vector2i, actor: Node2D) -> void