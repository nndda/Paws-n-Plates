extends Area2D
class_name ItemContainer

var item_shader : ShaderMaterial

@warning_ignore("int_as_enum_without_cast")
@export var container_name : Global.Containers = 0

@export var item_accept : Array[Global.Items] = []
var item_current : Array[Global.Items] = []

var interractable : bool = true:
    set(val):
        interractable = val
        monitoring = val
        monitorable = val
        if !val:
            Global.current_container = Global.Containers.None

@warning_ignore("unused_signal")
signal item_dropped(item : Global.Items, item_scn : Item)
signal item_okayed()
signal item_accepted(items : Array[Global.Items])

@warning_ignore("unused_signal")
signal fud_updated

@onready var arr_aud_drop : Array[AudioStreamPlayer2D] = [
    $Audio/Drop1,
    $Audio/Drop2,
]
@onready var arr_aud_err : Array[AudioStreamPlayer2D] = [
    $Audio/Err1,
    $Audio/Err2,
]

@onready var cont_script : Node = $Script

func _ready() -> void:
    var shader_dupl := ($Sprite2D.material as ShaderMaterial).duplicate(true)
    item_shader = shader_dupl
    $Sprite2D.material = item_shader
    item_shader.set_shader_parameter(&"active", false)
    item_okayed.connect(item_is_accepted)

func _on_area_entered(area : Area2D) -> void:
    if area.name == &"CursorArea" || area.name == &"IsUnclean":
        item_shader.set_shader_parameter(&"active", true)

        if interractable:
            #if area.name == &"CursorArea":
                Global.fx_jello(self)
                #if item_enter(Global.current_item, true):
                    #item_shader.set_shader_parameter(&"active", true)
                Global.current_container = container_name
                Global.current_container_scn = self

func _on_area_exited(area : Area2D) -> void:
    if area.name == &"CursorArea" || area.name == &"IsUnclean":
        item_shader.set_shader_parameter(&"active", false)

        if interractable:
            #if area.name == &"CursorArea":
                #item_shader.set_shader_parameter(&"active", false)
                Global.current_container = Global.Containers.None
                Global.current_container_scn = null

func item_reject() -> void:
    (arr_aud_err.pick_random() as AudioStreamPlayer2D).play()

func item_is_accepted() -> void:
    (arr_aud_drop.pick_random() as AudioStreamPlayer2D).play()

func item_enter(item : Global.Items, check_only : bool = false) -> bool:
    if !item_accept.has(item):
        #item_reject()
        return false

    if !has_items_required():
        if !check_only:
            item_current.append(item)
            item_accepted.emit(item_current)
        #print(item_current)
        return true

    #item_reject()
    return false

func has_items_required() -> bool:
    var items_count := {}
    for n in item_accept:
        items_count[n] = items_count.get(n, 0) + 1

    var current_count := {}
    for n in item_current:
        current_count[n] = current_count.get(n, 0) + 1

    for n in items_count:
        if current_count.get(n, 0) < items_count[n]:
            return false

    return true
