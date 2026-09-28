extends Node3D

const WIN = preload("uid://c735m4qynf22u")

var sailors: int = 0
var is_changing_scene: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# Trigger win condition only once
	if sailors >= 6 and not is_changing_scene:
		is_changing_scene = true
		get_tree().change_scene_to_packed(WIN)

func sailor_saved() -> void:
	sailors += 1
