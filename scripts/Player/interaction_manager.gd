extends Node3D
@export var statechart : StateChart

var npcs : Array[NPCInstance] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !statechart:
		statechart = $"../StateChart"
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
func _on_dialogue_ended(dialogue: DialogueResource):
	statechart.send_event("last_state")
	
func _unhandled_input(event: InputEvent) -> void:
	if npcs.size() > 0 and Input.is_action_just_pressed("interact"):

		statechart.send_event("in_dialogue")
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_npc_detector_body_entered(body: Node3D) -> void:
	statechart.send_event("can_converse")
	npcs.append(body as NPCInstance)



func _on_npc_detector_body_exited(body: Node3D) -> void:
	statechart.send_event("default")
	npcs.erase(body as NPCInstance)


func _on_conversing_state_entered() -> void:
	pass



func _on_in_dialogue_state_entered() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var npc : NPCInstance = npcs[0]
	DialogueManager.show_dialogue_balloon(npc.dialogue)
	statechart.send_event("conversing")
	statechart.set_expression_property("interact_location", npc.global_position)



func _on_in_dialogue_state_exited() -> void:
	Input.mouse_mode= Input.MOUSE_MODE_CAPTURED
	statechart.send_event("can_converse")
	
