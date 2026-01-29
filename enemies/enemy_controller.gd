extends CharacterBody3D

@export var speed := 6.0
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var player: Node3D

func _ready():
	player = get_tree().get_first_node_in_group("player")

	# Wait for navigation to be ready
	await get_tree().physics_frame

func _physics_process(delta):
	if player:
		nav_agent.target_position = player.global_position

	if nav_agent.is_navigation_finished():
		return

	var next_point = nav_agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()

	# Keep Y component for slopes
	velocity = direction * speed

	move_and_slide()

	# Face movement direction
	if direction.length() > 0.1:
		look_at(Vector3((global_position + direction).x, global_position.y, (global_position + direction).z))
