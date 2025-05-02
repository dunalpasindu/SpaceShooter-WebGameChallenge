extends Node2D

@export var enemy_tscn: PackedScene
@onready var mainScene = get_tree().root.get_node("World")

func _on_timer_timeout() -> void:
	if mainScene.is_game_over:
		return
	
	var new_enemy = enemy_tscn.instantiate()
	self.add_child(new_enemy)

	# Get the actual viewport dimensions to ensure enemies spawn within visible area
	var viewport_rect = get_viewport_rect()
	var viewport_width = viewport_rect.size.x
	
	var enemy_width = new_enemy.get_node("Sprite2D").texture.get_size().x
	
	# Limit the spawn position to be within the viewport with padding
	var padding = enemy_width / 2
	var rand_x = randf_range(padding, viewport_width - padding)
	
	new_enemy.position.x = rand_x
	new_enemy.position.y = -50
