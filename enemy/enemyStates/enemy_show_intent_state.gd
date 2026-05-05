class_name EnemyShowIntentState extends State

var enemy

func _init(e):
	enemy = e

func get_state_name() -> String:
	return "ShowIntent"

func enter():
	enemy.show_intent()
	enemy.current_actions[enemy.current_action_index].apply_stance(enemy, enemy.battle_manager)
	print("Show Intent")
