extends Node2D

enum State { PHASE_A, PHASE_B, PHASE_C }
var current_state = State.PHASE_A

var current_day = 1
var my_cash = 10000000
var my_portfolio = {}

var trade_time_left = 180.0
var tick_timer = 0.0
var pending_orders = []

# --- UI 노드 연결 ---
@onready var phase_a_ui = $CanvasLayer/PhaseA
@onready var news_label = $CanvasLayer/PhaseA/NewsLabel
@onready var go_trade_btn = $CanvasLayer/PhaseA/GoTradeButton

@onready var phase_b_ui = $CanvasLayer/PhaseB
@onready var info_label = $CanvasLayer/PhaseB/InfoLabel
@onready var asset_label = $CanvasLayer/PhaseB/AssetLabel
@onready var stock_select = $CanvasLayer/PhaseB/StockSelectButton
@onready var time_label = $CanvasLayer/PhaseB/TimeLabel
@onready var chart_line = $CanvasLayer/PhaseB/ChartLine
@onready var order_type_select = $CanvasLayer/PhaseB/OrderTypeSelect
@onready var order_amount_input = $CanvasLayer/PhaseB/OrderAmountInput
@onready var order_price_input = $CanvasLayer/PhaseB/OrderPriceInput

@onready var phase_c_ui = $CanvasLayer/PhaseC
@onready var result_label = $CanvasLayer/PhaseC/ResultLabel

var has_checked_news = false
var has_worked_today = false
var rent_fee = 500000
var days_to_rent = 30
var is_game_over = false

func _ready():
	for stock_name in MarketManager.stock_names:
		stock_select.add_item(stock_name)
		my_portfolio[stock_name] = {
			"amount": 0,
			"avg_price": 0
		}

	stock_select.item_selected.connect(_on_stock_selected)

	order_type_select.clear()
	order_type_select.add_item("시장가 (즉시 체결)")
	order_type_select.add_item("지정가 (예약 체결)")
	order_type_select.select(0)

	start_phase_a()

# ==========================================
# 실시간 처리
# ==========================================
func _process(delta):
	if current_state != State.PHASE_B:
		return

	trade_time_left -= delta
	tick_timer += delta
	update_time_ui()

	if tick_timer >= 1.0:
		tick_timer -= 1.0
		MarketManager.tick_realtime()
		check_pending_orders()
		draw_chart()
		update_portfolio_ui()

	if trade_time_left <= 0:
		start_phase_c()

# ==========================================
# [A파트: 정보 수집]
# ==========================================
func start_phase_a():
	current_state = State.PHASE_A
	phase_a_ui.show()
	phase_b_ui.hide()
	phase_c_ui.hide()

	go_trade_btn.hide()
	has_checked_news = false
	has_worked_today = false

	news_label.text = "Day " + str(current_day) + " 아침입니다. 뉴스를 선택하세요."

func show_news(accuracy_percent, flavor_text):
	if has_checked_news:
		return

	if MarketManager.stock_names.is_empty():
		news_label.text = "종목 데이터가 없습니다."
		return

	has_checked_news = true

	var random_stock = MarketManager.stock_names[randi() % MarketManager.stock_names.size()]
	var will_go_up = MarketManager.future_fluctuations.get(random_stock, 0.0) > 0.0
	var is_telling_truth = (randi() % 100) < accuracy_percent
	var predicted_up = will_go_up if is_telling_truth else not will_go_up
	var up_down_text = "상승" if predicted_up else "하락"

	news_label.text = flavor_text + "\n\n[전문가 힌트: " + random_stock + " 내일 " + up_down_text + " 예상!]"
	go_trade_btn.show()

func _on_tv_news_button_pressed():
	show_news(80, "TV 뉴스: 우량주 중심의 안정적인 장세 예상...")

func _on_internet_button_pressed():
	show_news(70, "인터넷 기사: [단독] 특정 테마주 대형 계약 임박설...")

func _on_youtube_button_pressed():
	show_news(30, "유튜브: (속보) 세력 매집 포착! 풀매수 가즈아!!")

