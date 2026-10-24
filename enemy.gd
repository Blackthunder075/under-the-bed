

extends CharacterBody2D

@export var move_speed: float = 100.0
@export var detection_radius: float = 810.0
@export var catch_distance: float = 20.0
@export var stop_distance: float = 10.0

var player: CharacterBody2D = null
var start_position: Vector2
var stunned_time: float = 0.0


func _ready() -> void:
	start_position = global_position


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		velocity = Vector2.ZERO
		return

	if stunned_time > 0.0:
		stunned_time -= delta
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if bool(player.get("is_hidden")):
		move_toward_start()
		return

	var distance_to_player := global_position.distance_to(player.global_position)

	if distance_to_player > detection_radius:
		move_toward_start()
		return

	if distance_to_player <= catch_distance:
		velocity = Vector2.ZERO
		move_and_slide()

		var main := get_parent()
		if main.has_method("end_game"):
			main.call("end_game", false)
		return

	if distance_to_player <= stop_distance:
		velocity = Vector2.ZERO
	else:
		var direction := global_position.direction_to(player.global_position)
		velocity = direction * move_speed

	move_and_slide()


func move_toward_start() -> void:
	var distance := global_position.distance_to(start_position)

	if distance > 1.0:
		velocity = global_position.direction_to(start_position) * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func stun(seconds: float) -> void:
	stunned_time = seconds


func _on_attack_range_body_entered(body: Node2D) -> void:
	pass


func _on_attack_range_body_exited(body: Node2D) -> void:
	pass
