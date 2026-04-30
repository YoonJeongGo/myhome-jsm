extends Node

signal time_changed()
signal phase_changed(phase: String)

enum Phase {
	MENU,
	MORNING,
	TRADING,
	SETTLEMENT,
	NIGHT
}

var current_phase: Phase = Phase.MENU
var current_day: int = 1
var current_time: String = "07:00"

@export var tick_interval: float = 1.0  # 1초마다 틱
var timer: Timer
var trading_ticks: int = 0
var max_trading_ticks: int = 180  # 3분 (틱당 1초)

func _ready():
	timer = Timer.new()
	timer.wait_time = tick_interval
	timer.one_shot = false
	timer.timeout.connect(_on_tick)
	add_child(timer)

func start_day():
	current_day = 1
	current_phase = Phase.MORNING
	current_time = "09:00"
	trading_ticks = 0
	phase_changed.emit(get_current_phase())
	time_changed.emit()

func advance_to_morning():
	current_phase = Phase.MORNING
	current_time = "09:00"
	phase_changed.emit(get_current_phase())
	time_changed.emit()

func advance_to_trading():
	current_phase = Phase.TRADING
	current_time = "09:00"
	trading_ticks = 0
	timer.start()
	phase_changed.emit(get_current_phase())
	time_changed.emit()

func advance_to_settlement():
	current_phase = Phase.SETTLEMENT
	timer.stop()
	current_time = "15:30"
	phase_changed.emit(get_current_phase())
	time_changed.emit()

func next_day():
	current_day += 1
	current_phase = Phase.MORNING
	current_time = "09:00"
	trading_ticks = 0

	# MarketManager에 다음 날 준비 요청
	if has_node("/root/MarketManager"):
		var market_manager = get_node("/root/MarketManager")
		market_manager.advance_day()

	phase_changed.emit(get_current_phase())
	time_changed.emit()

func _on_tick():
	if current_phase == Phase.TRADING:
		trading_ticks += 1

		# MarketManager에 가격 업데이트 요청
		if has_node("/root/MarketManager"):
			var market_manager = get_node("/root/MarketManager")
			market_manager.tick_realtime()

		# 거래 시간 종료 체크
		if trading_ticks >= max_trading_ticks:
			advance_to_settlement()

func get_current_phase() -> String:
	match current_phase:
		Phase.MENU:
			return "메뉴"
		Phase.MORNING:
			return "아침"
		Phase.TRADING:
			return "장중"
		Phase.SETTLEMENT:
			return "결산"
		Phase.NIGHT:
			return "야간"
	return "알 수 없음"

func get_formatted_time() -> String:
	return current_time

func is_trading_phase() -> bool:
	return current_phase == Phase.TRADING