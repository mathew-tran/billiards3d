extends Node

func GetMainBall():
	var result = get_tree().get_nodes_in_group("MainBall")
	if result:
		return result[0]
	return null
	
