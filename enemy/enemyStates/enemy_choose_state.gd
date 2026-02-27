class_name EnemyChooseState extends State

var enemy

func _init(e):
	enemy = e

func get_state_name() -> String:
	return "Choose"

func enter():
	enemy.current_action = enemy.pick_action()
	enemy.state_machine.transition("ShowIntent")
