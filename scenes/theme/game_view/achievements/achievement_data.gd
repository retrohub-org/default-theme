extends MarginContainer

@export var unlocked_color : Color
@export var unlocked_hard_core_color : Color

@onready var n_icon_frame := %Frame
@onready var n_icon := %Icon
@onready var n_type := %Type
@onready var n_title := %Title
@onready var n_time := %Time
@onready var n_unlock_rate := %UnlockRate
@onready var n_description := %Description

@onready var max_y := get_viewport().get_visible_rect().size.y + 50
var media_loaded := false
var achievement : RetroAchievementsIntegration.Achievement

static var material_locked := StyleBoxEmpty.new()
static var material_unlocked : StyleBoxFlat
static var material_unlocked_hard_core : StyleBoxFlat

func _ready():
	set_process(false)
	if not material_unlocked and not material_unlocked_hard_core:
		material_unlocked = StyleBoxFlat.new()
		material_unlocked_hard_core = StyleBoxFlat.new()
		for mat: StyleBoxFlat in [material_unlocked, material_unlocked_hard_core]:
			mat.draw_center = false
			mat.corner_radius_top_left = 1
			mat.shadow_size = 5
			mat.anti_aliasing = false
		material_unlocked.shadow_color = unlocked_color
		material_unlocked_hard_core.shadow_color = unlocked_hard_core_color
	n_icon.material = n_icon.material.duplicate(false)

func _process(_delta):
	# Handle behavior differently if currently loaded media or not
	if media_loaded:
		check_unload_media()
	else:
		check_load_media()

# Check if we should unload media
func check_unload_media():
	# Unload if we leave the limits
	var parent_y = get_parent().position.y
	if parent_y + position.y + size.y < -50 or global_position.y > max_y:
		media_loaded = false
		n_icon.texture = null

func check_load_media():
	# Load if we are inside the limits
	var parent_y = get_parent().position.y
	if parent_y + position.y + size.y >= -50 and global_position.y <= max_y:
		media_loaded = true
		n_icon.texture = await achievement.load_icon()

func set_data(info: RetroAchievementsIntegration.GameInfo, achievement: RetroAchievementsIntegration.Achievement):
	self.achievement = achievement
	set_process(true)

	n_title.text = achievement.title
	n_description.text = achievement.description

	var unlock_count
	if achievement.unlocked_hard_mode:
		# Unlockled (hard mode)
		unlock_count = achievement.unlocked_hard_mode_count
		n_icon_frame.add_theme_stylebox_override("panel", material_unlocked_hard_core)
	elif achievement.unlocked:
		# Unlocked (soft mode)
		unlock_count = achievement.unlocked_count
		n_icon_frame.add_theme_stylebox_override("panel", material_unlocked)
	else:
		# Locked
		unlock_count = max(achievement.unlocked_count, achievement.unlocked_hard_mode_count)
		n_icon_frame.add_theme_stylebox_override("panel", material_locked)
		n_icon.material.set_shader_parameter("enable", true)
		n_icon.material.set_shader_parameter("modulate", Color.GRAY)
	n_unlock_rate.text = "Unlocked by %.1f%% other players" % (unlock_count / float(info.player_count) * 100)

	n_type.visible = achievement.type != RetroAchievementsIntegration.Achievement.Type.NORMAL
	match achievement.type:
		RetroAchievementsIntegration.Achievement.Type.MISSABLE:
			n_type.tooltip_text = "This achievement can be missed during a playthrough."
			n_type.texture = preload("res://assets/theme/icons/achievement_missable.svg")
		RetroAchievementsIntegration.Achievement.Type.PROGRESSION:
			n_type.tooltip_text = "This achievement represents in-game progression."
			n_type.texture = preload("res://assets/theme/icons/achievement_progression.svg")
		RetroAchievementsIntegration.Achievement.Type.WIN:
			n_type.tooltip_text = "This achievement means you've reached (one of) the game's ending."
			n_type.texture = preload("res://assets/theme/icons/achievement_win.svg")
