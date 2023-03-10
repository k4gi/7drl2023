extends Node2D


const CHARACTER = preload("res://Character.tscn")
const ENEMY = preload("res://Enemy.tscn")
const ITEM = preload("res://Item.tscn")
const INVENTORY_PANEL = preload("res://InventoryPanel.tscn")
const FINAL_MAP = preload("res://FinalMap.tscn")


var pathfinding

var Character = null

var random = RandomNumberGenerator.new()

var current_level = 1


func _ready():
	pass


func start_new_game():
	reset_game()
	
	setup_stats()
	
	$Map.cellular_automata_generation()
	
	random.randomize()
	
	setup_pathfinding()
	
	#spawning entities goes in the middle here
	setup_entities()


func start_new_level():
	reset_entities()
	
	if current_level < 4:
		$Map.cellular_automata_generation()
		
		setup_pathfinding()
		
		setup_entities()
	else:
		var final_map = FINAL_MAP.instantiate()
		
		for each_cell_coords in $Map.get_used_cells(0):
			var atlas_coords = final_map.get_cell_atlas_coords(0, each_cell_coords)
			$Map.set_cell(0, each_cell_coords, 0, atlas_coords)
		
		spawn_character( $Map.local_to_map( final_map.get_node("CharacterPos").get_position() ) )
		spawn_item( $Map.local_to_map( final_map.get_node("TreasurePos").get_position() ), "ring" )
		spawn_item( $Map.local_to_map( final_map.get_node("StairsPos").get_position() ), "final_stair" )
		
		final_map.queue_free()


func setup_pathfinding():
	pathfinding = AStarGrid2D.new()
	pathfinding.set_size( $Map.SIZE )
	pathfinding.update()
	for each_grid_pos in $Map.get_used_cells(0):
		if $Map.is_wall_at_grid( each_grid_pos ):
			pathfinding.set_point_solid( each_grid_pos, true )


func setup_entities():
	var empty_map_squares = $Map.get_used_cells_by_id(0, 0, $Map.EMPTY_SPACE)
	var random_square = random.randi() % empty_map_squares.size()
	
	var character_position = empty_map_squares[random_square]
	spawn_character(character_position)
	empty_map_squares.remove_at(random_square)
	
	#enemies should be at least . . . TEN squares away from the Character
	remove_squares_close_to(empty_map_squares, character_position)
	
	#one staircase
	random_square = random.randi() % empty_map_squares.size()
	spawn_item(empty_map_squares[random_square], "stair")
	empty_map_squares.remove_at(random_square)
	
	#different enemy spawning on each of three levels...
	print( empty_map_squares.size() )
	match current_level:
		1:
			var number_of_rats = randi() % ( empty_map_squares.size() / 100 ) + 5
			spawn_many_enemies(empty_map_squares, random, "rat", number_of_rats)
			var number_of_zombies = randi() % ( empty_map_squares.size() / 100 ) + 6
			spawn_many_enemies(empty_map_squares, random, "zombie", number_of_zombies)
		2:
			var number_of_rats = randi() % ( empty_map_squares.size() / 100 ) + 4
			spawn_many_enemies(empty_map_squares, random, "rat", number_of_rats)
			var number_of_zombies = randi() % ( empty_map_squares.size() / 100 ) + 5
			spawn_many_enemies(empty_map_squares, random, "zombie", number_of_zombies)
			var number_of_frogs = randi() % (empty_map_squares.size() / 100 ) + 4
			spawn_many_enemies(empty_map_squares, random, "frog", number_of_frogs)
		3:
			var number_of_rats = randi() % ( empty_map_squares.size() / 100 ) + 6
			spawn_many_enemies(empty_map_squares, random, "rat", number_of_rats)
			var number_of_zombies = randi() % ( empty_map_squares.size() / 100 ) + 6
			spawn_many_enemies(empty_map_squares, random, "zombie", number_of_zombies)
			var number_of_frogs = randi() % (empty_map_squares.size() / 100 ) + 8
			spawn_many_enemies(empty_map_squares, random, "frog", number_of_frogs)
	
	#ten coins * current level??
	for ten_times in range(0,current_level*10):
		random_square = random.randi() % empty_map_squares.size()
		spawn_item(empty_map_squares[random_square], "money")
		empty_map_squares.remove_at(random_square)
	
	#different item spawning too
	match current_level:
		1:
			#two knives
			random_square = random.randi() % empty_map_squares.size()
			spawn_item(empty_map_squares[random_square], "knife")
			empty_map_squares.remove_at(random_square)
			random_square = random.randi() % empty_map_squares.size()
			spawn_item(empty_map_squares[random_square], "knife")
			empty_map_squares.remove_at(random_square)
		2:
			#one knife, one sword
			random_square = random.randi() % empty_map_squares.size()
			spawn_item(empty_map_squares[random_square], "knife")
			empty_map_squares.remove_at(random_square)
			random_square = random.randi() % empty_map_squares.size()
			spawn_item(empty_map_squares[random_square], "sword")
			empty_map_squares.remove_at(random_square)
		3:
			#two swords
			random_square = random.randi() % empty_map_squares.size()
			spawn_item(empty_map_squares[random_square], "sword")
			empty_map_squares.remove_at(random_square)
			random_square = random.randi() % empty_map_squares.size()
			spawn_item(empty_map_squares[random_square], "sword")
			empty_map_squares.remove_at(random_square)


