extends ColorRect


signal attempt_move_to(pos: Vector2)


func _unhandled_input(event):
	if event.is_action_pressed("move_up"):
		emit_signal( "attempt_move_to", get_position() + Vector2(0,-6) )
	if event.is_action_pressed("move_down"):
		emit_signal( "attempt_move_to", get_position() + Vector2(0,6) )
	if event.is_action_pressed("move_left"):
		emit_signal( "attempt_move_to", get_position() + Vector2(-6,0) )
	if event.is_action_pressed("move_right"):
		emit_signal( "attempt_move_to", get_position() + Vector2(6,0) )


func move_to(pos: Vector2):
	set_position(pos)
