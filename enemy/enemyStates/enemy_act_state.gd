class_name EnemyActState extends State

var enemy

func _init(e):
	enemy = e

func get_state_name() -> String:
	return "Act"

func enter():
	enemy.hide_intent()
	enemy.current_action.execute(enemy, enemy.battle_manager)
	enemy.state_machine.transition("Choose")
