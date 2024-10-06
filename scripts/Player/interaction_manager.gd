extends Node3D
class_name InteractionManager
@export var statechart: StateChart

var npcs: Array[NPCInstance] = []
var current_npc: NPCInstance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !statechart:
		statechart = $"../StateChart"
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
func _on_dialogue_ended(_dialogue: DialogueResource):
	statechart.send_event("last_state")
	
func _on_npc_detector_body_entered(body: Node3D) -> void:
	statechart.send_event("can_converse")
	npcs.append(body as NPCInstance)


func _on_npc_detector_body_exited(body: Node3D) -> void:
	statechart.send_event("default")
	npcs.erase(body as NPCInstance)
	
func _on_can_converse_state_unhandled_input(_event: InputEvent) -> void:
	# this does not guarantee that the player is in the right state
	# all transition are handled by the statechart
	if Input.is_action_just_pressed("interact"):
		statechart.send_event("in_dialogue")
		

func _on_in_dialogue_state_entered() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var npc: NPCInstance = npcs[0]
	DialogueManager.show_dialogue_balloon(npc.details.get_current_dialogue())
	statechart.set_expression_property("interact_location", npc.global_position)
	current_npc = npc
	

func _on_in_dialogue_state_exited() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	statechart.send_event("can_converse")
	current_npc = null


func _on_can_drive_state_unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		Globals.player.try_enter_vehicle()
