extends MarginContainer

func _on_Host_gui_input(event):
    if (!is_clicked(event)): return
    
    get_tree().change_scene("res://Host.tscn")

func _on_Join_gui_input(event):
    if (!is_clicked(event)): return
    
    get_tree().change_scene("res://Client.tscn")
    
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
