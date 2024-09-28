extends Node3D
var subject: Node3D = null
var idx: int = 0
var current_target: Vector3 = Vector3.ZERO
var possible_targets = []


var locked_on = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	subject = get_parent()
	top_level = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("lock_on"):
		if possible_targets.size() > 0:
			if current_target:
				idx = (idx + 1) % possible_targets.size()
			current_target = possible_targets[idx].global_position
			locked_on = true
	if Input.is_action_just_released("lock_on"):
		locked_on = false


	if locked_on:
		global_position = subject.global_position.lerp(current_target, 0.5)
	else:
		global_position = subject.global_position


func _on_target_detect_body_entered(body: Node3D) -> void:
	possible_targets.append(body)


func _on_target_detect_body_exited(body: Node3D) -> void:
	possible_targets.erase(body)
