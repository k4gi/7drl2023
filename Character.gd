extends Control


signal attempt_move_to(pos: Vector2)


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


func move_to(pos: Vector2):
	set_position(pos)
