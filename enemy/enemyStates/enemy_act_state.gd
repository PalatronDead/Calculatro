class_name EnemyActState extends State

var enemy

func _init(e):
	enemy = e

func get_state_name() -> String:
	return "Act"

func enter():
	enemy.hide_intent()
	enemy.current_actions[enemy.current_action_index].execute(enemy, enemy.battle_manager)
	print("Act state")
	enemy.current_action_index += 1
	if enemy.current_action_index >= enemy.current_actions.size():
		enemy.current_action_index = 0
	enemy.state_machine.transition("Choose")
