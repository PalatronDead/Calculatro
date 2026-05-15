class_name EnemyAction extends Resource

@export var name: String
@export var intent_icon: Texture2D
@export var base_value: int = 0

func execute(enemy, player):
	pass
	
func apply_stance(enemy, player):
	pass

func get_true_base_value(enemy) -> int:
	return base_value
