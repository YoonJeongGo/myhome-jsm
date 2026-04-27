extends Node2D

const TOAST_DURATION: float = 2.0

@onready var UIRoot = $CanvasLayer/UIRoot
@onready var top_time_label = $CanvasLayer/UIRoot/TopBar/TimeLabel
@onready var market_badge = $CanvasLayer/UIRoot/TopBar/MarketBadge
@onready var top_day_label = $CanvasLayer/UIRoot/TopBar/DayLabel
@onready var top_cash_label = $CanvasLayer/UIRoot/TopBar/TopAssets/CashLabel
@onready var top_total_label = $CanvasLayer/UIRoot/TopBar/TopAssets/TotalLabel
@onready var top_pnl_label = $CanvasLayer/UIRoot/TopBar/TopAssets/PnlLabel

@onready var screen_market = $CanvasLayer/UIRoot/ScreenMarket
@onready var screen_detail = $CanvasLayer/UIRoot/ScreenDetail
@onready var screen_portfolio = $CanvasLayer/UIRoot/ScreenPortfolio
@onready var screen_save = $CanvasLayer/UIRoot/ScreenSave

@onready var search_input = $CanvasLayer/UIRoot/ScreenMarket/SearchBar/SearchInput
@onready var search_button = $CanvasLayer/UIRoot/ScreenMarket/SearchBar/SearchButton
@onready var stock_list = $CanvasLayer/UIRoot/ScreenMarket/StockScroll/StockList

@onready var back_button = $CanvasLayer/UIRoot/ScreenDetail/DetailHeader/BackButton
@onready var detail_name = $CanvasLayer/UIRoot/ScreenDetail/DetailHeader/DetailText/DetailName
@onready var detail_ticker = $CanvasLayer/UIRoot/ScreenDetail/DetailHeader/DetailText/DetailTicker
@onready var price_label = $CanvasLayer/UIRoot/ScreenDetail/PriceLabel
@onready var change_label = $CanvasLayer/UIRoot/ScreenDetail/ChangeLabel
@onready var chart_panel = $CanvasLayer/UIRoot/ScreenDetail/ChartPanel
@onready var open_label = $CanvasLayer/UIRoot/ScreenDetail/PriceGrid/OpenLabel
@onready var high_label = $CanvasLayer/UIRoot/ScreenDetail/PriceGrid/HighLabel
@onready var low_label = $CanvasLayer/UIRoot/ScreenDetail/PriceGrid/LowLabel
@onready var vol_label = $CanvasLayer/UIRoot/ScreenDetail/PriceGrid/VolLabel
@onready var qty_label = $CanvasLayer/UIRoot/ScreenDetail/MyStockInfo/MyStockVBox/QtyLabel
@onready var avg_label = $CanvasLayer/UIRoot/ScreenDetail/MyStockInfo/MyStockVBox/AvgLabel
@onready var eval_label = $CanvasLayer/UIRoot/ScreenDetail/MyStockInfo/MyStockVBox/EvalLabel
@onready var pnl_label = $CanvasLayer/UIRoot/ScreenDetail/MyStockInfo/MyStockVBox/PnlLabel
@onready var buy_large_button = $CanvasLayer/UIRoot/TradeButtons/BuyLargeButton
@onready var sell_large_button = $CanvasLayer/UIRoot/TradeButtons/SellLargeButton
@onready var trade_buttons = $CanvasLayer/UIRoot/TradeButtons

@onready var portfolio_cash = $CanvasLayer/UIRoot/ScreenPortfolio/SummaryCard/SummaryVBox/PortfolioCash
@onready var portfolio_eval = $CanvasLayer/UIRoot/ScreenPortfolio/SummaryCard/SummaryVBox/PortfolioEval
@onready var portfolio_total = $CanvasLayer/UIRoot/ScreenPortfolio/SummaryCard/SummaryVBox/PortfolioTotal
@onready var portfolio_pnl = $CanvasLayer/UIRoot/ScreenPortfolio/SummaryCard/SummaryVBox/PortfolioPnl
@onready var holding_list = $CanvasLayer/UIRoot/ScreenPortfolio/HoldingScroll/HoldingList

