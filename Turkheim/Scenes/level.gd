extends Node3D

var sailors = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if sailors == 6:
		get_tree().reload_current_scene()

func sailor_saved() -> void:
	sailors = sailors + 1
