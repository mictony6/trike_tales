extends CharacterBody3D
class_name Player

@onready var pivot: SpringArm3D = $Pivot
@onready var state_chart: StateChart = $StateChart

@onready var collider = $Collider
const MOUSE_SENSITIVITY = 0.005
const SPEED = 2.0
const RUNNING_SPEED = SPEED * 2
const JUMP_VELOCITY = 4.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction: Vector3 = Vector3.ZERO


func _physics_process(delta):
	state_chart.set_expression_property("is_on_floor", is_on_floor())
	
	#apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	get_input_direction()


	if Input.is_action_just_pressed("jump") and is_on_floor():
		state_chart.send_event("jump")

	move_and_slide()

func get_input_direction():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")

	# rotate player to the camera direction
	direction = move_direction.rotated(Vector3.UP, pivot.rotation.y).normalized()


func _on_walk_state_physics_processing(delta: float):
	#rotate the player to the velocity direction
	if is_on_floor():
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 20)
		if !direction:
			state_chart.send_event("idle")
			
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	if (Input.is_action_pressed("sprint")):
		state_chart.send_event("sprint")


func _on_idle_state_physics_processing(delta: float):
	if direction:
		state_chart.send_event("walk")
	else:
		velocity.x = move_toward(velocity.x, Vector3.ZERO.x, delta * 20)
		velocity.z = move_toward(velocity.z, Vector3.ZERO.z, delta * 20)

func _on_sprint_state_physics_processing(delta: float):
	#rotate the player to the velocity direction
	if is_on_floor():
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 20)
		if !direction:
			state_chart.send_event("idle")
	
	velocity.x = direction.x * RUNNING_SPEED
	velocity.z = direction.z * RUNNING_SPEED

	if Input.is_action_just_released("sprint"):
		state_chart.send_event("walk")


var last_state_before_jump = null
func _on_jump_state_physics_processing(delta: float) -> void:
	if is_on_floor():
		state_chart.send_event("last_state")
	

func _on_jump_state_entered() -> void:
	velocity.y = JUMP_VELOCITY

var mount_position: Node3D = null

func enter_vehicle(target_pos: Node3D, vehicle_rotation_y: float, camera_target: Node3D) -> void:
	collider.disabled = true
	mount_position = target_pos
	# move player to target position
	global_position = target_pos.global_position
	# rotate player to the vehicle direction
	rotation.y = vehicle_rotation_y

	state_chart.send_event("driving")
	pivot.set_subject(camera_target)
	await pivot.lerp_spring_length(10, 0.5)


func _on_driving_state_physics_processing(delta: float) -> void:

	# make the player follow the vehicle
	global_position = mount_position.global_position
	# rotate player to the vehicle direction
	rotation = mount_position.global_rotation

func exit_vehicle():
	collider.disabled = false
	state_chart.send_event("last_state")
	rotation_degrees.x = 0
	rotation_degrees.z = 0
	pivot.set_subject(self)
	await pivot.lerp_spring_length(5, 0.5)
