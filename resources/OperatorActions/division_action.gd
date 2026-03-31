class_name DivisionAction extends OperatorAction

func apply_effect(payload: AttackPayload, modifier_value: int) -> void:
		payload.aoe_targets = modifier_value
