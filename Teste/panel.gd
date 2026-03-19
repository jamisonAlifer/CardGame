extends Control

func can_receive(card):
	# regras do slot
	return true


func try_receive(card):
	if can_receive(card):
		print("Carta recebida:", card.name)
		
		card.get_parent().remove_child(card)
