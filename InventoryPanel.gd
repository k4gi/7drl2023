extends PanelContainer


const INVENTORY_ENTRY = preload("res://InventoryEntry.tscn")
const STYLE_BOX_BLACK = preload("res://StyleBoxBlack.tres")
const STYLE_BOX_WHITE = preload("res://StyleBoxWhite.tres")


var border_height = 0
var border_width = 0

var current_selection = 1


func _unhandled_input(event):
	if event.is_action_pressed("move_up"):
		current_selection -= 1
		if current_selection < 1:
			current_selection = border_height
		select_item(current_selection)
	elif event.is_action_pressed("move_down"):
		current_selection += 1
		if current_selection > border_height:
			current_selection = 1
		select_item(current_selection)
	elif event.is_action_pressed("move_action"):
		pass


func add_item(item_name: String):
	var new_entry = INVENTORY_ENTRY.instantiate()
	new_entry.set_text(item_name)
	
	border_height += 1
	if item_name.length() > border_width:
		border_width = item_name.length()
	
	$BorderText/HBox/VBoxEntries.add_child(new_entry)


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


func select_item(entry_number):
	for items in range(1, $BorderText/HBox/VBoxEntries.get_child_count()):
		var current_entry = $BorderText/HBox/VBoxEntries.get_child(items)
		if items == entry_number:
			current_entry.set("theme_override_colors/font_color", Color.BLACK)
			current_entry.set("theme_override_styles/normal", STYLE_BOX_WHITE)
		else:
			current_entry.set("theme_override_colors/font_color", Color.WHITE)
			current_entry.set("theme_override_styles/normal", STYLE_BOX_BLACK)

