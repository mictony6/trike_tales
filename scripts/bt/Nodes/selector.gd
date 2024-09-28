extends Task
class_name Selector

var sequence
var idx = 0

func _ready() -> void:
    set_sequence()

func set_sequence() -> void:
    idx = 0
    sequence = range(get_child_count())

func run():
    get_child(sequence[idx]).run()
    running()


func child_success():
    set_sequence()
    success()

func child_fail():
    idx += 1
    if idx >= get_child_count():
        set_sequence()
        fail()