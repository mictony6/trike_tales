extends Node3D

@onready var quest_indicator: Control = $Quest
@onready var details: NPCDetails
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	quest_indicator.visible = not camera.is_position_behind(global_position)
	if quest_indicator.visible:
		quest_indicator.visible = (details.is_near_player or details.is_near_trike) and details.has_quest()
	quest_indicator.set_position(camera.unproject_position(global_position))
