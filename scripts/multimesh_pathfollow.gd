@tool
extends MultiMeshInstance3D
class_name MultiMeshPathFollow
@export var distance_between_mesh : float = 1.0 :
	set(value):
		distance_between_mesh = value
		if Engine.is_editor_hint():
			update_multimesh()
@export var path : Path3D:
	set(value):
		if path:
			path.curve_changed.disconnect(_on_path_3d_curve_changed)
		path = value
		if Engine.is_editor_hint():
			path.curve_changed.connect(_on_path_3d_curve_changed)
			
var change = 0
@export var is_dirty : bool = true
var trimesh : Shape3D
var staticbody : StaticBody3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_multimesh()
	is_dirty = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint() and is_dirty:
		
		update_multimesh()
		is_dirty = false
		
func update_multimesh():
	print("Updating multimes:" + name)

	var curve : Curve3D = path.curve
	var ms = multimesh
	if staticbody:
		staticbody.queue_free()
	trimesh = ms.mesh.create_convex_shape(true, true)
	staticbody = StaticBody3D.new()
	add_child(staticbody)
	
	staticbody.position = Vector3.ZERO
	
	var path_length = curve.get_baked_length()
	var count = floor(path_length/distance_between_mesh)
	
	ms.instance_count = count
	var offset = distance_between_mesh/2
	
	for i in range(0, count):
		var curve_distance = offset + distance_between_mesh * i
		var position = curve.sample_baked(curve_distance, true)
		var forward = position.direction_to(curve.sample_baked(curve_distance+0.1, true))
		var up = curve.sample_baked_up_vector(curve_distance, true)
		var basis = Basis()
		basis.y = up
		basis.x = forward.cross(up).normalized()
		basis.z = -forward
		
		 ## Extract the Euler angles (rotations in radians)
		#var euler_angles = basis.get_euler()
#
		## Reset the Z rotation (keep X and Y rotations intact)
		#euler_angles.z = 0
		#if randf_range(0.0, 1.0) > 0.5:
			#euler_angles.y = deg_to_rad(90)
#
		## Apply the new rotation
		#basis.from_euler(euler_angles)
		
		var _transform = Transform3D(basis, position)

		
		ms.set_instance_transform(i, _transform)
		#
		if Engine.is_editor_hint():
			continue
		
		var shape = CollisionShape3D.new()
		staticbody.add_child(shape)
		shape.shape = trimesh
		shape.transform = _transform
		shape.scale = Vector3.ONE
		
	
		
	


func _on_path_3d_curve_changed() -> void:
	is_dirty = true
