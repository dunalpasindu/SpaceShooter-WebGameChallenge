extends Area2D

@export var speed: float = 400
@onready var mainScene = $'../..'

func _process(delta: float) -> void:
	position.y += speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area.name == "Laser": # Check if the colliding object is a laser
		mainScene.score += 10
	self.queue_free()
