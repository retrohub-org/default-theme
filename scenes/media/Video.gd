extends TextureRect

@export var loop := false
@export var volume_db := 0.0: set = set_volume_db

func set_volume_db(_volume_db: float):
	volume_db = _volume_db
	$Container/VideoStreamPlayer.volume_db = volume_db

func _process(delta):
	pass
	#if $Container/VideoStreamPlayer.is_playing():
	#	

func get_video_player():
	return $Container/VideoStreamPlayer

func play():
	$Container/VideoStreamPlayer.play()
	await get_tree().process_frame
	setup_ratio()

func stop():
	$Container/VideoStreamPlayer.stop()

func setup_ratio():
	var tex : Texture2D = $Container/VideoStreamPlayer.get_video_texture()
	if tex:
		texture = tex
		$Container.ratio = tex.get_size().aspect()

func _on_VideoPlayer_finished():
	if loop:
		$Container/VideoStreamPlayer.stream_position = 0
		$Container/VideoStreamPlayer.play()
