class_name ShopItemDisplay extends Button

@onready var description_label = $DescriptionLabel
@onready var title_label = $TitleLabel
@onready var cost_label = $CostLabel

signal shop_item_selected(data: PassiveItemData)

var data: PassiveItemData

func setup(new_data: PassiveItemData):
	data = new_data
	update_visuals()
	
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	
	scale = Vector2.ONE		
	animate_pop()

func _on_pressed():
	shop_item_selected.emit(data)
	print(" SHOP ITEM SELECTED:", data.name)
	
func update_visuals():
	description_label.text = data.description
	title_label.text = data.name
	cost_label.text = "$" + str(data.cost)

func animate_pop():
	scale = Vector2(0.2, 0.2)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1,1), 0.5)
