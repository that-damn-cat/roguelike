class_name Player
extends AnimatedSprite2D

enum InputState {WAITING, POLLING, MOVING}

signal start_turn
signal move_finished
signal collided(collided_tile: Vector2i)

@export_category("Camera")
@export var camera_target: Marker2D
@export var camera: Camera2D

@export_category("Visuals")
@export_range(0.0, 1.0, 0.05) var bump_ratio: float = 0.35
var move_tween: Tween

@export_category("Controls")
@export var input_polling_time: float = 0.06
var _poll_time_remaining: float = 0.0
var _input_state := InputState.WAITING
var _move_intent := Vector2.ZERO

var game: Game
var level: Level


func _enter_tree() -> void:
	if camera == null or camera_target == null:
		push_error("Player Camera Missing")
		return

	# Focus the camera on the player before it enters the tree
	camera_target.global_position = global_position

	camera.position_smoothing_enabled = false
	camera.global_position = global_position
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = Constants.TILE_SIZE

func _ready() -> void:
	# Fetch references to important nodes
	game = NodeFinder.get_game_root()
	level = NodeFinder.get_level()

	# Get target animation speed
	speed_scale = _find_speed_mult("default", Constants.TURN_TIME_SECONDS)

func _process(delta: float) -> void:
	if not game.can_player_act():
		_move_intent = Vector2.ZERO
		return

	match _input_state:
		InputState.WAITING:
			_move_intent = _poll_direction()
			if _move_intent == Vector2.ZERO:
				return

			_input_state = InputState.POLLING
			_poll_time_remaining = input_polling_time

		InputState.POLLING:
			_poll_time_remaining -= delta
			_move_intent = _poll_direction()
			if _poll_time_remaining <= 0.0:
				_input_state = InputState.MOVING

		InputState.MOVING:
			start_turn.emit()

			if _move_intent.x > 0:
				flip_h = false
			elif _move_intent.x < 0:
				flip_h = true

			_setup_tween()

			var target_tile: Vector2i = level.get_tilemap_position(global_position) + Vector2i(_move_intent)

			if level.is_tile_walkable(target_tile):
				_tween_move(_move_intent)
				play("default")
				return

			if level.is_tile_interactable(target_tile):
				level.interact_with(target_tile, self)
			else:
				SFXService.play("bump")

			_tween_bounce(_move_intent)
			collided.emit(target_tile)



func _setup_tween() -> void:
	if move_tween:
		move_tween.kill()

	move_tween = create_tween()
	move_tween.finished.connect(_on_move_tween_finished)

func _tween_move(direction: Vector2) -> void:
	var new_position: Vector2 = global_position + (direction * Constants.TILE_SIZE)

	move_tween.set_trans(Tween.TRANS_SINE)
	move_tween.set_ease(Tween.EASE_IN_OUT)
	move_tween.set_parallel()
	move_tween.tween_property(self, "global_position", new_position, Constants.TURN_TIME_SECONDS)
	move_tween.tween_property(camera_target, "global_position", new_position, Constants.TURN_TIME_SECONDS)

func _tween_bounce(direction: Vector2) -> void:
	var start_position: Vector2 = global_position
	var bump_end: Vector2 = start_position + (direction * Constants.TILE_SIZE * bump_ratio)

	move_tween.set_trans(Tween.TRANS_ELASTIC)
	move_tween.set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self, "global_position", bump_end, 0.4 * Constants.TURN_TIME_SECONDS)

	move_tween.set_trans(Tween.TRANS_SINE)
	move_tween.set_ease(Tween.EASE_IN_OUT)
	move_tween.tween_property(self, "global_position", start_position, 0.6 * Constants.TURN_TIME_SECONDS)

func _on_move_tween_finished() -> void:
	move_tween.finished.disconnect(_on_move_tween_finished)
	move_tween.kill()
	move_finished.emit()
	stop()
	_input_state = InputState.WAITING

func _poll_direction() -> Vector2:
	var direction = _move_intent
	direction.x += Input.get_axis("left", "right")
	direction.x = sign(direction.x)

	direction.y += Input.get_axis("up", "down")
	direction.y = sign(direction.y)

	return(direction)

func _get_anim_duration(anim_name: String) -> float:
	var anim_fps = sprite_frames.get_animation_speed(anim_name)

	var total: float = 0.0
	for i in range(sprite_frames.get_frame_count(anim_name)):
		var frame_duration: float = sprite_frames.get_frame_duration(anim_name, i)
		total += frame_duration / anim_fps

	return(total)

## Returns the speed multiplier needed for the
## animation `anim_name` to last `target_duration` seconds.
func _find_speed_mult(anim_name: String, target_duration: float) -> float:
	return(_get_anim_duration(anim_name) / target_duration)
