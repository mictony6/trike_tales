extends Node
class_name BlackBoard

var trike_near = false
var player_near = false


func _on_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Vehicle"):
		body = body as Trike
		trike_near = true
	elif body is Player:
		player_near = true

func _on_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("Vehicle"):
		trike_near = false
	else:
		player_near = false