@onready var save_name_input = $CanvasLayer/UIRoot/ScreenSave/SaveInput
@onready var save_button = $CanvasLayer/UIRoot/ScreenSave/SaveButton
@onready var overwrite_button = $CanvasLayer/UIRoot/ScreenSave/OverwriteButton
@onready var save_list = $CanvasLayer/UIRoot/ScreenSave/SaveList

@onready var nav_market = $CanvasLayer/UIRoot/BottomNav/NavMarket
@onready var nav_portfolio = $CanvasLayer/UIRoot/BottomNav/NavPortfolio
@onready var nav_save = $CanvasLayer/UIRoot/BottomNav/NavSave

@onready var buy_modal = $CanvasLayer/UIRoot/BuyModal
@onready var buy_name = $CanvasLayer/UIRoot/BuyModal/BuyVBox/BuyName
@onready var buy_price = $CanvasLayer/UIRoot/BuyModal/BuyVBox/BuyPrice
@onready var buy_qty = $CanvasLayer/UIRoot/BuyModal/BuyVBox/BuyQty
@onready var buy_total = $CanvasLayer/UIRoot/BuyModal/BuyVBox/BuyTotal
@onready var buy_confirm = $CanvasLayer/UIRoot/BuyModal/BuyVBox/BuyConfirm

@onready var sell_modal = $CanvasLayer/UIRoot/SellModal
@onready var sell_name = $CanvasLayer/UIRoot/SellModal/SellVBox/SellName
@onready var sell_price = $CanvasLayer/UIRoot/SellModal/SellVBox/SellPrice
@onready var sell_qty = $CanvasLayer/UIRoot/SellModal/SellVBox/SellQty
@onready var sell_total = $CanvasLayer/UIRoot/SellModal/SellVBox/SellTotal
@onready var sell_confirm = $CanvasLayer/UIRoot/SellModal/SellVBox/SellConfirm

@onready var toast_label = $CanvasLayer/UIRoot/ToastLabel
@onready var toast_timer = $CanvasLayer/UIRoot/ToastTimer

var selected_stock_id: String = ""
var save_slots: Array = []

func _ready() -> void:
	print("main.gd ready")
	print("current scene:", get_tree().current_scene)
	print("UIRoot visible:", UIRoot.visible)
	print("UIRoot size:", UIRoot.get_size())
	print("viewport rect:", get_viewport().get_visible_rect())
	print("screen_market visible:", screen_market.visible)

	_connect_ui()
	_refresh_all()
	switch_screen("market")
	print("market ids:", MarketManager.get_all_stock_ids())

	if TimeManager.has_signal("time_changed"):
		TimeManager.time_changed.connect(_on_time_changed)

	if GameManager.has_signal("day_changed"):
		GameManager.day_changed.connect(_on_game_day_changed)

	if MarketManager.has_signal("prices_updated"):
		MarketManager.prices_updated.connect(_on_prices_updated)

	toast_label.visible = false
	_show_toast("게임 UI가 준비되었습니다.")

func _connect_ui() -> void:
	search_button.pressed.connect(Callable(self, "_on_search_pressed"))
	search_input.text_changed.connect(Callable(self, "_on_search_text_changed"))
	back_button.pressed.connect(Callable(self, "_on_back_pressed"))
	buy_large_button.pressed.connect(Callable(self, "_on_open_buy_modal"))
	sell_large_button.pressed.connect(Callable(self, "_on_open_sell_modal"))
	buy_qty.text_changed.connect(Callable(self, "_on_buy_qty_changed"))
	sell_qty.text_changed.connect(Callable(self, "_on_sell_qty_changed"))
	buy_confirm.pressed.connect(Callable(self, "_on_confirm_buy"))
	sell_confirm.pressed.connect(Callable(self, "_on_confirm_sell"))
	save_button.pressed.connect(Callable(self, "_on_save_pressed"))
	overwrite_button.pressed.connect(Callable(self, "_on_overwrite_pressed"))
	nav_market.pressed.connect(Callable(self, "_on_nav_pressed").bind("market"))
	nav_portfolio.pressed.connect(Callable(self, "_on_nav_pressed").bind("portfolio"))
	nav_save.pressed.connect(Callable(self, "_on_nav_pressed").bind("save"))
	toast_timer.timeout.connect(Callable(self, "_on_toast_timeout"))

