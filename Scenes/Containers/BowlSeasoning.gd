extends Node

var container : ItemContainer = get_parent()
@onready var sprite : Sprite2D = $"../Sprite2D"

var step : int = 0

var has_flour : bool = false
var has_salt : bool = false
var has_pepper : bool = false

var nugget_queue : Array[Item] = []

var tutor_flag : bool = false

var UWUSAGE_LEFT : int = 4
var usage_left : int = 0:
    set(val):
        usage_left = val
        if val <= 0:
            step = 0
            has_flour = false
            has_salt = false
            has_pepper = false
            #container.interractable = true
            sprite.texture = load("res://Assets/Sprites/BowlSeasoningEmpty.png")

func _on_item_dropped(item : Global.Items, item_scn : Item) -> void:
    #if container.interractable:
        if item == Global.Items.Flour && !has_flour:
            step += 1
            has_flour = true
            check_if_ready()
            container.item_okayed.emit()

        elif item == Global.Items.Salt && !has_salt:
            step += 1
            has_salt = true
            check_if_ready()
            container.item_okayed.emit()

        elif item == Global.Items.Pepper && !has_pepper:
            step += 1
            has_pepper = true
            check_if_ready()
            container.item_okayed.emit()
        
        elif item == Global.Items.MeatEgged && \
            has_flour && \
            has_salt && \
            has_pepper:

                var nugget_seasoned : Item = (
                    load("res://Scenes/Items/MeatSeasoned.tscn"
                ) as PackedScene).instantiate()
                nugget_seasoned.global_position = item_scn.global_position
                #nugget_seasoned.set_meta(&"container_owner", self)
                nugget_seasoned.container = container
                container.get_parent().add_child(nugget_seasoned)
                nugget_queue.append(nugget_seasoned)
                container.fud_updated.emit()
                nugget_seasoned.tree_exiting.connect(nugget_queue.erase.bind(nugget_seasoned))
                nugget_seasoned.tree_exiting.connect(container.fud_updated.emit)

                item_scn.queue_free()

                container.item_okayed.emit()

                usage_left = usage_left - 1

                sprite.texture = load("res://Assets/Sprites/BowlSeasoning" + str(
                    clampi(int(remap(usage_left, 0, UWUSAGE_LEFT, 1, 3)), 1, 3)
                ) + ".png")

                if usage_left <= 0:
                    step = 0
                    has_flour = false
                    has_salt = false
                    has_pepper = false
                    #container.interractable = true
                    sprite.texture = load("res://Assets/Sprites/BowlSeasoningEmpty.png")

                if !tutor_flag && Global.tutorial_step == 3:
                    Global.progress_tutor()
                    tutor_flag = true
                    Global.is_hand_clean = false

        else:
            container.item_reject()

    #else:
        #container.item_reject()
    
    #print(Global.Items.keys()[item],  " ", step, " - ", has_flour, " ", has_salt, " ", has_pepper)

func check_if_ready() -> void:
    if has_flour &&\
        has_salt && \
        has_pepper:
            usage_left = UWUSAGE_LEFT
            #container.interractable = false

    sprite.texture = load("res://Assets/Sprites/BowlSeasoning" + str(clampi(step, 1, 3)) + ".png")
