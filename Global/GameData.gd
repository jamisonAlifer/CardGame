extends Node

# ==========================
# DADOS DO JOGADOR / JOGO
# ==========================
var current_player: Player 
var player_uuid: String = ""
var players: Array = []

var turn_time: float = 05.0  # 30 segundos
var _turn_timer: Timer
var _remaining_time: float = 0.0
# ==========================
# SINAIS
# ==========================
# Emitido quando a lista de jogadores é atualizada
signal players_data_updated(players: Array[Player])
signal turn_started(player_uuid)
signal play_phase_started(player_uuid)
signal combat_phase_started(player_uuid: String, card: Card)
signal turn_ended(player_uuid)
signal turn_timer_updated(seconds_left)  # envia o tempo restante
# ==========================
# CONFIGURAÇÃO DE SALVAMENTO
# ==========================
const SAVE_PATH = "user://player_info.json"

func _ready():
	# Cria a instância do Player aqui
	turn_started.connect(set_turn)
	
	if current_player == null:
		current_player = Player.new()
	load_config()
	await get_tree().create_timer(1.0).timeout  # espera 2 segundos
	create_timer()
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
	print("save Player, player: ", current_player.name)
	players = _players.duplicate()  # evita referência direta
	players_data_updated.emit(players)

# ==========================
# CONFIGURA O TURNO ATUAL
# ==========================
func set_turn(_player_uuid: String) -> void:
	print("iniciando turno de: ", _player_uuid)
	if players.size() == 0:
		print("0 jogadores")
		return

	# atualiza o jogador ativo
	self.player_uuid = _player_uuid  # corrigido, antes estava self.player_uuid = self.player_uuid

	# define tempo restante e inicia o timer
	_remaining_time = turn_time
	_turn_timer.start()

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
	print("SAlvando player: ",current_player.UUID)
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
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	print("buscando player: ",current_player.UUID)
	if data:
		current_player.name = data.get("player_name", "")
		current_player.UUID = data.get("uuid", "")
		
func create_timer():
	# cria um timer interno
	_turn_timer = Timer.new()
	_turn_timer.wait_time = 1.0  # tick a cada 1 segundo
	_turn_timer.one_shot = false
	_turn_timer.autostart = false
	add_child(_turn_timer)
	_turn_timer.timeout.connect(_on_timer_tick)
	
func _on_timer_tick():
	if _remaining_time >0 :
		_remaining_time -= 1
		emit_signal("turn_timer_updated", _remaining_time)
	return
