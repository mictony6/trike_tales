extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var behavior_tree: Task = null
var direction = Vector3.ZERO
var previous_pos = Vector3.ZERO

func _ready() -> void:
	behavior_tree.start()
	previous_pos = global_transform.origin
func _physics_process(delta: float) -> void:
	behavior_tree.run()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_move_left_on_run(action: Leaf) -> void:
	direction = Vector3.LEFT
	print("Move Left")
	if (global_position.distance_to(previous_pos) > 10):
		previous_pos = global_position
		action.success()
		return
	action.running()


func _on_jump_on_run(action: Leaf) -> void:
	print("Jump")
	velocity.y = JUMP_VELOCITY
	action.success()


func _on_move_right_on_run(action: Leaf) -> void:
	direction = Vector3.RIGHT
	print("Move Right")
	if (global_position.distance_to(previous_pos) > 10):
		previous_pos = global_position
		action.success()
		return
	action.running()

func _on_land_on_run(action: Leaf) -> void:
	if is_on_floor():
		print("Land")
		action.success()
	else:
		action.running()
