extends Node2D


const CHARACTER = preload("res://Character.tscn")
const ENEMY = preload("res://Enemy.tscn")
const ITEM = preload("res://Item.tscn")


var pathfinding

var Character = null

var random = RandomNumberGenerator.new()


func _ready():
	pass


func start_new_game():
	reset_game()
	
	$Map.cellular_automata_generation()
	
	random.randomize()
	
	setup_pathfinding()
	
	#spawning entities goes in the middle here
	setup_entities()
	
	#finalize world with numbers
	setup_stats()


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
	
	#to start with we will spawn . . . FIVE enemies
	for five_times in range(0,5):
		random_square  = random.randi() % empty_map_squares.size()
		spawn_enemy(empty_map_squares[random_square])
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
	Character = new_character
	%Entities.add_child(new_character)


func spawn_enemy(grid_pos, id:="zombie"):
	var new_enemy = ENEMY.instantiate()
	new_enemy.set_position( $Map.map_to_local( grid_pos ) )
	new_enemy.set_enemy_id(id)
	
	%Enemies.add_child(new_enemy)


func setup_stats():
	State.character_stats = Data.CHARACTER_LIST["default"].duplicate()
	refresh_state()


func reset_game():
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
	
	State.character_stats = {}
	State.character_inventory = {}


func spawn_enemy_during_game():
	var empty_map_squares = $Map.get_used_cells_by_id(0, 0, $Map.EMPTY_SPACE)
	var character_position = $Map.local_to_map( Character.get_position() )
	remove_squares_close_to(empty_map_squares, character_position)
	
	var random_square = random.randi() % empty_map_squares.size()
	
	spawn_enemy( empty_map_squares[random_square] )


func _on_character_attempt_move_to(pos):
	var has_moved = false
	
	#character might not be standing on anything
	Character.set_colour_normal()
	
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
					Character.set_colour_invert()
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
		if each_enemy.get("is_active"):
			var path_to_character = pathfinding.get_id_path( $Map.local_to_map( each_enemy.get_position() ), $Map.local_to_map( Character.get_position() ) )
			if path_to_character.size() > 2: #far enough away to move toward character
				each_enemy.set_position( $Map.map_to_local( path_to_character[1] ) )
				#moving is happening, so we can see if we need to change colour
				each_enemy.set_colour_normal()
				for each_item in %Items.get_children():
					if each_item.get_position() == each_enemy.get_position():
						each_enemy.set_colour_invert()
						break
			elif path_to_character.size() == 2: #adjacent to character, attacking time
				add_message("%s strikes you for %d damage!" % [each_enemy.enemy_stats["name"], each_enemy.enemy_stats["attack"]])
				State.character_stats["hp"] -= Data.ENEMY_LIST[each_enemy.enemy_id]["attack"]
				if State.character_stats["hp"] <= 0:
					add_message("You have been killed by %s :(" % each_enemy.enemy_stats["name"])
					%Entities.remove_child(Character)
					Character.queue_free()
					Character = null
					return


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
			add_message("You pick up the %s" % Data.ITEM_LIST[each_item.item_id]["name"])
			if not State.character_inventory.has(each_item.item_id):
				State.character_inventory[each_item.item_id] = 1
			else:
				State.character_inventory[each_item.item_id] += 1
			%Items.remove_child(each_item)
			each_item.queue_free()
	
	#end turn
	enemy_movement()
	refresh_state()
	if Character != null:
		Character.is_active = true


func _on_new_game_button_pressed():
	start_new_game()


func _on_inventory_button_pressed():
	pass # Replace with function body.


func _on_help_button_pressed():
	pass # Replace with function body.
