extends Node2D

var mouse_pos : Vector2

@export var cursor : Sprite2D

func _process(delta: float) -> void:
    mouse_pos = get_global_mouse_position()
    cursor.position = mouse_pos
