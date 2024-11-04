extends Node

var container : ItemContainer = get_parent()

signal nugget_received_from_pan

var nugget_queue : Array[Item] = []

func check_if_win() -> void:
    if nugget_queue.size() >= 32:
        pass

func nugget_lost(what_nugget : Item) -> void:
    nugget_queue.erase(what_nugget)
    container.fud_updated.emit()
    Global.current_nugget = nugget_queue.size()
    Global.current_nugget_updated.emit()

func _on_item_dropped(item : Global.Items, item_scn : Item) -> void:
    if item == Global.Items.MeatCooked:
        nugget_queue.append(item_scn)
        nugget_received_from_pan.emit()
        container.fud_updated.emit()
        item_scn.tree_exiting.connect(nugget_lost.bind(item_scn))
        item_scn.interractable = false
        item_scn.init_position = container.get_global_mouse_position()
        item_scn.global_position = item_scn.init_position
        Global.current_nugget = nugget_queue.size()
        Global.current_nugget_updated.emit()
        check_if_win()
        container.item_okayed.emit()
    else:
        container.item_reject()
