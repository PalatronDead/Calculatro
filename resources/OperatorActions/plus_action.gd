class_name PlusAction extends OperatorAction

func apply_effect(payload: AttackPayload, modifier_value: int) -> void:
		payload.base_damage += modifier_value
