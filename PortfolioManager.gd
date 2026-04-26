extends Node

signal portfolio_changed
signal trade_executed(action, stock_id, quantity, price, total_cost)

# =========================
# 기본 자금
# =========================
var cash: int = 1000000

# holdings 구조
# {
#   "stock_1": {
#       "quantity": 10,
#       "avg_price": 10200.0
#   }
# }
var holdings: Dictionary = {}

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
# 네 MarketManager 구조에 맞춤
# 우선순위:
# 1) get_price(stock_id)
# 2) current_prices[stock_id]
# =========================
func get_stock_price(stock_id: String) -> float:
	if not has_node("/root/MarketManager"):
		push_error("MarketManager Autoload not found.")
		return -1.0

	var market_manager = get_node("/root/MarketManager")

	# 1) 함수 방식
	if market_manager.has_method("get_price"):
		var price: float = float(market_manager.get_price(stock_id))
		if price > 0.0:
			return price

	# 2) current_prices 딕셔너리 방식
	if "current_prices" in market_manager:
		var current_prices = market_manager.current_prices
		if current_prices is Dictionary and current_prices.has(stock_id):
			var current_price: float = float(current_prices[stock_id])
			if current_price > 0.0:
				return current_price

	push_error("Stock price not found for stock_id: " + stock_id)
	return -1.0

# =========================
# 매수
# =========================
func buy_stock(stock_id: String, quantity: int) -> bool:
	if quantity <= 0:
		print("매수 실패: 수량은 1 이상이어야 함")
		return false

	var price: float = get_stock_price(stock_id)
	if price <= 0:
		print("매수 실패: 잘못된 주가")
		return false

	var total_cost: int = int(round(price * quantity))

	if cash < total_cost:
		print("매수 실패: 현금 부족")
		return false

	cash -= total_cost

	if not holdings.has(stock_id):
		holdings[stock_id] = {
			"quantity": 0,
			"avg_price": 0.0
		}

	var old_quantity: int = int(holdings[stock_id]["quantity"])
	var old_avg_price: float = float(holdings[stock_id]["avg_price"])

	var new_quantity: int = old_quantity + quantity
	var new_avg_price: float = 0.0

	if new_quantity > 0:
		new_avg_price = ((old_quantity * old_avg_price) + (quantity * price)) / new_quantity

	holdings[stock_id]["quantity"] = new_quantity
	holdings[stock_id]["avg_price"] = new_avg_price

	print("[매수 성공] 종목:", stock_id, " 수량:", quantity, " 단가:", price, " 총액:", total_cost)
	print("현재 현금:", cash)

	trade_executed.emit("buy", stock_id, quantity, price, total_cost)
	portfolio_changed.emit()
	return true

# =========================
# 매도
# =========================
func sell_stock(stock_id: String, quantity: int) -> bool:
	if quantity <= 0:
		print("매도 실패: 수량은 1 이상이어야 함")
		return false

	if not holdings.has(stock_id):
		print("매도 실패: 보유하지 않은 종목")
		return false

	var owned_quantity: int = int(holdings[stock_id]["quantity"])
	if owned_quantity < quantity:
		print("매도 실패: 보유 수량 부족")
		return false

	var price: float = get_stock_price(stock_id)
	if price <= 0:
		print("매도 실패: 잘못된 주가")
		return false

	var total_income: int = int(round(price * quantity))

	holdings[stock_id]["quantity"] = owned_quantity - quantity
	cash += total_income

	# 전량 매도 시 holdings에서 제거
	if int(holdings[stock_id]["quantity"]) <= 0:
		holdings.erase(stock_id)

	print("[매도 성공] 종목:", stock_id, " 수량:", quantity, " 단가:", price, " 총액:", total_income)
	print("현재 현금:", cash)

	trade_executed.emit("sell", stock_id, quantity, price, total_income)
	portfolio_changed.emit()
	return true

# =========================
# 보유 종목 조회
# =========================
func get_holding(stock_id: String) -> Dictionary:
	if holdings.has(stock_id):
		return holdings[stock_id]

	return {
		"quantity": 0,
		"avg_price": 0.0
	}

func get_holding_quantity(stock_id: String) -> int:
	if holdings.has(stock_id):
		return int(holdings[stock_id]["quantity"])
	return 0

func get_holding_avg_price(stock_id: String) -> float:
	if holdings.has(stock_id):
		return float(holdings[stock_id]["avg_price"])
	return 0.0

func get_all_holdings() -> Dictionary:
	return holdings.duplicate(true)

# =========================
# 평가금액 계산
# =========================
func get_stock_value(stock_id: String) -> int:
	if not holdings.has(stock_id):
		return 0

	var quantity: int = int(holdings[stock_id]["quantity"])
	var price: float = get_stock_price(stock_id)

	if price <= 0:
		return 0

	return int(round(quantity * price))

func get_total_stock_value() -> int:
	var total: int = 0

	for stock_id in holdings.keys():
		total += get_stock_value(stock_id)

	return total

func get_total_asset() -> int:
	return cash + get_total_stock_value()

# =========================
# 손익 계산
# =========================
func get_unrealized_profit(stock_id: String) -> int:
	if not holdings.has(stock_id):
		return 0

	var quantity: int = int(holdings[stock_id]["quantity"])
	var avg_price: float = float(holdings[stock_id]["avg_price"])
	var current_price: float = get_stock_price(stock_id)

	if current_price <= 0:
		return 0

	return int(round((current_price - avg_price) * quantity))

func get_total_unrealized_profit() -> int:
	var total: int = 0

	for stock_id in holdings.keys():
		total += get_unrealized_profit(stock_id)

	return total

# =========================
# 테스트 출력용
# =========================
func print_portfolio() -> void:
	print("========== 포트폴리오 ==========")
	print("현금: ", cash)

	if holdings.is_empty():
		print("보유 종목 없음")
	else:
		for stock_id in holdings.keys():
			var data = holdings[stock_id]
			var quantity: int = int(data["quantity"])
			var avg_price: float = float(data["avg_price"])
			var current_price: float = get_stock_price(stock_id)
			var eval_value: int = int(round(current_price * quantity))
			var profit: int = int(round((current_price - avg_price) * quantity))

			print("종목: ", stock_id)
			print(" - 보유 수량: ", quantity)
			print(" - 평균 단가: ", avg_price)
			print(" - 평가금액: ", eval_value)
			print(" - 평가손익: ", profit)

	print("총 주식 평가금액: ", get_total_stock_value())
	print("총 자산: ", get_total_asset())
	print("================================")

# =========================
# 테스트용 / 초기화
# =========================
func reset_portfolio() -> void:
	cash = 0
	holdings.clear()
	print("포트폴리오 초기화 완료")
	portfolio_changed.emit()
