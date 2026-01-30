extends CharacterBody3D

@export var speed := 6.0
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var knockback_velocity := Vector3.ZERO
@export var knockback_friction := 5.0
@export var fall_gravity := 30.0

var player: Node3D

var type = game_state.types_of_masks.onca

@onready var max_health = 100
@onready var health = 100

func _ready():
	# Get player node
	player = get_tree().get_first_node_in_group("player")

	# Wait for navigation to be ready
	await get_tree().physics_frame

	$MeshInstance3D2.set_surface_override_material(0, $MeshInstance3D2.get_surface_override_material(0).duplicate())
	$MeshInstance3D2.get_surface_override_material(0).albedo_color = game_state.get_mask_color(type)
	$MeshInstance3D2.get_surface_override_material(0).emission = game_state.get_mask_color(type)

func _physics_process(delta):
	if player:
		nav_agent.target_position = player.global_position

	if nav_agent.is_navigation_finished():
		return

	var next_point = nav_agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()

	# Apply gravity
	if not is_on_floor():
		velocity.y -= fall_gravity * delta

	velocity.x = direction.x * speed + knockback_velocity.x
	velocity.z = direction.z * speed + knockback_velocity.z

	move_and_slide()

	# Decay knockback over time
	knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, knockback_friction * delta)

	# Face movement direction
	if direction.length() > 0.1:
		look_at(Vector3((global_position + direction).x, global_position.y, (global_position + direction).z))

func take_knockback(from_position: Vector3, force: float):
	var direction = (global_position - from_position).normalized()
	direction.y = 0
	direction = direction.normalized()
	
	knockback_velocity = direction * force
	velocity.y = force * 0.2

func take_damage(amount):
	health = max(0, health - amount)

	if health <= 0:
		queue_free()

func _on_hit_area_body_entered(body: Node3D) -> void:
	if body.is_in_group('player'):
		body.take_damage(10)

		take_knockback(player.global_position, 40.0)
