class_name PowerupAction extends EnemyAction

func execute(enemy, battle_manager):
	print("Powering uppp!")
	enemy.powerup_modifier = 3.0
	await enemy.get_tree().create_timer(0.5).timeout

	
