extends Node

# Must be unique for each instance/scene
enum Items {
    None,
    Test,
    Kitten,
    Meat,
    MeatChopped,
    MeatEgged,
    MeatSeasoned,
    Knive,
    Eggs,
    Whisk,
    Flour,
    Salt,
    Pepper,
    Soap,
    MeatCooked,
    KittenOren,
    KittenKuro,
    KittenShiro,
}

enum Containers {
    None,
    Test,
    CuttingBoard,
    BowlEggRaw,
    BowlEggBeaten,
    BowlEggEmpty,
    BowlSeasoning,
    Plate,
    WashHandThingy,
    FryingPan,
}

var current_item : Items
var current_item_scn : Node2D

var current_container : Containers
var current_container_scn : ItemContainer

var mouse_pos : Vector2

var is_holding_item : bool = false

var is_holding_kitten : bool = false

var cursor : Sprite2D

var kitten_poi : Array[KittenPoi] = []

@warning_ignore("unused_signal")
signal game_lose
@warning_ignore("unused_signal")
signal game_won

var is_hand_clean : bool = true:
    set(val):
        is_hand_clean = val
        hand_clean_state_changed.emit(val)

var current_nugget : int = 0:
    set(val):
        current_nugget = val
        current_nugget_updated.emit()

signal current_nugget_updated()

@warning_ignore("unused_signal")
signal poi_updated

signal hand_clean_state_changed(status : bool)

var is_in_tutorial : bool = true
var tutorial_step : int = 0

signal tutorial_progressed

const GOAL : int = 24

func progress_tutor() -> void:
    if is_in_tutorial:
        tutorial_progressed.emit()


func fx_jello(target : CanvasItem) -> void:
    target.scale = Vector2.ONE
    var jello_tween := create_tween()
    jello_tween \
        .tween_property(target, ^"scale", Vector2(1.1, 0.8), 0.1) \
        .set_trans(Tween.TRANS_BOUNCE) \
        .set_ease(Tween.EASE_OUT)
    jello_tween \
        .tween_property(target, ^"scale", Vector2(0.9, 1.1), 0.1) \
        .set_trans(Tween.TRANS_BOUNCE) \
        .set_ease(Tween.EASE_IN)
    jello_tween \
        .tween_property(target, ^"scale", Vector2.ONE, 0.1) \
        .set_trans(Tween.TRANS_BOUNCE) \
        .set_ease(Tween.EASE_OUT) \
        .set_delay(0.06)
