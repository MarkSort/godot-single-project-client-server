extends Node

const SERVER_PORT = 1337
const WEB_SOCKET_PORT = 1338
const MAX_PLAYERS = 100

const game_scene = preload("res://Game.tscn")
const player_scene = preload("res://PlayerOther.tscn")
const input_scene = preload("res://Input.tscn")

var delta_total = 0
var tick_server = 1

var ws_server = WebSocketServer.new()
var wr_peer_connections = {}
var webrtc = WebRTCMultiplayer.new()

var game

func _ready():
    var peer = NetworkedMultiplayerENet.new()
    
    if (OK != bulk_connect([
        "network_peer_connected",
        "network_peer_disconnected",
        "network_peer_packet"
    ])):
        set_process(false)
        return

    var result = peer.create_server(SERVER_PORT, MAX_PLAYERS)
    if (result != OK):
        lug.lug("create_server result %s" % result)
        set_process(false)
        return

    get_tree().set_network_peer(peer)

    game = game_scene.instance()
    game.hide()
    game.is_server = true
    get_tree().get_root().add_child(game)
    
    
    ws_server.listen(WEB_SOCKET_PORT)
    ws_server.connect("client_connected", self, "ws_client_connected")
    ws_server.connect("data_received", self, "ws_data_received")
    

    lug.lug("Server Ready")
    
func ws_client_connected(ws_id, protocol):
    lug.lug("ws_client_connected ws_id %s" % ws_id)

func ws_data_received(ws_id):
    lug.lug("ws_data_received ws_id %s" % ws_id)
    var ws_peer = ws_server.get_peer(ws_id)
    var message = ws_peer.get_packet().get_string_from_ascii()
    if wr_peer_connections.has(ws_id):
        return ws_handle_answer(wr_peer_connections[ws_id], ws_peer, message)
    ws_handle_offer(ws_id, ws_peer, message)

func ws_handle_offer(ws_id, ws_peer, message):
    var wr_peer_connection = WebRTCPeerConnection.new()
    var offer = wr_peer_connection.create_offer()
    wr_peer_connections[ws_id] = wr_peer_connection
    # no, this has to be a new node?
    
    
func ws_handle_answer(wr_peer_connection, ws_peer, message):
    pass

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


func _process(delta):
    delta_total += delta
    var ticks = 0
    
    while (delta_total > .1):
        ticks += 1
        delta_total -= .1

    if (ticks > 1):
        lug.lug("more than 1 tick processed in single _process call")

    if (ticks > 0 && get_tree().multiplayer.get_network_connected_peers().size() > 0): 
        var message = "%s" % tick_server
        for id in game.players:
            message += "|%s," % id
            var origin = game.players[id].node.get_global_transform().origin
            message += "%s," % origin.x
            message += "%s" % origin.z
        
        var result = get_tree().multiplayer.send_bytes(
            message.to_ascii(), 0, NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE)
            
        if (result != OK):
            lug.lug("error on send_bytes in Server: %s" % result)

        tick_server += 1

func network_peer_packet(id, packet):
    var player = game.players[id]

    var message = packet.get_string_from_ascii().split(",")

    var tick = int(message[0])
    if (tick <= player.tick):
        lug.lug("skipping old delayed player message")
        return

    if (player.tick > 0 && tick > player.tick + 1):
        lug.lug("detected dropped or delayed player messages")

    player.tick = tick
    player.speed = float(message[1])
    player.move_dir = float(message[2])
    player.node.rotation.y = float(message[3])

func network_peer_connected(id):
    lug.lug("server network_peer_connected peer_id %s" % id)
    var player = player_scene.instance()
    player.translate(Vector3(0, 0, game.players.size() * -1.5))
    game.players[id] = {"node": player, "speed": 0, "move_dir": 0, "tick": 0}
    game.add_child(player)

func network_peer_disconnected(id):
    lug.lug("server network_peer_disconnected peer_id %s" % id)
    game.remove_child(game.players[id].node)
    game.players.erase(id)
