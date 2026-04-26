extends Node

signal time_changed(hour: int, minute: int)
signal phase_changed(phase_name: String)
signal market_opened()
signal market_closed()
signal day_ended()

# 문서 기준 시그널
signal day_started()

# 기존 코드 호환용
signal info_phase_started()

@export var minute_interval_seconds: float = 0.25
@export var auto_run: bool = true

var current_hour: int = 7
var current_minute: int = 0
var is_running: bool = false

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = minute_interval_seconds
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

	# 다른 Autoload들(_ready)까지 끝난 뒤 하루 초기화
	call_deferred("_start_day_setup")


func _start_day_setup() -> void:
	reset_day()

	if auto_run:
		start()


func start() -> void:
	is_running = true
	timer.start()


func stop() -> void:
	is_running = false
	timer.stop()


func reset_day() -> void:
	current_hour = 7
	current_minute = 0
	time_changed.emit(current_hour, current_minute)
	_check_phase_events()


func get_time_string() -> String:
	return "%02d:%02d" % [current_hour, current_minute]


func _on_timer_timeout() -> void:
	if not is_running:
		return

	advance_minute()


func advance_minute() -> void:
	current_minute += 1

	if current_minute >= 60:
		current_minute = 0
		current_hour += 1

	time_changed.emit(current_hour, current_minute)
	_check_phase_events()


func _check_phase_events() -> void:
	if current_hour == 7 and current_minute == 0:
		phase_changed.emit("INFO")

		# 문서 기준
		day_started.emit()

		# 기존 코드 호환용
		info_phase_started.emit()

	elif current_hour == 9 and current_minute == 0:
		phase_changed.emit("MARKET")
		market_opened.emit()

	elif current_hour == 15 and current_minute == 30:
		phase_changed.emit("AFTER_MARKET")
		market_closed.emit()

	elif current_hour == 23 and current_minute == 0:
		phase_changed.emit("SETTLEMENT")
		day_ended.emit()
		reset_day()
