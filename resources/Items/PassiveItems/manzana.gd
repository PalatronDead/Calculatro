class_name Manzana extends PassiveItemData

func ready():
	RunManager.on_modifying_max_hp.connect(_on_max_hp_modifiying)
	
func _on_max_hp_modifiying(cmd: ModifyPlayerHPCommand):
	CommandQueuee.add(ModifyMaxHPCommand.new(5))
	
	CommandQueuee.add(ModifyMaxHPCommand.new(5))
	
