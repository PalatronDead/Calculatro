class_name ItemDisplay extends Button

signal item_selected(data: ItemData)

var data: ItemData

func setup(new_data: ItemData):
	data = new_data
	update_visuals()
	
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	
	await get_tree().process_frame
	scale = Vector2.ONE		
	animate_pop()

func _on_pressed():
	item_selected.emit(data)
	print("ITEM SELECTED:", data.display_name)
	
func update_visuals():
	if data.type == ItemData.Type.INTEGER:
		$Label.text = str(data.get_modified_value())
	else:
		$Label.text = data.display_name

func animate_pop():
	scale = Vector2(0.2, 0.2)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1,1), 0.5)
