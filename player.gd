extends CharacterBody2D

@export var toy_texture: Texture2D
@export var monster_texture: Texture2D


@export var toy_speed: float = 155.0
@export var monster_speed: float = 250.0
@export var max_energy: float = 100.0
@export var transform_cost: float = 20.0
@export var energy_drain_per_second: float = 10.0
@export var energy_recharge_per_second: float = 20.0

var energy: float = 100.0
var is_monster: bool = false
var is_hidden: bool = false
var attack_cooldown: float = 0.0
var enemy: Node2D = null


func _ready() -> void:
	energy = max_energy
	$Sprite2D.texture = toy_texture
	


func _physics_process(delta: float) -> void:
	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	if is_hidden:
		velocity = Vector2.ZERO
		if Input.is_action_just_pressed("interact"):
			leave_hiding()
		update_energy(delta)
		return

	if Input.is_action_just_pressed("transform"):
		toggle_form()

	if Input.is_action_just_pressed("interact"):
		try_hide()

	if Input.is_action_just_pressed("attack") and is_monster:
		attack_enemy()

	var direction := Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)

	var speed := monster_speed if is_monster else toy_speed
	velocity = direction * speed
	move_and_slide()

	update_energy(delta)


func toggle_form() -> void:
	if is_monster:
		is_monster = false
		$Sprite2D.texture = toy_texture
		return

	if energy < transform_cost:
		return

	energy -= transform_cost
	is_monster = true
	$Sprite2D.texture = monster_texture


func update_energy(delta: float) -> void:
	if is_monster:
		energy -= energy_drain_per_second * delta
		if energy <= 0.0:
			energy = 0.0
			is_monster = false
			$Sprite2D.texture = toy_texture
	elif is_hidden:
		energy = min(max_energy, energy + energy_recharge_per_second * delta)

func try_hide() -> void:
	if is_monster:
		return

	var spots = get_tree().get_nodes_in_group("hide_spots")

	for spot in spots:
		if not is_instance_valid(spot):
			continue

		if global_position.distance_to(spot.global_position) > 64.0:
			continue

		if not spot.has_method("start_hiding"):
			continue

		if not spot.call("start_hiding", self):
			print("This spot has already been discovered: ", spot.name)
			continue

		is_hidden = true
		velocity = Vector2.ZERO
		$Sprite2D.visible = false
		set_meta("current_hide_spot", spot)

		print("Patch is hiding at: ", spot.name)
		return

	print("No usable hiding spot nearby!")



func leave_hiding() -> void:
	if has_meta("current_hide_spot"):
		var spot = get_meta("current_hide_spot")

		if is_instance_valid(spot) and spot.has_method("stop_hiding"):
			spot.call("stop_hiding")

		remove_meta("current_hide_spot")

	is_hidden = false
	$Sprite2D.visible = true
	print("Patch left the hiding spot!")

func attack_enemy() -> void:
	if attack_cooldown > 0.0:
		return

	attack_cooldown = 0.55

	if enemy == null or not is_instance_valid(enemy):
		print("No enemy in attack range!")
		return

	if global_position.distance_to(enemy.global_position) > 100.0:
		print("Enemy is too far away!")
		return

	if enemy.has_method("stun"):
		enemy.call("stun", 5.5)
		print("Monster stunned!")

	attack_cooldown = 0.55

	if enemy == null or not is_instance_valid(enemy):
		print("No enemy in attack range!")
		return

	if global_position.distance_to(enemy.global_position) > 65.0:
		print("Enemy is too far away!")
		return

	if enemy.has_method("stun"):
		enemy.call("stun", 5.5)
		print("Monster stunned!")

	attack_cooldown = 0.55

	if enemy != null and is_instance_valid(enemy):
		if global_position.distance_to(enemy.global_position) < 48.0:
			if enemy.has_method("stun"):
				enemy.call("stun", 5.5)

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		enemy = body


func _on_attack_range_body_exited(body: Node2D) -> void:
	if body == enemy:
		enemy = null
