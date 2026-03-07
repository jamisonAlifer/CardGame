extends RefCounted
class_name Deck

var cards: Array[Card] = []
var discart: Array[Card] = []

func _init():
	load_default_cards()
	shuffle()
func card_by_index(index: int) ->  Card:
	return cards[index]
	
func load_default_cards():
	var monsters = load_cards_from_json("res://card/card_monsters.json")
	var equipments = load_cards_from_json("res://card/card.json")
	cards.append_array(monsters)
	cards.append_array(equipments)
	
func shuffle():
	cards.shuffle()

func draw_card() -> Card:
	if cards.is_empty():
		print("Reembaralhando deck...")
		load_default_cards()
		shuffle()
	return cards.pop_back()
	
func load_cards_from_json(path: String) -> Array[Card]:
	var cards: Array[Card] = []

	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	for card_data in data:
		var card := Card.new()
		card.id = card_data["id"]
		card.name = card_data["name"]
		card.rarity = card_data["rarity"]
		card.category = card_data["category"]
		card.slot = card_data["equipment"]["slot"] if card_data["equipment"]["slot"] != null else ""
		card.hands_required = card_data["equipment"]["hands_required"] 
		card.power_bonus = card_data["stats"]["power_bonus"]
		card.value = card_data["economy"]["value"]
		card.effects = card_data["effects"]
		
		if card_data["restrictions"]["class"] != null:
			card.restrictions["class"] = card_data["restrictions"]["class"]

		if card_data["restrictions"]["race"] != null:
			card.restrictions["race"] = card_data["restrictions"]["race"]

		if card_data["category"] == "monster":
			card.monster_level = card_data["monster"]["level"]
			card.monster_power = card_data["monster"]["power"]
			card.reward_levels = card_data["monster"]["rewards"]["levels"]
			card.reward_treasures = card_data["monster"]["rewards"]["treasures"]
		cards.append(card)

	return cards
