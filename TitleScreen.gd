extends MarginContainer

const server_scene = preload("res://Server.tscn")
const client_scene = preload("res://Client.tscn")
const player_scene = preload("res://Player.tscn")

func _on_Host_gui_input(event):
    if (!is_clicked(event)): return
    
    hide()

    lug.lug("Host Starting Server")
    var server = server_scene.instance()
    get_tree().get_root().add_child(server)
    
    var player = player_scene.instance()
    server.players[1] = {"node": player, "up": false, "down": false, "left": false, "right": false}
    server.game.add_child(player)
    server.game.show()

func _on_Join_gui_input(event):
    if (!is_clicked(event)): return
    
    hide()
    
    lug.lug("Join Starting Client")
    var client = client_scene.instance()
    get_tree().get_root().add_child(client)

func _on_Quit_gui_input(event):
    if (!is_clicked(event)): return

    get_tree().quit()


func is_clicked(event):
    if (!(event is InputEventMouseButton)):
        return false
        
    if (!event.pressed || event.button_index != 1):
        return false

    # TODO returns true on initial mouse down, but should only return true on
    # mouse up, and only if cursor is still over the button
    return true

