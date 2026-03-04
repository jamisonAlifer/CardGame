extends Resource
class_name Card

@export var id: String                 # Identificador único da carta
@export var name: String               # Nome visível da carta
@export var slot: String               # Slot onde pode ser equipado (hand, feet, chest, head, legs)
@export var hands_required: int = 1    # Quantas mãos ocupa (para armas)
@export var power_bonus: int = 0       # Bônus de poder que adiciona ao jogador
@export var value: int = 0             # Valor em ouro
@export var restrictions: Dictionary = {
	"class": [],
	"race": []
}
@export var rarity: String = "common"  # Raridade da carta (common, rare, epic, legendary)
@export var effects: Array = []        # Efeitos especiais (pode ser uma lista de dicionários ou strings)


@export var category: String

# Monster
var monster_level: int = 0
var monster_power: int = 0
var reward_gold: int = 0
var reward_levels: int = 0