func _on_go_trade_button_pressed():
	start_phase_b()

# ==========================================
# [B파트: 투자 및 매매]
# ==========================================
func start_phase_b():
	current_state = State.PHASE_B
	phase_a_ui.hide()
	phase_b_ui.show()
	phase_c_ui.hide()

	trade_time_left = 180.0
	tick_timer = 0.0

	update_time_ui()
	update_portfolio_ui()
	draw_chart()

func update_time_ui():
	var elapsed_real_sec = 180.0 - trade_time_left
	var in_game_minutes_passed = (elapsed_real_sec / 180.0) * 390.0
	var total_minutes = 9 * 60 + in_game_minutes_passed
	var hours = floori(total_minutes / 60.0)
	var minutes = int(total_minutes) % 60
	time_label.text = "현재 시각: %02d:%02d" % [hours, minutes]

func _on_stock_selected(_index):
	update_portfolio_ui()
	draw_chart()

func draw_chart():
	if stock_select.get_selected_id() == -1:
		return

	var selected_stock = _get_selected_stock_name()
	if selected_stock == "":
		return

	if not MarketManager.intraday_history.has(selected_stock):
		return

	var history = MarketManager.intraday_history[selected_stock]

	chart_line.clear_points()
	if history.size() < 2:
		return

	var max_price = history[0]
	var min_price = history[0]

	for p in history:
		if p > max_price:
			max_price = p
		if p < min_price:
			min_price = p

	var price_diff = max_price - min_price
	if price_diff == 0:
		price_diff = 1

	var chart_width = 300.0
	var chart_height = 100.0

	for i in range(history.size()):
		var x = (float(i) / 180.0) * chart_width
		var y = (float(max_price - history[i]) / float(price_diff)) * chart_height
		chart_line.add_point(Vector2(x, y))

func update_portfolio_ui():
	if stock_select.get_selected_id() == -1:
		return

	var selected_stock = _get_selected_stock_name()
	if selected_stock == "":
		return

	var current_price = _get_current_price(selected_stock)
	var data = my_portfolio[selected_stock]
	var owned = data["amount"]
	var avg = data["avg_price"]

	var eval_amount = current_price * owned
	var invested_amount = avg * owned
	var profit = eval_amount - invested_amount
	var profit_rate = 0.0
	if invested_amount > 0:
		profit_rate = (float(profit) / float(invested_amount)) * 100.0

	info_label.text = (
		"현재 날짜: Day " + str(current_day) +
		"\n종목: " + selected_stock +
		"\n주가: " + str(current_price) + "원" +
		"\n보유 수량: " + str(owned) + "주" +
		"\n평균단가: " + str(avg) + "원" +
		"\n매수원금: " + str(invested_amount) + "원" +
		"\n평가금액: " + str(eval_amount) + "원" +
		"\n평가손익: " + str(profit) + "원" +
		"\n수익률: " + "%.2f" % profit_rate + "%"
	)

	var total_invested = get_total_invested_amount()
	var total_eval = get_total_evaluation_amount()
	var total_profit = total_eval - total_invested
	var total_profit_rate = 0.0
	if total_invested > 0:
		total_profit_rate = (float(total_profit) / float(total_invested)) * 100.0

	asset_label.text = (
		"현금: " + str(my_cash) + "원" +
		"\n총매수원금: " + str(total_invested) + "원" +
		"\n총평가금액: " + str(total_eval) + "원" +
		"\n총평가손익: " + str(total_profit) + "원" +
		"\n총수익률: " + "%.2f" % total_profit_rate + "%" +
		"\n총자산: " + str(get_total_asset()) + "원"
	)

func get_total_asset() -> int:
	return my_cash + get_total_evaluation_amount()

func get_total_invested_amount() -> int:
	var total = 0
	for stock_name in my_portfolio:
		var data = my_portfolio[stock_name]
		total += data["amount"] * data["avg_price"]
	return total

func get_total_evaluation_amount() -> int:
	var total = 0
	for stock_name in my_portfolio:
		var data = my_portfolio[stock_name]
		total += _get_current_price(stock_name) * data["amount"]
	return total

