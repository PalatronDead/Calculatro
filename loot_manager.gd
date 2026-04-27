extends Node


func manage_loot(loot_table: LootTable) -> LootItem:
	var total_weight: int = 0
	for loot_item in loot_table.loot_items:
		total_weight += loot_item.weight
	var loot_number = randi_range(1, total_weight)
	for loot_item in loot_table.loot_items:
		loot_number -= loot_item.weight
		if(loot_number <= 0):
			return loot_item
	return

func get_shop_items(shop_loot_table: ShopLootTable, amount: int = 3) -> Array[PassiveItemData]:
	var shop_items: Array[PassiveItemData] = []
	
	var available_shop_items: Array[ShopLootItem] = shop_loot_table.shop_loot_items.duplicate()
	
	for i in range(amount):
		var total_weight: int = 0
		for item in available_shop_items:
			total_weight += item.weight
			
		var loot_number = randi_range(1, total_weight)
		var selected_shop_item: ShopLootItem = null
		
		for item in available_shop_items:
			loot_number -= item.weight
			if loot_number <= 0:
				selected_shop_item = item
				break
				
		if selected_shop_item:	
			shop_items.append(selected_shop_item.shop_item)
			available_shop_items.erase(selected_shop_item)

	return shop_items
