extends Node

var _player: Player
var _game: Game
var _level: Level


func get_player() -> Player:
	if is_instance_valid(_player):
		return(_player)

	_player = get_tree().get_first_node_in_group("player")

	return(_player)

func get_game_root() -> Game:
	if is_instance_valid(_game):
		return(_game)

	_game = get_tree().get_first_node_in_group("game")

	return(_game)

func get_level() -> Level:
	if is_instance_valid(_level):
		return(_level)

	_level = get_tree().get_first_node_in_group("level")

	return(_level)