func remove_squares_close_to(map_squares, grid_pos, distance:=10):
	var squares_to_be_removed = []
	for each_square in map_squares:
		if abs( each_square.x - grid_pos.x ) < distance and \
			abs( each_square.y - grid_pos.y ) < distance:
				squares_to_be_removed.append( each_square )
	for each_square in squares_to_be_removed:
		map_squares.erase(each_square)


func spawn_character(grid_pos):
	var new_character = CHARACTER.instantiate()
	new_character.set_position( $Map.map_to_local( grid_pos ) )
	new_character.attempt_move_to.connect(_on_character_attempt_move_to)
	new_character.attempt_action_at.connect(_on_character_attempt_action_at)
	new_character.open_inventory.connect(_on_character_open_inventory)
	Character = new_character
	%Entities.add_child(new_character)


func spawn_many_enemies(map_squares, random_generator, enemy_id, number_of_enemies):
	for each_time in range(0,number_of_enemies):
		var random_square  = random_generator.randi() % map_squares.size()
		spawn_enemy(map_squares[random_square], enemy_id)
		map_squares.remove_at(random_square)


func spawn_enemy(grid_pos, id:="zombie"):
	var new_enemy = ENEMY.instantiate()
	new_enemy.set_position( $Map.map_to_local( grid_pos ) )
	new_enemy.set_enemy_id(id)
	
	pathfinding.set_point_solid( grid_pos, true )
	
	%Enemies.add_child(new_enemy)


func spawn_item(grid_pos, id):
	var new_item = ITEM.instantiate()
	new_item.set_position( $Map.map_to_local( grid_pos ) )
	new_item.set_item_id(id)
	
	%Items.add_child(new_item)


func setup_stats():
	State.character_stats = Data.CHARACTER_LIST["default"].duplicate()
	State.character_equip = {"weapon": null, "armour": null}
	current_level = 1
	refresh_state()


func reset_game():
	reset_entities()
	
	State.character_stats = {}
	State.character_inventory = {}
	
	for each_child in %Messages.get_children():
		%Messages.remove_child(each_child)
		each_child.queue_free()


func reset_entities():
	for each_item in %Items.get_children():
		%Items.remove_child(each_item)
		each_item.queue_free()
	for each_enemy in %Enemies.get_children():
		%Enemies.remove_child(each_enemy)
		each_enemy.queue_free()
	if Character != null:
		%Entities.remove_child(Character)
		Character.queue_free()
		Character = null


func spawn_enemy_during_game():
	var empty_map_squares = $Map.get_used_cells_by_id(0, 0, $Map.EMPTY_SPACE)
	var character_position = $Map.local_to_map( Character.get_position() )
	remove_squares_close_to(empty_map_squares, character_position)
	
	var random_square = random.randi() % empty_map_squares.size()
	
	if randi() % 10 < 5:
		spawn_enemy( empty_map_squares[random_square], "rat" )
	else:
		spawn_enemy( empty_map_squares[random_square], "zombie" )


