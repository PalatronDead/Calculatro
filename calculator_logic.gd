class_name CalculatorLogic extends Node

func calculate_sequence(sequence_data: Array[ItemData]) -> int:
	var formula_string: String = ""
	var number_operators = 0
	
	for item in sequence_data:
		if item.type == ItemData.Type.INTEGER:
			formula_string += str(item.get_modified_value())
		elif item.type == ItemData.Type.OPERATOR:
			formula_string += item.operator_symbol
			number_operators += 1
			
	if (number_operators >=1):
		print("Raw Formula: ", formula_string)
	
		var expression = Expression.new()
		var error = expression.parse(formula_string)
	
		if error != OK:
			push_error("Invalid Math Formula: " + expression.get_error_text())
			return 0
	
		var result = expression.execute()
	
		if expression.has_execute_failed():
			return 0
	
		return int(result)
	return 0
