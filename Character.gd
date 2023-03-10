extends Control


signal attempt_move_to(pos: Vector2)
signal attempt_action_at(pos: Vector2)
signal open_inventory()


const FOREGROUND_COLOUR = Color.WHITE
const BACKGROUND_COLOUR = Color.BLACK


var is_active = true


func _unhandled_input(event):
	if is_active:
		if event.is_action_pressed("move_up"):
			is_active = false
			emit_signal( "attempt_move_to", get_position() + Vector2(0,-6) )
		elif event.is_action_pressed("move_down"):
			is_active = false
			emit_signal( "attempt_move_to", get_position() + Vector2(0,6) )
		elif event.is_action_pressed("move_left"):
			is_active = false
			emit_signal( "attempt_move_to", get_position() + Vector2(-6,0) )
		elif event.is_action_pressed("move_right"):
			is_active = false
			emit_signal( "attempt_move_to", get_position() + Vector2(6,0) )
		elif event.is_action_pressed("move_up_left"):
			is_active = false
			emit_signal( "attempt_move_to", get_position() + Vector2(-6,-6) )
		elif event.is_action_pressed("move_up_right"):
			is_active = false
			emit_signal( "attempt_move_to", get_position() + Vector2(6,-6) )
		elif event.is_action_pressed("move_down_left"):
			is_active = false
			emit_signal( "attempt_move_to", get_position() + Vector2(-6,6) )
		elif event.is_action_pressed("move_down_right"):
			is_active = false
			emit_signal( "attempt_move_to", get_position() + Vector2(6,6) )
		elif event.is_action_pressed("move_wait"):
			is_active = false
			emit_signal( "attempt_move_to", get_position() )
		elif event.is_action_pressed("move_action"):
			is_active = false
			emit_signal( "attempt_action_at", get_position() )
		
		elif event.is_action_pressed("move_inventory"):
			emit_signal( "open_inventory" )


func move_to(pos: Vector2):
	set_position(pos)


func set_colour_normal():
	$ColorRect.set_color(BACKGROUND_COLOUR)
	$Label.set_modulate(FOREGROUND_COLOUR)


func set_colour_invert():
	$ColorRect.set_color(FOREGROUND_COLOUR)
	$Label.set_modulate(BACKGROUND_COLOUR)
