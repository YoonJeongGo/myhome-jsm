extends Node

signal portfolio_changed
signal trade_executed(action, stock_code, quantity, price, total_cost)

# =========================
# 기본 자금
# =========================
var cash: int = 10000000

# holdings 구조
# {
#   "005930": {
#       "quantity": 10,
#       "avg_price": 10200.0
#   }
# }
var holdings: Dictionary = {}

# pending_orders 구조
# {
#   "id": "unique_id",
#   "type": "buy" or "sell",
#   "stock_code": "005930",
#   "quantity": 10,
#   "price": 10200,
#   "timestamp": 1234567890
# }
var pending_orders: Array = []
var next_order_id: int = 1

# =========================
# 초기화
# =========================
func _ready() -> void:
	print("PortfolioManager ready.")

# =========================
# 자금 설정 / 조회
# =========================
func set_cash(amount: int) -> void:
	cash = max(amount, 0)
	portfolio_changed.emit()

func get_cash() -> int:
	return cash

func add_cash(amount: int) -> void:
	if amount <= 0:
		return

	cash += amount
	print("[현금 증가] 금액:", amount, " / 현재 현금:", cash)
	portfolio_changed.emit()

func subtract_cash(amount: int) -> bool:
	if amount <= 0:
		print("현금 차감 실패: 금액은 1 이상이어야 함")
		return false

	if cash < amount:
		print("현금 차감 실패: 현금 부족")
		return false

	cash -= amount
	print("[현금 차감] 금액:", amount, " / 현재 현금:", cash)
	portfolio_changed.emit()
	return true

# =========================
# 주가 조회
# =========================
func get_stock_price(stock_code: String) -> float:
	if not has_node("/root/MarketManager"):
		push_error("MarketManager Autoload not found.")
		return -1.0

	var market_manager = get_node("/root/MarketManager")
	return market_manager.get_price(stock_code)

# =========================
# 시장가 매수
# =========================
func buy_market(stock_code: String, quantity: int) -> bool:
	if quantity <= 0:
		print("매수 실패: 수량은 1 이상이어야 함")
		return false

	var price: float = get_stock_price(stock_code)
	if price <= 0:
		print("매수 실패: 잘못된 주가")
		return false

	var total_cost: int = int(round(price * quantity))

	if cash < total_cost:
		print("매수 실패: 현금 부족")
		return false

	cash -= total_cost

	if not holdings.has(stock_code):
		holdings[stock_code] = {
			"quantity": 0,
			"avg_price": 0.0
		}

	var old_quantity: int = int(holdings[stock_code]["quantity"])
	var old_avg_price: float = float(holdings[stock_code]["avg_price"])

	var new_quantity: int = old_quantity + quantity
	var new_avg_price: float = 0.0

	if new_quantity > 0:
		new_avg_price = ((old_quantity * old_avg_price) + (quantity * price)) / new_quantity

	holdings[stock_code]["quantity"] = new_quantity
	holdings[stock_code]["avg_price"] = new_avg_price

	print("[시장가 매수 성공] 종목:", stock_code, " 수량:", quantity, " 단가:", price, " 총액:", total_cost)
	print("현재 현금:", cash)

	trade_executed.emit("buy", stock_code, quantity, price, total_cost)
	portfolio_changed.emit()
	return true

# =========================
# 지정가 매수
# =========================
func buy_limit(stock_code: String, quantity: int, limit_price: int) -> bool:
	if quantity <= 0 or limit_price <= 0:
		print("지정가 매수 실패: 잘못된 입력값")
		return false

	var total_cost: int = quantity * limit_price
	if cash < total_cost:
		print("지정가 매수 실패: 현금 부족")
		return false

	var order = {
		"id": str(next_order_id),
		"type": "buy",
		"stock_code": stock_code,
		"quantity": quantity,
		"price": limit_price,
		"timestamp": Time.get_unix_time_from_system()
	}

	pending_orders.append(order)
	next_order_id += 1

	print("[지정가 매수 주문] 종목:", stock_code, " 수량:", quantity, " 지정가:", limit_price)
	portfolio_changed.emit()
	return true

# =========================
# 시장가 매도
# =========================
func sell_market(stock_code: String, quantity: int) -> bool:
	if quantity <= 0:
		print("매도 실패: 수량은 1 이상이어야 함")
		return false

	if not holdings.has(stock_code):
		print("매도 실패: 보유하지 않은 종목")
		return false

	var owned_quantity: int = int(holdings[stock_code]["quantity"])
	if owned_quantity < quantity:
		print("매도 실패: 보유 수량 부족")
		return false

	var price: float = get_stock_price(stock_code)
	if price <= 0:
		print("매도 실패: 잘못된 주가")
		return false

	var total_income: int = int(round(price * quantity))

	holdings[stock_code]["quantity"] = owned_quantity - quantity
	cash += total_income

	# 전량 매도 시 holdings에서 제거
	if int(holdings[stock_code]["quantity"]) <= 0:
		holdings.erase(stock_code)

	print("[시장가 매도 성공] 종목:", stock_code, " 수량:", quantity, " 단가:", price, " 총액:", total_income)
	print("현재 현금:", cash)

	trade_executed.emit("sell", stock_code, quantity, price, total_income)
	portfolio_changed.emit()
	return true

