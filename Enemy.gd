extends Control


const FOREGROUND_COLOUR = Color.WHITE
const BACKGROUND_COLOUR = Color.BLACK


var is_active = true
var enemy_id = "zombie"

var enemy_stats = {}


func set_colour_normal():
	$ColorRect.set_color(BACKGROUND_COLOUR)
	$Label.set_modulate(FOREGROUND_COLOUR)


func set_colour_invert():
	$ColorRect.set_color(FOREGROUND_COLOUR)
	$Label.set_modulate(BACKGROUND_COLOUR)


