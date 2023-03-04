extends TileMap


#character atlas co-ordinates
const VERTICAL_BAR = Vector2i(8,2)
const HYPHEN = Vector2i(13,0)
const FORWARD_SLASH = Vector2i(15,0)
const BACK_SLASH = Vector2i(18,1)


const WALLS = [VERTICAL_BAR, HYPHEN]


func is_wall_at(pos: Vector2):
	var grid_pos = local_to_map(pos)
	return WALLS.has( get_cell_atlas_coords(0, grid_pos) )


func is_wall_at_grid(grid_pos: Vector2i):
	return WALLS.has( get_cell_atlas_coords(0, grid_pos) )
