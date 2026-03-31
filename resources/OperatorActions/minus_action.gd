class_name MinusAction extends OperatorAction

func apply_effect(payload: AttackPayload, modifier_value: int) -> void:
		payload.lifesteal_amount = modifier_value
		payload.base_damage -= modifier_value
