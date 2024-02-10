extends MarginContainer

@export var mastery_color : Color
@export var mastery_hardcore_color : Color

@onready var n_data := %Data
@onready var n_achievement_cnt := %AchievementContainer
@onready var n_completion_progression_details := %CompletionProgressionDetails
@onready var n_completion_win_details := %CompletionWinDetails
@onready var n_completion_bar := %CompletionBar
@onready var n_completion_complete := %CompletionComplete
@onready var n_completion_progress := %CompletionProgress
@onready var n_mastery_details := %MasteryDetails
@onready var n_mastery_details_hardcore := %MasteryDetailsHardcore
@onready var n_mastery_bar := %MasteryBar
@onready var n_mastery_bar_hardcore := %MasteryBarHardcore
@onready var n_mastery_complete := %MasteryComplete
@onready var n_mastery_progression_hardcore := %MasteryProgressionHardcore
@onready var n_mastery_progression := %MasteryProgression

@onready var completion_progression_details_base_text : String = n_completion_progression_details.text
@onready var completion_win_details_base_text : String = n_completion_win_details.text
@onready var mastery_details_base_text : String = n_mastery_details.text
@onready var mastery_details_hardcore_base_text : String = n_mastery_details_hardcore.text

@onready var n_loading := %Loading

@onready var n_error := %Error
@onready var n_error_label := %ErrorLabel
@onready var n_retry_button := %RetryButton

@onready var n_unavailable := %Unavailable

@onready var achievement_data_scene := preload("res://scenes/theme/game_view/achievements/achievement_data.tscn")

var rcheevos : RetroAchievementsIntegration
var game_data : RetroHubGameData
var game_info : RetroAchievementsIntegration.GameInfo

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_config_changed()
	RetroHubConfig.config_updated.connect(func(key: String, old, new):
		_on_config_changed()
	)

func _on_config_changed():
	if RetroHubConfig.config.integration_rcheevos_enabled:
		setup_achievements()
		_on_visibility_changed()
	else:
		if is_instance_valid(rcheevos):
			rcheevos.queue_free()
			rcheevos = null
		set_node_visible(n_unavailable)

func set_error_retry(error: String, retry_callable: Callable):
	set_error(error)
	for callable in n_retry_button.get_signal_connection_list("pressed"):
		n_retry_button.disconnect("pressed", callable["callable"])
	if retry_callable:
		n_retry_button.visible = true
		n_retry_button.connect("pressed", retry_callable, CONNECT_ONE_SHOT)
	else:
		n_retry_button.visible = false

func set_error(error: String):
	set_node_visible(n_error)
	n_error_label.text = error
	n_retry_button.visible = false

func setup_achievements():
	if rcheevos:
		remove_child(rcheevos)
		rcheevos.queue_free()
	if RetroAchievementsIntegration.is_available():
		rcheevos = RetroAchievementsIntegration.new()
		add_child(rcheevos)
		await get_tree().process_frame
		if not is_instance_valid(rcheevos):
			set_error_retry("An error ocurred when initializing RetroAchievements. Please check the console for more details", setup_achievements)
			rcheevos = null
	else:
		set_node_visible(n_unavailable)

func set_node_visible(node: Node):
	n_data.visible = n_data == node
	n_loading.visible = n_loading == node
	n_error.visible = n_error == node
	n_unavailable.visible = n_unavailable == node

func _on_open_settings_button_pressed():
	RetroHubUI.open_app_config()

func _on_visibility_changed():
	if is_visible_in_tree() and rcheevos:
		set_node_visible(n_loading)
		game_info = await rcheevos.get_game_info(game_data)
		match game_info.err:
			RetroAchievementsIntegration.GameInfo.Error.OK:
				await load_achievements()
				set_node_visible(n_data)
			RetroAchievementsIntegration.GameInfo.Error.ERR_INVALID_CRED:
				set_error_retry("The RetroAchievements credentials are invalid. Please check your settings and try again.", _on_visibility_changed)
			RetroAchievementsIntegration.GameInfo.Error.ERR_CONSOLE_NOT_SUPPORTED:
				set_error("The \"%s\" system is not yet supported by RetroAchievements. If you think this is a mistake, please open a bug report on RetroHub." % game_data.system.fullname)
			RetroAchievementsIntegration.GameInfo.Error.ERR_GAME_NOT_FOUND:
				set_error("Your game file could not be found on RetroAchievements' database. Please ensure the game hash matches one of the supported hashes, listed on the website's game info page.\n\nYour game hash: %s" % rcheevos.get_game_hash(game_data))
			RetroAchievementsIntegration.GameInfo.Error.ERR_NETWORK:
				set_error_retry("There was a network error. Please check your internet connection, and check if the RetroAchievements website is online.", _on_visibility_changed)
			RetroAchievementsIntegration.GameInfo.Error.ERR_INTERNAL, _:
				set_error_retry("There was an internal error. Please check the console for more details, and report this error on RetroHub.", _on_visibility_changed)
	elif n_achievement_cnt != null:
		for child in n_achievement_cnt.get_children():
			n_achievement_cnt.remove_child(child)
			child.queue_free()

