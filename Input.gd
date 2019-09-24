extends Node

var delta_accrued = 0
var tick = 1
var include_tick = false

var listener

func _process(delta):
    delta_accrued += delta
    var ticks = 0
    
    while (delta_accrued > .1):
        ticks += 1
        delta_accrued -= .1

    if (ticks > 1):
        lug.lug("more than 1 tick processed in single _process call")

    if (ticks > 0):
        var input = get_input_speed_and_direction()
        
        if (include_tick):
            listener.update_input(tick, input.speed, input.move_dir)
        else:
            listener.update_input(input.speed, input.move_dir)

        tick += 1

func get_input_speed_and_direction():
    var speed = 0
    var direction = -1
    
    var up = Input.is_key_pressed(KEY_W) || Input.is_key_pressed(KEY_UP)
    var down = Input.is_key_pressed(KEY_S) || Input.is_key_pressed(KEY_DOWN)
    var left = Input.is_key_pressed(KEY_A) || Input.is_key_pressed(KEY_LEFT)
    var right = Input.is_key_pressed(KEY_D) || Input.is_key_pressed(KEY_RIGHT)

    if (up && !down):
        if (left && !right): direction = 225
        elif (right && !left): direction = 315
        else: direction = 270
    elif (down && !up):
        if (left && !right): direction = 135
        elif (right && !left): direction = 45
        else: direction = 90
    elif (left && !right): direction = 180
    elif (right && !left): direction = 0

    if (direction != -1):
        speed = 1
    else:
        direction = 0

    return {"speed": speed, "move_dir": deg2rad(direction)}

func _unhandled_input(event):
    if (event is InputEventMouseMotion):
        update_mouse(event.relative)
    elif (event is InputEventKey && event.scancode == KEY_ESCAPE && event.is_pressed()):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    elif (event is InputEventMouseButton && Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED):
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func update_mouse(relative):
    if (Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED): return

    listener.player.rotate_y(-relative.x/700)

    listener.player.camera.rotate_x(-relative.y/700)
    if (listener.player.camera.rotation.x < deg2rad(-90)):
        listener.player.camera.rotation.x = deg2rad(-90)
    elif (listener.player.camera.rotation.x > -.1):
        listener.player.camera.rotation.x = -.1
