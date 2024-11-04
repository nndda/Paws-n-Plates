extends Area2D
class_name KittenPoi

var has_fud : bool = false

@export var container : ItemContainer

@onready var point : Marker2D = $Point

signal fud_updated_loc

func _ready() -> void:
    $Point/Debug.queue_free()
    if container != null:
        container.fud_updated.connect(_on_fud_updated)
    _on_fud_updated()

func _on_fud_updated() -> void:
    if container != null:
        if container.cont_script != null:
            has_fud = !container.cont_script.nugget_queue.is_empty()
            #print("has_fud - ", has_fud)
            Global.poi_updated.emit()
            fud_updated_loc.emit()

func remov_fud_from_container() -> void:
    if container.cont_script:
        if "nugget_queue" in container.cont_script:
            if !container.cont_script.nugget_queue.is_empty():
                var uwu = container.cont_script.nugget_queue.pick_random()
                if uwu != null:
                    uwu.queue_free()
                    Global.poi_updated.emit()
                    fud_updated_loc.emit()
            else:
                Global.poi_updated.emit()
            #var victim : Item = container.cont_script.nugget_queue.pick_random()
            #container.cont_script.nugget_queue.erase(victim)
