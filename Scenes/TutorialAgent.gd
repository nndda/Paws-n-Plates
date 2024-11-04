extends Node2D

@onready var s1 : Node2D = $GrabNChopMeat
@onready var s2 : Node2D = $Egg
@onready var s3 : Node2D = $Seasoning
@onready var s4 : Node2D = $Cats
@onready var s5 : Node2D = $Last

@onready var ssteps : Array[Node2D] = [
    s1,
    s2,
    s3,
    s4,
    s5,
]

func progress() -> void:
    if Global.tutorial_step + 1 <= ssteps.size():
        for n in ssteps:
            n.visible = false
        ssteps[Global.tutorial_step].visible = true
        Global.tutorial_step += 1

func _ready() -> void:
    #Global.is_in_tutorial = true
    if Global.is_in_tutorial:
        progress()
        Global.tutorial_progressed.connect(progress)

func _process(_delta : float) -> void:
    #if Global.is_in_tutorial:
        if Input.is_action_just_pressed(&"TutorSkip"):
            Global.is_in_tutorial = false
            get_tree().reload_current_scene()

#func _input(event : InputEvent) -> void:
    #if Global.is_in_tutorial:
        #if event.is_action_pressed(&"TutorSkip"):
            #Global.is_in_tutorial = false
            #get_tree().reload_current_scene()
            #for n in ssteps:
                #n.visible = false

#func _exit_tree() -> void:
    #Global.is_in_tutorial = true
    #Global.tutorial_step = -1
