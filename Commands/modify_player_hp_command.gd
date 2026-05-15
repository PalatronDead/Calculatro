class_name ModifyPlayerHPCommand extends Command

var amount: int

func _init(_amount: int):
	amount = _amount
	
func execute():
	RunManager.emit_signal("on_player_modifiying_hp", self)
	RunManager.modifiy_hp(amount)