func _refresh_all() -> void:
	render_topbar()
	render_stock_list()
	render_portfolio()
	render_save_slots()

func _on_search_pressed() -> void:
	render_stock_list()

func _on_search_text_changed(_new_text: String) -> void:
	render_stock_list()

func _on_nav_pressed(screen_name: String) -> void:
	switch_screen(screen_name)

func switch_screen(screen_name: String) -> void:
	screen_market.visible = screen_name == "market"
	screen_detail.visible = screen_name == "detail"
	screen_portfolio.visible = screen_name == "portfolio"
	screen_save.visible = screen_name == "save"
	trade_buttons.visible = screen_name == "detail"

	if screen_name == "market":
		render_stock_list()
	elif screen_name == "portfolio":
		render_portfolio()
	elif screen_name == "save":
		render_save_slots()

func render_topbar() -> void:
	var time_text = TimeManager.get_time_string() if TimeManager.has_method("get_time_string") else "00:00"
	top_time_label.text = time_text
	market_badge.text = "장중" if (TimeManager.current_hour >= 9 and TimeManager.current_hour < 15) else "마감"
	top_day_label.text = "DAY %d" % GameManager.get_current_day()
	top_cash_label.text = "현금: %s원" % fmt(PortfolioManager.get_cash())
	top_total_label.text = "총자산: %s원" % fmt(PortfolioManager.get_total_asset())
	var pnl_value = PortfolioManager.get_total_asset() - PortfolioManager.get_cash()
	top_pnl_label.text = "평가손익: %s원" % fmt(pnl_value)

func render_stock_list() -> void:
	for child in stock_list.get_children():
		child.queue_free()

	var filter_text = search_input.text.strip_edges().to_lower()
	var stock_ids = MarketManager.get_all_stock_ids() if MarketManager.has_method("get_all_stock_ids") else []

	for stock_id in stock_ids:
		var stock_name = MarketManager.get_stock_name(stock_id)
		var price = MarketManager.get_price(stock_id)
		var combined = "%s %s" % [stock_name.to_lower(), stock_id]
		if filter_text != "" and combined.findn(filter_text) == -1:
			continue

		var row = Button.new()
		row.text = "%s [%s] %s원" % [stock_name, stock_id, fmt(price)]
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.pressed.connect(Callable(self, "_on_stock_row_pressed").bind(stock_id))
		stock_list.add_child(row)

	if stock_list.get_child_count() == 0:
		var empty = Label.new()
		empty.text = "검색 결과가 없습니다."
		stock_list.add_child(empty)

func _on_stock_row_pressed(stock_id: String) -> void:
	selected_stock_id = stock_id
	render_detail()
	switch_screen("detail")

