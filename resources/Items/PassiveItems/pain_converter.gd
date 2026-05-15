class_name PainConverter extends PassiveItemData

func ready():
	RunManager.on_player_hp_modifiying.connect(_on_hp_modifiying)
	
func _on_hp_modifiying(cmd: ModifyPlayerHPCommand):
	if cmd.amount > 0:
		for enemy in RunManager.current_enemies:
			if is_instance_valid(enemy):
				CommandQueuee.add(WaitCommand.new(RunManager.get_tree(),0.2))
				CommandQueuee.add(DealDamageCommand.new(cmd.amount, enemy, RunManager.player))

	
