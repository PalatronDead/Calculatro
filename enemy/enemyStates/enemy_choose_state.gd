class_name EnemyChooseState extends State

var enemy

func _init(e):
	enemy = e

func get_state_name() -> String:
	return "Choose"

func enter():
	enemy.damage_modifier = 1.0
	enemy.current_actions = enemy.pick_actions()
	enemy.state_machine.transition("ShowIntent")
	print('Choose State')
