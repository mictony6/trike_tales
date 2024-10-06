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
var limit = 8
var engine_status = false
@export var seats: Array[Seat]
var available_seats = 0:
	get():
		var count = 0
		for seat in seats:
			if !seat.occupied:
				count += 1
		return count


@onready var back_left_wheel: VehicleWheel3D = $WheelBackLeft
@onready var back_right_wheel: VehicleWheel3D = $WheelBackRight

# Called when the node enters the scene tree for the first time.
func _ready():
	control_ui.visible = false
	Globals.trike = self
	driver = Globals.player
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_SHIFT:
				limit = 15
		elif event.is_released():
			if event.keycode == KEY_SHIFT:
				limit = 8

func _on_player_detector_body_entered(body: Node3D) -> void:
	control_ui.visible = true
	driver.state_chart.send_event("can_drive")


func _on_player_detector_body_exited(body: Node3D) -> void:
	control_ui.visible = false
	driver.state_chart.send_event("default")


func _on_vacant_state_processing(delta: float) -> void:
	engine_status = false
	
	back_left_wheel.brake = 250
	back_right_wheel.brake = 250


func stop_vehicle() -> void:
	# stops the forces acting on vehicle
	# doest not make player exit the vehicle
	steering = 0
	engine_force = 0

func control():
	# this where controls switch to vehicle
	state_chart.send_event("driving")
	control_ui.visible = false
	player_detector.monitoring = false
	stop_vehicle()

func uncontrol():
	# this where controls switch to player
	state_chart.send_event("vacant")
	control_ui.visible = true
	player_detector.monitoring = true
	stop_vehicle()

var acceleration = 1
func _on_driving_state_processing(delta: float) -> void:
	acceleration = 1 if Input.get_axis("backward", "forward") >= 0 else -1


	# stop the vehicle
	if Input.is_action_just_pressed("brake"):
		engine_status = !engine_status


func _on_driving_state_physics_processing(delta: float) -> void:
	# get the steering input
	steering = move_toward(steering, Input.get_axis("right", "left"), delta * 2)
	steering = clampf(steering, -max_steering, max_steering)

	engine_force = acceleration * max_torque if engine_status else 0
	#if steering != 0:
		#engine_force*=0.1
	# linear_velocity = linear_velocity.normalized() * min(linear_velocity.length(), 53)
	var hvelocity = Vector2(linear_velocity.x, linear_velocity.z)
	if hvelocity.length() > limit:
		hvelocity = hvelocity.normalized() * limit
		linear_velocity.x = hvelocity.x
		linear_velocity.z = hvelocity.y

func get_vacant_seat() -> Seat:
	for seat in seats:
		print(seat)
		if !seat.occupied:
			return seat
	return null
func has_passenger() -> bool:
	for seat in seats:
		if seat.occupied:
			return true
	return false

func _on_driving_state_entered() -> void:
	pass
