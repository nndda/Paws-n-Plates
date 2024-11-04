extends Node2D

var mouse_pos : Vector2

@export var cursor : Sprite2D
@export var nugget_count_indicater : Label

@export var kitten_poi : Array[KittenPoi] = []

@export var dirty_hand_label : Label

func _ready() -> void:
    Global.current_nugget_updated.connect(nugget_updated)
    Global.kitten_poi = kitten_poi
    Global.game_lose.connect(game_lose)
    Global.game_won.connect(game_win)
    print("\n", Global.is_in_tutorial)
    if !Global.is_in_tutorial:
        $Scene/TutorialAgent.queue_free()
        $Scene/Kittens.call_deferred(&"set_process_mode", PROCESS_MODE_INHERIT)
        $Scene/Kittens.visible = true
        $UI/Control/TIMEEEEE/Timer.start()
    else:
        $UI/Control/NuggetCount.visible = false
        $UI/Control/TextureRect.visible = false
        $UI/Control/TIMEEEEE.visible = false

var game_losetocats : bool = false

var game_w : bool = false

func game_win() -> void:
    if !game_w:
        game_w = true
        print("www")
        $UI/Control/TIMEEEEE/Timer.stop()
        $UI/WinScreen.visible = true
        $Scene.call_deferred(&"set_process_mode", PROCESS_MODE_DISABLED)
        $UI/WinScreen/Label/Label3.text = $UI/Control/TIMEEEEE.text


func game_lose() -> void:
    if !game_losetocats:
        $UI/DefeatScreen.visible = true
        $Scene.call_deferred(&"set_process_mode", PROCESS_MODE_DISABLED)
        game_losetocats = true

func nugget_updated() -> void:
    nugget_count_indicater.text = str(Global.current_nugget) + "/" + str(Global.GOAL)
    if Global.current_nugget >= Global.GOAL:
        game_win()

func _process(_delta : float) -> void:
    dirty_hand_label.visible = !Global.is_hand_clean
    mouse_pos = get_global_mouse_position()
    cursor.position = mouse_pos
    Global.mouse_pos = mouse_pos
    
    $Scene/KittenPoi/KittenPoiSeasoned.has_fud = !$Scene/Containers/BowlSeasoning/Script.nugget_queue.is_empty()
    #$ItemDbg.text = Global.Items.keys()[Global.current_item]
    #$ContainerDbg.text = Global.Containers.keys()[Global.current_container]
    #$MousePos.text = str(Global.mouse_pos.snappedf(0.1))
    #if Global.current_item_scn:
        #$CurrentItemScn.text = str(Global.current_item_scn.name)
    #else:
        #$CurrentItemScn.text = ""

func _input(event : InputEvent) -> void:
    if game_losetocats:
        if event.is_action_pressed(&"Restart"):
            get_tree().reload_current_scene()


func _on_interval_update_poi_timeout() -> void:
    Global.poi_updated.emit()
