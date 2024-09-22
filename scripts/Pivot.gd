extends SpringArm3D

@onready var camera: Camera3D = $Camera3D
@export var subject: Node3D
@onready var player: Node3D = get_parent()
var offset: Vector3 = Vector3.ZERO

const MOUSE_SENSITIVITY = 0.25
# Called when the node enters the scene tree for the first time.
func _ready():
	offset = global_transform.origin - subject.global_position

	top_level = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.x -= (event.relative.y * MOUSE_SENSITIVITY)
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 55)

		rotation_degrees.y -= (event.relative.x * MOUSE_SENSITIVITY)
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)

	#switch mouse mode when pressing ESC
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta):
			
	# Reposition the pivot to the player's position
	# lerp the y to avoid too much vertical movement

	var target_position = subject.global_position + offset
	global_transform.origin.x = target_position.x
	global_transform.origin.z = target_position.z
	global_transform.origin.y = lerp(global_position.y, target_position.y, 2 * delta)

func set_subject(obj: Node3D) -> void:
	print(obj)
	subject = obj
	

func lerp_spring_length(target_length: float, duration: float) -> void:
	var initial_length = spring_length
	var elapsed_time = 0.0

	while elapsed_time < duration:
		elapsed_time += get_process_delta_time()
		var t = elapsed_time / duration
		spring_length = lerp(initial_length, target_length, t)
		await get_tree().create_timer(0.01).timeout

	# Ensure the final value is set
	spring_length = target_length