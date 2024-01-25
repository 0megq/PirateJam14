extends VSplitContainer


func set_score(score: int) -> void:
	$Score.text = "+%s" % score
	$Score.show()


func hide_score() -> void:
	$Score.hide()
