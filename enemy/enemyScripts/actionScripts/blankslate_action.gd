class_name BlankSlateAction extends EnemyAction

func execute(enemy, battle_manager):
	await enemy.get_tree().create_timer(1.0).timeout
	battle_manager.calculator_ui.eliminate_entire_hand()
	battle_manager.calculator_ui.start_turn()
