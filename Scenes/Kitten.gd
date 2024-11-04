extends Area2D
class_name Kittens

@warning_ignore("int_as_enum_without_cast")
@export var item_name : Global.Items = 0
var item_shader : ShaderMaterial

@onready var arr_aud_pick : Array[AudioStreamPlayer2D] = [
    $Audio/Pick1,
    $Audio/Pick2,
]

@onready var sprite : Sprite2D = $Sprite2D
@onready var sprite_fud : Sprite2D = $Sprite2D/Fud

@onready var sprite_anim : AnimationPlayer = $Sprite2D/AnimationPlayer

@onready var eat_timer_progres_bar : ProgressBar = $EatTimerProgressBar

@onready var eat_timer : Timer = $EatTimer

var target_poi : KittenPoi

var is_in_kitten_poi : bool = false


func _on_poi_updated() -> void:
    calculate_distance()


func _enter_tree() -> void:
    get_tree().current_scene.ready.connect(calculate_distance)

func _ready() -> void:
    Global.poi_updated.connect(_on_poi_updated)
    var shader_dupl := (sprite.material as ShaderMaterial).duplicate(true)
    item_shader = shader_dupl
    sprite.material = item_shader
    item_shader.set_shader_parameter(&"active", false)

func munch_fud_anim() -> void:
    Global.fx_jello(sprite_fud)

var game_lost : bool = false
var s : float
var is_me : bool = false
func _process(delta : float) -> void:
    is_me = Global.current_item == item_name && Global.current_item_scn == self
    item_shader.set_shader_parameter(&"active", is_me)

    if is_me:
        if Input.is_action_pressed(&"Hold"):
            Global.is_holding_item = true
            Global.is_holding_kitten = true
            global_position.x = Global.cursor.global_position.x
            global_position.y = clampf(Global.cursor.global_position.y, 15.0, 40)
            Global.current_item = item_name

    s = remap(
        clampf(global_position.y, 15.0, 50.0), 15.0, 46.0, 0.4, 1.2
    )
    scale = Vector2(s, s)

    if !game_lost:
        if (!is_in_kitten_poi || eat_timer.time_left <= 0) && target_poi != null:
            global_position = global_position.move_toward(
                target_poi.point.global_position, delta * 2.0 *
                remap(Global.current_nugget, 0.0, Global.GOAL, 1.0, 6.5)
            )

    #eat_timer_progres_bar.visible = eat_timer.time_left > 0
    #eat_timer_progres_bar.value = eat_timer.time_left

    #if is_in_kitten_poi:
        #if target_poi != null:
            #await target_poi.fud_updated_loc
            #print("free")
            #target_poi.remov_fud_from_container()
            #sprite_anim.play(&"Munch")
            #eat_timer.start(8.0)
            #sprite_fud.visible = true


func _input(event : InputEvent) -> void:
    if Global.current_item == item_name:
        if Global.current_item_scn == self:
            if event.is_action_pressed(&"Hold"):
                (arr_aud_pick.pick_random() as AudioStreamPlayer2D).play()
                $Nyan.play()
                Global.is_hand_clean = false
            elif event.is_action_released(&"Hold"):
                global_position = Global.cursor.global_position
                Global.is_holding_item = false
                Global.is_holding_kitten = false
                calculate_distance()

func _on_area_entered(area : Area2D) -> void:
    if area is KittenPoi:
        is_in_kitten_poi = true
        target_poi = area
        if target_poi.has_fud:
            target_poi.remov_fud_from_container()
            sprite_anim.play(&"Munch")
            #eat_timer.start(8.0)
            call_deferred(&"set_process_mode", PROCESS_MODE_ALWAYS)
            call_deferred(&"monitorable", false)
            call_deferred(&"monitoring", false)
            sprite_fud.visible = true
            $CollisionShape2D.queue_free()
            game_lost = true
            Global.game_lose.emit()
            return

    sprite_anim.play(&"Walk")

func _on_area_exited(area : Area2D) -> void:
    if area is KittenPoi:
        is_in_kitten_poi = false

func calculate_distance() -> void:
    #print(get_nearest_poi())
    target_poi = get_nearest_poi()

func get_nearest_poi() -> KittenPoi:
    var nearpoi : KittenPoi = null
    var min_dist : float = INF

    for poi in Global.kitten_poi:
        if poi.has_fud:
            var dist = global_position.distance_squared_to(poi.global_position)
            if dist < min_dist:
                min_dist = dist
                nearpoi = poi

    return nearpoi

func _on_eat_timer_timeout() -> void:
    sprite_anim.play(&"Walk")
    sprite_fud.visible = false
    if is_in_kitten_poi:
        if target_poi != null:
            if target_poi.has_fud:
                target_poi.remov_fud_from_container()
                sprite_anim.play(&"Munch")
                #eat_timer.start(8.0)
                call_deferred(&"set_process_mode", PROCESS_MODE_ALWAYS)
                call_deferred(&"monitorable", false)
                call_deferred(&"monitoring", false)
                sprite_fud.visible = true
                $CollisionShape2D.queue_free()
                game_lost = true
                Global.game_lose.emit()
                return

    sprite_anim.play(&"Walk")

func _on_animation_player_animation_finished(anim_name : StringName) -> void:
    if anim_name == &"Much":
        if !is_in_kitten_poi:
            sprite_anim.play(&"Walk")
        else:
            if target_poi != null:
                if !target_poi.has_fud:
                    sprite_anim.play(&"Walk")
