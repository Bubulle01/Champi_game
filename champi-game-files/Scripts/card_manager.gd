extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1
const DEFAULT_CARD_SCALE = 0.9
const CARD_BIGGER_SCALE = 1
const CARD_SMALLER_SCALE = 0.7

var card_being_dragged
var screen_size
var is_hovering_on_card
var player_hand_reference
var played_fight_card_this_turn = false

func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x),
			clamp(mouse_pos.y, 0, screen_size.y))

			
func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
	
	# Met la souris au millieu de la carte quand prise
	# var card_pos = card.position
	# Input.warp_mouse(Vector2(card_pos.x,card_pos.y))

func finish_drag():
	card_being_dragged.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		# if card can be placed in this slot
		if card_being_dragged.card_type == card_slot_found.card_slot_type:
			# if card is placed in good slot
			if (card_being_dragged.card_placement + 1 == card_slot_found.card_slot_niv
				or card_being_dragged.card_placement == card_slot_found.card_slot_niv
				or card_being_dragged.card_placement - 1 == card_slot_found.card_slot_niv
				or (card_being_dragged.card_placement > 10 and card_slot_found.card_slot_niv > 10)):
			# if card is placed in the same slot level
				if !played_fight_card_this_turn:
					# Carte laché sur un emplacement vide
					card_being_dragged.scale = Vector2(CARD_SMALLER_SCALE,CARD_SMALLER_SCALE)
					card_being_dragged.z_index = -1
					card_being_dragged.card_placement = card_slot_found.card_slot_niv
					player_hand_reference.remove_card_from_hand(card_being_dragged)
					card_being_dragged.card_slot_is_in = card_slot_found
					card_being_dragged.position = card_slot_found.position
					card_being_dragged.position_card_xy = card_slot_found.position
					if card_being_dragged.card_type == "terrain":
						card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
					card_slot_found.card_in_slot = true
					card_being_dragged = null
					return
	
	if (card_being_dragged.card_placement == 0):
		player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	else:
		card_being_dragged.position = card_slot_found.position
	card_being_dragged = null
	

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		# return (result[0].collider.get_parent())
		return get_card_with_highest_z_index(result)
	return null
	
func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
	
	
func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var currend_card = cards[i].collider.get_parent()
		if currend_card.z_index > highest_z_index:
			highest_z_card = currend_card
			highest_z_index = currend_card.z_index
	return highest_z_card
	
func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	
func on_left_click_released():
	if card_being_dragged:
		finish_drag()
		
func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
	
func on_hovered_off_card(card):
	# Check if card is NOT in card slot
	if !card.card_slot_is_in:
		# Check if card is NOT being dragged
		if !card_being_dragged:
			highlight_card(card, false)
			var new_card_hovered = raycast_check_for_card()
			if new_card_hovered:
				highlight_card(new_card_hovered, true)
			else:
				is_hovering_on_card = false

func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
		card.z_index = 2
	else:
		card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
		card.z_index = 1
	
func reset_player_fight():
	played_fight_card_this_turn = false
