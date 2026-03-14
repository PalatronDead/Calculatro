class_name EnemyShowIntentState extends State

var enemy

func _init(e):
	enemy = e

func get_state_name() -> String:
	return "ShowIntent"

func enter():
	enemy.show_intent()
	print("Show Intent")
