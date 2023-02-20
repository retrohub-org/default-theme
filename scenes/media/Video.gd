extends TextureRect

export var loop := false
export(float, -80, 24, 0.01) var volume_db := 0.0 setget set_volume_db

func set_volume_db(_volume_db: float):
	volume_db = _volume_db
	$Container/VideoPlayer.volume_db = volume_db

func _process(delta):
	if $Container/VideoPlayer.is_playing():
		var tex : Texture = $Container/VideoPlayer.get_video_texture()
		texture = tex

func get_video_player():
	return $Container/VideoPlayer

func play():
	$Container/VideoPlayer.play()
	yield(get_tree(), "idle_frame")
	setup_ratio()

func stop():
	$Container/VideoPlayer.stop()

func setup_ratio():
	var tex : Texture = $Container/VideoPlayer.get_video_texture()
	if tex:
		tex.flags |= Texture.FLAG_MIPMAPS
		$Container.ratio = tex.get_size().aspect()

func _on_VideoPlayer_finished():
	if loop:
		$Container/VideoPlayer.play()