func render_detail() -> void:
	if selected_stock_id == "":
		return

	var stock_name = MarketManager.get_stock_name(selected_stock_id)
	var price = MarketManager.get_price(selected_stock_id)
	var history = MarketManager.get_intraday_history(selected_stock_id)

	detail_name.text = stock_name
	detail_ticker.text = selected_stock_id
	price_label.text = "%s원" % fmt(price)

	if history.size() > 0:
		var open_price = int(history[0])
		var high_price = int(history.max())
		var low_price = int(history.min())
		var diff = price - open_price
		var percent_change = 0.0 if open_price == 0 else float(diff) / float(open_price) * 100.0

		change_label.text = "전일대비: %s원 (%+.2f%%)" % [fmt(diff), percent_change]
		open_label.text = "시가: %s원" % fmt(open_price)
		high_label.text = "고가: %s원" % fmt(high_price)
		low_label.text = "저가: %s원" % fmt(low_price)
	else:
		change_label.text = "전일대비: -"
		open_label.text = "시가: -"
		high_label.text = "고가: -"
		low_label.text = "저가: -"

	vol_label.text = "거래량: -"

	var holding = PortfolioManager.get_holding(selected_stock_id)
	qty_label.text = "수량: %d주" % int(holding["quantity"])
	avg_label.text = "평균단가: %s원" % fmt(float(holding["avg_price"]))
	var eval_value = int(float(holding["quantity"]) * price)
	eval_label.text = "평가금액: %s원" % fmt(eval_value)
	var pnl = int((price - float(holding["avg_price"])) * float(holding["quantity"]))
	pnl_label.text = "평가손익: %s원" % fmt(pnl)

	buy_name.text = stock_name
	buy_price.text = "단가: %s원" % fmt(price)
	sell_name.text = stock_name
	sell_price.text = "단가: %s원" % fmt(price)

	_draw_stock_chart(selected_stock_id)

func _draw_stock_chart(stock_id: String) -> void:
	if chart_panel == null:
		return

	for child in chart_panel.get_children():
		if child is Line2D:
			child.queue_free()

	var history = MarketManager.get_intraday_history(stock_id)
	if history.size() < 2:
		return

	var chart_width = max(chart_panel.get_size().x - 24.0, 1.0)
	var chart_height = max(chart_panel.get_size().y - 24.0, 1.0)
	var min_price = int(history.min())
	var max_price = int(history.max())
	var value_range = max(max_price - min_price, 1)

	var chart_line = Line2D.new()
	chart_line.width = 3
	chart_line.default_color = Color(0.2, 0.8, 0.4)
	chart_line.position = Vector2.ZERO

	for i in range(history.size()):
		var x = 12.0 + chart_width * float(i) / float(history.size() - 1)
		var y = 12.0 + chart_height * (1.0 - float(int(history[i]) - min_price) / float(value_range))
		chart_line.add_point(Vector2(x, y))

	chart_panel.add_child(chart_line)

func render_portfolio() -> void:
	portfolio_cash.text = "현금: %s원" % fmt(PortfolioManager.get_cash())
	portfolio_eval.text = "주식 평가금: %s원" % fmt(PortfolioManager.get_total_stock_value())
	portfolio_total.text = "총 자산: %s원" % fmt(PortfolioManager.get_total_asset())
	var pnl_value = PortfolioManager.get_total_asset() - PortfolioManager.get_cash()
	portfolio_pnl.text = "총 평가손익: %s원" % fmt(pnl_value)

	for child in holding_list.get_children():
		child.queue_free()

	var holdings = PortfolioManager.get_all_holdings()
	if holdings.is_empty():
		var empty = Label.new()
		empty.text = "보유 종목이 없습니다."
		holding_list.add_child(empty)
		return

	for stock_id in holdings.keys():
		var data = holdings[stock_id]
		var stock_name = MarketManager.get_stock_name(stock_id)
		var price = MarketManager.get_price(stock_id)
		var qty = int(data["quantity"])
		var eval_value = int(price * qty)
		var pnl = int((price - float(data["avg_price"])) * qty)
		var entry = Button.new()
		entry.text = "%s [%s] %d주 | %s원 | %s원" % [stock_name, stock_id, qty, fmt(eval_value), fmt(pnl)]
		entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		entry.pressed.connect(Callable(self, "_on_stock_row_pressed").bind(stock_id))
		holding_list.add_child(entry)

