#Slot.gd
extends Panel

var default_tex = preload("res://Src/Assets/GUI/inventory-slot.png")
var empty_tex = preload("res://Src/Assets/GUI/inventory-slot-inactive.png")
var selected_tex = preload("res://Src/Assets/GUI/hotbar_selected_slot.png")

var default_style: StyleBoxTexture = null
var empty_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null

var ItemClass = preload("res://Src/Player&Inventory/Inventory/Item.tscn")
var item = null
var slot_index
var slot_type

enum SlotType {
	HOTBAR = 0,
	INVENTORY,
	SHIRTS,
	SHORTS,
	PANTS,
	SHOES,
	NECKLACES,
	BACKPACKS,
	LEFTRINGS,
	RIGHTRINGS,
	VESTS,
	GRENADES,
	LEFTUTILITIES,
	RIGHTUTILITIES,
}

func _ready():
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	default_style.texture = default_tex
	empty_style.texture = empty_tex
	selected_style.texture = selected_tex
	refresh_style()

func refresh_style():
	if slot_type == SlotType.SHIRTS:
		if find_parent("Inventory").equip_slots[0].item:
			find_parent("Inventory")._on_shirt_change(find_parent("Inventory").equip_slots[0].slot_type,true)
		else:
			find_parent("Inventory")._on_shirt_change(find_parent("Inventory").equip_slots[0].slot_type,false)
	if slot_type == SlotType.BACKPACKS:
		if find_parent("Inventory").equip_slots[4].item:
			find_parent("Inventory")._on_set_backpack(find_parent("Inventory").equip_slots[4].slot_type,true)
		else:
			find_parent("Inventory")._on_set_backpack(find_parent("Inventory").equip_slots[4].slot_type,false)
	if slot_type == SlotType.HOTBAR:
		if find_parent("Hotbar").slots[0].item:
			find_parent("Hotbar")._on_set_assault_rifle(find_parent("Hotbar").slots[0].slot_type,true)
			find_parent("Hotbar")._on_set_mining_drill(find_parent("Hotbar").slots[0].slot_type,true)
		else:
			find_parent("Hotbar")._on_set_assault_rifle(find_parent("Hotbar").slots[0].slot_type,false)
			find_parent("Hotbar")._on_set_mining_drill(find_parent("Hotbar").slots[0].slot_type,false)
			
	if SlotType.HOTBAR == slot_type and PlayerInventory.active_item_slot == slot_index:
		set('custom_styles/panel', selected_style)
	elif item == null:
		set('custom_styles/panel', empty_style)
	else:
		set('custom_styles/panel', default_style)

func pickFromSlot():
	remove_child(item)
	var inventoryNode = find_parent("UserInterface")
	inventoryNode.add_child(item)
	item.z_index = 3
	item = null
	refresh_style()
	
func putIntoSlot(new_item):
	item = new_item
	item.position = Vector2(0, 0)
	var inventoryNode = find_parent("UserInterface")
	inventoryNode.remove_child(item)
	add_child(item)
	item.z_index = 1
	refresh_style()

func initialize_item(item_name, item_quantity):
	if item == null:
		item = ItemClass.instance()
		add_child(item)
		item.set_item(item_name, item_quantity)
	else:
		item.set_item(item_name, item_quantity)
	refresh_style()
