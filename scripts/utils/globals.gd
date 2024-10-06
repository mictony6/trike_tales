extends Node
var player: Player
var trike: Trike
var active_quest: Quest
var quest_list: Array[Quest]
var completed_quests: Array[Quest]

#objectives

func take_passenger() -> void:
    player.get_npc_in_dialogue().on_taken(trike)