extends Node

class_name Task

enum {
    FRESH,
    RUNNING,
    FAILED,
    SUCCEDED,
    CANCELLED
}

var control: Task = null
var tree = null
var guard = null
var status = FRESH
var is_entry = false


func running():
    status = RUNNING
    if control:
        control.child_running()


func success():
    status = SUCCEDED
    if control:
        control.child_success()

func fail():
    status = FAILED
    if control:
        control.child_fail()

func cancel():
    status = CANCELLED
    if control:
        control.child_cancel()

func run():
    pass

func child_success():
    pass

func child_fail():
    pass

func child_running():
    pass

func start():
    status = FRESH
    for child in get_children():
        var _child: Task = child
        _child.control = self
        _child.tree = self.tree
        _child.start()

func reset():
    cancel()
    status = FRESH
