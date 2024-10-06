extends Resource
class_name NPCDetails

@export var name: String
@export var quests: Array[Quest] = []
var is_near_player = false
var is_near_trike = false
@export var default_dialogue: DialogueResource


func get_next_pending_quest() -> Quest:
    for quest in quests:
        if quest.status == Quest.Status.PENDING:
            return quest
    return null

func get_current_active_quest() -> Quest:

    for quest in quests:
        if quest.status == Quest.Status.ACTIVE:
            return quest
        if quest.status == Quest.Status.PENDING:
            quest.start()
            return quest
    return null

func get_current_dialogue() -> DialogueResource:
    if get_current_active_quest() == null:
        return default_dialogue
    return get_current_active_quest().dialogue

func has_quest() -> bool:
    return get_current_active_quest() != null