# ==========================================
# 매수 / 매도
# ==========================================
func _on_buy_button_pressed():
	var stock = _get_selected_stock_name()
	if stock == "":
		return

	var amount = _get_input_amount()
	if amount <= 0:
		return

	var current_price = _get_current_price(stock)
	var is_limit = order_type_select.get_selected_id() == 1
	var target_price = _get_target_price(current_price, is_limit)
	if target_price <= 0:
		return

	var total_cost = target_price * amount
	if my_cash < total_cost:
		print("현금 부족: 필요 ", total_cost, " / 보유 ", my_cash)
		return

	my_cash -= total_cost

	if is_limit:
		pending_orders.append({
			"type": "buy",
			"stock": stock,
			"price": target_price,
			"amount": amount
		})
		print(stock, " 지정가 매수 주문 등록")
	else:
		_apply_buy(stock, amount, target_price)
		print(stock, " 시장가 매수 체결")

	update_portfolio_ui()

func _apply_buy(stock: String, amount: int, price: int):
	var data = my_portfolio[stock]
	var prev_amount = data["amount"]
	var prev_avg = data["avg_price"]
	var new_total_amount = prev_amount + amount

	if new_total_amount <= 0:
		data["amount"] = 0
		data["avg_price"] = 0
		return

	data["avg_price"] = int((prev_avg * prev_amount + price * amount) / float(new_total_amount))
	data["amount"] = new_total_amount

func _on_sell_button_pressed():
	var stock = _get_selected_stock_name()
	if stock == "":
		return

	var amount = _get_input_amount()
	if amount <= 0:
		return

	var data = my_portfolio[stock]
	if data["amount"] < amount:
		print("보유 수량 부족: ", data["amount"], "주 보유 중")
		return

	var current_price = _get_current_price(stock)
	var is_limit = order_type_select.get_selected_id() == 1
	var target_price = _get_target_price(current_price, is_limit)
	if target_price <= 0:
		return

	if is_limit:
		pending_orders.append({
			"type": "sell",
			"stock": stock,
			"price": target_price,
			"amount": amount
		})
		print(stock, " 지정가 매도 주문 등록")
	else:
		_apply_sell(stock, amount, current_price)
		print(stock, " 시장가 매도 체결")

	update_portfolio_ui()

func _apply_sell(stock: String, amount: int, price: int):
	var data = my_portfolio[stock]
	data["amount"] -= amount
	my_cash += price * amount

	if data["amount"] <= 0:
		data["amount"] = 0
		data["avg_price"] = 0

# ==========================================
# 지정가 체결 검사
# ==========================================
func check_pending_orders():
	var remaining_orders = []

	for order in pending_orders:
		var current_price = _get_current_price(order["stock"])

		if order["type"] == "buy":
			if current_price <= order["price"]:
				_apply_buy(order["stock"], order["amount"], order["price"])
				print(order["stock"], " 지정가 매수 체결!")
			else:
				remaining_orders.append(order)

		elif order["type"] == "sell":
			var data = my_portfolio[order["stock"]]
			if data["amount"] < order["amount"]:
				print(order["stock"], " 지정가 매도 주문 취소 (보유 수량 부족)")
				continue

			if current_price >= order["price"]:
				_apply_sell(order["stock"], order["amount"], order["price"])
				print(order["stock"], " 지정가 매도 체결!")
			else:
				remaining_orders.append(order)

	if pending_orders.size() != remaining_orders.size():
		pending_orders = remaining_orders
		update_portfolio_ui()

