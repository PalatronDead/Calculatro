class_name Enemy extends Node2D

@export var damage_value: int = 5

@export var max_hp: int = 100
var current_hp: int

@onready var hp_label = $HPLabel

signal died


func _ready():
	current_hp = max_hp
	update_ui()

func take_damage(amount: int):
	current_hp -= amount
	update_ui()
	
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if current_hp <= 0:
		die()

func attack() -> int:
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x + 10, 0.1)
	tween.tween_property(self, "position:x", position.x - 10, 0.1)
	tween.tween_property(self, "position:x", position.x, 0.1)
	
	return damage_value

func update_ui():
	hp_label.text = str(current_hp) + " / " + str(max_hp)

func die():
	died.emit()
	queue_free()
