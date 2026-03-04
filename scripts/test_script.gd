extends Node2D
func _ready():
	var player = Player.new()
	
	var cards = load_cards_from_json("res://card/card.json")
	var dagger = cards[1]
	
	player.add_to_hand(dagger)
	print("Hand before:", player.hand.size())
	
	player.equip_item(dagger)
	
	print("Hand after:", player.hand.size())
	print("Equipped in hand:", player.equipment["hand"]["items"].size())
	print("Total power:", player.get_power())
	print("Bonus:", player.calculate_bonus())
	print("Level:", player.level)
	print("Base:", player.base_power)
	
	
func load_cards_from_json(path: String) -> Array[Card]:
	var cards: Array[Card] = []

	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	for card_data in data:
		var card := Card.new()
		card.id = card_data["id"]
		card.name = card_data["name"]
		card.rarity = card_data["rarity"]

		card.slot = card_data["equipment"]["slot"]
		card.hands_required = card_data["equipment"]["hands_required"]
		card.power_bonus = card_data["stats"]["power_bonus"]
		card.value = card_data["economy"]["value"]

		if card_data["restrictions"]["class"] != null:
			card.restrictions["class"] = card_data["restrictions"]["class"]

		if card_data["restrictions"]["race"] != null:
			card.restrictions["race"] = card_data["restrictions"]["race"]

		card.effects = card_data["effects"]

		cards.append(card)

	return cards
