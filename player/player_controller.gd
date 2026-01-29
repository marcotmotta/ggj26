extends CharacterBody3D

@export var move_speed := 10.0
@export var jump_velocity := 25
@export var gravity := 50.0
@export var turn_speed := 12.0

@onready var cam_yaw_pivot := $CameraRig/Center/YawPivot
@onready var visual := $Visual

var curr_mask_type = null

func _process(delta):
	# Align to camera direction.
	visual.rotation.y = lerp_angle(visual.rotation.y, cam_yaw_pivot.global_rotation.y, turn_speed * delta)

func _physics_process(delta):
	var input_dir := Vector2.ZERO
	var movement_dir := Vector3.ZERO

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
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	else:
		velocity.y -= gravity * delta

	move_and_slide()

func remove_mask(type):
	match type:
		game_state.types_of_masks.hummingbird:
			visual.get_node("MaskHandler/Center/Mask1").visible = false
			print("Remove Mask1")
		game_state.types_of_masks.turtle:
			visual.get_node("MaskHandler/Center/Mask2").visible = false
			print("Remove Mask2")

	curr_mask_type = null

func add_mask(type):
	remove_mask(curr_mask_type)

	match type:
		game_state.types_of_masks.hummingbird:
			visual.get_node("MaskHandler/Center/Mask1").visible = true
			print("Add Mask1")
		game_state.types_of_masks.turtle:
			visual.get_node("MaskHandler/Center/Mask2").visible = true
			print("Add Mask2")

	curr_mask_type = type
