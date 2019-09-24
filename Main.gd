extends Node

func _ready():
    var buildType = OS.get_name()
    lug.lug("Build type %s" % buildType)
    
    if (buildType == "Server"):
        var result = get_tree().change_scene("res://Server.tscn")
        if (result != OK):
            lug.lug("could not change scene to Server %s" % result)
    else:
        var result = get_tree().change_scene("res://TitleScreen.tscn")
        if (result != OK):
            lug.lug("could not change scene to TitleScreen %s" % result)
