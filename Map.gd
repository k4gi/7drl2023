extends TileMap


#size of dungeon
const SIZE = Vector2i(80,24)

#character atlas co-ordinates
const VERTICAL_BAR = Vector2i(8,2)
const HYPHEN = Vector2i(13,0)
const FORWARD_SLASH = Vector2i(15,0)
const BACK_SLASH = Vector2i(18,1)
const HASH = Vector2i(3,0)
const SOLID_SQUARE = Vector2i(7,15)
const LIGHT_GRID = Vector2i(8,15)
const HEAVY_GRID = Vector2i(9,15)
const HOLLOW_SQUARE = Vector2i(11,15)
const EMPTY_SPACE = Vector2i(0,0)

#which of these tiles are walls?
const WALLS = [VERTICAL_BAR, HYPHEN, FORWARD_SLASH, BACK_SLASH, SOLID_SQUARE]


func is_wall_at(pos: Vector2):
	var grid_pos = local_to_map(pos)
	return WALLS.has( get_cell_atlas_coords(0, grid_pos) )


func is_wall_at_grid(grid_pos: Vector2i):
	return WALLS.has( get_cell_atlas_coords(0, grid_pos) )


func cellular_automata_generation():
	var random = RandomNumberGenerator.new()
	random.randomize()
	
	var generations = []
	var current_generation = 0
	
	generations.append( [] )
	
	#first step, build an array
	for x in SIZE.x:
		generations[current_generation].append( [] )
		for y in SIZE.y:
			if random.randi() % 100 < 50: 
				generations[current_generation][x].append( EMPTY_SPACE )
			else:
				generations[current_generation][x].append( SOLID_SQUARE )
	
	#second step, smoothing
	var smoothing_steps = 2
	
	while smoothing_steps > 0:
		generations.append( [] )
		current_generation += 1
		
		for x in SIZE.x:
			generations[current_generation].append( [] )
			for y in SIZE.y:
				var number_of_walls = 0
				#look at the 3x3 area around x,y
				for x_range in range(x-1, x+2):
					for y_range in range(y-1, y+2):
						if x_range < 0 or x_range >= SIZE.x or y_range < 0 or y_range >= SIZE.y or \
							WALLS.has( generations[current_generation-1][x_range][y_range] ):
								number_of_walls += 1
				if number_of_walls >= 5:
					generations[current_generation][x].append( SOLID_SQUARE )
				else:
					generations[current_generation][x].append( EMPTY_SPACE )
		smoothing_steps -= 1
	
	#third step, flooding a cave and filling in the rest
	var flood_squares = [Vector2i(SIZE.x/2, SIZE.y/2)]
	append_neighbours_to_flood( flood_squares, generations[current_generation] )
	print(flood_squares)
	
	#fourth step, checking the cave is big enough
	var grid_size = SIZE.x * SIZE.y
	print(grid_size)
	print(flood_squares.size())
	if grid_size - flood_squares.size() < grid_size/3:
		#not a big enough dungeon, try again
		#cellular_automata_generation()
		pass
	
	#fifth step, assemble final grid
	generations.append( [] )
	current_generation += 1
	for x in SIZE.x:
		generations[current_generation].append( [] )
		for y in SIZE.y:
			if flood_squares.has( Vector2i(x,y) ):
				generations[current_generation][x].append( EMPTY_SPACE )
			else:
				generations[current_generation][x].append( SOLID_SQUARE )
	
	#final step, export to the TileMap
	for x in SIZE.x:
		for y in SIZE.y:
			set_cell(0,  Vector2i(x,y), 0, generations[current_generation][x][y] )


func append_neighbours_to_flood(flood, map_grid):
	print("new recursion")
	var new_flood = []
	
	for each_flood_square in flood:
		for x_range in range( each_flood_square.x-1, each_flood_square.x+2 ):
			for y_range in range( each_flood_square.y-1, each_flood_square.y+2 ):
				if x_range < 0 or x_range >= SIZE.x or y_range < 0 or y_range >= SIZE.y:
					continue
				var new_square = Vector2i(x_range, y_range)
				if not flood.has( new_square ) and not new_flood.has( new_square ) and map_grid[x_range][y_range] == EMPTY_SPACE:
					new_flood.append(new_square)
	
	print(new_flood)
	if new_flood.size() > 0:
		append_neighbours_to_flood( new_flood, map_grid )
		flood.append_array( new_flood )
	


