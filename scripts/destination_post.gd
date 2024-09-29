extends Node3D
class_name DestinationPost

@export var npc: NPCInstance


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("NPC"):
		if body == npc:
			npc.on_reached_destination()
			queue_free()
