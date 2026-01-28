extends Node3D

@export var mouse_sensitivity := 0.003
@export var min_pitch := -0.8 # Look down.
@export var max_pitch := +0.4 # Look up.

@export var min_zoom := 3.0
@export var max_zoom := 9.0
@export var zoom_speed := 0.5
@export var zoom_smoothness := 8.0

var pitch := 0.0
var zoom := 6.0
var target_zoom := 6.0

@onready var camera := $PitchPivot/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	camera.position = Vector3(0, 0, zoom) # This places the camera behind the character.

func _input(event):
	if Input.is_action_just_pressed("esc"):  # Debug?
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Horizontal rotation (yaw).
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Vertical rotation (pitch).
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, min_pitch, max_pitch)
		$PitchPivot.rotation.x = pitch

	if event is InputEventMouseButton and event.pressed:
		# Zoom in.
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom -= zoom_speed

		# Zoom out.
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom += zoom_speed

		target_zoom = clamp(target_zoom, min_zoom, max_zoom)

func _process(delta):
	zoom = lerp(zoom, target_zoom, zoom_smoothness * delta)
	camera.position.z = zoom
