extends Node2D


func _on_character_attempt_move_to(pos):
	#ask enemies and such if they're here already
	#then ask the map if there's a wall
	if not $Map.is_wall_at(pos):
		$Character.move_to(pos)
