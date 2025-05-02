extends Label

@onready var mainScene = $"../.."

func _process(delta: float) -> void:
	if mainScene:
		self.text = "Score: " + str(mainScene.score)
