extends Area2D

@export var laser_tcsn: PackedScene
@onready var mainScene = $".."

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	position.x = mouse_pos.x
	
	if Input.is_action_just_pressed("fire"):
		var new_laser = laser_tcsn.instantiate()
		add_sibling(new_laser)
		new_laser.position = self.position


func _on_area_entered(area):
	if area.is_in_group("enemy"):
		self.queue_free()
		mainScene.is_game_over = true
		# Call the game_over function to properly handle score saving
		print("DEBUG: Player collision with enemy detected, calling game_over()")
		mainScene.game_over()
