extends Node2D

const CARD_SCENE_PATH = "res://Scene/opponent_carte.tscn"
const CARD_DRAW_SPEED = 0.2
const STARTING_HAND_SIZE = 5

var opponent_deck = ["carteMerde","carteMouche","carteTerrain","carteChampiBoxer","carteMouche","carteMouche","carteMouche"]
var card_database_reference

func _ready() -> void:
	opponent_deck.shuffle()
	$RichTextLabel.visible = true
	$RichTextLabel.text = str(opponent_deck.size())
	card_database_reference = preload("res://Scripts/card_database.gd")
	for i in range(STARTING_HAND_SIZE):
		draw_card()
	
func draw_card():
	var card_drawn_name = opponent_deck[0]
	opponent_deck.erase(card_drawn_name)
	
	if opponent_deck.size() == 0:
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(opponent_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://Assets/sprites/" + card_drawn_name + ".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.get_node("BackCard").texture = load(str("res://Assets/sprites/deckAdverse.png"))
	new_card.get_node("PV").text = str(card_database_reference.CARDS[card_drawn_name][0])
	new_card.attack = card_database_reference.CARDS[card_drawn_name][1]
	new_card.get_node("Atk").text = str(new_card.attack)
	new_card.card_type = str(card_database_reference.CARDS[card_drawn_name][2])
	new_card.card_equipe = 2
	new_card.card_placement = 6
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../OpponentHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	
	
