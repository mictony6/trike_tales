extends Resource
class_name Quest

enum Status {PENDING, ACTIVE, COMPLETED}
@export var title: String
@export var description: String
@export var status: Status = Status.PENDING
@export var objectives: Array[Quest] = []
@export var dialogue: DialogueResource

func start():
    status = Status.ACTIVE


func is_completed():
    for objective in objectives:
        if objective.status != Status.COMPLETED:
            return false
    return true