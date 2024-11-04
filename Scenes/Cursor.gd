extends Area2D
class_name SpriteCursor

@onready var indicator_normal : Sprite2D = $"../Indicator/Normal"
@onready var indicator_grab : Sprite2D = $"../Indicator/Grabable"
@onready var indicator_forbidden : Sprite2D = $"../Indicator/NuhUh"

@onready var indicator_sprites : Array[Sprite2D] = [
    indicator_normal,
    indicator_grab,
    indicator_forbidden,
]

@onready var is_unclean_area : Area2D = $IsUnclean

func _ready() -> void:
    Global.cursor = get_parent()
    $IsUnclean/CollisionShape2D.shape = $CollisionShape2D.shape
    Global.hand_clean_state_changed.connect(hand_clean_state_changed)
    hand_clean_state_changed(Global.is_hand_clean)

var s : float
@onready var parent : Sprite2D = get_parent()
func _process(_delta : float) -> void:
    s = remap(
        clampf(Global.cursor.position.y, 20.0, 80.0), 20.0, 76.0, 0.2, 1.0
    )
    Global.cursor.scale = Vector2(s, s)

    if Global.is_holding_kitten:
        Global.cursor.global_position.y = clampf(Global.cursor.global_position.y, 15.0, 40)

func hand_clean_state_changed(status : bool) -> void:
    monitoring = status
    monitorable = status
    is_unclean_area.monitoring = !status
    is_unclean_area.monitorable = !status

func indicator_disable_all() -> void:
    for n in indicator_sprites:
        n.visible = false

func indicate_normal() -> void:
    indicator_disable_all()
    indicator_normal.visible = true

func indicate_grab() -> void:
    indicator_disable_all()
    indicator_grab.visible = true

func indicate_forbid() -> void:
    indicator_disable_all()
    indicator_forbidden.visible = true

func _on_area_entered(area : Area2D) -> void:
    if (area is Item || area is Kittens) && !Global.is_holding_item:
        if area is Item:
            if area.clean_hand_not_required:
                indicate_grab()
            elif !area.clean_hand_not_required && Global.is_hand_clean:
                indicate_grab()

        Global.fx_jello(area.sprite)
        Global.current_item = area.item_name
        Global.current_item_scn = area

func _on_area_exited(area : Area2D) -> void:
    if (area is Item || area is Kittens) && !Global.is_holding_item:
        indicate_normal()

        if Global.current_item == area.item_name:
            Global.current_item = Global.Items.None
        Global.current_item_scn = null


func _on_is_unclean_area_entered(area : Area2D) -> void:
    var area_par : Node2D = area.get_parent()
    if area_par is Item:
        if area_par.clean_hand_not_required:
            _on_area_entered(area_par)
        else:
            indicate_forbid()
    elif area is Kittens:
        _on_area_entered(area)

func _on_is_unclean_area_exited(area : Area2D) -> void:
    var area_par : Node2D = area.get_parent()
    if area_par is Item:
        if area_par.clean_hand_not_required:
            _on_area_exited(area_par)
        indicate_normal()
    elif area is Kittens:
        _on_area_exited(area)
