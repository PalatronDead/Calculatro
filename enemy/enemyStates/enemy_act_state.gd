class_name EnemyActState extends State

var enemy

func _init(e):
	enemy = e

func get_state_name() -> String:
	return "Act"

func enter():
	enemy.hide_intent()
	print("About to execute: ", enemy.current_action.resource_path)
	enemy.current_action.execute(enemy, enemy.battle_manager)
	print("Act state")
	enemy.state_machine.transition("Choose")
