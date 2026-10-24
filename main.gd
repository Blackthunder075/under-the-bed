extends Node2D

@onready var player = $Player
@onready var enemy = $Enemy
@onready var energy_bar: ProgressBar = $HUD/VBoxContainer/EnergyBar
@onready var timer_label: Label = $HUD/VBoxContainer/TimerLabel
@onready var status_label: Label = $HUD/VBoxContainer/StatusLabel

@export var night_length: float = 90.0

var time_left: float = 0.0
var game_ended: bool = false


func _ready() -> void:
	time_left = night_length
	enemy.set("player", player)
	player.set("enemy", enemy)
	energy_bar.max_value = float(player.get("max_energy"))
	status_label.text = "Protect the child until dawn."


func _process(delta: float) -> void:
	if game_ended:
		return

	time_left -= delta
	if time_left < 0.0:
		time_left = 0.0

	energy_bar.value = float(player.get("energy"))
	timer_label.text = "Dawn in: %02d" % int(ceil(time_left))

	if time_left <= 0.0:
		end_game(true)


func end_game(survived: bool) -> void:
	if game_ended:
		return
	game_ended = true
	player.set_physics_process(false)
	enemy.set_physics_process(false)
	

	if not survived:
		status_label.text = "Oh no.The monster got to the child."
		return
		

	status_label.text = "Morning light reaches the room..."
	await get_tree().create_timer(2.5).timeout
	status_label.text = "The child wakes and looks for Patch."
	await get_tree().create_timer(2.5).timeout
	status_label.text = "They find Patch beneath the bed and hold him close."
	await get_tree().create_timer(3.0).timeout
	status_label.text = "Patch kept the child safe. They will never know."
