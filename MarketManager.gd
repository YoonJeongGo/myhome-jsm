extends Node

signal prices_updated()

var stocks = {}
var stock_names = []
var future_fluctuations = {}
var intraday_history = {}

var snapshot_by_name = {}
var ticker_to_name = {}

var tick_index = 0
var max_ticks = 180

const MAX_STOCKS = 10
const MIN_PRICE = 100
const MARKET_DATA_PATH = "res://stock_data.csv"

func _ready():
	randomize()
	load_market_data(MARKET_DATA_PATH)

func load_market_data(file_path: String) -> void:
	_reset_all_data()

	if not FileAccess.file_exists(file_path):
		push_error("CSV 없음 -> " + file_path)
		return

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("CSV 열기 실패")
		return

	# 헤더 제거
	if not file.eof_reached():
		file.get_csv_line()

	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() < 4:
			continue

		var ticker = str(line[0]).strip_edges()
		var stock_name = str(line[1]).strip_edges()
		var price_text = str(line[3]).strip_edges()

		if ticker == "" or stock_name == "":
			continue

		if not _is_int_like(price_text):
			continue

		if stock_names.size() >= MAX_STOCKS:
			continue

		var base_price = int(price_text)
		base_price = max(base_price, MIN_PRICE)

		var path = _generate_path(base_price)

		snapshot_by_name[stock_name] = {
			"ticker": ticker,
			"base_price": base_price,
			"path": path
		}
		ticker_to_name[ticker] = stock_name

	file.close()
	_build_runtime()

	if stock_names.is_empty():
		push_error("종목 데이터 없음")

# =========================

func tick_realtime():
	if stock_names.is_empty():
		return

	if tick_index < max_ticks - 1:
		tick_index += 1

	for stock_name in stock_names:
		var path = snapshot_by_name[stock_name]["path"]
		var idx = clampi(tick_index, 0, path.size() - 1)

		var price = int(path[idx])
		price = max(price, MIN_PRICE)

		stocks[stock_name]["price"] = price
		intraday_history[stock_name].append(price)

func advance_day():
	tick_index = 0

	for stock_name in stock_names:
		var base_price = snapshot_by_name[stock_name]["base_price"]
		var path = _generate_path(base_price)

		snapshot_by_name[stock_name]["path"] = path

		var start_price = int(path[0])

		stocks[stock_name]["price"] = start_price
		intraday_history[stock_name] = [start_price]
		future_fluctuations[stock_name] = _calc_direction(path)

# =========================

func _build_runtime():
	stock_names.clear()
	stocks.clear()
	intraday_history.clear()
	future_fluctuations.clear()

	for stock_name in snapshot_by_name.keys():
		var path = snapshot_by_name[stock_name]["path"]

		if path.is_empty():
			continue

		var start_price = int(path[0])

		stock_names.append(stock_name)

		stocks[stock_name] = {
			"price": start_price,
			"ticker": snapshot_by_name[stock_name]["ticker"]
		}

		intraday_history[stock_name] = [start_price]
		future_fluctuations[stock_name] = _calc_direction(path)

# =========================

func _generate_path(base_price: int) -> Array:
	var path = []

	var high = int(base_price * 1.05)
	var low = int(base_price * 0.95)

	var pivot1 = randi_range(20, 70)
	var pivot2 = randi_range(90, 150)

	if pivot2 <= pivot1:
		pivot2 = pivot1 + 10

	var bullish = randf() > 0.5

	var a = base_price
	var b = high if bullish else low
	var c = low if bullish else high
	var d = int(randf_range(low, high))

	for i in range(max_ticks):
		var t = 0.0
		var price = 0.0

		if i <= pivot1:
			t = float(i) / max(pivot1, 1)
			price = lerp(a, b, t)
		elif i <= pivot2:
			t = float(i - pivot1) / max(pivot2 - pivot1, 1)
			price = lerp(b, c, t)
		else:
			t = float(i - pivot2) / max(max_ticks - pivot2, 1)
			price = lerp(c, d, t)

		price += randi_range(-10, 10)
		price = max(int(price), MIN_PRICE)

		path.append(price)

	path[0] = base_price
	path[path.size() - 1] = d

	return path

# =========================

func _calc_direction(path: Array) -> float:
	if path.size() < 2:
		return 0.0

	var start = float(path[0])
	var end = float(path[path.size() - 1])

	if start == 0:
		return 0.0

	return (end - start) / start

# =========================

func _reset_all_data():
	stocks.clear()
	stock_names.clear()
	future_fluctuations.clear()
	intraday_history.clear()
	snapshot_by_name.clear()
	ticker_to_name.clear()
	tick_index = 0

func get_stock_name(stock_id: String) -> String:
	if ticker_to_name.has(stock_id):
		return ticker_to_name[stock_id]

	if stocks.has(stock_id):
		return stock_id

	return ""

func get_price(stock_id: String) -> float:
	var stock_name = get_stock_name(stock_id)
	if stock_name == "":
		return 0.0

	if stocks.has(stock_name):
		return float(stocks[stock_name]["price"])

	return 0.0

func get_all_stock_ids() -> Array:
	return ticker_to_name.keys()

func get_tick_index() -> int:
	return tick_index

func apply_trend(stock_id: String, trend_value: float) -> void:
	var stock_name = get_stock_name(stock_id)
	if stock_name == "":
		push_error("MarketManager.apply_trend: stock_id not found: " + stock_id)
		return

	if not future_fluctuations.has(stock_name):
		future_fluctuations[stock_name] = 0.0

	future_fluctuations[stock_name] = clamp(future_fluctuations[stock_name] + trend_value, -1.0, 1.0)

	if stocks.has(stock_name):
		var current_price = float(stocks[stock_name]["price"])
		current_price = max(int(current_price * (1.0 + trend_value)), MIN_PRICE)
		stocks[stock_name]["price"] = int(current_price)
		if intraday_history.has(stock_name):
			intraday_history[stock_name].append(int(current_price))

	if has_signal("prices_updated"):
		prices_updated.emit()

func get_ma5(stock_id: String) -> float:
	return _calculate_moving_average(stock_id, 5)

func get_ma20(stock_id: String) -> float:
	return _calculate_moving_average(stock_id, 20)

func _calculate_moving_average(stock_id: String, period: int) -> float:
	if not intraday_history.has(stock_id):
		return 0.0

	var history = intraday_history[stock_id]
	if history.size() < period:
		return 0.0

	var sum: float = 0.0
	for i in range(history.size() - period, history.size()):
		sum += float(history[i])

	return sum / float(period)

func _is_int_like(text: String) -> bool:
	if text == "":
		return false

	for i in text.length():
		var c = text.unicode_at(i)
		if c < 48 or c > 57:
			return false

	return true