func render_save_slots() -> void:
	for child in save_list.get_children():
		child.queue_free()

	if save_slots.is_empty():
		var empty = Label.new()
		empty.text = "저장된 게임이 없습니다."
		save_list.add_child(empty)
		return

	for i in range(save_slots.size()):
		var slot = save_slots[i]
		var container = HBoxContainer.new()
		var label = Label.new()
		label.text = "%s — DAY %d / %s원" % [slot["name"], slot["day"], fmt(slot["total_asset"])]
		container.add_child(label)
		var btn = Button.new()
		btn.text = "불러오기"
		btn.pressed.connect(Callable(self, "_on_load_slot").bind(i))
		container.add_child(btn)
		save_list.add_child(container)

func _on_load_slot(index: int) -> void:
	_show_toast("저장 슬롯 %d 불러오기" % index)

func _on_back_pressed() -> void:
	switch_screen("market")

func _on_open_buy_modal() -> void:
	if selected_stock_id == "":
		_show_toast("종목을 선택해주세요.")
		return
	buy_modal.visible = true
	buy_qty.text = "1"
	_update_buy_total()

func _on_open_sell_modal() -> void:
	if selected_stock_id == "":
		_show_toast("종목을 선택해주세요.")
		return
	sell_modal.visible = true
	sell_qty.text = "1"
	_update_sell_total()

func _on_buy_qty_changed(_new_text: String) -> void:
	_update_buy_total()

func _on_sell_qty_changed(_new_text: String) -> void:
	_update_sell_total()

func _update_buy_total() -> void:
	var price = MarketManager.get_price(selected_stock_id)
	var qty = buy_qty.text.to_int()
	buy_total.text = "총 금액: %s원" % fmt(price * qty)

func _update_sell_total() -> void:
	var price = MarketManager.get_price(selected_stock_id)
	var qty = sell_qty.text.to_int()
	sell_total.text = "총 금액: %s원" % fmt(price * qty)

func _on_confirm_buy() -> void:
	var qty = buy_qty.text.to_int()
	if qty <= 0:
		_show_toast("올바른 수량을 입력하세요.")
		return
	var success = PortfolioManager.buy_stock(selected_stock_id, qty)
	buy_modal.visible = false
	if success:
		_show_toast("매수 완료: %d주" % qty)
	else:
		_show_toast("매수 실패")
	_refresh_all()

func _on_confirm_sell() -> void:
	var qty = sell_qty.text.to_int()
	if qty <= 0:
		_show_toast("올바른 수량을 입력하세요.")
		return
	var success = PortfolioManager.sell_stock(selected_stock_id, qty)
	sell_modal.visible = false
	if success:
		_show_toast("매도 완료: %d주" % qty)
	else:
		_show_toast("매도 실패")
	_refresh_all()

func _on_save_pressed() -> void:
	var save_name = save_name_input.text.strip_edges()
	if save_name == "":
		_show_toast("저장 이름을 입력하세요.")
		return
	save_slots.append({"name": save_name, "day": GameManager.get_current_day(), "total_asset": PortfolioManager.get_total_asset()})
	render_save_slots()
	_show_toast("저장 완료: %s" % save_name)

func _on_overwrite_pressed() -> void:
	if save_slots.is_empty():
		_show_toast("저장된 슬롯이 없습니다.")
		return
	save_slots[0]["day"] = GameManager.get_current_day()
	save_slots[0]["total_asset"] = PortfolioManager.get_total_asset()
	render_save_slots()
	_show_toast("덮어쓰기 완료")

func _on_time_changed(_hour: int, _minute: int) -> void:
	render_topbar()

func _on_game_day_changed(_new_day: int) -> void:
	render_topbar()

func _on_prices_updated() -> void:
	render_stock_list()
	render_detail()
	render_portfolio()

func _show_toast(message: String) -> void:
	toast_label.text = message
	toast_label.visible = true
	toast_timer.start()

func _on_toast_timeout() -> void:
	toast_label.visible = false

func fmt(value: float) -> String:
	var text = str(int(value))
	var parts: Array = []
	while text.length() > 3:
		parts.insert(0, text.substr(text.length() - 3, 3))
		text = text.substr(0, text.length() - 3)
	if text != "":
		parts.insert(0, text)
	return String(",").join(parts)
