extends Node

const CARD_BIGGER_SCALE = 1
const CARD_SMALLER_SCALE = 0.7
const MOVE_SPEED = 0.2

var battle_timer
var empty_fight_card_slots = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_timer = $"../BattleTimer"
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	
	empty_fight_card_slots.append($"../CardSlots/CarteSlot6-1")
	empty_fight_card_slots.append($"../CardSlots/CarteSlot6-2")
	empty_fight_card_slots.append($"../CardSlots/CarteSlot6-3")
	empty_fight_card_slots.append($"../CardSlots/CarteSlot6-4")
	
	$"../CardSlots/CarteSlot1-1".card_slot_niv = 1
	$"../CardSlots/CarteSlot1-2".card_slot_niv = 1
	$"../CardSlots/CarteSlot1-3".card_slot_niv = 1
	$"../CardSlots/CarteSlot1-4".card_slot_niv = 1
	$"../CardSlots/CarteSlot2-0".card_slot_niv = 11
	$"../CardSlots/CarteSlot3-1".card_slot_niv = 2
	$"../CardSlots/CarteSlot3-2".card_slot_niv = 2
	$"../CardSlots/CarteSlot3-3".card_slot_niv = 2
	$"../CardSlots/CarteSlotMid".card_slot_niv = 12
	$"../CardSlots/CarteSlot4-1".card_slot_niv = 3
	$"../CardSlots/CarteSlot4-2".card_slot_niv = 3
	$"../CardSlots/CarteSlot4-3".card_slot_niv = 3
	$"../CardSlots/CarteSlot5-0".card_slot_niv = 13
	
func _on_end_turn_button_pressed() -> void:
	opponent_turn()
	
func opponent_turn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	
	# Wait 1 second
	battle_timer.start()
	await battle_timer.timeout
	
	# If can dram a card, draw then 1 second
	if $"../OpponentDeck".opponent_deck.size() != 0:
		$"../OpponentDeck".draw_card()
		battle_timer.start()
		await battle_timer.timeout

	#Check if free fight card slots, and if me, end turn
	if empty_fight_card_slots.size() == 0:
		opponent_turn()
		return
	
	# Try play card and wait 1 second if played
	await try_play_card_with_highest_attack()
	
	end_opponent_turn()
	
func try_play_card_with_highest_attack():
		# Get random empty slot to play the card in 
	var opponent_hand = $"../OpponentHand".opponent_hand
	if opponent_hand.size() == 0:
		end_opponent_turn()
		
	var random_empty_fight_card_slots = empty_fight_card_slots.pick_random()
	empty_fight_card_slots.erase(random_empty_fight_card_slots)
	
	# Play card in hard with higest attack
	var card_with_higest_attack = opponent_hand[0]
	for card in opponent_hand:
		if card.attack > card_with_higest_attack.attack:
			card_with_higest_attack = card
			
	# Animate card to position 
	var tween = get_tree().create_tween()
	tween.tween_property(card_with_higest_attack, "position", random_empty_fight_card_slots.position, MOVE_SPEED)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(card_with_higest_attack, "scale", random_empty_fight_card_slots.scale, MOVE_SPEED)
	card_with_higest_attack.get_node("AnimationPlayer").play("card_flip")
	
	# Remove the card from opponents hand
	$"../OpponentHand".remove_card_from_hand(card_with_higest_attack)
	
	# Wait 1 second
	battle_timer.start()
	await battle_timer.timeout

	
func end_opponent_turn():
	$"../Deck".reset_draw()
	$"../CardManager".reset_player_fight()
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true
