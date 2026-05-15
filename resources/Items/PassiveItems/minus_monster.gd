class_name MinusMonster extends PassiveItemData

func ready():
	RunManager.on_player_hp_modifiying.connect(_on_hp_modifiying)
	
func _on_hp_modifiying(cmd: ModifyPlayerHPCommand):
	if cmd.amount > 2:
		cmd.amount *= 2
	
