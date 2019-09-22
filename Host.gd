extends Node

const server_scene = preload("res://Server.tscn")

func _ready():
    lug.lug("Host Ready")
    var server = server_scene.instance()
    get_tree().get_root().add_child(server)
