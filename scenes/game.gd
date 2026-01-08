class_name Game
extends Node

signal turn_started
signal turn_finished

@export var turn_cooldown_seconds: float = 0.05
var _turn_time_remaining: float = 0.0

var turn_in_process: bool = false

var _player: Player
var _actors_finished: int = 0
var _total_actors: int = 1


func _ready() -> void:
	_player = NodeFinder.get_player()

	if _player == null:
		push_error("Game could not find Player")
		return

	_player.start_turn.connect(_on_turn_start)
	_player.move_finished.connect(_on_actor_finished)

func _process(delta: float) -> void:
	if not turn_in_process:
		return

	if _total_actors <= 0:
		push_warning("Game has %s actors, turn will never end" % _total_actors)

	_turn_time_remaining -= delta

	if _turn_time_remaining <= 0.0 and _actors_finished >= _total_actors:
		_end_turn()


func can_player_act() -> bool:
	return(not turn_in_process)


func _end_turn() -> void:
	_turn_time_remaining = 0.0
	turn_in_process = false
	turn_finished.emit()

func _on_turn_start() -> void:
	if turn_in_process:
		return

	turn_in_process = true
	turn_started.emit()
	_actors_finished = 0
	_total_actors = _get_actor_count()
	_turn_time_remaining = Constants.TURN_TIME_SECONDS + turn_cooldown_seconds

func _on_actor_finished() -> void:
	_actors_finished += 1

func _get_actor_count() -> int:
	return(1)