# =========================
# 지정가 매도
# =========================
func sell_limit(stock_code: String, quantity: int, limit_price: int) -> bool:
	if quantity <= 0 or limit_price <= 0:
		print("지정가 매도 실패: 잘못된 입력값")
		return false

	if not holdings.has(stock_code):
		print("지정가 매도 실패: 보유하지 않은 종목")
		return false

	var owned_quantity: int = int(holdings[stock_code]["quantity"])
	if owned_quantity < quantity:
		print("지정가 매도 실패: 보유 수량 부족")
		return false

	var order = {
		"id": str(next_order_id),
		"type": "sell",
		"stock_code": stock_code,
		"quantity": quantity,
		"price": limit_price,
		"timestamp": Time.get_unix_time_from_system()
	}

	pending_orders.append(order)
	next_order_id += 1

	print("[지정가 매도 주문] 종목:", stock_code, " 수량:", quantity, " 지정가:", limit_price)
	portfolio_changed.emit()
	return true

# =========================
# 미체결 주문 처리 (매 틱마다 호출)
# =========================
func process_pending_orders():
	var orders_to_remove = []

	for order in pending_orders:
		var stock_code = order["stock_code"]
		var current_price = get_stock_price(stock_code)

		if order["type"] == "buy":
			# 매수 주문: 현재가가 지정가 이하일 때 체결
			if current_price <= order["price"]:
				if buy_market(stock_code, order["quantity"]):
					orders_to_remove.append(order)
					print("[지정가 매수 체결] 주문 ID:", order["id"])
		elif order["type"] == "sell":
			# 매도 주문: 현재가가 지정가 이상일 때 체결
			if current_price >= order["price"]:
				if sell_market(stock_code, order["quantity"]):
					orders_to_remove.append(order)
					print("[지정가 매도 체결] 주문 ID:", order["id"])

	# 체결된 주문 제거
	for order in orders_to_remove:
		pending_orders.erase(order)

	if orders_to_remove.size() > 0:
		portfolio_changed.emit()

# =========================
# 미체결 주문 취소
# =========================
func cancel_order(order_id: String) -> bool:
	for i in range(pending_orders.size()):
		if pending_orders[i]["id"] == order_id:
			pending_orders.remove_at(i)
			print("[주문 취소] 주문 ID:", order_id)
			portfolio_changed.emit()
			return true
	return false

# =========================
# 보유 종목 조회
# =========================
func get_holding(stock_code: String) -> Dictionary:
	if holdings.has(stock_code):
		return holdings[stock_code]

	return {
		"quantity": 0,
		"avg_price": 0.0
	}

func get_holding_quantity(stock_code: String) -> int:
	if holdings.has(stock_code):
		return int(holdings[stock_code]["quantity"])
	return 0

func get_holding_avg_price(stock_code: String) -> float:
	if holdings.has(stock_code):
		return float(holdings[stock_code]["avg_price"])
	return 0.0

func get_all_holdings() -> Dictionary:
	return holdings.duplicate(true)

# =========================
# 평가금액 계산
# =========================
func get_stock_value(stock_code: String) -> int:
	if not holdings.has(stock_code):
		return 0

	var quantity: int = int(holdings[stock_code]["quantity"])
	var price: float = get_stock_price(stock_code)

	if price <= 0:
		return 0

	return int(round(quantity * price))

func get_total_stock_value() -> int:
	var total: int = 0

	for stock_code in holdings.keys():
		total += get_stock_value(stock_code)

	return total

func get_total_value() -> int:
	return cash + get_total_stock_value()

# =========================
# 손익 계산
# =========================
func get_unrealized_profit(stock_code: String) -> int:
	if not holdings.has(stock_code):
		return 0

	var quantity: int = int(holdings[stock_code]["quantity"])
	var avg_price: float = float(holdings[stock_code]["avg_price"])
	var current_price: float = get_stock_price(stock_code)

	if current_price <= 0:
		return 0

	return int(round((current_price - avg_price) * quantity))

func get_total_pnl() -> int:
	var total: int = 0

	for stock_code in holdings.keys():
		total += get_unrealized_profit(stock_code)

	return total

# =========================
# 목표 달성도 계산
# =========================
func get_goal_progress() -> float:
	var target = 55000000.0  # 목표 자산
	var current = get_total_value()
	return min((current / target) * 100.0, 100.0)

# =========================
# 테스트 출력용
# =========================
func print_portfolio() -> void:
	print("========== 포트폴리오 ==========")
	print("현금: ", cash)

	if holdings.is_empty():
		print("보유 종목 없음")
	else:
		for stock_code in holdings.keys():
			var data = holdings[stock_code]
			var quantity: int = int(data["quantity"])
			var avg_price: float = float(data["avg_price"])
			var current_price: float = get_stock_price(stock_code)
			var eval_value: int = int(round(current_price * quantity))
			var profit: int = int(round((current_price - avg_price) * quantity))

			print("종목: ", stock_code)
			print(" - 보유 수량: ", quantity)
			print(" - 평균 단가: ", avg_price)
			print(" - 평가금액: ", eval_value)
			print(" - 평가손익: ", profit)

	print("총 주식 평가금액: ", get_total_stock_value())
	print("총 자산: ", get_total_value())
	print("================================")

# =========================
# 테스트용 / 초기화
# =========================
func reset_portfolio() -> void:
	cash = 10000000
	holdings.clear()
	pending_orders.clear()
	next_order_id = 1
	print("포트폴리오 초기화 완료")
	portfolio_changed.emit()