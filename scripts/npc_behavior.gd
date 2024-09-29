extends CharacterBody3D
class_name NPCInstance

@export var behavior_tree: Task = null
@export var dialogue : DialogueResource
@onready var blackboard: BlackBoard = $BlackBoard
var has_quest : bool = true

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var direction = Vector3.ZERO
var previous_pos = Vector3.ZERO


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


func _on_jump_on_run(action: Leaf) -> void:
	velocity.y = JUMP_VELOCITY
	action.success()


func _on_land_on_run(action: Leaf) -> void:
	if is_on_floor():
		action.success()
	else:
		action.running()

func on_reached_destination() -> void:
	print("NPC has reached the destination")
