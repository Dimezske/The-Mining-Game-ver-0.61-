extends KinematicBody2D

#class_name Player, "res://Assets/Characters/chacter1.png"
class_name Player

onready var Tool: Node2D = get_node("ToolHolder")
onready var Weapon: Node2D = get_node("WeaponHolder")
onready var parent = get_parent()

var weapon : Dictionary = {
	"M4": load("res://Src/Weapons/AssaultRifles/M4.tscn"),
	"Trm17" : load("res://Src/Weapons/AssaultRifles/Trm17.tscn")
}
var current_weapon
#onready var M4_path = load("res://Scenes/M4.tscn")
#onready var TRM17_path = load("res://Scenes/Trm17.tscn")
onready var items = preload("res://Src/Player&Inventory/Inventory/Item.tscn")
onready var animated_sprite = $AnimatedSprite
onready var velocity = Global.player_velocity
onready var states = $StateMachine
onready var shirt = $Shirt
onready var shirtsleeves = $ShirtSleeves
onready var backpack = $Backpack
onready var tools = $ToolHolder
onready var weapons = $WeaponHolder

var facing
export (int) var speed = 200
var dir = [0,1,2,3]
var player_in_range : bool
var isHoldingTool : bool
var isHoldingWeapon : bool
var isLazer : bool

#var hotbar = null
#func init(hotbar):
#	self.hotbar = hotbar
	
func _ready():
	Global.player_node = self
	#self.global_position = Global.player_initial_map_position
	#states.init(self)
	pass

func _physics_process(_delta):
	_get_input()
	#get_tool_pickup()
	get_weapon_pickup()
	#drop_tool()
	if Input.is_action_just_pressed('fire'): # Test if button is pressed
		for weapons in $WeaponHolder.get_children(): # Iterate over all weapons
			if 'fire' in weapons: # Does this "weapon" essentially have a fire button?
				weapons.fire() # Fire the weapon
				print('fire')

func getClothing(clothing_name):
	match clothing_name:
		"shirt": return shirt

# Player Movements
func _get_input():
	velocity = Vector2()
	speed = Global.player_speed
#states = $StateMachine/Idle
	if Input.is_action_pressed("sprint"):
		#states = $StateMachine/Run
		Global.player_isRunning = true 
		speed = 300
		pass
	else:
		speed = 200
	if Input.is_action_pressed("move-right"):
		Global.player_direction = "0"
		facing = Vector2(1,0)
		velocity.x += 1
		backpack.region_rect = Rect2(50,20,50,50)
		backpack.position = Vector2(-20,-45)
		backpack.z_index = 0
		if $Footsteps.playing == false:
			$Footsteps.play()
	if Input.is_action_pressed("move-left"):
		Global.player_direction = "1"
		facing = Vector2(-1,0)
		velocity.x -= 1
		backpack.region_rect = Rect2(150,20,50,50)
		backpack.position = Vector2(18,-45)
		backpack.z_index = 0
		if $Footsteps.playing == false:
			$Footsteps.play()
	if Input.is_action_pressed("move-down"):
		Global.player_direction = "2"
		facing = Vector2(0,1)
		velocity.y += 1
		backpack.region_rect = Rect2(0,20,50,50)
		backpack.position = Vector2(1,-45)
		backpack.z_index = -1
		if $Footsteps.playing == false:
			$Footsteps.play()
	if Input.is_action_pressed("move-up"):
		Global.player_direction = "3"
		facing = Vector2(0,-1)
		velocity.y -= 1
		backpack.region_rect = Rect2(200,20,50,50)
		backpack.position = Vector2(1,-45)
		backpack.z_index = 0
		if $Footsteps.playing == false:
			$Footsteps.play()

	velocity = velocity.normalized() * speed
	velocity = move_and_slide(velocity)
	# not sure what these are for
	for child in self.get_children():
		if child.is_in_group("ToolHolder"):
			child.animate(velocity)
	for child in self.get_children():
		if child.is_in_group("WeaponHolder"):
			child.animate(velocity)
	#Player Animations for Idle and Walk
#	if velocity == Vector2.ZERO:
#		$AnimationTree.get("parameters/playback").travel("Idle")
#	else:
#		$AnimationTree.get("parameters/playback").travel("Walk")
#		$AnimationTree.set("parameters/Idle/blend_position", velocity)
#		$AnimationTree.set("parameters/Walk/blend_position", velocity)
	if velocity == Vector2.ZERO:
		$AnimationTree.get("parameters/playback").travel("Idle")
	else:
		$AnimationTree.get("parameters/playback").travel("Walk")
		$AnimationTree.set("parameters/Idle/blend_position", facing)
		$AnimationTree.set("parameters/Walk/blend_position", facing)
	#Animation hold
#	for weapons in $Position2D/Weapons.get_children(): # Iterate over all weapons
#		if 'parent_velocity' in weapons: # Does this "weapon" want to receive the player's velocity?
#			weapons.parent_velocity = velocity
	for weapons in $WeaponHolder.get_children(): # Iterate over all weapons
		if 'parent_velocity' in weapons: # Does this "weapon" want to receive the player's velocity?
			weapons.parent_velocity = velocity

func _input(event):
	if event.is_action_pressed("interact"):
		if $PickupZone.items_in_range.size() > 0:
			var pickup_item = $PickupZone.items_in_range.values()[0]
			pickup_item.pick_up_item(self)
			$PickupZone.items_in_range.erase(pickup_item)
		
		for area in $PickupZone.get_overlapping_areas():
			if area.is_in_group("Tools"):
				$Position2D/Tools.add_child(area)
				Global.isHoldingTool = true

func get_weapon_pickup():
	if Input.is_action_just_pressed("interact"):
		for area in $PickupZone.get_overlapping_areas():
			if area.is_in_group("Weapons"):
				area.get_parent().remove_child(area)
				area.position = Vector2(0,-25)
				$WeaponHolder.add_child(area)
				isHoldingWeapon = true
				# someone told me to put this here it has comments already
				for weapon in $WeaponHolder.get_children(): # Iterate over all weapons
					if 'fire' in weapon: # Does this "weapon" essentially have a fire button?
						weapon.fire() # Fire the weapon
						print('fire')

func equip(weapon_name, hotbar):
	print("Weapon Equiped")
	for slot in hotbar.slots:
		print(slot, " slot item: ", slot.item)
		print(weapon)
		if not slot.item:
			return
		if weapon.has(slot.item.item_name):
			var w = weapon[slot.item.item_name].instance()
			get_node("WeaponHolder").add_child(w)
			current_weapon = w
			isHoldingWeapon = true
			return
		print("Weapon not in any slot")
