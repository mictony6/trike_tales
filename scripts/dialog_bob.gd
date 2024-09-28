extends Node3D # or Node2D if working in 2D

# Variables to control the bobbing effect
var amplitude: float = 0.1 # The height of the bobbing
var speed: float = 2.0 # The speed of the bobbing
var initial_position: Vector3

# Store the initial position of the object
func _ready():
	initial_position = global_position

# Bob up and down over time
func _process(delta: float):
	# Apply a sine wave to the Y axis to create the bobbing effect
	var offset = sin(Time.get_ticks_msec() * 0.001 * speed) * amplitude
	global_transform.origin.y = initial_position.y + offset
