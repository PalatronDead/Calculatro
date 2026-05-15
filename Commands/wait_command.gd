class_name WaitCommand extends Command

var duration: float
var tree: SceneTree

func _init(_tree: SceneTree, _duration: float):
	duration = _duration
	tree = _tree


func execute():
	await tree.create_timer(duration).timeout
