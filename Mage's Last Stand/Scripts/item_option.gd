extends ColorRect

var mouse_over := false
var item = null
@onready var player := get_tree().get_first_node_in_group("player")
@onready var name_label := $NameLabel
@onready var description_label := $DescriptionLabel
@onready var level_label := $LevelLabel
@onready var item_icon := $ItemBackground/ItemIcon
signal selected_item(item)

func _ready():
	connect("selected_item",Callable(player,"upgrade_character"))
	if item == null:
		item = "food"
	name_label.text = UpgradeDatabase.UPGRADES[item]["displayname"]
	description_label.text = UpgradeDatabase.UPGRADES[item]["details"]
	level_label.text = UpgradeDatabase.UPGRADES[item]["level"]
	item_icon.texture = load(UpgradeDatabase.UPGRADES[item]["icon"])

func _input(event):
	if event.is_action("left_click"):
		if mouse_over:
			emit_signal("selected_item",item)

func _on_mouse_entered():
	mouse_over = true

func _on_mouse_exited():
	mouse_over = false
