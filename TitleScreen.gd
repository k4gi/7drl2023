extends Node2D


var pathfinding


func _ready():
	pathfinding = AStarGrid2D.new()
	pathfinding.set_size( Vector2i(80,24) )
	#pathfinding.set_cell_size( Vector2(6,6) )
	pathfinding.update()
	
	for each_grid_pos in $Map.get_used_cells(0):
		if $Map.is_wall_at_grid( each_grid_pos ):
			pathfinding.set_point_solid( each_grid_pos, true )


func _on_character_attempt_move_to(pos):
	#ask enemies and such if they're here already
	for each_enemy in $Enemies.get_children():
		if each_enemy.get_position() == pos:
			#attack this enemy
			pass
	
	#then ask the map if there's a wall
	if not $Map.is_wall_at(pos):
		$Character.move_to(pos)
		#check if there's an item at this position
		for each_item in $Items.get_children():
			if each_item.get_position() == pos:
				add_message("You see %s here" % Data.item_list[each_item.item_id]["name"])
	enemy_movement()
	$Character.set("is_active", true)


func enemy_movement():
	for each_enemy in $Enemies.get_children():
		if each_enemy.get("is_active"):
			var path_to_character = pathfinding.get_id_path( $Map.local_to_map( each_enemy.get_position() ), $Map.local_to_map( $Character.get_position() ) )
			if path_to_character.size() > 2:
				each_enemy.set_position( $Map.map_to_local( path_to_character[1] ) )


func add_message(message: String):
	var new_label = Label.new()
	new_label.set_text(message)
	$Scroll/VBox.add_child(new_label)
	$Scroll/VBox.move_child(new_label, 0)
	$Scroll.set_v_scroll(0)
