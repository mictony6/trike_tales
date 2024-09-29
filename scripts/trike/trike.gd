extends VehicleBody3D
class_name Trike

@export var control_ui: Control
@onready var state_chart: StateChart = $StateChart
@onready var player_detector: Area3D = $PlayerDetector
@onready var driver: Player = null
@onready var player_target: Node3D = $PlayerMountTarget
@onready var camera_target: Node3D = $CameraTarget
var max_steering = 0.5
@export var max_torque: int
var limit = 6
var engine_status = false


var available_seats = 1


@onready var back_left_wheel: VehicleWheel3D = $WheelBackLeft
@onready var back_right_wheel: VehicleWheel3D = $WheelBackRight

# Called when the node enters the scene tree for the first time.
func _ready():
	control_ui.visible = false
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_SHIFT:
				limit = 15
		elif event.is_released():
			if event.keycode == KEY_SHIFT:
				limit = 6

func _on_player_detector_body_entered(body: Node3D) -> void:
	control_ui.visible = true
	if !driver:
		driver = body as Player


func _on_player_detector_body_exited(body: Node3D) -> void:
	control_ui.visible = false


func _on_vacant_state_processing(delta: float) -> void:
	engine_status = false
	
	back_left_wheel.brake = 250
	back_right_wheel.brake = 250

	# brake = 100
	if control_ui.visible and Input.is_action_just_pressed("interact"):
		driver.enter_vehicle(player_target, rotation_degrees.y, camera_target)
		state_chart.send_event("driving")
		control_ui.visible = false
		player_detector.monitoring = false
		stop_vehicle()

func stop_vehicle() -> void:
	steering = 0
	engine_force = 0


var acceleration = 1
func _on_driving_state_processing(delta: float) -> void:
	acceleration = 1 if Input.get_axis("backward", "forward") >= 0 else -1


	# stop the vehicle
	if Input.is_action_just_pressed("brake"):
		engine_status = !engine_status


	if Input.is_action_just_pressed("exit"):
		driver.exit_vehicle()
		state_chart.send_event("vacant")
		player_detector.monitoring = true
		stop_vehicle()

		
func _on_driving_state_physics_processing(delta: float) -> void:
	# get the steering input
	steering = move_toward(steering, Input.get_axis("right", "left"), delta * 5)
	steering = clampf(steering, -max_steering, max_steering)

	engine_force = acceleration * max_torque if engine_status else 0
	#if steering != 0:
		#engine_force*=0.1
	# linear_velocity = linear_velocity.normalized() * min(linear_velocity.length(), 53)
	var hvelocity = Vector2(linear_velocity.x, linear_velocity.z)
	if hvelocity.length() > limit :
		hvelocity = hvelocity.normalized() * limit
		linear_velocity.x = hvelocity.x
		linear_velocity.z = hvelocity.y
