extends Task
class_name AlwaysSuccess

func run():
    if get_child_count() > 0:
        get_child(0).run()
    success()
func child_success():
    pass
func child_fail():
    pass