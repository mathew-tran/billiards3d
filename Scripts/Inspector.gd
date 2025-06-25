extends Node3D

func _process(delta: float) -> void:
	look_at(Finder.GetMainBall().global_position)
	#rotation.x = 0
	$blockbench_export/Camera3D.look_at(Finder.GetMainBall().global_position)
