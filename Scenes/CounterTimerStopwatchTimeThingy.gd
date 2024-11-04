extends Label

@onready var timer : Timer = $Timer

var seconds_passed : int = 0

func stop() -> void:
    timer.stop()

func _on_timer_timeout() -> void:
    seconds_passed += 1
    update_display()

func update_display():
    @warning_ignore("integer_division")
    text = "%01d:%02d" % [seconds_passed / 60, seconds_passed % 60]
