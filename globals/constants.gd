extends Node

# Graphics
const TILE_SIZE: int = 12
const TILE_CENTER_OFFSET := Vector2(6.0, 6.0)
const BG_COLOR := Color("#101010")

# Audio
const SFX_LIBRARY: SfxLib = preload("res://resources/sfx_library.tres") as SfxLib
const MAX_PLAYERS_PER_SFX: int = 4
const SFX_BUS: StringName = &"SFX"
const BGM_BUS: StringName = &"Music"

# Game Config
const TURN_TIME_SECONDS: float = 0.25

# Behaviors
const NULL_INTERACTION: InteractStrategy = preload("res://resources/InteractStrategy/implementations/null_interaction.tres")

func _enter_tree() -> void:
	RenderingServer.set_default_clear_color(BG_COLOR)
