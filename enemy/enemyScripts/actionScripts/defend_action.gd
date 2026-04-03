class_name DefendAction extends EnemyAction

func execute(enemy, battle_manager):
	print("Defense activated")
	await enemy.get_tree().create_timer(0.5).timeout
	
