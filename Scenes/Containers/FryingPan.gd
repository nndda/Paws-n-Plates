extends Node

var container : ItemContainer = get_parent()

var is_frying : bool = false

var how_many_nugget : int = 0

@onready var done_tone : AudioStreamPlayer = $"../RingDone"
@onready var frying_tone : AudioStreamPlayer2D = $"../IsFrying"

func a_nugget_has_been_done(what_nugget : Item) -> void:
    done_tone.play()
    var nugget_done : Item = (load("res://Scenes/Items/MeatCooked.tscn") as PackedScene).instantiate()
    nugget_done.global_position = what_nugget.global_position
    container.get_parent().add_child(nugget_done)
    what_nugget.queue_free()

#func _process(delta: float) -> void:
    #($"../Label" as Label).text = str(how_many_nugget)

func _on_item_dropped(item : Global.Items, item_scn : Item) -> void:
    if item == Global.Items.MeatSeasoned && how_many_nugget < 4:
        how_many_nugget += 1
        item_scn.interractable = false
        item_scn.monitorable = false
        item_scn.monitoring = false
        item_scn.init_position = container.get_global_mouse_position()
        item_scn.global_position = container.get_global_mouse_position()
        var timer := Timer.new()
        timer.one_shot = true
        timer.timeout.connect(a_nugget_has_been_done.bind(item_scn))
        item_scn.add_child(timer)
        timer.start(10.0)
        frying_tone.playing = how_many_nugget > 0
        item_scn.container.cont_script.nugget_queue.erase(item_scn)
        #if Global.is_in_tutorial:
            #Global.is_in_tutorial = false
        #if Global.current_nugget >= Global.GOAL:
            #Global.game_won.emit()


func _on_script_nugget_received_from_pan() -> void:
    how_many_nugget -= 1
    frying_tone.playing = how_many_nugget > 0
