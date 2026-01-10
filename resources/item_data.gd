class_name ItemData extends Resource

enum Type {INTEGER, OPERATOR}

@export_group("Identity")
@export var type: Type
@export var display_name: String = ""
@export var icon: Texture2D

@export_group("Values")
@export var value: int = 0
@export var operator_symbol: String = ""
