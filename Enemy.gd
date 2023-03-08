extends Control


const FOREGROUND_COLOUR = Color.WHITE
const BACKGROUND_COLOUR = Color.BLACK


var is_active = false

var enemy_id = "zombie"

var current_move_delay = 0

var enemy_stats = {}


func set_enemy_id(id: String):
	enemy_id = id
	enemy_stats = Data.ENEMY_LIST[enemy_id].duplicate()
	$Label.set_text( enemy_stats["char"] )


func set_colour_normal():
	$ColorRect.set_color(BACKGROUND_COLOUR)
	$Label.set_modulate(FOREGROUND_COLOUR)


func set_colour_invert():
	$ColorRect.set_color(FOREGROUND_COLOUR)
	$Label.set_modulate(BACKGROUND_COLOUR)