func _on_character_attempt_move_to(pos):
	var has_moved = false
	
	#character might not be standing on anything
	#Character.set_colour_normal()
	
	#any recent messages are old now
	for each_message in %Messages.get_children():
		each_message.set_modulate(Color(0.7,0.7,0.7))
	
	if not has_moved:
		#ask enemies and such if they're here already
		for each_enemy in %Enemies.get_children():
			if each_enemy.get_position() == pos:
				add_message("You attack %s for %d damage!" % [each_enemy.enemy_stats["name"], State.character_stats["attack"]])
				each_enemy.enemy_stats["hp"] -= State.character_stats["attack"]
				if each_enemy.enemy_stats["hp"] <= 0:
					add_message("You have killed the %s!" % each_enemy.enemy_stats["name"])
					%Enemies.remove_child(each_enemy)
					each_enemy.queue_free()
					spawn_enemy_during_game()
				has_moved = true
				break
	
	if not has_moved:
	#then ask the map if there's a wall
		if not $Map.is_wall_at(pos):
			Character.move_to(pos)
			#check if there's an item at this position
			for each_item in %Items.get_children():
				if each_item.get_position() == pos:
#					Character.set_colour_invert()
					add_message("You see %s here" % Data.ITEM_LIST[each_item.item_id]["name"])
			has_moved = true
	
	#end turn
	enemy_movement()
	refresh_state()
	if Character != null:
		Character.set("is_active", true)


func enemy_movement():
	#if i want enemies to move in more than one way i should give each of them their own movement function
	for each_enemy in %Enemies.get_children():
		pathfinding.set_point_solid( $Map.local_to_map( each_enemy.get_position() ), false )
		var path_to_character = pathfinding.get_id_path( $Map.local_to_map( each_enemy.get_position() ), $Map.local_to_map( Character.get_position() ) )
		
		#activating enemies within range
		if not each_enemy.get("is_active"):
			if path_to_character.size() >= 2 and path_to_character.size() < each_enemy.enemy_stats["notice_range"]:
				each_enemy.set("is_active", true)
		
		#moving and attacking
		if each_enemy.get("is_active"):
			if path_to_character.size() > 2: #far enough away to move toward character
				if each_enemy.current_move_delay > 0:
					each_enemy.current_move_delay -= 1
				else: #it's time to move
					each_enemy.current_move_delay = each_enemy.enemy_stats["move_delay"]
					each_enemy.current_move_range = each_enemy.enemy_stats["move_range"]
					
					
					if each_enemy.current_move_range > path_to_character.size() - 2:
						each_enemy.set_position( $Map.map_to_local( path_to_character[-2] ) )
						each_enemy.current_move_range -= path_to_character.size() - 2
					else:
						each_enemy.set_position( $Map.map_to_local( path_to_character[each_enemy.current_move_range] ) )
						each_enemy.current_move_range = 0
					#moving is happening, so we can see if we need to change colour
#					each_enemy.set_colour_normal()
#					for each_item in %Items.get_children():
#						if each_item.get_position() == each_enemy.get_position():
#							each_enemy.set_colour_invert()
#							break
			
			if path_to_character.size() == 2 or each_enemy.current_move_range > 0: #adjacent to character, attacking time
				add_message("%s strikes you for %d damage!" % [each_enemy.enemy_stats["name"], each_enemy.enemy_stats["attack"]])
				State.character_stats["hp"] -= Data.ENEMY_LIST[each_enemy.enemy_id]["attack"]
				if State.character_stats["hp"] <= 0:
					add_message("You have been killed by %s :(" % each_enemy.enemy_stats["name"])
					add_message("You made it to Level %d" % current_level)
					add_message("You perish clutching %d worth in treasure" % get_inventory_value())
					delete_character()
					return
		pathfinding.set_point_solid( $Map.local_to_map( each_enemy.get_position() ), true )


