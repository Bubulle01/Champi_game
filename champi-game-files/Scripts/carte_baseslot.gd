extends Node2D

var card_in_slot = false
var card_slot_type = "fight"
var card_slot_niv
var position_card_xy

func return_cardslot(card, speed):
	player_hand.insert(0, card)
	update_hand_position(speed)
	else:
		animate_card_to_position(card, card.starting_position, DEFAULT_CARD_MOVE_SPEED)
	
func update_hand_position(speed):
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position, speed)
		
func calculate_card_position(index):
	var total_width = (player_hand.size() -1) * (CARD_WITH + SPACE_BETWEEN)
	var x_offset = center_screen_x + index * (CARD_WITH + SPACE_BETWEEN) - total_width / 2
	return x_offset
