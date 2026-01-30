extends Area3D

@export var speed := 20.0
@export var damage := 50

var direction := Vector3.FORWARD

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	if not body.is_in_group('player'):
		if body.is_in_group('enemy'):
			body.take_damage(damage)

			queue_free()

func _on_timer_timeout() -> void:
	queue_free()