# ==========================================
# [C파트: 장 마감 및 결산]
# ==========================================
func start_phase_c():
	current_state = State.PHASE_C
	phase_a_ui.hide()
	phase_b_ui.hide()
	phase_c_ui.show()

	var refunded_cash = 0
	for order in pending_orders:
		if order["type"] == "buy":
			var refund_amount = order["price"] * order["amount"]
			refunded_cash += refund_amount
			my_cash += refund_amount
	pending_orders.clear()

	var total_invested = get_total_invested_amount()
	var total_eval = get_total_evaluation_amount()
	var total_profit = total_eval - total_invested
	var total_profit_rate = 0.0
	if total_invested > 0:
		total_profit_rate = (float(total_profit) / float(total_invested)) * 100.0

	var end_text = "Day " + str(current_day) + " 장이 마감되었습니다.\n"

	if refunded_cash > 0:
		end_text += "미체결 매수 주문 취소: " + str(refunded_cash) + "원 환불\n"

	if current_day % days_to_rent == 0:
		my_cash -= rent_fee
		end_text += "월세 " + str(rent_fee) + "원 차감\n"
		if my_cash < 0:
			is_game_over = true
			end_text += "\n[파산] 현금이 부족하여 쫓겨났습니다...\n"

	end_text += "\n현금: " + str(my_cash) + "원"
	end_text += "\n총매수원금: " + str(total_invested) + "원"
	end_text += "\n총평가금액: " + str(total_eval) + "원"
	end_text += "\n총평가손익: " + str(total_profit) + "원"
	end_text += "\n총수익률: " + "%.2f" % total_profit_rate + "%"
	end_text += "\n총자산: " + str(get_total_asset()) + "원"

	var holding_summary = _build_holding_summary()
	if holding_summary != "":
		end_text += "\n\n[보유 종목]\n" + holding_summary
	else:
		end_text += "\n\n[보유 종목 없음]"

	if is_game_over:
		end_text += "\n\n게임 종료를 원하면 다음 날 버튼을 누르세요."

	result_label.text = end_text

# ==========================================
# 다음 날 버튼
# ==========================================
func _on_next_day_button_pressed():
	if is_game_over:
		get_tree().quit()
		return

	current_day += 1
	MarketManager.advance_day()
	start_phase_a()

# ==========================================
# 알바 버튼
# ==========================================
func _on_work_button_pressed():
	if has_worked_today:
		result_label.text += "\n\n오늘은 이미 알바를 했습니다."
		return

	has_worked_today = true
	var work_pay = 200000
	my_cash += work_pay
	result_label.text += "\n\n알바 수입 " + str(work_pay) + "원\n현금: " + str(my_cash) + "원"

# ==========================================
# 내부 유틸
# ==========================================
func _get_selected_stock_name() -> String:
	if stock_select.get_selected_id() == -1:
		return ""
	return stock_select.get_item_text(stock_select.get_selected_id())

func _get_current_price(stock_name: String) -> int:
	if not MarketManager.stocks.has(stock_name):
		return 0
	return int(MarketManager.stocks[stock_name]["price"])

func _get_input_amount() -> int:
	var text = order_amount_input.text.strip_edges()
	if text == "":
		print("주문수량을 입력하세요.")
		return 0

	var amount = int(text)
	if amount <= 0:
		print("주문수량은 1 이상이어야 합니다.")
		return 0

	return amount

func _get_target_price(current_price: int, is_limit: bool) -> int:
	if not is_limit:
		return current_price

	var text = order_price_input.text.strip_edges()
	if text == "":
		print("지정가를 입력하세요.")
		return -1

	if not text.is_valid_int():
		print("지정가는 숫자로 입력하세요.")
		return -1

	var input_price = int(text)
	if input_price <= 0:
		print("지정가는 1 이상이어야 합니다.")
		return -1

	return input_price

func _build_holding_summary() -> String:
	var lines = []

	for stock_name in my_portfolio:
		var data = my_portfolio[stock_name]
		if data["amount"] <= 0:
			continue

		var current_price = _get_current_price(stock_name)
		var eval_amount = current_price * data["amount"]
		var invested_amount = data["avg_price"] * data["amount"]
		var profit = eval_amount - invested_amount
		var rate = 0.0
		if invested_amount > 0:
			rate = (float(profit) / float(invested_amount)) * 100.0

		lines.append(
			stock_name +
			" | " + str(data["amount"]) + "주" +
			" | 평균 " + str(data["avg_price"]) + "원" +
			" | 평가손익 " + str(profit) + "원" +
			" | 수익률 " + "%.2f" % rate + "%"
		)

	return "\n".join(lines)
