extends Node

# ==========================
# DADOS DO JOGO
# ==========================
var current_player: Player
var players: Array[Player]
var player_turn: String
var helper_locked := false

# ==========================
# SINAIS
# ==========================
signal players_ready                                          # lista de jogadores populada
signal players_data_updated                                   # lista de jogadores atualizada
signal turn_started(player_uuid: String)
signal play_phase_started(player_uuid: String)
signal combat_phase_started(player_uuid: String, card: Card)
signal turn_ended(player_uuid: String)
signal equipment_equip
signal explorer
signal find_helper(request_player_uuid: String)
signal helper_selected(helper_uuid: String)
signal invoke_monster

# ==========================
# CONSTANTES
# ==========================
const SAVE_PATH = "user://player_info.json"

# ==========================
# READY
# ==========================
func _ready() -> void:
	if current_player == null:
		current_player = Player.new()
	load_config()

# ==========================
# CRIAÇÃO DO JOGADOR LOCAL
# ==========================
func create_player(name: String) -> void:
	current_player.name = name
	current_player.UUID = generate_uuid()
	save_config()
	players_data_updated.emit()

# ==========================
# SALVA LISTA DE JOGADORES
# ==========================
func savePlayers(_players: Array) -> void:
	players = _players.duplicate()
	players_ready.emit()  # ← avisa que a lista está pronta para a UI

# ==========================
# BUSCA JOGADOR POR UUID
# ==========================
func getPlayer(uuid: String) -> Player:
	for player in players:
		if player.UUID == uuid:
			return player
	push_error("getPlayer: UUID não encontrado -> " + uuid)
	return null

# ==========================
# CONFIGURA O TURNO ATUAL
# ==========================
func set_turn(player_uuid: String) -> void:
	if players.size() == 0:
		push_error("set_turn: nenhum jogador na lista")
		return
	var player = getPlayer(player_uuid)
	if player == null:
		return
	print("\nSET TURN: ", player.name, "\n")
	player_turn = player_uuid
	play_phase_started.emit(player_uuid)

# ==========================
# GERADOR DE UUID
# ==========================
func generate_uuid() -> String:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	const HEX = "0123456789abcdef"
	var uuid = ""
	for i in range(32):
		uuid += HEX[rng.randi_range(0, 15)]
	return uuid

# ==========================
# SALVA CONFIGURAÇÃO LOCAL
# ==========================
func save_config() -> void:
	var data = {
		"player_name": current_player.name,
		"uuid": current_player.UUID
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("save_config: não foi possível abrir o arquivo")
		return
	file.store_string(JSON.stringify(data))
	file.close()
	print("Configuração salva: ", current_player.UUID)

# ==========================
# CARREGA CONFIGURAÇÃO LOCAL
# ==========================
func load_config() -> String:
	if not FileAccess.file_exists(SAVE_PATH):
		return ""
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("load_config: não foi possível abrir o arquivo")
		return ""
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data:
		current_player.name = data.get("player_name", "")
		current_player.UUID = data.get("uuid", "")
		return current_player.name
	return ""
