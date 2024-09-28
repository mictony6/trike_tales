extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var behavior_tree: Task = null
var direction = Vector3.ZERO
var previous_pos = Vector3.ZERO

@onready var blackboard: BlackBoard = $BlackBoard


func _ready() -> void:
	behavior_tree.start()
	previous_pos = global_transform.origin

func _process(delta: float) -> void:
	behavior_tree.run()

func _physics_process(delta: float) -> void:
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


func _on_is_not_near_trike_on_run(action: Leaf) -> void:
	if blackboard.trike_near:
		action.fail()
	else:
		action.success()
