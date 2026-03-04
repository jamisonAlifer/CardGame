extends RefCounted
class_name Player

# --- Base Attributes ---
var name: String
var level: int = 1
var base_power: int = 1
var gold: int = 0
var identity: String = ""
var skip_turns: int = 0

# Cards in hand (TIPADO)
var hand: Array[Card] = []

# Equipment slots
var equipment := {
	"hand":  { "items": [] as Array[Card], "max": 2 },
	"feet":  { "items": [] as Array[Card], "max": 1 },
	"chest": { "items": [] as Array[Card], "max": 1 },
	"head":  { "items": [] as Array[Card], "max": 1 },
	"legs":  { "items": [] as Array[Card], "max": 1 }
}

func setname(_name: String) -> void:
	name = _name
# --- Equipment Logic ---
func equip_item(item: Card) -> void:
	if not equipment.has(item.slot):
		print("Equipamento não pode ser usado: "+ item.name)
		return
	
	var slot_data = equipment[item.slot]
	
	# Special rule for hand (hands_required)
	if item.slot == "hands":
		var used_hands := 0
		for equipped in slot_data["items"]:
			used_hands += equipped.hands_required
		if used_hands + item.hands_required > slot_data["max"]:
			print("Mãos sem espaço: "+ item.name)
			return
	
	if slot_data["items"].size() < slot_data["max"]:
		slot_data["items"].append(item)
		print(item.slot)
		hand.erase(item)

# --- Power Calculation ---
func get_power() -> int:
	return level + base_power + calculate_bonus()

func calculate_bonus() -> int:
	var total: int = 0
	
	for slot in equipment:
		var slot_data = equipment[slot]
		for item in slot_data["items"]:
			total += item.power_bonus
	
	return total

# --- Hand Management ---
func add_to_hand(card: Card) -> void:
	hand.append(card)

func discard_from_hand(index: int) -> void:
	if index >= 0 and index < hand.size():
		hand.remove_at(index)
		
func level_up(_level:int):
	level += _level
	print("Palyer subiu para o nivel: "+str(level))
