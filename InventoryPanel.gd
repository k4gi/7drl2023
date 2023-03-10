extends PanelContainer


signal update_equipment(new_item_id)


const INVENTORY_ENTRY = preload("res://InventoryEntry.tscn")
const STYLE_BOX_BLACK = preload("res://StyleBoxBlack.tres")
const STYLE_BOX_WHITE = preload("res://StyleBoxWhite.tres")


var border_height = 0
var border_width = 0

var current_selection = 1

var equipment_updated = null


func _unhandled_input(event):
	get_window().set_input_as_handled()
	if event.is_action_pressed("move_up"):
		current_selection -= 1
		if current_selection < 1:
			current_selection = border_height
		select_item()
	elif event.is_action_pressed("move_down"):
		current_selection += 1
		if current_selection > border_height:
			current_selection = 1
		select_item()
	elif event.is_action_pressed("move_action"):
		var selected_item_id = $BorderText/HBox/VBoxEntries.get_child(current_selection).get("item_id")
		if Data.ITEM_LIST[selected_item_id]["equip"] != null:
			if State.character_equip[ Data.ITEM_LIST[selected_item_id]["equip"] ] != selected_item_id:
				equipment_updated = selected_item_id
		close_inventory()
	elif event.is_action_pressed("move_inventory"):
		close_inventory()


func close_inventory():
	get_tree().set_pause(false)
	if equipment_updated != null:
		emit_signal("update_equipment", equipment_updated)
	get_parent().remove_child(self)
	queue_free()


func add_all_items():
	for each_item_id in State.character_inventory.keys():
		add_item( each_item_id )

func add_item(item_id: String):
	var new_entry = INVENTORY_ENTRY.instantiate()
	
	var new_entry_text = "%d %s" % [State.character_inventory[item_id], Data.ITEM_LIST[item_id]["name"]] 
	
	if Data.ITEM_LIST[item_id]["equip"] != null:
		if State.character_equip[ Data.ITEM_LIST[item_id]["equip"] ] == item_id:
			new_entry_text += " (equipped)"
		else:
			new_entry_text += " (can equip)"
	
	new_entry.set_text( new_entry_text )
	new_entry.set("item_id", item_id)

	border_height += 1
	if new_entry_text.length() > border_width:
		border_width = new_entry_text.length()
	
	$BorderText/HBox/VBoxEntries.add_child(new_entry)


func finalise():
	add_all_items()
	set_border()
	select_item()


func set_border():
	var border_text := "/"
	
	for x in border_width:
		border_text += "-"
	
	border_text += "\\"
	
	for y in border_height:
		border_text += "\n|"
		for x in border_width:
			border_text += " "
		border_text += "|"
	
	border_text += "\n\\"
	
	for x in border_width:
		border_text += "-"
	
	border_text += "/"
	
	$BorderText.set_text( border_text )


func select_item():
	for items in range(1, $BorderText/HBox/VBoxEntries.get_child_count()):
		var current_entry = $BorderText/HBox/VBoxEntries.get_child(items)
		if items == current_selection:
			current_entry.set("theme_override_colors/font_color", Color.BLACK)
			current_entry.set("theme_override_styles/normal", STYLE_BOX_WHITE)
		else:
			current_entry.set("theme_override_colors/font_color", Color.WHITE)
			current_entry.set("theme_override_styles/normal", STYLE_BOX_BLACK)

