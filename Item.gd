extends Control


var item_id = "money"

func set_item_id(id: String):
	item_id = id
	$Label.set_text( Data.ITEM_LIST[item_id]["char"] )
