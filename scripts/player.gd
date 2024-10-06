extends CharacterBody3D
class_name Player

@onready var pivot: Pivot = $Pivot
@onready var state_chart: StateChart = $StateChart
@onready var interaction_manager: InteractionManager = $InteractionManager

@onready var body_collider = $Collider
const MOUSE_SENSITIVITY = 0.005
const SPEED = 2.0
const RUNNING_SPEED = SPEED * 2
const JUMP_VELOCITY = 4.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	Globals.player = self
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
		if !direction:
			state_chart.send_event("idle")
			return
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 20)
			
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
		if !direction:
			state_chart.send_event("idle")
			return
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 20)
	
	velocity.x = direction.x * RUNNING_SPEED
	velocity.z = direction.z * RUNNING_SPEED

	if Input.is_action_just_released("sprint"):
		state_chart.send_event("walk")
	

var last_state_before_jump = null
func _on_jump_state_physics_processing(delta: float) -> void:
	if is_on_floor():
		print("on floor")
		state_chart.send_event("last_state")
	
func _on_jump_state_entered() -> void:
	velocity.y = JUMP_VELOCITY

var mount_position: Node3D = null

func try_enter_vehicle() -> void:
	state_chart.send_event("driving")

func exit_vehicle():
	state_chart.send_event("last_state")

func _on_driving_state_entered() -> void:
	var target_pos: Node3D = Globals.trike.player_target
	var vehicle_rotation_y: float = Globals.trike.rotation_degrees.y
	var camera_target: Node3D = Globals.trike.camera_target

	turn_on_vehicle()

	body_collider.disabled = true
	#mount position is offset to which the player must stand for the 
	# mount animation to look correctly
	mount_position = target_pos
	global_position = target_pos.global_position
	
	# rotate player to the vehicle's forward direction
	rotation.y = vehicle_rotation_y

	
	# change camera to look at verhicle
	pivot.enter_vehicle(camera_target)
	pivot.set_length_to_driving()

func _on_driving_state_physics_processing(delta: float) -> void:
	velocity = Vector3.ZERO

	# make the player follow the vehicle
	global_position = mount_position.global_position
	# rotate player to the vehicle direction
	rotation = mount_position.global_rotation
	
func _on_driving_state_exited() -> void:
	body_collider.disabled = false
	rotation_degrees.x = 0
	rotation_degrees.z = 0

	Globals.trike.uncontrol()
	pivot.exit_vehicle()
	pivot.set_length_to_normal()


func _on_in_dialogue_state_physics_processing(delta: float) -> void:
	velocity = Vector3.ZERO
	var interact_location: Vector3 = state_chart.get_expression_property("interact_location")
	var direction_to_npc: Vector3 = (interact_location - global_position).normalized()
	var target_angle: float = atan2(-direction_to_npc.x, -direction_to_npc.z)
	rotation.y = lerp_angle(rotation.y, target_angle, delta * 10)
	#look_at(state_chart.get_expression_property("interact_location"), Vector3.UP)


func get_npc_in_dialogue() -> NPCInstance:
	return interaction_manager.current_npc

func turn_on_vehicle():
	Globals.trike.control()


func _on_driving_state_unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("exit"):
		print("exit vehicle")
		exit_vehicle()
