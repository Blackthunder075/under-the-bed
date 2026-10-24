




extends Node2D

@export var hide_time: float = 5.0

var player_hidden: bool = false
var hide_timer: float = 0.0
var discovered: bool = false
var hiding_player: Node2D = null


func _ready() -> void:
	add_to_group("hide_spots")


func start_hiding(player: Node2D) -> bool:
	if discovered or player_hidden:
		return false

	player_hidden = true
	hide_timer = 0.0
	hiding_player = player
	print("Hiding started at: ", name)
	return true


func stop_hiding() -> void:
	player_hidden = false
	hide_timer = 0.0
	hiding_player = null


func _process(delta: float) -> void:
	if not player_hidden:
		return

	hide_timer += delta

	if hide_timer >= hide_time:
		player_hidden = false
		discovered = true
		hide_timer = 0.0

		if is_instance_valid(hiding_player):
			if hiding_player.has_method("leave_hiding"):
				hiding_player.call("leave_hiding")

		hiding_player = null
		print("The monster found Patch at ", name, "! Find another hiding spot.")
