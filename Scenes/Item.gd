extends Area2D
class_name Item

@warning_ignore("int_as_enum_without_cast")
@export var item_name : Global.Items = 0
var item_shader : ShaderMaterial

var container : ItemContainer

@export var clean_hand_not_required : bool = false

var interractable : bool = true:
    set = set_interractable

func set_interractable(val : bool) -> void:
    interractable = val
    monitoring = val
    monitorable = val
    if !val:
        Global.current_item = Global.Items.None

var init_position : Vector2
var tween_back : Tween

@onready var arr_aud_pick : Array[AudioStreamPlayer2D] = [
    $Audio/Pick1,
    $Audio/Pick2,
]

@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
    var shader_dupl := (sprite.material as ShaderMaterial).duplicate(true)
    item_shader = shader_dupl
    sprite.material = item_shader
    item_shader.set_shader_parameter(&"active", false)

    $IsUnclean/CollisionShape2D.shape = $CollisionShape2D.shape

    init_position = global_position

var is_me : bool = false
func _process(_delta : float) -> void:
    is_me = Global.current_item == item_name && Global.current_item_scn == self
    item_shader.set_shader_parameter(&"active", is_me)
    if is_me:
        if Input.is_action_pressed(&"Hold"):
            Global.is_holding_item = true
            global_position = Global.mouse_pos
            Global.current_item = item_name

            if tween_back != null:
                if tween_back.is_running():
                    tween_back.stop()

func _input(event : InputEvent) -> void:
    if Global.current_item == item_name:
        if Global.current_item_scn == self:
            if event.is_action_pressed(&"Hold"):
                (arr_aud_pick.pick_random() as AudioStreamPlayer2D).play()
            elif event.is_action_released(&"Hold"):
                if Global.current_container != Global.Containers.None &&\
                    Global.current_container_scn != null:
                    Global.current_container_scn.item_dropped.emit(item_name, self)
                    if Global.current_container_scn.item_enter(item_name):
                        global_position = init_position
                        Global.current_item_scn = null
                        Global.current_item = Global.Items.None
                        Global.is_holding_item = false
                        return
                Global.is_holding_item = false
                tween_back_to_place()

func tween_back_to_place() -> void:
    #interractable = false
    tween_back = create_tween() \
        .set_ease(Tween.EASE_OUT) \
        .set_trans(Tween.TRANS_EXPO)
    #tween_back.finished.connect(tween_back_finished)
    tween_back.tween_property(
        self, ^"global_position", init_position, .5
    )
    if Global.current_item == item_name:
        Global.current_item = Global.Items.None
