extends Node3D

const LEVEL = preload("uid://cdbmlufck5ldl")

var is_changing_scene: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_interactable_slider_slider_moved(position: Variant) -> void:
	# Convert position to float safely
	var pos_value = float(position)
	
	# Only trigger if below 0.1 AND we haven't already started changing scenes
	if pos_value < 0.1 and not is_changing_scene:
		is_changing_scene = true
		get_tree().change_scene_to_packed(LEVEL)
