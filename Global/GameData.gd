extends Node

# ==========================
# DADOS DO JOGADOR / JOGO
# ==========================
var current_player: Player 
var players: Array[Player]
@export var player_turn: String 
# ==========================
# SINAIS
# ==========================
# Emitido quando a lista de jogadores é atualizada
signal players_data_updated(players: Array[Player])
signal turn_started(player_uuid)
signal play_phase_started(player_uuid)
signal combat_phase_started(player_uuid: String, card: Card)
signal turn_ended(player_uuid)
signal equipment_equip()
signal explorer()
signal find_helper(request_player_uuid)
signal helper_selected(helper_uuid)
signal invoke_monster()

var helper_locked := false
# ==========================
# CONFIGURAÇÃO DE SALVAMENTO
# ==========================
const SAVE_PATH = "user://player_info.json"

func _ready():

	if current_player == null:
		current_player = Player.new()
	load_config()
	await get_tree().create_timer(1.0).timeout  # espera 2 segundos
	
func getPlayer(uuid):
	for play in players:
		if play.UUID == uuid:
			return play
# ==========================
# CRIAÇÃO DO JOGADOR LOCAL
# ==========================
func create_player(name: String):
	current_player.name = name
	current_player.UUID = generate_uuid()
	save_config()

	# Atualiza a lista de jogadores (mesmo que seja só ele agora)
	players_data_updated.emit(players)

# ==========================
# SALVA LISTA DE JOGADORES
# ==========================
func savePlayers(_players: Array) -> void:
	players = _players.duplicate()  # evita referência direta
	players_data_updated.emit(players)

# ==========================
# CONFIGURA O TURNO ATUAL
# ==========================
func set_turn(_player_uuid: String) -> void:
	print("\nSET TURN CHAMADO: ", getPlayer(_player_uuid).name,"\n")
	if players.size() == 0:
		print("0 jogadores")
		return

	# atualiza o jogador ativo
	self.player_turn = _player_uuid  # corrigido, antes estava self.player_uuid = self.player_uuid

	# dispara sinal de fase de jogo
	play_phase_started.emit(_player_uuid)

# ==========================
# GERADOR DE UUID
# ==========================
func generate_uuid() -> String:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var hex = "0123456789abcdef"
	var uuid = ""
	for i in range(32):
		uuid += hex[rng.randi_range(0, 15)]
	return uuid

# ==========================
# SALVA CONFIGURAÇÃO LOCAL
# ==========================
func save_config():
	print("Salvando player: ",current_player.UUID)
	var data = {
		"player_name": current_player.name,
		"uuid": current_player.UUID
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

# ==========================
# CARREGA CONFIGURAÇÃO LOCAL
# ==========================
func load_config():
	if not FileAccess.file_exists(SAVE_PATH):
		return null
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if data:
		current_player.name = data.get("player_name", "")
		current_player.UUID = data.get("uuid", "")
		return current_player.name 
	return null
