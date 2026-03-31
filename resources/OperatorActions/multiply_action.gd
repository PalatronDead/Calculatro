class_name MultiplyAction extends OperatorAction

func apply_effect(payload: AttackPayload, modifier_value: int) -> void:
		payload.hit_count = modifier_value