func load_achievements():
	var unlock_count := 0
	var unlock_hardcore_count := 0
	var total_progresion := 0
	var total_win := 0
	var unlock_progression := 0
	var unlock_win := 0
	for achievement in game_info.achievements:
		if achievement.unlocked:
			unlock_count += 1
		if achievement.unlocked_hard_mode:
			unlock_hardcore_count += 1
		if achievement.type == RetroAchievementsIntegration.Achievement.Type.PROGRESSION:
			total_progresion += 1
			if achievement.unlocked or achievement.unlocked_hard_mode:
				unlock_progression += 1
		if achievement.type == RetroAchievementsIntegration.Achievement.Type.WIN:
			total_win += 1
			if achievement.unlocked or achievement.unlocked_hard_mode:
				unlock_win += 1

	n_completion_progression_details.text = completion_progression_details_base_text % [
		unlock_progression, total_progresion
	]
	if total_win > 0:
		n_completion_win_details.visible = true
		if unlock_win > 0:
			n_completion_win_details.text = "Achieved %d out of %d endings" % [unlock_win, total_win]
		else:
			n_completion_win_details.text = completion_win_details_base_text % total_win
	elif unlock_progression < total_progresion:
		n_completion_win_details.visible = false
	if total_progresion == 0:
		n_completion_bar.value = 0
		n_completion_complete.visible = false
		n_completion_progress.text = "???"
		n_completion_progression_details.text = "(no progression info to evaluate)" 
	else:
		var completion_value := unlock_progression / float(total_progresion)
		n_completion_complete.visible = is_equal_approx(completion_value, 1.0)
		n_completion_bar.value = completion_value
		n_completion_progress.text = "%d%%" % floori(completion_value * 100)
	
	var total_count := game_info.achievements.size()
	n_mastery_details.text = mastery_details_base_text % [unlock_count, total_count]
	n_mastery_details_hardcore.text = mastery_details_hardcore_base_text % [unlock_hardcore_count]
	n_mastery_bar.max_value = total_count
	n_mastery_bar.value = unlock_count
	n_mastery_bar_hardcore.max_value = total_count
	n_mastery_bar_hardcore.value = unlock_hardcore_count

	var mastery_value := unlock_count / float(total_count)
	var mastery_hardcore_value := unlock_hardcore_count / float(total_count)
	if is_equal_approx(mastery_value, mastery_hardcore_value):
		n_mastery_progression.visible = false
	else:
		n_mastery_progression.visible = true
		n_mastery_progression.text = "%d%%" % floori(mastery_value * 100)
	n_mastery_progression_hardcore.text = "%d%%" % floori(mastery_hardcore_value * 100)
	if is_equal_approx(mastery_hardcore_value, 1.0):
		n_mastery_complete.visible = true
		n_mastery_complete.modulate = mastery_hardcore_color
	elif is_equal_approx(mastery_value, 1.0):
		n_mastery_complete.visible = true
		n_mastery_complete.modulate = mastery_color
	else:
		n_mastery_complete.visible = false
	
	var instance_count := 0
	for achievement in game_info.achievements:
		var data := achievement_data_scene.instantiate()
		n_achievement_cnt.add_child(data)
		data.set_data(game_info, achievement)
		instance_count += 1
		# Instancing objects stalls the main thread. Multithreading cannot solve this sadly.
		# So, we only instance 3 objects per frame, to prevent visible stutters.
		if instance_count > 2:
			instance_count = 0
			await get_tree().process_frame
