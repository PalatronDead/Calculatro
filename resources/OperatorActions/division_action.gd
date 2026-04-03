class_name DivisionAction extends OperatorAction

func apply_effect(payload: AttackPayload, modifier_value: int) -> void:
		payload.base_damage = payload.base_damage / modifier_value
		payload.aoe_targets = modifier_value
