class_name CalculatorLogic extends Node

func calculate_sequence(sequence_data: Array[ItemData]) -> AttackPayload:
	var new_payload = AttackPayload.new()
	var current_number_str: String = ""
	var current_operator: OperatorAction = null
	
	
	for item in sequence_data:
		if item.type == ItemData.Type.INTEGER:
			current_number_str += str(item.value)
		elif item.type == ItemData.Type.OPERATOR:
			if current_number_str != null:
				if current_operator == null:
					new_payload.base_damage = int(current_number_str)
				else:
					current_operator.apply_effect(new_payload, int(current_number_str))	
			
			current_operator = item.operator_action
			current_number_str = ""
	
	if current_number_str != null:
				if current_operator == null:
					new_payload.base_damage = int(current_number_str)
				else:
					current_operator.apply_effect(new_payload, int(current_number_str))			
	
	return new_payload
