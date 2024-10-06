extends CharacterBody3D
class_name NPCInstance

@export var details: NPCDetails
@export var behavior_tree: Task = null
@onready var blackboard: BlackBoard = $BlackBoard
var has_quest: bool = true

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var direction = Vector3.ZERO
var previous_pos = Vector3.ZERO
var look_at_player = false
var active: bool = true


func _ready() -> void:
	behavior_tree.start()
	previous_pos = global_transform.origin
	$"Bubble Indicator".details = details
	

func _process(delta: float) -> void:
	if active:
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

	if look_at_player:
		var player_location: Vector3 = Globals.player.position
		var direction_to_player: Vector3 = (player_location - global_position).normalized()
		var target_angle: float = atan2(-direction_to_player.x, -direction_to_player.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 10)

	move_and_slide()

func activate() -> void:
	active = true
func deactivate() -> void:
	active = false


# behavior tree functions
# (is near trike?) -> [is near player? (jump -> land)] -> (move to trike -> has_reached_trike? )

func _on_is_not_near_trike_on_run(action: Leaf) -> void:
	if details.is_near_trike:
		look_at_player = true
		action.fail()
	else:
		action.success()
		look_at_player = false


func _on_jump_on_run(action: Leaf) -> void:
	velocity.y = JUMP_VELOCITY
	action.success()


func _on_land_on_run(action: Leaf) -> void:
	if is_on_floor():
		action.success()
	else:
		action.running()


func _on_is_player_near_on_run(action: Leaf) -> void:
	if details.is_near_player:
		action.fail()
	else:
		action.success()


func on_reached_destination() -> void:
	print("NPC has reached the destination")


func _on_idle_on_run(action: Leaf) -> void:
	# do something here for npc idle state
	rotation.y = lerp_angle(rotation.y, 0, 0.1)
	action.success()

# once player agrees to take the passenger

func on_taken(trike: Trike) -> void:
	var seat: Seat = trike.get_vacant_seat()
	seat.occupied = true
	seat.occupant = details
	queue_free()

func _on_has_quest_on_run(action: Leaf) -> void:
	if details.has_quest():
		action.success()
	else:
		action.fail()


func _on_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Vehicle"):
		details.is_near_trike = true
	elif body is Player:
		details.is_near_player = true


func _on_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("Vehicle"):
		details.is_near_trike = false
	else:
		details.is_near_player = false
