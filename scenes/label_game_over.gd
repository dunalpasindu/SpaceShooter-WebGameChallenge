extends Label

@onready var mainScene = get_tree().root.get_node("World")
@onready var restartLabel = $"../RestartLabel"

func _process(delta: float) -> void:
	if mainScene.is_game_over == true:
		restartLabel.visible = true
		self.visible = true
	
	if Input.is_action_just_pressed("ui_accept") and mainScene.is_game_over == true:
		restartLabel.visible = false
		get_tree().reload_current_scene()
		mainScene.reset_value()