func delete_character():
	%Entities.remove_child(Character)
	Character.queue_free()
	Character = null

func add_message(message: String):
	var new_label = Label.new()
	new_label.set_text(message)
	%Messages.add_child(new_label)
	%Messages.move_child(new_label, 0)
	%MessageScroll.set_v_scroll(0)


func refresh_state():
	for each_key in State.character_stats.keys():
		%VBoxState.find_child(each_key).set_text( str(State.character_stats[each_key]))


func _on_character_attempt_action_at(pos):
	#any recent messages are old now
	for each_message in %Messages.get_children():
		each_message.set_modulate(Color(0.7,0.7,0.7))
	
	for each_item in %Items.get_children():
		if each_item.get_position() == pos:
			#how to deal with more than one item?
			if Data.ITEM_LIST[each_item.item_id]["interact"]:
				#interact instead of pickup
				interact_with( each_item )
			else:
				pick_up( each_item )
	
	#end turn
	enemy_movement()
	refresh_state()
	if Character != null:
		Character.is_active = true


func interact_with( item: Object ):
	match item.item_id:
		"stair":
			current_level += 1
			add_message("You descend the staircase to Level %d . . ." % current_level)
			start_new_level()
		"final_stair":
			add_message("You have finished the game :D")
			add_message("You return with %d worth in treasure" % get_inventory_value())
			delete_character()
			return


func get_inventory_value() -> int:
	var value = 0
	
	for each_key in State.character_inventory.keys():
		value += State.character_inventory[each_key] * Data.ITEM_LIST[each_key]["value"]
	
	return value


func pick_up( item: Object ):
	add_message("You pick up the %s" % Data.ITEM_LIST[item.item_id]["name"])
	if not State.character_inventory.has(item.item_id):
		State.character_inventory[item.item_id] = 1
	else:
		State.character_inventory[item.item_id] += 1
	%Items.remove_child(item)
	item.queue_free()


func open_inventory():
	if State.character_inventory.size() > 0:
		var new_inventory = INVENTORY_PANEL.instantiate()
		new_inventory.update_equipment.connect(_on_inventory_panel_update_equipment)
		new_inventory.finalise()
		%Popups.add_child(new_inventory)
		get_tree().set_pause(true)


func _on_inventory_panel_update_equipment(new_item_id):
	var slot_change = Data.ITEM_LIST[new_item_id]["equip"]
	
	if State.character_equip[slot_change] != null:
		for each_stat in Data.ITEM_LIST[ State.character_equip[slot_change] ]["effect"].keys():
			State.character_stats[each_stat] -= Data.ITEM_LIST[ State.character_equip[slot_change] ]["effect"][each_stat]
	
	State.character_equip[slot_change] = new_item_id
	for each_stat in Data.ITEM_LIST[ new_item_id ]["effect"].keys():
		State.character_stats[each_stat] += Data.ITEM_LIST[ new_item_id ]["effect"][each_stat]
	
	add_message("You start using your %s" % Data.ITEM_LIST[new_item_id]["name"])
	refresh_state()


func _on_new_game_button_pressed():
	start_new_game()


func _on_inventory_button_pressed():
	open_inventory()


func _on_character_open_inventory():
	open_inventory()


func _on_1x_button_pressed():
	var viewport_width = ProjectSettings.get("display/window/size/viewport_width")
	var viewport_height = ProjectSettings.get("display/window/size/viewport_height")
	
	get_window().set_size( Vector2i( viewport_width, viewport_height ) )


func _on_2x_button_pressed():
	var viewport_width = ProjectSettings.get("display/window/size/viewport_width")
	var viewport_height = ProjectSettings.get("display/window/size/viewport_height")
	
	get_window().set_size( Vector2i( viewport_width*2, viewport_height*2 ) )


func _on_3x_button_pressed():
	var viewport_width = ProjectSettings.get("display/window/size/viewport_width")
	var viewport_height = ProjectSettings.get("display/window/size/viewport_height")
	
	get_window().set_size( Vector2i( viewport_width*3, viewport_height*3 ) )
