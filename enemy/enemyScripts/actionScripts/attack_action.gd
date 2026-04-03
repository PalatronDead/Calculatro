class_name AttackAction extends EnemyAction

func execute(enemy, battle_manager):
	battle_manager.take_damage(base_value + RunManager.chaos_level)
	print("Wololo")
	print(base_value)
	
