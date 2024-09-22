extends DirectionalLight3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_x(deg_to_rad(0.2) * delta)
	# Get the current rotation (rotation_degrees is in degrees)
	var current_angle = rotation_degrees.x

	# Check if the sun is below or above the horizon (simple angle check)
	if current_angle > 2: # If rotation exceeds 180, the light is below the horizon
		light_energy = move_toward(light_energy, 0.0, 2 * delta) # Turn off the light
	elif current_angle < -2:
		light_energy = move_toward(light_energy, 1.0, 2 * delta) # Turn off the light
