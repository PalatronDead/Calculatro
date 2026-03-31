class_name PowerupAction extends EnemyAction

func execute(enemy, battle_manager):
	battle_manager.take_damage(base_value)
	print("Wololo")
	print(base_value)
