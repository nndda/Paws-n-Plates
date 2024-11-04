extends Node

var container : ItemContainer = get_parent()
@onready var spr_meat : Sprite2D = $"../Sprite2D/Meat"

var tutor_flag : bool = false

@onready var smoll_meats : PackedVector2Array = [
    $"../Sprite2D/PLACEHOLDER0".global_position,
    $"../Sprite2D/PLACEHOLDER1".global_position,
    $"../Sprite2D/PLACEHOLDER2".global_position,
    $"../Sprite2D/PLACEHOLDER3".global_position,
]

var nugget_queue : Array[Item] = []

func _ready() -> void:
    spr_meat.visible = false
    $"../Sprite2D/PLACEHOLDER0".queue_free()
    $"../Sprite2D/PLACEHOLDER1".queue_free()
    $"../Sprite2D/PLACEHOLDER2".queue_free()
    $"../Sprite2D/PLACEHOLDER3".queue_free()

func _on_item_dropped(item : Global.Items, _item_scn : Item) -> void:
    if container.interractable:
        if item == Global.Items.Meat:
            spr_meat.visible = true
            container.item_okayed.emit()

        elif item == Global.Items.Knive:
            if container.has_items_required():
                #print(item, "  -  UWU")
                spr_meat.visible = false
                container.interractable = false
                container.item_okayed.emit()
                for n in smoll_meats:
                    var load_desu : Item = (load("res://Scenes/Items/MeatChopped.tscn") as PackedScene).instantiate()
                    container.get_parent().add_child(load_desu)
                    load_desu.global_position = n
                    load_desu.init_position = n
                    load_desu.tree_exiting.connect(container.fud_updated.emit)
                    load_desu.tree_exiting.connect(remove_meat.bind(load_desu))
                    nugget_queue.append(load_desu)
                    container.fud_updated.emit()

                if !tutor_flag && Global.tutorial_step == 1:
                    Global.progress_tutor()
                    tutor_flag = true

        else:
            container.item_reject()

    else:
        container.item_reject()

func remove_meat_rand() -> void:
    nugget_queue.erase(nugget_queue.pick_random())
    container.fud_updated.emit()

func remove_meat(item : Item) -> void:
    nugget_queue.erase(item)
    if nugget_queue.is_empty():
        container.interractable = true
    container.fud_updated.emit()
    
