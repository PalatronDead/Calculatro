class_name RedrawAction extends EnemyAction

func execute(enemy, battle_manager):
	await enemy.get_tree().create_timer(1.0).timeout
	var hand_slots_with_numbers_only : Array[ItemDisplay]
	for slot in battle_manager.calculator_ui.hand_slots.get_children():
		for child in slot.get_children():
			if child is ItemDisplay and child.data.type == ItemData.Type.INTEGER:
				hand_slots_with_numbers_only.append(child)
	
	hand_slots_with_numbers_only.sort_custom(func (a,b): return a.data.value > b.data.value)
	print(hand_slots_with_numbers_only[0].data, hand_slots_with_numbers_only[1].data)
	var redrawn_tokens = min(2, hand_slots_with_numbers_only.size())
	
	for i in range(redrawn_tokens):
		var redrawn_token = hand_slots_with_numbers_only[i]
		
		redrawn_token.data = preload("res://resources/number_zero.tres")
		
		redrawn_token.setup(redrawn_token.data)
		
		print(redrawn_token)
		print(redrawn_token.data)
