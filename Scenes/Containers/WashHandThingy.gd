extends Node

var tutor_flag : bool = false

var container : ItemContainer = get_parent()

func _on_item_dropped(item : Global.Items, _item_scn : Item) -> void:
    print(Global.Items.keys()[item])
    if item == Global.Items.Soap && !Global.is_hand_clean:
        Global.is_hand_clean = true
        container.item_okayed.emit()
        if !tutor_flag && Global.tutorial_step == 4:
            Global.progress_tutor()
            tutor_flag = true
    else:
        container.item_reject()
