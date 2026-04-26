extends Node

signal game_started
signal day_changed(new_day: int)
signal daily_expense_applied(expense_amount: int, remaining_cash: int)
signal total_assets_changed(total_assets: int)
signal game_over_triggered(reason: String)
signal victory_triggered(reason: String)

# =========================
# 게임 기본 설정
# =========================
@export var start_cash: int = 1000000
@export var daily_living_cost: int = 50000
@export var target_total_assets: int = 30000000

# =========================
# 게임 상태
# =========================
var current_day: int = 1
var is_game_over: bool = false
var is_victory: bool = false
var game_started_once: bool = false

# =========================
# 초기화
# =========================
func _ready() -> void:
	connect_time_manager_signals()
	start_new_game()

# =========================
# TimeManager 시그널 연결
# =========================
func connect_time_manager_signals() -> void:
	if not has_node("/root/TimeManager"):
		print("[경고] GameManager: TimeManager Autoload를 찾을 수 없습니다.")
		return

	if TimeManager.has_signal("day_ended"):
		if not TimeManager.day_ended.is_connected(_on_day_ended):
			TimeManager.day_ended.connect(_on_day_ended)
	else:
		print("[경고] GameManager: TimeManager에 day_ended 시그널이 없습니다.")

# =========================
# 새 게임 시작
# =========================
func start_new_game() -> void:
	current_day = 1
	is_game_over = false
	is_victory = false
	game_started_once = true

	if has_node("/root/PortfolioManager"):
		PortfolioManager.reset_portfolio()
		PortfolioManager.set_cash(start_cash)
	else:
		print("[경고] GameManager: PortfolioManager Autoload를 찾을 수 없습니다.")

	print("=== 새 게임 시작 ===")
	print("현재 일차: ", current_day)
	print("시작 자금: ", start_cash)
	print("하루 생활비: ", daily_living_cost)
	print("목표 총자산: ", target_total_assets)

	game_started.emit()
	day_changed.emit(current_day)
	emit_total_assets_changed()
	check_victory_condition()

# =========================
# 하루 종료 처리
# =========================
func _on_day_ended() -> void:
	if is_game_over or is_victory:
		return

	print("=== 하루 종료 처리 시작 ===")

	apply_daily_living_cost()

	if is_game_over or is_victory:
		return

	next_day()

# =========================
# 생활비 차감
# =========================
func apply_daily_living_cost() -> void:
	if not has_node("/root/PortfolioManager"):
		print("[경고] GameManager: PortfolioManager가 없어 생활비 차감 불가")
		return

	var current_cash: int = PortfolioManager.get_cash()

	# 생활비를 낼 수 없는 경우 게임오버
	if current_cash < daily_living_cost:
		print("[게임오버] 생활비 부족 - 현재 현금:", current_cash, " / 필요 생활비:", daily_living_cost)
		trigger_game_over("생활비 부족")
		return

	var result: bool = PortfolioManager.subtract_cash(daily_living_cost)

	if result:
		var remaining_cash: int = PortfolioManager.get_cash()
		print("[생활비 차감] 금액:", daily_living_cost, " / 남은 현금:", remaining_cash)
		daily_expense_applied.emit(daily_living_cost, remaining_cash)
		emit_total_assets_changed()
		check_victory_condition()
	else:
		print("[게임오버] 생활비 차감 실패")
		trigger_game_over("생활비 차감 실패")

# =========================
# 다음 날로 진행
# =========================
func next_day() -> void:
	current_day += 1
	print("[다음 날 진행] 현재 일차:", current_day)
	day_changed.emit(current_day)

	emit_total_assets_changed()
	check_victory_condition()

# =========================
# 총자산 계산 요청
# 실제 계산은 PortfolioManager가 담당
# =========================
func get_total_assets() -> int:
	if not has_node("/root/PortfolioManager"):
		return 0

	return PortfolioManager.get_total_asset()

func emit_total_assets_changed() -> void:
	var total_assets: int = get_total_assets()
	total_assets_changed.emit(total_assets)

# =========================
# 승리 조건 체크
# =========================
func check_victory_condition() -> void:
	if is_game_over or is_victory:
		return

	var total_assets: int = get_total_assets()

	if total_assets >= target_total_assets:
		trigger_victory("목표 자산 달성")

# =========================
# 현금 조회
# =========================
func get_current_cash() -> int:
	if not has_node("/root/PortfolioManager"):
		return 0

	return PortfolioManager.get_cash()

# =========================
# 현재 날짜 조회
# =========================
func get_current_day() -> int:
	return current_day

# =========================
# 목표 자산 조회
# =========================
func get_target_total_assets() -> int:
	return target_total_assets

# =========================
# 목표 달성률 조회
# =========================
func get_goal_progress_percent() -> float:
	if target_total_assets <= 0:
		return 0.0

	return (float(get_total_assets()) / float(target_total_assets)) * 100.0

# =========================
# 게임오버 처리
# =========================
func trigger_game_over(reason: String) -> void:
	if is_game_over or is_victory:
		return

	is_game_over = true
	print("=== 게임오버 ===")
	print("사유: ", reason)

	game_over_triggered.emit(reason)

# =========================
# 승리 처리
# =========================
func trigger_victory(reason: String) -> void:
	if is_game_over or is_victory:
		return

	is_victory = true
	print("=== 승리 ===")
	print("사유: ", reason)

	victory_triggered.emit(reason)

# =========================
# 상태 조회
# =========================
func is_running() -> bool:
	return game_started_once and not is_game_over and not is_victory

# =========================
# 디버그 출력
# =========================
func print_game_status() -> void:
	print("========== 게임 상태 ==========")
	print("현재 일차: ", current_day)
	print("게임오버 여부: ", is_game_over)
	print("승리 여부: ", is_victory)
	print("현재 현금: ", get_current_cash())
	print("현재 총자산: ", get_total_assets())
	print("목표 총자산: ", target_total_assets)
	print("목표 달성률: %.2f%%" % get_goal_progress_percent())
	print("하루 생활비: ", daily_living_cost)
	print("================================")
