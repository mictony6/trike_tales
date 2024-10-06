extends Task

class_name Leaf
signal on_run(action: Leaf)

func run():
	on_run.emit(self)
