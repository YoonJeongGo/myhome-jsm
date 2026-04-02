extends Node

# =========================================================
# MarketManager.gd
# 현재 main.gd 와 호환되도록 만든 시계열 재생형 버전
#
# main.gd 에서 사용하는 것:
# - stock_names
# - stocks[종목명]["price"]
# - future_fluctuations[종목명]
# - intraday_history[종목명]
# - tick_realtime()
# - advance_day()
#
# CSV 형식:
# ticker,name,day,price
# 005930,삼성전자,1,70100
# 005930,삼성전자,2,70300
# 005930,삼성전자,3,69900
# 000660,SK하이닉스,1,124000
# ...
#
# 또는 3번째 컬럼이 date 여도 상관없음.
# 실제로는 0,1,3 컬럼만 사용함.
# =========================================================

var stocks = {}
var stock_names = []
var future_fluctuations = {}
var intraday_history = {}

# 내부 시계열 저장
# 구조:
# series_by_name[stock_name] = {
#     "ticker": "005930",
#     "history": [70100, 70300, 69900, ...]
# }
var series_by_name = {}

# 현재 tick 위치
var tick_index := 0
var max_ticks := 0

const MAX_STOCKS := 10
const MIN_PRICE := 100

# 기존 단일 스냅샷 CSV 대신 시계열 CSV로 교체해서 사용
const MARKET_DATA_PATH := "res://stock_data.csv"

func _ready():
	load_market_data(MARKET_DATA_PATH)

func load_market_data(file_path: String):
	_reset_all_data()

	if not FileAccess.file_exists(file_path):
		push_error("MarketManager: CSV 파일이 없습니다 -> " + file_path)
		return

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("MarketManager: CSV 파일 열기 실패 -> " + file_path)
		return

	# 헤더 스킵
	if not file.eof_reached():
		file.get_csv_line()

	var selected_names = []

	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.is_empty():
			continue

		# 최소 4컬럼 필요: ticker,name,day/date,price
		if line.size() < 4:
			continue

		var ticker = str(line[0]).strip_edges()
		var stock_name = str(line[1]).strip_edges()
		var price_text = str(line[3]).strip_edges()

		if ticker == "" or stock_name == "" or price_text == "":
			continue

		if not _is_int_like(price_text):
			continue

		var price = max(_to_int_safe(price_text), MIN_PRICE)

		if not series_by_name.has(stock_name):
			if selected_names.size() >= MAX_STOCKS:
				continue

			series_by_name[stock_name] = {
				"ticker": ticker,
				"history": []
			}
			selected_names.append(stock_name)

		series_by_name[stock_name]["history"].append(price)

	file.close()

	_build_runtime_state()

	if stock_names.is_empty():
		push_error("MarketManager: 유효한 시계열 데이터가 없습니다 -> " + file_path)

# =========================================================
# main.gd 호환용 함수
# =========================================================

func tick_realtime():
	if stock_names.is_empty():
		return

	if max_ticks <= 0:
		return

	if tick_index < max_ticks - 1:
		tick_index += 1

	for stock_name in stock_names:
		var history = series_by_name[stock_name]["history"]
		if history.is_empty():
			continue

		var idx = clampi(tick_index, 0, history.size() - 1)
		var new_price = max(int(history[idx]), MIN_PRICE)

		stocks[stock_name]["price"] = new_price
		intraday_history[stock_name].append(new_price)

func advance_day():
	# 현재 버전에서는 같은 시계열을 처음부터 다시 재생
	# 나중에 날짜 묶음 구조가 생기면 여기서 "다음 날짜 그룹"으로 이동시키면 됨
	tick_index = 0

	for stock_name in stock_names:
		var history = series_by_name[stock_name]["history"]
		if history.is_empty():
			continue

		var start_price = max(int(history[0]), MIN_PRICE)
		stocks[stock_name]["price"] = start_price
		intraday_history[stock_name] = [start_price]
		future_fluctuations[stock_name] = _calculate_future_direction(history)

# =========================================================
# 선택 사용 가능 함수
# =========================================================

func get_price(stock_name: String) -> int:
	if not stocks.has(stock_name):
		return 0
	return int(stocks[stock_name].get("price", 0))

func get_history(stock_name: String) -> Array:
	if not intraday_history.has(stock_name):
		return []
	return intraday_history[stock_name]

func get_tick_index() -> int:
	return tick_index

func set_tick_index(value: int):
	tick_index = max(value, 0)

	for stock_name in stock_names:
		var history = series_by_name[stock_name]["history"]
		if history.is_empty():
			continue

		var idx = clampi(tick_index, 0, history.size() - 1)
		stocks[stock_name]["price"] = int(history[idx])

		var rebuilt_history = []
		for i in range(idx + 1):
			rebuilt_history.append(int(history[i]))
		intraday_history[stock_name] = rebuilt_history

func get_ma5(stock_name: String) -> float:
	return _get_moving_average(stock_name, 5)

func get_ma20(stock_name: String) -> float:
	return _get_moving_average(stock_name, 20)

# =========================================================
# 내부 함수
# =========================================================

func _build_runtime_state():
	stock_names.clear()
	stocks.clear()
	future_fluctuations.clear()
	intraday_history.clear()

	for stock_name in series_by_name.keys():
		var info = series_by_name[stock_name]
		var history = info["history"]

		if history.is_empty():
			continue

		var start_price = max(int(history[0]), MIN_PRICE)

		stock_names.append(stock_name)

		stocks[stock_name] = {
			"price": start_price,
			"ticker": info["ticker"]
		}

		intraday_history[stock_name] = [start_price]

		# 기존 뉴스 시스템 호환용
		# 시작값 대비 마지막값 방향으로 상승/하락 힌트 제공
		future_fluctuations[stock_name] = _calculate_future_direction(history)

	max_ticks = _calculate_max_ticks()
	tick_index = 0

func _calculate_max_ticks() -> int:
	var result = 0

	for stock_name in series_by_name.keys():
		var history = series_by_name[stock_name]["history"]
		if history.size() > result:
			result = history.size()

	return result

func _calculate_future_direction(history: Array) -> float:
	if history.size() < 2:
		return 0.0

	var start_price = float(history[0])
	var end_price = float(history[history.size() - 1])

	if start_price <= 0.0:
		return 0.0

	return (end_price - start_price) / start_price

func _get_moving_average(stock_name: String, period: int) -> float:
	if not intraday_history.has(stock_name):
		return 0.0

	var history = intraday_history[stock_name]
	if history.is_empty():
		return 0.0

	var count = mini(period, history.size())
	var sum = 0.0

	for i in range(history.size() - count, history.size()):
		sum += float(history[i])

	return sum / float(count)

func _reset_all_data():
	stocks.clear()
	stock_names.clear()
	future_fluctuations.clear()
	intraday_history.clear()
	series_by_name.clear()
	tick_index = 0
	max_ticks = 0

func _is_int_like(text: String) -> bool:
	if text == "":
		return false

	var normalized = text.replace(",", "")
	if normalized.begins_with("-"):
		normalized = normalized.substr(1)

	if normalized == "":
		return false

	for i in range(normalized.length()):
		var code = normalized.unicode_at(i)
		if code < 48 or code > 57:
			return false

	return true

func _to_int_safe(text: String) -> int:
	return int(text.replace(",", ""))
