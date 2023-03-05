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
			if randi() % 100 < 50: 
				generations[current_generation][x].append( Vector2i.ZERO )
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
					generations[current_generation][x].append( Vector2i.ZERO )
		smoothing_steps -= 1
	
	#third step, flooding a cave and filling in the rest
	#fourth step, checking the cave is big enough
	#can both of these be done at once
	
	#final step, export to the TileMap
	for x in SIZE.x:
		for y in SIZE.y:
			set_cell(0,  Vector2i(x,y), 0, generations[current_generation][x][y] )
