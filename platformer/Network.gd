extends Node

var CoinBronze = preload("res://scenes/pickup/CoinBronze.tscn")
var CoinSilver = preload("res://scenes/pickup/CoinSilver.tscn")
var CoinGold = preload("res://scenes/pickup/CoinGold.tscn")

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 5

var players = { }
var self_data = { name = '', position = Vector3(-9.5, 0.5, -0.5), score=0, player_status=0}
var game_time = 0
var game_status = 1

var coins = { }

signal player_disconnected
signal server_disconnected

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')

func create_server(player_nickname, game_time_minutes):
	game_time = game_time_minutes*60
	self_data.name = player_nickname
	self_data.gamestatus = game_status
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	

func connect_to_server(player_nickname):
	self_data.name = player_nickname
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
	
func _connected_to_server():
	var local_player_id = get_tree().get_network_unique_id()
	players[local_player_id] = self_data
	rpc('_send_player_info', local_player_id, self_data, coins, game_time, game_status)
	
	
func _on_player_disconnected(id):
	players.erase(id)

func _on_player_connected(connected_player_id):
	var local_player_id = get_tree().get_network_unique_id()
	if not(get_tree().is_network_server()):
		rpc_id(1, '_request_player_info', local_player_id, connected_player_id)


remote func _request_player_info(request_from_id, player_id):
	if get_tree().is_network_server():
		rpc_id(request_from_id, '_send_player_info', player_id, players[player_id], coins)


# A function to be used if needed. The purpose is to request all players in the current session.
remote func _request_players(request_from_id):
	if get_tree().is_network_server():
		for peer_id in players:
			if( peer_id != request_from_id):
				rpc_id(request_from_id, '_send_player_info', peer_id, players[peer_id], coins)

remote func _send_player_info(id, info, coins, game_time, game_status):
	print(game_time)
	print(game_status)
	
	players[id] = info
	var new_player = load('res://scenes/Player.tscn').instance()
	new_player.name = str(id)
	new_player.set_network_master(id)
	$'/root/Map/'.add_child(new_player)
	new_player.init(info.name, info.position, true)
	
	if not(get_tree().is_network_server()):
		self.coins = coins
	
		for coin in coins:
			var new_coin
			if coin.match("*Gold*"):
				new_coin = CoinGold.instance()
			elif coin.match("*Silver*"):
				 new_coin = CoinSilver.instance()
			else:
				new_coin = CoinBronze.instance()
	
			new_coin.transform.origin = coins[coin]
			new_coin.connect("coin_collected", $'/root/Map', "increase_coin_collected")
			$'/root/Map'.add_child(new_coin)

func update_position(id, position):
	players[id].position = position
