extends Task
class_name Limit

@export var LIMIT: int = 4

var count: int = 0

func run():
    get_child(0).run()
    running()

func child_success():
    count += 1
    if count >= LIMIT:
        count = 0
        fail()
    else:
        success()

func child_fail():
    count = 0
    fail()

func cancel():
    count = 0
    super.cancel()