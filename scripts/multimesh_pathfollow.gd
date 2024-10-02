@tool
extends MultiMeshInstance3D
class_name MultiMeshPathFollow
@export var distance_between_mesh : float = 1.0 :
	set(value):
		distance_between_mesh = value
		if Engine.is_editor_hint():
			update_multimesh()
@export var path : Path3D
@export var is_dirty : bool = true
var trimesh : Shape3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trimesh = multimesh.mesh.create_trimesh_shape()
	update_multimesh()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dirty:
		update_multimesh()
		is_dirty = false
		
func update_multimesh():
	var ms = multimesh
	var curve : Curve3D = path.curve
	
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
		var _transform = Transform3D(basis, position)
		
		ms.set_instance_transform(i, _transform)
		
		if Engine.is_editor_hint():
			continue
		
		var sBody = StaticBody3D.new()
		var shape = CollisionShape3D.new()
		shape.shape = trimesh
		
		sBody.add_child(shape)
		add_child(sBody)
		sBody.transform = _transform
		
		
	


func _on_path_3d_curve_changed() -> void:
	update_multimesh()
