extends Node

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 1337

const game_scene = preload("res://Game.tscn")
const player_scene = preload("res://Player.tscn")
const player_other_scene = preload("res://PlayerOther.tscn")
const input_scene = preload("res://Input.tscn")

var players = {}
var tick_server = 0

var game
var input
var player

func _ready():
    set_process(false)

    var peer = NetworkedMultiplayerENet.new()

    if (OK != bulk_connect([
        "network_peer_connected",
        "network_peer_disconnected",
        "network_peer_packet",
 
       #client only
        "connected_to_server",
        "connection_failed",
        "server_disconnected"
    ])): return

    var result = peer.create_client(SERVER_IP, SERVER_PORT)
    if (result != OK):
        lug.lug("create_client result %s" % result)
        return

    get_tree().set_network_peer(peer)
    
    lug.lug("Client Ready")

func bulk_connect(signals):
    var bulk_result = OK
    for signal_name in signals:
        var result
        if (signal_name == "network_peer_packet"):
            # why is this one different?
            result = get_tree().multiplayer.connect(signal_name, self, signal_name)
        else:
            result = get_tree().connect(signal_name, self, signal_name)

        if (result != OK):
            lug.lug("error connecting signal '%s' in Server: %s" % [signal_name, result])
            bulk_result = result

    return bulk_result


func network_peer_connected(id):
    lug.lug("client network_peer_connected peer_id %s" % id)

    if (id != 1):
        return
    
    game = game_scene.instance()
    get_tree().get_root().add_child(game)
    player = player_scene.instance()

    var player_id = get_tree().multiplayer.get_network_unique_id()
    players[player_id] = player
    lug.lug("joined as %s" % player_id)

    game.add_child(player)
    game.show()

    input = input_scene.instance()
    input.listener = self
    input.include_tick = true
    get_tree().get_root().add_child(input)

func network_peer_disconnected(id):
    lug.lug("client network_peer_disconnected peer_id %s" % id)
    
    if (id == 1):
        input.set_process(false)
        
func connected_to_server():
    lug.lug("client connected_to_server")

func server_disconnected():
    lug.lug("client server_disconnected")
    input.set_process(false)

func network_peer_packet(id, packet):
    # only read messages from server
    if (id != 1): return
    
    var player_messages = packet.get_string_from_ascii().split("|")

    var tick = int(player_messages[0])
    player_messages.remove(0)

    if (tick < tick_server):
        lug.lug("skipping old delayed message: %s < %s" % [tick, tick_server])
        return

    if (tick_server != 0 && tick > tick_server + 1):
        lug.lug("detected dropped or delayed message(s): %s > %s + 1" % [tick, tick_server])
    
    tick_server = tick
    
    var disconnected_players = players.keys()
    
    for player_message in player_messages:
        var props = player_message.split(",")
        var player_id = int(props[0])
        if (!players.has(player_id)):
            players[player_id] = player_other_scene.instance()
            get_tree().get_root().add_child(players[player_id])
        else:
            disconnected_players.erase(player_id)

        players[player_id].transform.origin = Vector3(float(props[1]), 0, float(props[2]))
        
    for disconnected_player in disconnected_players:
        get_tree().get_root().remove_child(players[disconnected_player])
        players.erase(disconnected_player)

func update_input(tick, speed, move_dir):
    var message = "%s,%s,%s,%s" % [tick, speed, move_dir, player.rotation.y]
    
    var result = get_tree().multiplayer.send_bytes(
        message.to_ascii(), 1, NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE)

    if (result != OK):
        lug.lug("error on send_bytes in Client: %s" % result)
