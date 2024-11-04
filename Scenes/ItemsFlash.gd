extends Sprite2D

func _ready() -> void:
    var tween : Tween = create_tween().set_loops()
    tween.tween_property(self, ^"modulate:v", 1, 0.25) \
        .set_ease(Tween.EASE_OUT) \
        .from(15) \
        .set_delay(0.9)
