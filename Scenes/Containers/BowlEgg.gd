extends Node

var container : ItemContainer = get_parent()
@onready var sprite : Sprite2D = $"../Sprite2D"

var nugget_queue : Array[Item] = []

var tutor_flag : bool = false

#var nugget_able : bool = false
var nugget_able_for : int = 0:
    set(val):
        nugget_able_for = val
        if val <= 0:
            nugget_able_for = 0
            container.container_name = Global.Containers.BowlEggEmpty
            sprite.texture = load("res://Assets/Sprites/BowlEggEmpty.png")

func _on_item_dropped(item : Global.Items, item_scn : Item) -> void:
    if item == Global.Items.Eggs:
        if container.container_name == Global.Containers.BowlEggEmpty:
            container.container_name = Global.Containers.BowlEggRaw
            sprite.texture = load("res://Assets/Sprites/BowlEggHas.png")
            container.item_okayed.emit()

    elif item == Global.Items.Whisk:
        if container.container_name == Global.Containers.BowlEggRaw:
            container.container_name = Global.Containers.BowlEggBeaten
            sprite.texture = load("res://Assets/Sprites/BowlEggScrambled.png")
            #nugget_able = true
            nugget_able_for = 4
            container.item_okayed.emit()

    elif item == Global.Items.MeatChopped:
        if container.container_name == Global.Containers.BowlEggBeaten:
            nugget_able_for -= 1
            var nugget_egged : Item = (load("res://Scenes/Items/MeatEgged.tscn") as PackedScene).instantiate()
            nugget_egged.global_position = item_scn.global_position
            item_scn.queue_free()
            container.get_parent().add_child(nugget_egged)
            #nugget_egged.tree_exiting.connect(container.fud_updated.emit)
            #nugget_egged.tree_exiting.connect(nugget_queue.erase.bind(nugget_egged))
            nugget_egged.tree_exiting.connect(rem_nugget.bind(nugget_egged))
            nugget_queue.append(nugget_egged)
            container.fud_updated.emit()
            container.item_okayed.emit()

            if !tutor_flag && Global.tutorial_step == 2:
                Global.progress_tutor()
                tutor_flag = true

    else:
        container.item_reject()

func rem_nugget(what_nugget : Item):
    nugget_queue.erase(what_nugget)
    container.fud_updated.emit()
