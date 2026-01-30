extends CharacterBody3D

@export var move_speed := 10.0
@export var jump_velocity := 25
@export var gravity := 50.0
@export var turn_speed := 5.0

@onready var cam := $CameraRig/Center/YawPivot/PitchPivot/Camera3D
@onready var cam_yaw_pivot := $CameraRig/Center/YawPivot
@onready var health_bar := $CameraRig/CanvasLayer/HealthBar
@onready var visual := $Visual

@onready var max_health = 100
@onready var health = 100

var curr_mask_type = null

# Projectiles.
@onready var projectile_beijaflor_scene = preload("res://projectiles/ProjectileBeijaFlor.tscn")
@onready var projectile_tartaruga_scene = preload("res://projectiles/ProjectileTartaruga.tscn")
@onready var projectile_garca_scene = preload("res://projectiles/ProjectileGarca.tscn")
@onready var projectile_arara_scene = preload("res://projectiles/ProjectileArara.tscn")
@onready var projectile_macaco_scene = preload("res://projectiles/ProjectileMacaco.tscn")
@onready var projectile_onca_scene = preload("res://projectiles/ProjectileOnca.tscn")
@onready var projectile_peixe_scene = preload("res://projectiles/ProjectilePeixe.tscn")

func _process(delta):
	# Align to camera direction.
	visual.rotation.y = lerp_angle(visual.rotation.y, cam_yaw_pivot.global_rotation.y, turn_speed * delta)

	# Update UI.
	health_bar.max_value = max_health
	health_bar.value = health

func _physics_process(delta):
	var input_dir = Vector2.ZERO
	var movement_dir = Vector3.ZERO

	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")

	if input_dir.length() > 0:
		# Camera-relative directions.
		var forward: Vector3 = -cam_yaw_pivot.global_transform.basis.z
		var right: Vector3 = cam_yaw_pivot.global_transform.basis.x

		# Ignore vertical tilt.
		forward.y = 0
		right.y = 0
		forward = forward.normalized()
		right = right.normalized()

		movement_dir = (right * input_dir.x + forward * input_dir.y).normalized()

	# Horizontal movement.
	velocity.x = movement_dir.x * move_speed
	velocity.z = movement_dir.z * move_speed

	# Vertical movement.
	if is_on_floor():
		$Visual/PlayerModel/AnimationPlayer.play("mixamo_com")

		if Input.is_action_just_pressed("jump"):
			$Visual/PlayerModel/AnimationPlayer.play("Jumping/mixamo_com")
			velocity.y = jump_velocity

	else:
		velocity.y -= gravity * delta

	move_and_slide()

func _input(event):
	if event.is_action_pressed("m1") and curr_mask_type != null: # Must have mask to shoot!?
		throw_projectile()

func remove_current_mask():
	for mask in $Visual/MaskHandler/Masks.get_children():
		mask.visible = false

	curr_mask_type = null

func add_mask(type):
	remove_current_mask()

	match type:
		game_state.types_of_masks.beijaflor:
			visual.get_node("MaskHandler/Masks/Mask1").visible = true
		game_state.types_of_masks.tartaruga:
			visual.get_node("MaskHandler/Masks/Mask2").visible = true
		game_state.types_of_masks.garca:
			visual.get_node("MaskHandler/Masks/Mask3").visible = true
		game_state.types_of_masks.arara:
			visual.get_node("MaskHandler/Masks/Mask4").visible = true
		game_state.types_of_masks.macaco:
			visual.get_node("MaskHandler/Masks/Mask5").visible = true
		game_state.types_of_masks.onca:
			visual.get_node("MaskHandler/Masks/Mask6").visible = true
		game_state.types_of_masks.peixe:
			visual.get_node("MaskHandler/Masks/Mask7").visible = true

	curr_mask_type = type

func get_camera_aim_point(max_distance = 1000.0):
	var viewport = get_viewport()
	var screen_center = viewport.get_visible_rect().size * 0.5
	var ray_origin = cam.project_ray_origin(screen_center)
	var ray_direction = cam.project_ray_normal(screen_center)
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * max_distance)
	query.exclude = [self]
	var result := get_world_3d().direct_space_state.intersect_ray(query)

	if result:
		return result.position
	else:
		return ray_origin + ray_direction * max_distance

func throw_projectile():
	var projectile_instance

	match curr_mask_type:
		game_state.types_of_masks.beijaflor:
			projectile_instance = projectile_beijaflor_scene.instantiate()
		game_state.types_of_masks.tartaruga:
			projectile_instance = projectile_tartaruga_scene.instantiate()
		game_state.types_of_masks.garca:
			projectile_instance = projectile_garca_scene.instantiate()
		game_state.types_of_masks.arara:
			projectile_instance = projectile_arara_scene.instantiate()
		game_state.types_of_masks.macaco:
			projectile_instance = projectile_macaco_scene.instantiate()
		game_state.types_of_masks.onca:
			projectile_instance = projectile_onca_scene.instantiate()
		game_state.types_of_masks.peixe:
			projectile_instance = projectile_peixe_scene.instantiate()

	projectile_instance.global_position = global_position
	projectile_instance.direction = (get_camera_aim_point() - global_position).normalized()
	projectile_instance.type = curr_mask_type

	get_parent().add_child(projectile_instance)

func take_damage(amount):
	health = max(0, health - amount)
