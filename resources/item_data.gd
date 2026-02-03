class_name ItemData extends Resource

enum Type {INTEGER, OPERATOR}

@export_group("Identity")
@export var type: Type
@export var display_name: String = ""
@export var icon: Texture2D

@export_group("Values")
@export var value: int = 0
@export var operator_symbol: String = ""

@export_group("Modifiers")
@export var modifiers: Array[ModifierData] = []

func get_modified_value() -> int:
	if type != Type.INTEGER:
		return 0
	
	var final_value = value
	
	for modifier in modifiers:
		if modifier.type == ModifierData.Type.ADD_VALUE:
			final_value += modifier.value
	
	for modifier in modifiers:
		if modifier.type == ModifierData.Type.MULTIPLY_VALUE:
			final_value *= modifier.value

	return final_value

func add_modifier(modifier: ModifierData):
	modifiers.append(modifier)
	
