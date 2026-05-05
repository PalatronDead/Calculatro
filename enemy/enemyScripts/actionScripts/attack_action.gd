class_name AttackAction extends EnemyAction

func execute(enemy, battle_manager):
	if enemy.powerup_modifier > 1.0:
		battle_manager.take_damage(get_true_base_value(enemy))
		enemy.powerup_modifier = 1.0
	else:
		battle_manager.take_damage(get_true_base_value(enemy))
	print("Wololo")
	print(base_value)

func get_true_base_value(enemy) -> int:
	return (base_value + RunManager.chaos_level) * enemy.powerup_modifier
