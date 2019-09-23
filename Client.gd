extends Node

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 1337

const game_scene = preload("res://Game.tscn")
const player_scene = preload("res://Player.tscn")

var delta_accrued = 0
var players = {}
var tick_client = 1
var tick_server = 0

var game

func _ready():
    var peer = NetworkedMultiplayerENet.new()
    get_tree().connect("network_peer_connected", self, "network_peer_connected")
    get_tree().connect("network_peer_disconnected", self, "network_peer_disconnected")
    get_tree().multiplayer.connect("network_peer_packet", self, "network_peer_packet")

    var result = peer.create_client(SERVER_IP, SERVER_PORT)
    if (result != OK):
        lug.lug("create_client result %s" % result)
        return

    get_tree().set_network_peer(peer)
    
    set_process(false)

    lug.lug("Client Ready")

func _process(delta):
    delta_accrued += delta
    var ticks = 0
    
    while (delta_accrued > .1):
        ticks += 1
        delta_accrued -= .1

    if (ticks > 1):
        lug.lug("more than 1 tick processed in single _process call")

    if (ticks > 0): 
        var message = "%s,%s" % [tick_client, get_input_speed_and_direction()]
        
        get_tree().multiplayer.send_bytes(message.to_ascii(), 0, NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE)

        tick_client += 1

func network_peer_connected(id):
    lug.lug("client network_peer_connected peer_id %s" % id)
    
    set_process(true)

    game = game_scene.instance()
    get_tree().get_root().add_child(game)
    var player = player_scene.instance()
    players[get_tree().multiplayer.get_network_unique_id()] = player
    game.add_child(player)
    game.show()

func network_peer_disconnected(id):
    lug.lug("client network_peer_disconnected peer_id %s" % id)
    
    set_process(false)

func network_peer_packet(id, packet):
    var player_messages = packet.get_string_from_ascii().split("|")

    var tick = int(player_messages[0])
    player_messages.remove(0)

    if (tick < tick_server):
        lug.lug("skipping old delayed message")
        return

    if (tick_server != 0 && tick > tick_server + 1):
        lug.lug("detected dropped or delayed message(s)")
    
    tick_server = tick
    
    for player_message in player_messages:
        var props = player_message.split(",")
        var player_id = int(props[0])
        if (players.has(player_id)):
            var x = float(props[1])
            var z = float(props[2])
            players[player_id].transform.origin = Vector3(x, 0, z)

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

    return "%s,%s" % [speed, deg2rad(direction)]
