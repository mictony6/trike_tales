extends AnimationTree


func _on_idle_state_entered():
	# set the animation to idle
	set("parameters/Transition/transition_request", "idle")


func _on_walk_state_entered():
	set("parameters/Transition/transition_request", "walk")


func _on_sprint_state_entered():
	set("parameters/Transition/transition_request", "sprint")


func _on_jump_state_entered() -> void:
	
	set("parameters/OneShot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_jump_state_exited() -> void:
	set("parameters/OneShot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)


func _on_driving_state_entered() -> void:
	set("parameters/Transition/transition_request", "mount")


func _on_in_dialogue_state_entered() -> void:
	set("parameters/Transition/transition_request", "idle")
