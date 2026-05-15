class_name ModifyMaxHPCommand extends Command

var amount: int

func _init(_amount: int):
	amount = _amount
	
func execute():
	RunManager.emit_signal("on_modifying_max_hp", self)
	RunManager.modify_max_hp(amount)
