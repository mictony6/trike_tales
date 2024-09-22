extends Area3D
@export var state_chart: StateChart
	

func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("Vehicle")):
		state_chart.send_event("terrain_vehicle")
		

func _on_body_exited(body: Node3D) -> void:
	state_chart.send_event("terrain_normal")
