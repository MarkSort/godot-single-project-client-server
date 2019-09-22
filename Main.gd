extends Node

func _ready():
    var buildType = OS.get_name()
    lug.lug("Build type %s" % buildType)
    
    if (buildType == "Server"):
        get_tree().change_scene("res://Server.tscn")
    else:
        get_tree().change_scene("res://TitleScreen.tscn")
