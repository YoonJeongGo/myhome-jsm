extends Node2D

# ── 색상 (HTML과 동일) ──
const C_BG     := Color("#080a0f")
const C_PANEL  := Color("#0f1117")
const C_PANEL2 := Color("#161a24")
const C_BORDER := Color("#1e2535")
const C_BDR2   := Color("#252d3d")
const C_UP     := Color("#22c55e")
const C_DOWN   := Color("#ef4444")
const C_GOLD   := Color("#f59e0b")
const C_BLUE   := Color("#3b82f6")
const C_PURPLE := Color("#a855f7")
const C_TEXT   := Color("#dde4f0")
const C_TEXT2  := Color("#7d8faa")
const C_TEXT3  := Color("#3d4d63")

# ── 게임 데이터 (HTML과 동일) ──
var STOCKS: Array = []
const GOAL     := 55000000
const FOOD     := 30000
const RENT     := 500000
const MAX_TICK := 180

const NEWS_DB := {
	"tv": {
		"up": [
			{"stock": "삼성전자",        "text": "삼성전자, 3분기 반도체 수출 역대 최고치 기록.\n애널리스트 매수 의견 유지."},
			{"stock": "SK하이닉스",     "text": "SK하이닉스, AI 서버용 메모리 수요 급증.\n목표주가 상향."},
			{"stock": "LG에너지솔루션", "text": "LG에너지솔루션, IRA 세액공제 수혜 확대.\n수주잔고 사상 최대."},
			{"stock": "현대차",          "text": "현대차 전기차 수출 전년 대비 23% 증가.\n북미 시장 점유율 상승."},
			{"stock": "POSCO홀딩스",    "text": "POSCO홀딩스 리튬 생산 본격화.\n2차전지 소재 사업 성장 기대."},
		],
		"down": [
			{"stock": "삼성전자",        "text": "삼성전자 파운드리 수율 문제 지속.\n목표주가 하향 의견 증가."},
			{"stock": "SK하이닉스",     "text": "SK하이닉스 단기 자금 부담.\n기관 차익 실현 매물 출회."},
			{"stock": "LG에너지솔루션", "text": "전기차 수요 둔화 우려.\nLG에너지솔루션 수주 지연 가능성."},
			{"stock": "현대차",          "text": "현대차 원가 상승으로 수출 채산성 악화 우려."},
			{"stock": "POSCO홀딩스",    "text": "POSCO홀딩스 철광석 강보합.\n중국발 공급 과잉 지속."},
		]
	},
	"internet": {
		"up": [
			{"stock": "삼성전자",        "text": "[단독] 삼성전자, 엔비디아 HBM4 공급 계약 임박.\n사실확인 중."},
			{"stock": "SK하이닉스",     "text": "[속보] SK하이닉스 내일 기관 대규모 매수 예정.\n미확인."},
			{"stock": "LG에너지솔루션", "text": "[단독] LG에너지솔루션 미국 완성차 계약 막바지."},
			{"stock": "현대차",          "text": "[속보] 현대차 전기차 사전예약 목표 조기 달성."},
			{"stock": "POSCO홀딩스",    "text": "[단독] POSCO홀딩스, 리튬 장기공급 계약 타결 임박."},
		],
		"down": [
			{"stock": "삼성전자",        "text": "[단독] 삼성전자 생산라인 가동 중단 검토.\n확인 안 됨."},
			{"stock": "SK하이닉스",     "text": "[속보] SK하이닉스 주요 거래처 주문량 축소 가능성."},
			{"stock": "LG에너지솔루션", "text": "[단독] LG에너지솔루션 공장 투자 일정 연기."},
			{"stock": "현대차",          "text": "[속보] 현대차 노사 결렬 위기.\n파업 가능성 높아."},
			{"stock": "POSCO홀딩스",    "text": "[단독] POSCO홀딩스 중국 법인 실적 악화 보고서 유출."},
		]
	},
	"youtube": {
		"up": [
			{"stock": "삼성전자",        "text": "(충격) 삼성전자 내일 갭업ㄷㄷ\n지인 루트 세력 들어온다고 함 ㄷㄷ"},
			{"stock": "SK하이닉스",     "text": "SK하이닉스 내일 무조건 터진다\n증권사 형이 알려줬음 믿어봐"},
			{"stock": "LG에너지솔루션", "text": "(속보) LG에너지솔루션 세력 매집 완료!!\n내일 갭업 예상 고고"},
			{"stock": "현대차",          "text": "현대차 내일 대박 루머 확산\n출처 밝힐 수 없지만 확신"},
			{"stock": "POSCO홀딩스",    "text": "(긴급) POSCO홀딩스 내일 급등\n세력 매집 완료 확인 ㄷㄷ"},
		],
		"down": [
			{"stock": "삼성전자",        "text": "(경고) 삼성전자 내일 세력 던지기 예상\n지인 확인 조심하세요"},
			{"stock": "SK하이닉스",     "text": "SK하이닉스 내일 급락 루머\n진짜인지 모르겠지만 조사"},
			{"stock": "LG에너지솔루션", "text": "(충격) LG에너지솔루션 내부 대량 매도 포착"},
			{"stock": "현대차",          "text": "현대차 내일 하한가 간다는 유라이버\n믿거나 말거나"},
			{"stock": "POSCO홀딩스",    "text": "(속보) POSCO홀딩스 임원 나온다고 함\n구체 내용 모름 근데 떨어진다고"},
		]
	}
}

# ── 게임 상태 ──
var G := {
	"day": 1, "cash": 10000000, "startCash": 10000000,
	"portfolio": {}, "pendingOrders": [],
	"todayPnl": 0, "realPnl": 0, "tradeCount": 0, "refundAmt": 0,
	"workDone": false, "workIncome": 0, "todayExpense": 0,
	"rentDue": 30, "newsSelected": "", "curStock": 0, "tickIdx": 0,
}
var prices: Array = []
var all_hist: Array = []
var biases: Array = []

# ── 타이머 ──
var trade_tmr: Timer
var toast_tmr: Timer

# ── UI 노드 참조 ──
var ui_root: Control
var scr_menu: Control
var scr_morning: Control
var scr_trade: Control
var scr_settle: Control
var scr_night: Control

# HUD
var hud_day_v: Label
var hud_cash_v: Label
var hud_total_v: Label
var hud_pnl_v: Label
var hud_rent_v: Label
var hud_countdown_v: Label
var hud_goal_bar: ProgressBar
var hud_goal_pct: Label

# 아침
var m_clock: Label
var nr_box: Control
var nr_badge: Label
var nr_news_txt: Label
var hint_stk: Label
var hint_dir_lbl: Label
var btn_go: Button
var news_card_nodes: Array = []

# 거래
var wl_items: Array = []
var stock_list_vbox_node: VBoxContainer
var stock_search_edit: LineEdit
var stock_scroll_cont: ScrollContainer
var chart_line: Line2D
var chart_bg: Panel
var price_num_lbl: Label
var price_chg_lbl: Label
var trade_clk_lbl: Label
var r_cash_lbl: Label
var r_eval_lbl: Label
var r_total_lbl: Label
var r_profit_lbl: Label
var r_stk_title_lbl: Label
var r_price_lbl: Label
var r_qty_lbl: Label
var r_avg_lbl: Label
var r_stk_pnl_lbl: Label
var r_rate_lbl: Label
var port_list_vbox: VBoxContainer
var tab_mkt_btn: Button
var tab_lmt_btn: Button
var inp_qty: LineEdit
var inp_lmt: LineEdit
var o_sum_lbl: Label
var pending_vbox: VBoxContainer
var pending_box: Control
var order_mode := "mkt"

# 모달
var modal_overlay: Control
var modal_title_lbl: Label
var modal_stock_lbl: Label
var modal_price_lbl: Label
var modal_holding_lbl: Label
var modal_avail_lbl: Label
var modal_confirm_btn: Button
var modal_is_buy: bool = true
var modal_detail_unit: Label
var modal_detail_qty: Label
var modal_detail_total: Label
var modal_detail_after: Label

# 통계 바
var stat_vol_lbl: Label
var stat_val_lbl: Label
var stat_up_lbl: Label
var stat_dn_lbl: Label
var volumes: Array = []

# 결산
var sc_real_lbl: Label
var sc_unreal_lbl: Label
var sc_refund_lbl: Label
var sc_cnt_lbl: Label
var sc_exp_lbl: Label
var rent_row_ctrl: Control
var stc_val_lbl: Label
var stc_chg_lbl: Label
var gpb_bar: ProgressBar
var gpb_pct_lbl: Label
var s_holdings_vbox: VBoxContainer
var settle_act_ctrl: Control
var wo_cv_btn: Button
var wo_tutor_btn: Button
var wo_rest_btn: Button

# 일간
var night_msg_lbl: Label
var n_day_lbl: Label
var n_total_lbl: Label
var n_pnl_lbl: Label
var n_work_lbl: Label
var n_exp_lbl: Label
var n_goal_lbl: Label
var n_nextday_lbl: Label

# 토스트
var toast_panel: PanelContainer
var toast_lbl: Label

# ═══════════════════════════════════
# 초기화
# ═══════════════════════════════════
func _ready():
	randomize()
	_init_game_data()
	_build_ui()
	show_screen("menu")

func _load_stocks_from_csv():
	STOCKS.clear()
	var path = "res://stock_data.csv"
	if not FileAccess.file_exists(path):
		STOCKS = [
			{"name": "삼성전자",        "base": 179700, "vol": 0.008},
			{"name": "SK하이닉스",     "base": 215000, "vol": 0.011},
			{"name": "LG에너지솔루션", "base": 312500, "vol": 0.009},
			{"name": "현대차",          "base": 189200, "vol": 0.007},
			{"name": "POSCO홀딩스",    "base": 285000, "vol": 0.010},
		]
		return
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	if not file.eof_reached():
		file.get_csv_line()
	var seen: Dictionary = {}
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() < 4:
			continue
		var ticker = str(line[0]).strip_edges()
		var name   = str(line[1]).strip_edges()
		var price_str = str(line[3]).strip_edges()
		if ticker == "" or name == "" or seen.has(ticker):
			continue
		var base_price = price_str.to_int()
		if base_price < 100:
			continue
		seen[ticker] = true
		STOCKS.append({"name": name, "base": base_price, "vol": 0.007 + randf() * 0.007, "ticker": ticker})
	file.close()

func _init_game_data():
	_load_stocks_from_csv()
	prices.clear(); all_hist.clear(); biases.clear(); volumes.clear()
	for s in STOCKS:
		prices.append(s["base"])
		all_hist.append([s["base"]])
		biases.append(0.0)
		volumes.append(0)

# ═══════════════════════════════════
# UI 빌드 (전체 화면 구성)
# ═══════════════════════════════════
func _build_ui():
	var cl = CanvasLayer.new()
	add_child(cl)

	ui_root = Control.new()
	ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	cl.add_child(ui_root)

	# 전체 배경색
	var root_bg = ColorRect.new()
	root_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_bg.color = C_BG
	ui_root.add_child(root_bg)

	# HUD
	_build_hud()

	# 스크린 영역 (HUD 아래)
	var sa = Control.new()
	sa.set_anchor_and_offset(SIDE_LEFT,   0.0, 0.0)
	sa.set_anchor_and_offset(SIDE_TOP,    0.0, 42.0)
	sa.set_anchor_and_offset(SIDE_RIGHT,  1.0, 0.0)
	sa.set_anchor_and_offset(SIDE_BOTTOM, 1.0, 0.0)
	ui_root.add_child(sa)

	scr_menu    = _build_menu(sa)
	scr_morning = _build_morning(sa)
	scr_trade   = _build_trade(sa)
	scr_settle  = _build_settle(sa)
	scr_night   = _build_night(sa)

	_build_toast()
	_build_modal()

	# 타이머
	trade_tmr = Timer.new(); trade_tmr.one_shot = false; trade_tmr.wait_time = 1.0
	trade_tmr.timeout.connect(_on_trade_tick)
	add_child(trade_tmr)

	toast_tmr = Timer.new(); toast_tmr.one_shot = true; toast_tmr.wait_time = 2.5
	toast_tmr.timeout.connect(func(): toast_panel.visible = false)
	add_child(toast_tmr)

# ── StyleBox 헬퍼 ──
func _sb(bg: Color, bw: int, bc: Color, r: int) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_width_left = bw; s.border_width_right = bw
	s.border_width_top  = bw; s.border_width_bottom = bw
	s.border_color = bc
	s.corner_radius_top_left    = r; s.corner_radius_top_right    = r
	s.corner_radius_bottom_left = r; s.corner_radius_bottom_right = r
	return s

func _lbl(txt: String, col: Color, sz: int, bold: bool = false) -> Label:
	var l = Label.new()
	l.text = txt
	l.add_theme_color_override("font_color", col)
	l.add_theme_font_size_override("font_size", sz)
	return l

func _btn(txt: String, bg: Color, fg: Color, r: int = 8) -> Button:
	var b = Button.new()
	b.text = txt
	b.add_theme_color_override("font_color", fg)
	b.add_theme_color_override("font_hover_color", fg)
	b.add_theme_color_override("font_pressed_color", fg)
	b.add_theme_stylebox_override("normal",   _sb(bg, 0, bg, r))
	b.add_theme_stylebox_override("hover",    _sb(bg.lightened(0.15), 0, bg, r))
	b.add_theme_stylebox_override("pressed",  _sb(bg.darkened(0.15),  0, bg, r))
	b.add_theme_stylebox_override("disabled", _sb(C_BDR2, 0, C_BDR2, r))
	b.add_theme_font_size_override("font_size", 13)
	return b

func _sep_h() -> HSeparator:
	var s = HSeparator.new()
	s.add_theme_stylebox_override("separator", _sb(C_BORDER, 0, C_BORDER, 0))
	return s

func _sep_v() -> VSeparator:
	var s = VSeparator.new()
	s.add_theme_stylebox_override("separator", _sb(C_BDR2, 0, C_BDR2, 0))
	s.custom_minimum_size = Vector2(1, 18)
	return s

func _row(key: String, key_col: Color = C_TEXT2) -> HBoxContainer:
	var hb = HBoxContainer.new()
	var k = _lbl(key, key_col, 11)
	k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(k)
	return hb

# ═══════════════════════════════════
# HUD
# ═══════════════════════════════════
func _build_hud():
	var hud_bg = Panel.new()
	hud_bg.set_anchor_and_offset(SIDE_LEFT,   0.0, 0.0)
	hud_bg.set_anchor_and_offset(SIDE_TOP,    0.0, 0.0)
	hud_bg.set_anchor_and_offset(SIDE_RIGHT,  1.0, 0.0)
	hud_bg.set_anchor_and_offset(SIDE_BOTTOM, 0.0, 42.0)
	hud_bg.add_theme_stylebox_override("panel", _sb(C_PANEL, 1, C_BORDER, 0))
	ui_root.add_child(hud_bg)

	var hb = HBoxContainer.new()
	hb.set_anchors_preset(Control.PRESET_FULL_RECT)
	hb.add_theme_constant_override("separation", 0)
	var m = StyleBoxEmpty.new()
	m.content_margin_left = 16; m.content_margin_right = 16
	m.content_margin_top = 0;   m.content_margin_bottom = 0
	hb.add_theme_stylebox_override("panel", m)
	hud_bg.add_child(hb)

	# 로고
	var logo = _lbl("내집마련", C_GOLD, 11)
	logo.add_theme_font_size_override("font_size", 11)
	logo.custom_minimum_size.x = 80
	hb.add_child(logo)

	hb.add_child(_sep_v())
	hb.add_child(_hud_item("DAY",   "1",           C_TEXT, func(l): hud_day_v = l))
	hb.add_child(_sep_v())
	hb.add_child(_hud_item("현금",  "10,000,000",  C_TEXT, func(l): hud_cash_v = l))
	hb.add_child(_sep_v())
	hb.add_child(_hud_item("총자산","10,000,000",  C_UP,   func(l): hud_total_v = l))
	hb.add_child(_sep_v())
	hb.add_child(_hud_item("오늘수익","±0",        C_TEXT, func(l): hud_pnl_v = l))
	hb.add_child(_sep_v())
	hb.add_child(_hud_item("월세",  "D-30",        C_GOLD, func(l): hud_rent_v = l))
	hb.add_child(_sep_v())
	hb.add_child(_hud_item("남은시간","03:00",      C_TEXT2,func(l): hud_countdown_v = l))

	# 오른쪽
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(spacer)

	# 목표바
	var gw = VBoxContainer.new()
	gw.alignment = BoxContainer.ALIGNMENT_CENTER
	var glbl = _lbl("내집 목표", C_TEXT3, 9)
	gw.add_child(glbl)

	var gb_wrap = Control.new()
	gb_wrap.custom_minimum_size = Vector2(110, 5)
	var gb_bg = ColorRect.new()
	gb_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	gb_bg.color = C_BDR2
	gb_wrap.add_child(gb_bg)
	hud_goal_bar = ProgressBar.new()
	hud_goal_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_goal_bar.max_value = 100; hud_goal_bar.value = 0
	hud_goal_bar.show_percentage = false
	hud_goal_bar.add_theme_stylebox_override("background", _sb(C_BDR2, 0, C_BDR2, 3))
	hud_goal_bar.add_theme_stylebox_override("fill",       _sb(C_GOLD, 0, C_GOLD, 3))
	gb_wrap.add_child(hud_goal_bar)
	gw.add_child(gb_wrap)

	hud_goal_pct = _lbl("0.0%", C_GOLD, 11)
	gw.add_child(hud_goal_pct)
	hb.add_child(gw)

func _hud_item(key: String, val: String, col: Color, setter: Callable) -> VBoxContainer:
	var vb = VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.custom_minimum_size.x = 10
	var k = _lbl(key, C_TEXT3, 8)
	vb.add_child(k)
	var v = _lbl(val, col, 12)
	setter.call(v)
	vb.add_child(v)
	return vb

# ═══════════════════════════════════
# 메인 메뉴 화면
# ═══════════════════════════════════
func _build_menu(parent: Control) -> Control:
	var scr = Control.new()
	scr.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(scr)

	# 배경 그라디언트 느낌 (단색)
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#0d1a30")
	scr.add_child(bg)

	var menu_cc = CenterContainer.new()
	menu_cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	scr.add_child(menu_cc)

	var center = VBoxContainer.new()
	center.custom_minimum_size = Vector2(300, 0)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 10)
	menu_cc.add_child(center)

	# 배지
	var badge = _lbl("CAPSTONE PROJECT 2026", C_BLUE, 10)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(badge)

	# 타이틀
	var title = _lbl("내 집 마련\n프로젝트", C_TEXT, 38)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	center.add_child(title)

	var sub = _lbl("현실 반영 투자 시뮬레이션", C_TEXT2, 13)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(sub)

	# 스탯
	var stats = HBoxContainer.new()
	stats.alignment = BoxContainer.ALIGNMENT_CENTER
	stats.add_theme_constant_override("separation", 40)
	for item in [["₩10,000,000", "초기 자본금"], ["₩55,000,000", "목표 금액"], ["무제한", "도전 기간"]]:
		var vb = VBoxContainer.new()
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		var v = _lbl(item[0], C_GOLD, 16)
		v.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(v)
		var k = _lbl(item[1], C_TEXT3, 10)
		k.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(k)
		stats.add_child(vb)
	center.add_child(stats)

	# 버튼
	var start_btn = _btn("▶ 게임 시작", C_BLUE, Color.WHITE, 10)
	start_btn.custom_minimum_size = Vector2(260, 48)
	start_btn.pressed.connect(_on_start_game)
	center.add_child(start_btn)

	var ver = _lbl("v0.6.0-alpha", C_TEXT3, 10)
	ver.set_anchor_and_offset(SIDE_RIGHT,  1.0, -20.0)
	ver.set_anchor_and_offset(SIDE_BOTTOM, 1.0, -18.0)
	scr.add_child(ver)

	return scr

# ═══════════════════════════════════
# 아침 화면
# ═══════════════════════════════════
func _build_morning(parent: Control) -> Control:
	var scr = Control.new()
	scr.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(scr)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#100c05")
	scr.add_child(bg)

	var morning_cc = CenterContainer.new()
	morning_cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	scr.add_child(morning_cc)

	var body = VBoxContainer.new()
	body.custom_minimum_size = Vector2(640, 0)
	body.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_theme_constant_override("separation", 14)
	morning_cc.add_child(body)

	m_clock = _lbl("07:00", C_GOLD, 48)
	m_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(m_clock)

	var sub = _lbl("장 시작까지 · 정보 수집 단계", C_TEXT3, 11)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(sub)

	var msg = _lbl("오늘의 뉴스를 선택하세요", C_TEXT, 20)
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(msg)

	var desc = _lbl("어떤 매체를 선택하느냐에 따라 힌트의 신뢰도와 기대수익률이 달라집니다", C_TEXT2, 12)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(desc)

	# 뉴스 카드 3개
	var cards_hb = HBoxContainer.new()
	cards_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_hb.add_theme_constant_override("separation", 12)
	body.add_child(cards_hb)

	var card_data = [
		["tv",  "📺", "TV 뉴스 (안전파)",    "검증된 전문가 분석. 안정적 전망 제공.", "✔ 정확률 80%", C_BLUE],
		["net", "🌐", "인터넷 기사 (중도파)", "[단독] 핫마주 계약 어드밴스. 빠른 속보.", "▲ 정확률 70%", C_UP],
		["yt",  "📱", "유튜브 유라이버 (도박파)","(속보) 세력 매집 포착!! 고위험 고수익.", "⚠ 정확률 30%", C_DOWN],
	]
	news_card_nodes.clear()
	for cd in card_data:
		var card = _build_news_card(cd[0], cd[1], cd[2], cd[3], cd[4], cd[5])
		cards_hb.add_child(card)
		news_card_nodes.append(card)

	# 뉴스 결과 박스
	nr_box = PanelContainer.new()
	nr_box.add_theme_stylebox_override("panel", _sb(C_PANEL2, 1, C_BDR2, 10))
	nr_box.custom_minimum_size = Vector2(635, 0)
	nr_box.visible = false
	body.add_child(nr_box)

	var nr_inner = VBoxContainer.new()
	nr_inner.add_theme_constant_override("separation", 6)
	nr_box.add_child(nr_inner)

	nr_badge = _lbl("", C_BLUE, 10)
	nr_inner.add_child(nr_badge)
	nr_news_txt = _lbl("", C_TEXT, 13)
	nr_news_txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nr_inner.add_child(nr_news_txt)
	nr_inner.add_child(_sep_h())

	var hint_hb = HBoxContainer.new()
	hint_hb.add_theme_constant_override("separation", 9)
	var hp = PanelContainer.new()
	hp.add_theme_stylebox_override("panel", _sb(Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.1), 1, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.2), 8))
	hp.add_child(hint_hb)
	nr_inner.add_child(hp)

	hint_hb.add_child(_lbl("💡 오늘의 힌트", C_TEXT3, 10))
	hint_stk = _lbl("-", C_TEXT, 13)
	hint_hb.add_child(hint_stk)
	hint_hb.add_child(_lbl("내일 예상", C_TEXT3, 10))
	hint_dir_lbl = _lbl("-", C_TEXT, 13)
	hint_hb.add_child(hint_dir_lbl)

	# 거래 시작 버튼
	btn_go = _btn("🔔 장 시작하기 (09:00 오픈)", C_GOLD, Color.BLACK, 10)
	btn_go.custom_minimum_size = Vector2(635, 46)
	btn_go.add_theme_font_size_override("font_size", 14)
	btn_go.disabled = true
	btn_go.pressed.connect(_on_go_trade)
	body.add_child(btn_go)

	return scr

func _build_news_card(type: String, icon: String, type_txt: String, desc_txt: String, acc_txt: String, acc_color: Color) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 140)
	card.add_theme_stylebox_override("panel", _sb(C_PANEL2, 1, C_BDR2, 12))
	card.mouse_filter = Control.MOUSE_FILTER_STOP

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	card.add_child(vb)

	vb.add_child(_lbl(icon, C_TEXT, 22))
	var type_lbl = _lbl(type_txt, acc_color, 10)
	vb.add_child(type_lbl)
	var desc_lbl = _lbl(desc_txt, C_TEXT2, 11)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(desc_lbl)
	var acc_lbl = _lbl(acc_txt, acc_color, 9)
	vb.add_child(acc_lbl)

	card.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed:
			_pick_news(type)
	)
	return card

# ═══════════════════════════════════
# 거래 화면
# ═══════════════════════════════════
func _build_trade(parent: Control) -> Control:
	var scr = Control.new()
	scr.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(scr)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = C_BG
	scr.add_child(bg)

	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 0)
	scr.add_child(hbox)

	# ── 왼쪽 종목 검색 패널 ──
	var sl_cont = PanelContainer.new()
	sl_cont.custom_minimum_size = Vector2(210, 0)
	sl_cont.add_theme_stylebox_override("panel", _sb(C_PANEL, 1, C_BORDER, 0))
	hbox.add_child(sl_cont)

	var sl_vbox = VBoxContainer.new()
	sl_vbox.add_theme_constant_override("separation", 0)
	sl_cont.add_child(sl_vbox)

	# 검색 입력창
	var search_bg = PanelContainer.new()
	search_bg.add_theme_stylebox_override("panel", _sb(C_PANEL2, 0, C_BORDER, 0))
	sl_vbox.add_child(search_bg)
	stock_search_edit = LineEdit.new()
	stock_search_edit.placeholder_text = "🔍 종목 검색"
	stock_search_edit.add_theme_stylebox_override("normal", _sb(C_PANEL2, 0, C_BORDER, 0))
	stock_search_edit.add_theme_color_override("font_color", C_TEXT)
	stock_search_edit.add_theme_color_override("font_placeholder_color", C_TEXT3)
	stock_search_edit.add_theme_font_size_override("font_size", 11)
	stock_search_edit.text_changed.connect(func(q): _filter_stocks(q))
	search_bg.add_child(stock_search_edit)

	# 스크롤 종목 리스트
	var sl_scroll = ScrollContainer.new()
	sl_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sl_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sl_vbox.add_child(sl_scroll)
	stock_scroll_cont = sl_scroll

	stock_list_vbox_node = VBoxContainer.new()
	stock_list_vbox_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stock_list_vbox_node.add_theme_constant_override("separation", 1)
	sl_scroll.add_child(stock_list_vbox_node)

	wl_items.clear()
	for i in STOCKS.size():
		var s = STOCKS[i]
		var item = PanelContainer.new()
		item.add_theme_stylebox_override("panel", _sb(C_PANEL2, 1, C_BDR2, 0))
		item.mouse_filter = Control.MOUSE_FILTER_STOP
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var ivb = VBoxContainer.new()
		ivb.add_theme_constant_override("separation", 1)
		item.add_child(ivb)
		var top_row = HBoxContainer.new()
		var name_l = _lbl(s["name"], C_TEXT, 10)
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_l.clip_text = true
		top_row.add_child(name_l)
		ivb.add_child(top_row)
		var bot_row = HBoxContainer.new()
		var plbl = _lbl(fmt(s["base"]), C_TEXT, 11)
		plbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bot_row.add_child(plbl)
		var clbl = _lbl("+0.00%", C_UP, 9)
		bot_row.add_child(clbl)
		ivb.add_child(bot_row)
		stock_list_vbox_node.add_child(item)
		var idx = i
		item.gui_input.connect(func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed:
				_change_stock(idx)
		)
		wl_items.append({"panel": item, "price": plbl, "chg": clbl, "name": s["name"]})

	# ── 중앙 패널 (차트) ──
	var left = VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 0)
	hbox.add_child(left)

	# 탑바
	var topbar = PanelContainer.new()
	topbar.add_theme_stylebox_override("panel", _sb(C_PANEL, 1, C_BORDER, 0))
	left.add_child(topbar)
	var tb_hb = HBoxContainer.new()
	tb_hb.add_theme_constant_override("separation", 10)
	topbar.add_child(tb_hb)

	price_num_lbl = _lbl("179,700", C_TEXT, 18)
	tb_hb.add_child(price_num_lbl)
	price_chg_lbl = _lbl("+0.00%", C_UP, 11)
	tb_hb.add_child(price_chg_lbl)
	var spacer = Control.new(); spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tb_hb.add_child(spacer)
	trade_clk_lbl = _lbl("09:00", C_UP, 11)
	tb_hb.add_child(trade_clk_lbl)

	# 차트 영역
	chart_bg = Panel.new()
	chart_bg.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chart_bg.add_theme_stylebox_override("panel", _sb(C_PANEL, 1, C_BORDER, 8))
	left.add_child(chart_bg)

	chart_line = Line2D.new()
	chart_line.width = 2.0
	chart_line.default_color = C_UP
	chart_bg.add_child(chart_line)

	# 통계 바 (차트 아래, 시간축 위)
	var stat_bar = HBoxContainer.new()
	stat_bar.add_theme_constant_override("separation", 6)
	var stat_bar_pad = PanelContainer.new()
	stat_bar_pad.add_theme_stylebox_override("panel", _sb(C_PANEL, 1, C_BORDER, 0))
	stat_bar_pad.add_child(stat_bar)
	left.add_child(stat_bar_pad)

	for stat_data in [["📊 거래량", "0주", true], ["💰 거래대금", "0억", false], ["🔴 급상승", "-", true], ["🔵 급하락", "-", false]]:
		var sb = PanelContainer.new()
		sb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sb.add_theme_stylebox_override("panel", _sb(C_PANEL2, 1, C_BDR2, 6))
		var svb = VBoxContainer.new()
		svb.add_theme_constant_override("separation", 2)
		sb.add_child(svb)
		svb.add_child(_lbl(stat_data[0], C_TEXT3, 9))
		var val_lbl = _lbl(stat_data[1], C_DOWN if stat_data[2] else C_BLUE, 11)
		svb.add_child(val_lbl)
		stat_bar.add_child(sb)
		match stat_data[0]:
			"📊 거래량": stat_vol_lbl = val_lbl
			"💰 거래대금": stat_val_lbl = val_lbl
			"🔴 급상승": stat_up_lbl = val_lbl
			"🔵 급하락": stat_dn_lbl = val_lbl

	# 시간축
	var xaxis = HBoxContainer.new()
	xaxis.add_theme_constant_override("separation", 0)
	for t in ["09:00", "10:38", "12:15", "13:53", "15:30"]:
		var tl = _lbl(t, C_TEXT3, 9)
		tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		xaxis.add_child(tl)
	left.add_child(xaxis)

	# ── 오른쪽 패널 ──
	var right_cont = PanelContainer.new()
	right_cont.custom_minimum_size = Vector2(278, 0)
	right_cont.add_theme_stylebox_override("panel", _sb(C_PANEL, 1, C_BORDER, 0))
	hbox.add_child(right_cont)

	var right = VBoxContainer.new()
	right.add_theme_constant_override("separation", 0)
	right_cont.add_child(right)

	# 자산 요약
	var asset_sec = _build_right_section("내 자산")
	right.add_child(asset_sec[0])
	var av = asset_sec[1]
	r_cash_lbl   = _add_row(av, "현금",   "-")
	r_eval_lbl   = _add_row(av, "평가금", "-")
	av.add_child(_sep_h())
	r_total_lbl  = _add_row(av, "총 자산", "-", C_GOLD, 13)
	r_profit_lbl = _add_row(av, "총이익",  "-")

	# 종목 정보
	var stk_sec = _build_right_section("종목 정보")
	right.add_child(stk_sec[0])
	var sv = stk_sec[1]
	r_stk_title_lbl = _lbl("삼성전자", C_TEXT, 11)
	sv.add_child(r_stk_title_lbl)
	r_price_lbl   = _add_row(sv, "현재가",   "-")
	r_qty_lbl     = _add_row(sv, "보유 수량","0주")
	r_avg_lbl     = _add_row(sv, "평균 단가","-")
	r_stk_pnl_lbl = _add_row(sv, "평가이익", "-")
	r_rate_lbl    = _add_row(sv, "수익률",   "-")

	# 보유 종목 (스크롤)
	var port_sec = _build_right_section("보유 종목")
	var port_outer = port_sec[0]
	port_outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# pad(MarginContainer)와 inner(VBoxContainer)도 expand 되어야 port_scroll이 늘어남
	var port_pad = port_outer.get_child(1)
	port_pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
	port_pad.get_child(0).size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(port_outer)
	var port_scroll = ScrollContainer.new()
	port_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	port_sec[1].add_child(port_scroll)
	port_list_vbox = VBoxContainer.new()
	port_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	port_list_vbox.add_theme_constant_override("separation", 4)
	port_scroll.add_child(port_list_vbox)

	# 주문 버튼 (버튼 2개 → 모달 팝업)
	var ord_bg = PanelContainer.new()
	ord_bg.add_theme_stylebox_override("panel", _sb(C_PANEL, 1, C_BORDER, 0))
	right.add_child(ord_bg)
	var ord_vb = VBoxContainer.new()
	ord_vb.add_theme_constant_override("separation", 5)
	ord_bg.add_child(ord_vb)

	# 더미 입력 노드 (기존 _do_buy/_do_sell 로직 그대로 사용)
	inp_qty = LineEdit.new(); inp_qty.visible = false; add_child(inp_qty)
	inp_lmt = LineEdit.new(); inp_lmt.visible = false; add_child(inp_lmt)
	o_sum_lbl = _lbl("", C_TEXT3, 10); o_sum_lbl.visible = false; add_child(o_sum_lbl)
	tab_mkt_btn = Button.new(); tab_mkt_btn.visible = false; add_child(tab_mkt_btn)
	tab_lmt_btn = Button.new(); tab_lmt_btn.visible = false; add_child(tab_lmt_btn)

	var open_btns = HBoxContainer.new()
	open_btns.add_theme_constant_override("separation", 5)
	ord_vb.add_child(open_btns)
	var buy_btn = _btn("▲ 매수", Color(C_DOWN.r, C_DOWN.g, C_DOWN.b, 0.2), C_DOWN, 8)
	buy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buy_btn.custom_minimum_size = Vector2(0, 42)
	buy_btn.add_theme_font_size_override("font_size", 14)
	buy_btn.pressed.connect(func(): _open_modal(true))
	open_btns.add_child(buy_btn)
	var sell_btn = _btn("▼ 매도", Color(C_BLUE.r, C_BLUE.g, C_BLUE.b, 0.2), C_BLUE, 8)
	sell_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sell_btn.custom_minimum_size = Vector2(0, 42)
	sell_btn.add_theme_font_size_override("font_size", 14)
	sell_btn.pressed.connect(func(): _open_modal(false))
	open_btns.add_child(sell_btn)

	# 미체결
	pending_box = VBoxContainer.new()
	pending_box.add_theme_constant_override("separation", 0)
	pending_box.visible = false
	right.add_child(pending_box)
	pending_box.add_child(_lbl("미체결 주문", C_TEXT3, 8))
	pending_vbox = VBoxContainer.new()
	pending_box.add_child(pending_vbox)

	return scr

func _build_right_section(title: String) -> Array:
	var outer = VBoxContainer.new()
	outer.add_theme_constant_override("separation", 4)
	var sep = Panel.new()
	sep.custom_minimum_size = Vector2(0, 1)
	sep.add_theme_stylebox_override("panel", _sb(C_BORDER, 0, C_BORDER, 0))
	outer.add_child(sep)
	var inner = VBoxContainer.new()
	inner.add_theme_constant_override("separation", 3)
	var pad = MarginContainer.new()
	pad.add_theme_constant_override("margin_left",   10)
	pad.add_theme_constant_override("margin_right",  10)
	pad.add_theme_constant_override("margin_top",    8)
	pad.add_theme_constant_override("margin_bottom", 8)
	pad.add_child(inner)
	outer.add_child(pad)
	var title_lbl = _lbl(title.to_upper(), C_TEXT3, 8)
	inner.add_child(title_lbl)
	return [outer, inner]

func _add_row(parent: VBoxContainer, key: String, val: String, val_col: Color = C_TEXT, val_sz: int = 11) -> Label:
	var hb = HBoxContainer.new()
	var k = _lbl(key, C_TEXT2, 11)
	k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(k)
	var v = _lbl(val, val_col, val_sz)
	hb.add_child(v)
	parent.add_child(hb)
	return v

# ═══════════════════════════════════
# 결산 화면
# ═══════════════════════════════════
func _build_settle(parent: Control) -> Control:
	var scr = Control.new()
	scr.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(scr)
	var bg = ColorRect.new(); bg.set_anchors_preset(Control.PRESET_FULL_RECT); bg.color = C_BG
	scr.add_child(bg)

	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scr.add_child(scroll)

	var hb = HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_theme_constant_override("separation", 16)
	scroll.add_child(hb)

	# 왼쪽 컬럼
	var lc = VBoxContainer.new()
	lc.custom_minimum_size = Vector2(330, 0)
	lc.add_theme_constant_override("separation", 11)
	hb.add_child(lc)

	# 거래 결과
	var res_card = _sc_card("📊 오늘 거래 결과", lc)
	sc_real_lbl   = _sc_row(res_card, "실현이익",     "+0원", C_UP)
	sc_unreal_lbl = _sc_row(res_card, "평가이익",     "0원")
	sc_refund_lbl = _sc_row(res_card, "미체결 환불",  "없음")
	sc_cnt_lbl    = _sc_row(res_card, "총 거래 횟수", "0회")

	# 생활비
	var exp_card = _sc_card("💸 고정 생활비 지출", lc)
	_sc_row(exp_card, "🍚 식비 (1일)", "-30,000원", C_DOWN)
	rent_row_ctrl = HBoxContainer.new()
	var rk = _lbl("🏠 월세", C_TEXT2, 11)
	rk.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rent_row_ctrl.add_child(rk)
	rent_row_ctrl.add_child(_lbl("-500,000원", C_DOWN, 11))
	rent_row_ctrl.visible = false
	exp_card.add_child(rent_row_ctrl)
	exp_card.add_child(_sep_h())
	var exp_total_hb = HBoxContainer.new()
	var ek = _lbl("합계", C_TEXT, 11)
	ek.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exp_total_hb.add_child(ek)
	sc_exp_lbl = _lbl("-30,000원", C_DOWN, 11)
	exp_total_hb.add_child(sc_exp_lbl)
	exp_card.add_child(exp_total_hb)

	# 알바
	var work_card = _sc_card("💼 아르바이트 선택 (1일 1회)", lc)
	wo_cv_btn    = _build_work_btn("🪛 편의점 알바",   "4시간 · 오후 파트타임", "+200,000원", func(): _do_work("cv",    200000))
	wo_tutor_btn = _build_work_btn("📚 과외 알바",     "2시간 · 고수익",        "+350,000원", func(): _do_work("tutor", 350000))
	wo_rest_btn  = _build_work_btn("😴 오늘은 쉬기",   "내일 컨디션 회복",      "없음 없음",  func(): _do_work("rest",  0))
	work_card.add_child(wo_cv_btn)
	work_card.add_child(wo_tutor_btn)
	work_card.add_child(wo_rest_btn)

	# 오른쪽 컬럼
	var rc = VBoxContainer.new()
	rc.custom_minimum_size = Vector2(330, 0)
	rc.add_theme_constant_override("separation", 11)
	hb.add_child(rc)

	# 총자산 카드
	var total_card = PanelContainer.new()
	total_card.add_theme_stylebox_override("panel", _sb(C_PANEL2, 1, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.3), 10))
	rc.add_child(total_card)
	var tc_vb = VBoxContainer.new()
	tc_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	tc_vb.add_theme_constant_override("separation", 4)
	total_card.add_child(tc_vb)
	var tc_lbl = _lbl("오늘 최종 총자산", C_TEXT3, 9)
	tc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tc_vb.add_child(tc_lbl)
	stc_val_lbl = _lbl("-", C_GOLD, 26)
	stc_val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tc_vb.add_child(stc_val_lbl)
	stc_chg_lbl = _lbl("-", C_TEXT, 11)
	stc_chg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tc_vb.add_child(stc_chg_lbl)

	var gpb_hb = HBoxContainer.new()
	var gpb_k = _lbl("내집 목표 달성률", C_TEXT3, 10); gpb_k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gpb_hb.add_child(gpb_k)
	gpb_pct_lbl = _lbl("0.0%", C_TEXT3, 10)
	gpb_hb.add_child(gpb_pct_lbl)
	tc_vb.add_child(gpb_hb)

	gpb_bar = ProgressBar.new()
	gpb_bar.custom_minimum_size = Vector2(0, 7)
	gpb_bar.max_value = 100; gpb_bar.value = 0
	gpb_bar.show_percentage = false
	gpb_bar.add_theme_stylebox_override("background", _sb(C_BORDER, 0, C_BORDER, 4))
	gpb_bar.add_theme_stylebox_override("fill",       _sb(C_GOLD,   0, C_GOLD,   4))
	tc_vb.add_child(gpb_bar)

	# 보유 종목 현황
	var hold_card = _sc_card("🏦 보유 종목 현황", rc)
	hold_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	s_holdings_vbox = VBoxContainer.new()
	hold_card.add_child(s_holdings_vbox)

	# 다음 버튼
	settle_act_ctrl = VBoxContainer.new()
	settle_act_ctrl.visible = false
	rc.add_child(settle_act_ctrl)
	var next_btn = _btn("일간 해설 →", C_UP, Color.BLACK, 10)
	next_btn.custom_minimum_size = Vector2(0, 44)
	next_btn.add_theme_font_size_override("font_size", 14)
	next_btn.pressed.connect(_go_night)
	settle_act_ctrl.add_child(next_btn)

	return scr

func _sc_card(title: String, parent: VBoxContainer) -> VBoxContainer:
	var pc = PanelContainer.new()
	pc.add_theme_stylebox_override("panel", _sb(C_PANEL2, 1, C_BDR2, 10))
	parent.add_child(pc)
	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)
	pc.add_child(vb)
	vb.add_child(_lbl(title.to_upper(), C_TEXT3, 8))
	return vb

func _sc_row(parent: VBoxContainer, key: String, val: String, val_col: Color = C_TEXT) -> Label:
	var hb = HBoxContainer.new()
	var k = _lbl(key, C_TEXT2, 11); k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(k)
	var v = _lbl(val, val_col, 11)
	hb.add_child(v)
	parent.add_child(hb)
	return v

func _build_work_btn(name_txt: String, time_txt: String, pay_txt: String, cb: Callable) -> Button:
	var b = Button.new()
	b.text = ""
	b.add_theme_stylebox_override("normal",  _sb(C_PANEL,  1, C_BDR2,   8))
	b.add_theme_stylebox_override("hover",   _sb(C_PANEL2, 1, C_GOLD,   8))
	b.add_theme_stylebox_override("pressed", _sb(C_PANEL2, 1, C_GOLD,   8))
	b.add_theme_stylebox_override("disabled",_sb(C_PANEL,  1, C_BORDER, 8))
	b.custom_minimum_size = Vector2(0, 44)
	b.pressed.connect(cb)

	var hb = HBoxContainer.new()
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.set_anchors_preset(Control.PRESET_FULL_RECT)
	b.add_child(hb)
	var name_lbl = _lbl(name_txt, C_TEXT, 12); name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(name_lbl)
	var time_lbl = _lbl(time_txt, C_TEXT2, 10)
	time_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(time_lbl)
	var pay_lbl = _lbl(pay_txt, C_GOLD, 13)
	pay_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(pay_lbl)
	return b

# ═══════════════════════════════════
# 일간(야간) 화면
# ═══════════════════════════════════
func _build_night(parent: Control) -> Control:
	var scr = Control.new()
	scr.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(scr)
	var bg = ColorRect.new(); bg.set_anchors_preset(Control.PRESET_FULL_RECT); bg.color = C_BG
	scr.add_child(bg)

	var night_cc = CenterContainer.new()
	night_cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	scr.add_child(night_cc)

	var center = VBoxContainer.new()
	center.custom_minimum_size = Vector2(400, 0)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 12)
	night_cc.add_child(center)

	center.add_child(_lbl("🌙", C_TEXT, 28))
	var clock = _lbl("23:00", C_PURPLE, 50)
	clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(clock)
	var night_sub = _lbl("일간 · 하루가 끝났습니다", C_TEXT3, 11)
	night_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(night_sub)
	night_msg_lbl = _lbl("오늘도 수고했어요", C_TEXT, 14)
	night_msg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(night_msg_lbl)

	# 요약 카드
	var summary = PanelContainer.new()
	summary.add_theme_stylebox_override("panel", _sb(C_PANEL2, 1, C_BDR2, 12))
	summary.custom_minimum_size = Vector2(340, 0)
	center.add_child(summary)
	var sv = VBoxContainer.new()
	sv.add_theme_constant_override("separation", 4)
	summary.add_child(sv)
	sv.add_child(_lbl("📋 DAY 결산 요약", C_TEXT3, 9))
	n_day_lbl   = _sc_row(sv, "날짜",      "Day 1")
	n_total_lbl = _sc_row(sv, "총자산",    "-",  C_GOLD)
	n_pnl_lbl   = _sc_row(sv, "오늘 수익", "-")
	n_work_lbl  = _sc_row(sv, "알바 수입", "-")
	n_exp_lbl   = _sc_row(sv, "생활비 지출","-", C_DOWN)
	n_goal_lbl  = _sc_row(sv, "달성률",    "-",  C_GOLD)

	var morn_hb = HBoxContainer.new()
	morn_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(morn_hb)
	n_nextday_lbl = _lbl("2", C_TEXT, 14)
	var morn_btn_txt_pre = _lbl("☀ 다음 날 시작 (Day ", C_TEXT, 14)
	var morn_btn = _btn("☀ 다음 날 시작", C_GOLD, Color.BLACK, 10)
	morn_btn.custom_minimum_size = Vector2(260, 44)
	morn_btn.add_theme_font_size_override("font_size", 14)
	morn_btn.pressed.connect(_go_morning)
	center.add_child(morn_btn)

	return scr

# ── 토스트 ──
func _build_toast():
	toast_panel = PanelContainer.new()
	toast_panel.add_theme_stylebox_override("panel", _sb(C_PANEL2, 1, C_BDR2, 8))
	toast_panel.set_anchor_and_offset(SIDE_RIGHT,  1.0, -20.0)
	toast_panel.set_anchor_and_offset(SIDE_BOTTOM, 1.0, -20.0)
	toast_panel.set_anchor_and_offset(SIDE_LEFT,   1.0, -280.0)
	toast_panel.set_anchor_and_offset(SIDE_TOP,    1.0, -60.0)
	toast_panel.visible = false
	ui_root.add_child(toast_panel)
	toast_lbl = _lbl("", C_TEXT, 12)
	toast_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_panel.add_child(toast_lbl)

# ── 모달 빌드 ──
func _build_modal():
	# 별도 CanvasLayer(layer=100)로 항상 화면 최상단, 뷰포트 전체 커버 보장
	var modal_layer = CanvasLayer.new()
	modal_layer.layer = 100
	add_child(modal_layer)

	modal_overlay = Control.new()
	modal_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_overlay.visible = false
	modal_layer.add_child(modal_overlay)

	var dim = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.7)
	modal_overlay.add_child(dim)
	dim.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed:
			_close_modal()
	)

	# CenterContainer로 패널을 정중앙에 배치
	var modal_cc = CenterContainer.new()
	modal_cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_overlay.add_child(modal_cc)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(380, 0)
	panel.add_theme_stylebox_override("panel", _sb(C_PANEL2, 1, C_BDR2, 12))
	modal_cc.add_child(panel)

	var mvb = VBoxContainer.new()
	mvb.add_theme_constant_override("separation", 10)
	panel.add_child(mvb)

	# 헤더 (제목 + X버튼)
	var header = HBoxContainer.new()
	mvb.add_child(header)
	modal_title_lbl = _lbl("▲ 매수 주문", C_DOWN, 15)
	modal_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(modal_title_lbl)
	var close_btn = _btn("✕", C_PANEL2, C_TEXT2, 6)
	close_btn.custom_minimum_size = Vector2(28, 28)
	close_btn.pressed.connect(_close_modal)
	header.add_child(close_btn)

	mvb.add_child(_sep_h())

	# 종목 정보
	var info_bg = PanelContainer.new()
	info_bg.add_theme_stylebox_override("panel", _sb(C_PANEL, 1, C_BORDER, 8))
	mvb.add_child(info_bg)
	var info_vb = VBoxContainer.new()
	info_vb.add_theme_constant_override("separation", 4)
	info_bg.add_child(info_vb)
	modal_stock_lbl = _lbl("삼성전자", C_TEXT, 13)
	info_vb.add_child(modal_stock_lbl)
	var info_row1 = HBoxContainer.new()
	info_vb.add_child(info_row1)
	modal_price_lbl = _lbl("179,700원", C_GOLD, 12)
	modal_price_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_row1.add_child(modal_price_lbl)
	modal_holding_lbl = _lbl("보유 0주", C_TEXT2, 11)
	info_row1.add_child(modal_holding_lbl)
	modal_avail_lbl = _lbl("매수가능 0주", C_TEXT2, 10)
	info_vb.add_child(modal_avail_lbl)

	# 탭
	var tab_hb = HBoxContainer.new()
	tab_hb.add_theme_constant_override("separation", 4)
	mvb.add_child(tab_hb)
	tab_mkt_btn = _btn("시장가", Color(C_BLUE.r, C_BLUE.g, C_BLUE.b, 0.2), C_BLUE, 5)
	tab_mkt_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_mkt_btn.pressed.connect(func(): _set_order_mode("mkt"))
	tab_hb.add_child(tab_mkt_btn)
	tab_lmt_btn = _btn("지정가", C_PANEL, C_TEXT2, 5)
	tab_lmt_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_lmt_btn.pressed.connect(func(): _set_order_mode("lmt"))
	tab_hb.add_child(tab_lmt_btn)

	# 수량 입력
	inp_qty = LineEdit.new()
	inp_qty.placeholder_text = "수량 (주)"
	inp_qty.add_theme_stylebox_override("normal", _sb(C_PANEL, 1, C_BDR2, 6))
	inp_qty.add_theme_color_override("font_color", C_TEXT)
	inp_qty.add_theme_color_override("font_placeholder_color", C_TEXT3)
	inp_qty.text_changed.connect(func(_t): _calc_sum())
	mvb.add_child(inp_qty)

	# 지정가 입력
	inp_lmt = LineEdit.new()
	inp_lmt.placeholder_text = "지정가 (원)"
	inp_lmt.add_theme_stylebox_override("normal", _sb(C_PANEL, 1, C_BDR2, 6))
	inp_lmt.add_theme_color_override("font_color", C_TEXT)
	inp_lmt.add_theme_color_override("font_placeholder_color", C_TEXT3)
	inp_lmt.visible = false
	inp_lmt.text_changed.connect(func(_t): _calc_sum())
	mvb.add_child(inp_lmt)

	# 주문 요약
	var sum_bg = PanelContainer.new()
	sum_bg.add_theme_stylebox_override("panel", _sb(C_PANEL, 1, C_BORDER, 8))
	mvb.add_child(sum_bg)
	var sum_vb = VBoxContainer.new()
	sum_vb.add_theme_constant_override("separation", 4)
	sum_bg.add_child(sum_vb)
	modal_detail_unit  = _make_sum_row(sum_vb, "단가")
	modal_detail_qty   = _make_sum_row(sum_vb, "수량")
	modal_detail_total = _make_sum_row(sum_vb, "총금액")
	sum_vb.add_child(_sep_h())
	modal_detail_after = _make_sum_row(sum_vb, "주문 후 잔액")
	o_sum_lbl = modal_detail_total  # _calc_sum 호환

	# 확정 버튼
	modal_confirm_btn = _btn("매수 확정", C_DOWN, Color.WHITE, 10)
	modal_confirm_btn.custom_minimum_size = Vector2(0, 44)
	modal_confirm_btn.add_theme_font_size_override("font_size", 14)
	modal_confirm_btn.pressed.connect(_on_modal_confirm)
	mvb.add_child(modal_confirm_btn)

func _make_sum_row(parent: VBoxContainer, key: String) -> Label:
	var hb = HBoxContainer.new()
	var k = _lbl(key, C_TEXT2, 11); k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(k)
	var v = _lbl("-", C_TEXT, 11)
	hb.add_child(v)
	parent.add_child(hb)
	return v

func _open_modal(is_buy: bool):
	modal_is_buy = is_buy
	var idx: int = G["curStock"] as int
	var p: int   = prices[idx]
	var port: Dictionary = G["portfolio"].get(idx, {})
	var held: int = port.get("qty", 0) as int
	var cash: int = G["cash"] as int
	var avail_buy: int = cash / max(p, 1)

	modal_title_lbl.text = ("▲ 매수 주문" if is_buy else "▼ 매도 주문")
	modal_title_lbl.add_theme_color_override("font_color", C_DOWN if is_buy else C_BLUE)
	modal_stock_lbl.text   = STOCKS[idx]["name"] as String
	modal_price_lbl.text   = fmt(p) + "원"
	modal_holding_lbl.text = "보유 %d주" % held
	modal_avail_lbl.text   = ("매수가능 %d주" if is_buy else "매도가능 %d주") % (avail_buy if is_buy else held)
	modal_confirm_btn.text = "매수 확정" if is_buy else "매도 확정"
	modal_confirm_btn.add_theme_stylebox_override("normal",  _sb(C_DOWN if is_buy else C_BLUE, 0, C_DOWN, 10))
	modal_confirm_btn.add_theme_stylebox_override("hover",   _sb((C_DOWN if is_buy else C_BLUE).lightened(0.1), 0, C_DOWN, 10))
	modal_confirm_btn.add_theme_stylebox_override("pressed", _sb((C_DOWN if is_buy else C_BLUE).darkened(0.1), 0, C_DOWN, 10))

	inp_qty.text = ""; inp_lmt.text = ""
	order_mode = "mkt"
	_set_order_mode("mkt")
	_update_modal_sum()
	modal_overlay.visible = true

func _close_modal():
	modal_overlay.visible = false

func _on_modal_confirm():
	if modal_is_buy:
		_do_buy()
	else:
		_do_sell()
	if not modal_overlay.visible:
		return
	_close_modal()

func _update_modal_sum():
	var idx: int = G["curStock"] as int
	var qty: int = inp_qty.text.to_int()
	var unit_p: int = (inp_lmt.text.to_int() if inp_lmt.text.length() > 0 else prices[idx]) if order_mode == "lmt" else prices[idx]
	var total: int  = qty * unit_p
	var after: int  = (G["cash"] as int) - (total if modal_is_buy else -total)
	modal_detail_unit.text  = fmt(unit_p) + "원"
	modal_detail_qty.text   = ("%d주" % qty) if qty > 0 else "-"
	modal_detail_total.text = (fmt(total) + "원") if qty > 0 else "-"
	modal_detail_after.text = fmt(max(after, 0)) + "원"
	modal_detail_after.add_theme_color_override("font_color", C_DOWN if after >= 0 else C_GOLD)

# ═══════════════════════════════════
# 화면 전환
# ═══════════════════════════════════
func show_screen(name: String):
	scr_menu.visible    = (name == "menu")
	scr_morning.visible = (name == "morning")
	scr_trade.visible   = (name == "trade")
	scr_settle.visible  = (name == "settle")
	scr_night.visible   = (name == "night")

# ═══════════════════════════════════
# HUD 업데이트
# ═══════════════════════════════════
func _update_hud():
	var total: int  = _get_total_asset()
	var pct: float  = _get_goal_pct()
	hud_day_v.text   = str(G["day"] as int)
	hud_cash_v.text  = fmt(G["cash"] as int)
	hud_total_v.text = fmt(total)
	hud_rent_v.text  = "D-%d" % (G["rentDue"] as int)
	hud_goal_bar.value = pct
	hud_goal_pct.text  = "%.1f%%" % pct
	var dp: int = G["todayPnl"] as int
	hud_pnl_v.text  = ("+" if dp >= 0 else "") + fmt(dp)
	hud_pnl_v.add_theme_color_override("font_color", C_UP if dp >= 0 else C_DOWN)

# ═══════════════════════════════════
# PHASE A – 아침
# ═══════════════════════════════════
func _on_start_game():
	G["day"] = 1; G["cash"] = 10000000; G["startCash"] = 10000000
	G["portfolio"] = {}; G["pendingOrders"] = []
	G["todayPnl"] = 0; G["realPnl"] = 0; G["tradeCount"] = 0
	G["workDone"] = false; G["workIncome"] = 0; G["rentDue"] = 30
	G["newsSelected"] = ""; G["curStock"] = 0; G["tickIdx"] = 0
	for i in STOCKS.size():
		prices[i] = STOCKS[i]["base"]
		all_hist[i] = [STOCKS[i]["base"]]
		biases[i] = 0.0
	_init_morning()
	show_screen("morning")

func _init_morning():
	G["newsSelected"] = ""
	G["todayPnl"] = 0; G["realPnl"] = 0; G["tradeCount"] = 0
	G["refundAmt"] = 0; G["workDone"] = false; G["workIncome"] = 0
	for card in news_card_nodes:
		card.add_theme_stylebox_override("panel", _sb(C_PANEL2, 1, C_BDR2, 12))
	nr_box.visible = false
	btn_go.disabled = true
	_update_hud()
	_anim_morning_clock()

func _anim_morning_clock():
	var times := ["07:00","07:15","07:30","07:45","08:00","08:15","08:30","08:45","09:00"]
	var tmr = Timer.new(); tmr.wait_time = 0.12; tmr.one_shot = false
	add_child(tmr)
	var idx := 0
	tmr.timeout.connect(func():
		if idx < times.size():
			m_clock.text = times[idx]
			idx += 1
		else:
			tmr.stop(); tmr.queue_free()
	)
	tmr.start()

func _pick_news(media_type: String):
	G["newsSelected"] = media_type
	for i in news_card_nodes.size():
		var is_sel = (["tv","net","yt"][i] == media_type)
		news_card_nodes[i].add_theme_stylebox_override("panel",
			_sb(C_PANEL2, 2, C_GOLD, 12) if is_sel else _sb(C_PANEL2, 1, C_BDR2, 12)
		)

	var acc_map   := {"tv": 80, "net": 70, "yt": 30}
	var bias_map  := {"tv": 0.06, "net": 0.09, "yt": 0.14}
	var label_map := {"tv": "📺 TV 뉴스", "net": "🌐 인터넷 기사", "yt": "📱 유튜브 유라이버"}
	var db_map    := {"tv": "tv", "net": "internet", "yt": "youtube"}

	var acc: int       = acc_map[media_type]
	var actual_up: bool = randf() > 0.45
	var is_correct: bool = randi() % 100 < acc
	var hint_up: bool  = actual_up if is_correct else !actual_up
	var strength: float = bias_map[media_type]
	var s_idx: int     = randi() % STOCKS.size()
	biases[s_idx] = strength if actual_up else -strength

	var db_key: String = db_map[media_type]
	var dir: String    = "up" if hint_up else "down"
	var pool: Array = NEWS_DB[db_key][dir]
	var news: Dictionary = pool[randi() % pool.size()]

	nr_badge.text = label_map[media_type]
	nr_badge.add_theme_color_override("font_color",
		C_BLUE if media_type == "tv" else (C_UP if media_type == "net" else C_DOWN))
	nr_news_txt.text = news["text"]
	hint_stk.text = news["stock"]
	hint_dir_lbl.text = "▲ 상승" if hint_up else "▼ 하락"
	hint_dir_lbl.add_theme_color_override("font_color", C_UP if hint_up else C_DOWN)
	nr_box.visible = true
	btn_go.disabled = false

func _on_go_trade():
	if G["newsSelected"] == "":
		_toast("뉴스를 먼저 선택해주세요", "warn"); return
	_go_trade()

# ═══════════════════════════════════
# PHASE B – 거래
# ═══════════════════════════════════
func _go_trade():
	G["tickIdx"] = 0
	for i in STOCKS.size():
		prices[i] = STOCKS[i]["base"]
		all_hist[i] = [STOCKS[i]["base"]]
		volumes[i] = 0
	G["curStock"] = 0
	show_screen("trade")
	_update_hud()
	_update_right_panel()
	_render_portfolio()
	_render_watchlist()
	_draw_chart()
	trade_tmr.start()

func _on_trade_tick():
	G["tickIdx"] += 1
	_tick_market()
	_update_time_display()
	_draw_chart()
	_update_right_panel()
	_render_watchlist()
	_render_portfolio()
	_update_stats()
	_update_hud()
	if G["tickIdx"] >= MAX_TICK:
		trade_tmr.stop()
		_go_settle()

func _tick_market():
	for i in STOCKS.size():
		var bias: float  = (biases[i] as float) / MAX_TICK
		var noise: float = (randf() - 0.5) * 2.0 * (STOCKS[i]["vol"] as float)
		prices[i] = max(100, roundi(prices[i] * (1.0 + bias + noise)))
		all_hist[i].append(prices[i])
		volumes[i] = (volumes[i] as int) + randi_range(80, 600)
	_check_pending()

func _update_stats():
	if stat_vol_lbl == null: return
	var idx: int = G["curStock"] as int
	var vol: int = volumes[idx] as int
	stat_vol_lbl.text = _fmt_vol(vol)
	var val: int = vol * prices[idx] / 100000000
	stat_val_lbl.text = "%d억" % val

	var best_i := 0; var worst_i := 0
	var best_r := -9999.0; var worst_r := 9999.0
	for i in STOCKS.size():
		var base: int = STOCKS[i]["base"]
		var r: float  = (float(prices[i]) - base) / base * 100.0
		if r > best_r:  best_r  = r;  best_i = i
		if r < worst_r: worst_r = r; worst_i = i
	stat_up_lbl.text = "%s %s%.2f%%" % [STOCKS[best_i]["name"] as String,  "+" if best_r  >= 0 else "", best_r]
	stat_dn_lbl.text = "%s %s%.2f%%" % [STOCKS[worst_i]["name"] as String, "+" if worst_r >= 0 else "", worst_r]
	stat_up_lbl.add_theme_color_override("font_color", C_DOWN if best_r  >= 0 else C_BLUE)
	stat_dn_lbl.add_theme_color_override("font_color", C_BLUE if worst_r <  0 else C_DOWN)

func _fmt_vol(n: int) -> String:
	if n >= 10000: return "%.1f만주" % (n / 10000.0)
	return "%d주" % n

func _update_time_display():
	var game_min := (float(G["tickIdx"]) / MAX_TICK) * 390.0
	var total_min := 9 * 60 + game_min
	var h := int(total_min / 60); var m := int(int(total_min) % 60)
	var t := "%02d:%02d" % [h, m]
	trade_clk_lbl.text = t

	var remain: int = MAX_TICK - (G["tickIdx"] as int)
	var rm: int = remain / 60; var rs: int = remain % 60
	hud_countdown_v.text = "%02d:%02d" % [rm, rs]
	hud_countdown_v.add_theme_color_override("font_color",
		C_DOWN if remain <= 30 else (C_GOLD if remain <= 60 else C_TEXT2))

func _draw_chart():
	var idx: int = G["curStock"]
	var hist: Array = all_hist[idx]
	if hist.size() < 2:
		return
	var rect := chart_bg.get_rect()
	var W := rect.size.x; var H := rect.size.y
	if W <= 0 or H <= 0:
		return
	var pad := 10.0
	var mn := float(hist[0]); var mx := float(hist[0])
	for p in hist:
		mn = min(mn, float(p)); mx = max(mx, float(p))
	var rng := mx - mn
	if rng == 0.0: rng = 1.0

	chart_line.clear_points()
	var is_up: bool = hist[-1] >= hist[0]
	chart_line.default_color = C_UP if is_up else C_DOWN

	for i in hist.size():
		var x: float = (float(i) / MAX_TICK) * W
		var y: float = H - pad - ((float(hist[i]) - mn) / rng) * (H - pad * 2.0)
		chart_line.add_point(Vector2(x, y))

func _render_watchlist():
	for i in wl_items.size():
		var p: int    = prices[i]
		var base: int = STOCKS[i]["base"]
		var chg_pct: float = (float(p) - base) / base * 100.0
		var is_up: bool = p >= base
		wl_items[i]["price"].text = fmt(p)
		wl_items[i]["chg"].text = ("%s%.2f%%" % ["▲+" if is_up else "▼", abs(chg_pct)])
		wl_items[i]["chg"].add_theme_color_override("font_color", C_UP if is_up else C_DOWN)
		var is_sel: bool = i == G["curStock"]
		wl_items[i]["panel"].add_theme_stylebox_override("panel",
			_sb(C_PANEL2, 2, C_GOLD, 0) if is_sel else _sb(C_PANEL2, 0, C_BDR2, 0))

func _change_stock(idx: int):
	G["curStock"] = idx
	_update_right_panel()
	_draw_chart()
	_render_watchlist()
	# 선택된 종목으로 리스트 스크롤
	if stock_scroll_cont != null and idx < wl_items.size():
		var panel = wl_items[idx]["panel"] as Control
		if panel != null and panel.visible:
			stock_scroll_cont.ensure_control_visible(panel)

func _update_right_panel():
	var idx: int = G["curStock"]
	var p: int    = prices[idx]
	var base: int = STOCKS[idx]["base"]
	var chg: float = (float(p) - base) / base * 100.0
	var is_up: bool = p >= base
	price_num_lbl.text = fmt(p)
	price_chg_lbl.text = ("%s%.2f%%" % ["▲ +" if is_up else "▼ ", abs(chg)])
	price_chg_lbl.add_theme_color_override("font_color", C_UP if is_up else C_DOWN)
	r_stk_title_lbl.text = STOCKS[idx]["name"]
	r_price_lbl.text = fmt(p) + "원"

	var port: Dictionary = G["portfolio"].get(idx, {})
	if not port.is_empty() and port.get("qty", 0) > 0:
		var pnl: int   = (p - (port["avgPrice"] as int)) * (port["qty"] as int)
		var rate: float = (float(p) - (port["avgPrice"] as float)) / (port["avgPrice"] as float) * 100.0
		r_qty_lbl.text = fmt(port["qty"] as int) + "주"
		r_avg_lbl.text = fmt(port["avgPrice"] as int) + "원"
		r_stk_pnl_lbl.text = ("%s%s원" % ["+" if pnl >= 0 else "", fmt(pnl)])
		r_stk_pnl_lbl.add_theme_color_override("font_color", C_UP if pnl >= 0 else C_DOWN)
		r_rate_lbl.text = ("%s%.2f%%" % ["+" if rate >= 0 else "", rate])
		r_rate_lbl.add_theme_color_override("font_color", C_UP if rate >= 0 else C_DOWN)
	else:
		r_qty_lbl.text = "0주"; r_avg_lbl.text = "-"
		r_stk_pnl_lbl.text = "-"; r_rate_lbl.text = "-"

	var total: int = _get_total_asset()
	var eval_amt: int = 0
	for k in G["portfolio"]:
		eval_amt += prices[k] * (G["portfolio"][k].get("qty", 0) as int)
	r_cash_lbl.text  = fmt(G["cash"] as int) + "원"
	r_eval_lbl.text  = fmt(eval_amt) + "원"
	r_total_lbl.text = fmt(total) + "원"
	r_total_lbl.add_theme_color_override("font_color", C_GOLD)
	var tp: int = total - (G["startCash"] as int)
	r_profit_lbl.text = ("%s%s원" % ["+" if tp >= 0 else "", fmt(tp)])
	r_profit_lbl.add_theme_color_override("font_color", C_UP if tp >= 0 else C_DOWN)
	_calc_sum()

func _render_portfolio():
	for c in port_list_vbox.get_children():
		c.queue_free()
	var held := []
	for k in G["portfolio"]:
		if G["portfolio"][k].get("qty", 0) > 0:
			held.append(k)
	if held.is_empty():
		var empty = _lbl("보유 종목 없음", C_TEXT3, 11)
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		port_list_vbox.add_child(empty)
		return
	for k in held:
		var port: Dictionary = G["portfolio"][k]
		var cur: int   = prices[k]
		var avg: int   = port["avgPrice"] as int
		var qty: int   = port["qty"] as int
		var pnl: int   = (cur - avg) * qty
		var rate: float = (float(cur) - avg) / float(avg) * 100.0
		# 한국 주식: 수익=빨강(C_DOWN=#ef4444), 손실=파랑(C_BLUE=#3b82f6)
		var profit_col: Color = C_DOWN if pnl >= 0 else C_BLUE
		var profit_bg: Color  = Color(C_DOWN.r, C_DOWN.g, C_DOWN.b, 0.08) if pnl >= 0 else Color(C_BLUE.r, C_BLUE.g, C_BLUE.b, 0.08)
		var item = PanelContainer.new()
		item.add_theme_stylebox_override("panel", _sb(C_PANEL2, 1, profit_bg, 6))
		item.mouse_filter = Control.MOUSE_FILTER_STOP
		var vb = VBoxContainer.new(); vb.add_theme_constant_override("separation", 3)
		item.add_child(vb)
		var top_hb = HBoxContainer.new()
		var name_l = _lbl(STOCKS[k]["name"] as String, C_TEXT, 12)
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top_hb.add_child(name_l)
		var price_l = _lbl(fmt(cur) + "원", profit_col, 12)
		top_hb.add_child(price_l)
		vb.add_child(top_hb)
		var bot_hb = HBoxContainer.new()
		var qty_l = _lbl("%s주 · 평균 %s" % [fmt(qty), fmt(avg)], C_TEXT2, 10)
		qty_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bot_hb.add_child(qty_l)
		var sign: String = "+" if pnl >= 0 else ""
		var badge_bg = PanelContainer.new()
		badge_bg.add_theme_stylebox_override("panel", _sb(profit_bg, 0, profit_bg, 4))
		var pnl_l = _lbl("%s%s (%.2f%%)" % [sign, fmt(pnl), rate], profit_col, 10)
		badge_bg.add_child(pnl_l)
		bot_hb.add_child(badge_bg)
		vb.add_child(bot_hb)
		# 매수/매도 버튼 행
		var btn_hb = HBoxContainer.new()
		btn_hb.add_theme_constant_override("separation", 4)
		var ki: int = k
		# 아이템 클릭 → 해당 종목 차트로 전환
		item.gui_input.connect(func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed:
				_change_stock(ki)
		)
		var buy_b = _btn("▲ 매수", Color(C_DOWN.r, C_DOWN.g, C_DOWN.b, 0.25), C_DOWN, 5)
		buy_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buy_b.custom_minimum_size = Vector2(0, 28)
		buy_b.add_theme_font_size_override("font_size", 11)
		buy_b.pressed.connect(func():
			_change_stock(ki)
			_open_modal(true)
		)
		btn_hb.add_child(buy_b)
		var sell_b = _btn("▼ 매도", Color(C_BLUE.r, C_BLUE.g, C_BLUE.b, 0.25), C_BLUE, 5)
		sell_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sell_b.custom_minimum_size = Vector2(0, 28)
		sell_b.add_theme_font_size_override("font_size", 11)
		sell_b.pressed.connect(func():
			_change_stock(ki)
			_open_modal(false)
		)
		btn_hb.add_child(sell_b)
		vb.add_child(btn_hb)
		port_list_vbox.add_child(item)

func _filter_stocks(query: String):
	var q = query.strip_edges().to_lower()
	for item_data in wl_items:
		var n: String = (item_data["name"] as String).to_lower()
		item_data["panel"].visible = q.is_empty() or n.contains(q)

func _set_order_mode(mode: String):
	order_mode = mode
	inp_lmt.visible = (mode == "lmt")
	tab_mkt_btn.add_theme_stylebox_override("normal",
		_sb(Color(C_BLUE.r,C_BLUE.g,C_BLUE.b,0.2), 1, Color(C_BLUE.r,C_BLUE.g,C_BLUE.b,0.3), 5) if mode=="mkt" else _sb(C_PANEL2, 1, C_BDR2, 5))
	tab_mkt_btn.add_theme_color_override("font_color", C_BLUE if mode == "mkt" else C_TEXT2)
	tab_lmt_btn.add_theme_stylebox_override("normal",
		_sb(Color(C_BLUE.r,C_BLUE.g,C_BLUE.b,0.2), 1, Color(C_BLUE.r,C_BLUE.g,C_BLUE.b,0.3), 5) if mode=="lmt" else _sb(C_PANEL2, 1, C_BDR2, 5))
	tab_lmt_btn.add_theme_color_override("font_color", C_BLUE if mode == "lmt" else C_TEXT2)
	_calc_sum()

func _calc_sum():
	_update_modal_sum()

func _do_buy():
	var qty: int = inp_qty.text.to_int()
	if qty <= 0: _toast("수량을 입력해주세요", "warn"); return
	var idx: int = G["curStock"] as int
	var price: int = (inp_lmt.text.to_int() if inp_lmt.text.length() > 0 else 0) if order_mode == "lmt" else prices[idx]
	if order_mode == "lmt" and price <= 0: _toast("지정가를 입력해주세요", "warn"); return
	if order_mode == "mkt": price = prices[idx]
	var total: int = qty * price
	if (G["cash"] as int) < total: _toast("현금 부족 (필요: %s원)" % fmt(total), "err"); return
	G["cash"] = (G["cash"] as int) - total
	if order_mode == "lmt":
		G["pendingOrders"].append({"type": "buy", "idx": idx, "price": price, "qty": qty})
		_toast("지정가 매수 등록 · %s %d주 @ %s원" % [STOCKS[idx]["name"], qty, fmt(price)], "ok")
	else:
		_apply_buy(idx, qty, price); G["tradeCount"] += 1
		_toast("시장가 매수 · %s %d주 @ %s원" % [STOCKS[idx]["name"], qty, fmt(price)], "ok")
	inp_qty.text = ""; inp_lmt.text = ""
	_close_modal()
	_update_right_panel(); _render_portfolio(); _render_pending(); _update_hud()

func _do_sell():
	var qty: int = inp_qty.text.to_int()
	if qty <= 0: _toast("수량을 입력해주세요", "warn"); return
	var idx: int = G["curStock"] as int
	var port: Dictionary = G["portfolio"].get(idx, {})
	if port.is_empty() or port.get("qty", 0) < qty: _toast("보유 수량 부족", "err"); return
	var price: int = (inp_lmt.text.to_int() if inp_lmt.text.length() > 0 else 0) if order_mode == "lmt" else prices[idx]
	if order_mode == "lmt" and price <= 0: _toast("지정가를 입력해주세요", "warn"); return
	if order_mode == "mkt": price = prices[idx]
	if order_mode == "lmt":
		G["pendingOrders"].append({"type": "sell", "idx": idx, "price": price, "qty": qty})
		_toast("지정가 매도 등록 · %s %d주 @ %s원" % [STOCKS[idx]["name"], qty, fmt(price)], "ok")
	else:
		_apply_sell(idx, qty, price); G["tradeCount"] += 1
		_toast("시장가 매도 · %s %d주 @ %s원" % [STOCKS[idx]["name"], qty, fmt(price)], "ok")
	inp_qty.text = ""; inp_lmt.text = ""
	_close_modal()
	_update_right_panel(); _render_portfolio(); _render_pending(); _update_hud()

func _apply_buy(idx: int, qty: int, price: int):
	if not G["portfolio"].has(idx):
		G["portfolio"][idx] = {"qty": 0, "avgPrice": 0}
	var p: Dictionary = G["portfolio"][idx]
	p["avgPrice"] = roundi(((p["avgPrice"] as int) * (p["qty"] as int) + price * qty) / float((p["qty"] as int) + qty))
	p["qty"] = (p["qty"] as int) + qty

func _apply_sell(idx: int, qty: int, price: int):
	var p: Dictionary = G["portfolio"][idx]
	var gain: int = price * qty
	var cost: int = (p["avgPrice"] as int) * qty
	G["cash"] = (G["cash"] as int) + gain
	G["realPnl"] = (G["realPnl"] as int) + gain - cost
	G["todayPnl"] = (G["todayPnl"] as int) + gain - cost
	p["qty"] = (p["qty"] as int) - qty
	if (p["qty"] as int) <= 0:
		G["portfolio"].erase(idx)

func _check_pending():
	var remain: Array = []
	for o: Dictionary in G["pendingOrders"]:
		var cur: int = prices[o["idx"] as int]
		if o["type"] == "buy" and cur <= (o["price"] as int):
			_apply_buy(o["idx"] as int, o["qty"] as int, o["price"] as int)
			G["tradeCount"] = (G["tradeCount"] as int) + 1
			_toast("지정가 매수 체결 · %s %d주" % [STOCKS[o["idx"] as int]["name"] as String, o["qty"] as int], "ok")
		elif o["type"] == "sell" and cur >= (o["price"] as int):
			var port: Dictionary = G["portfolio"].get(o["idx"] as int, {})
			if not port.is_empty() and (port.get("qty", 0) as int) >= (o["qty"] as int):
				_apply_sell(o["idx"] as int, o["qty"] as int, o["price"] as int)
				G["tradeCount"] = (G["tradeCount"] as int) + 1
				_toast("지정가 매도 체결 · %s %d주" % [STOCKS[o["idx"] as int]["name"] as String, o["qty"] as int], "ok")
			else:
				remain.append(o)
		else:
			remain.append(o)
	if G["pendingOrders"].size() != remain.size():
		G["pendingOrders"] = remain
		_render_portfolio()
		_render_pending()

func _render_pending():
	for c in pending_vbox.get_children():
		c.queue_free()
	if G["pendingOrders"].is_empty():
		pending_box.visible = false
		return
	pending_box.visible = true
	for i in G["pendingOrders"].size():
		var o: Dictionary = G["pendingOrders"][i]
		var hb = HBoxContainer.new()
		var col: Color = C_UP if o["type"] == "buy" else C_DOWN
		var lbl = _lbl("%s %s %d주 @%s" % [STOCKS[o["idx"] as int]["name"] as String, "매수" if o["type"]=="buy" else "매도", o["qty"] as int, fmt(o["price"] as int)], col, 10)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hb.add_child(lbl)
		var cancel_btn = _btn("취소", Color(C_DOWN.r,C_DOWN.g,C_DOWN.b,0.15), C_DOWN, 4)
		cancel_btn.add_theme_font_size_override("font_size", 9)
		var oi: int = i
		cancel_btn.pressed.connect(func():
			var ord: Dictionary = G["pendingOrders"][oi]
			if ord["type"] == "buy":
				G["cash"] = (G["cash"] as int) + (ord["price"] as int) * (ord["qty"] as int)
			G["pendingOrders"].remove_at(oi)
			_render_pending()
			_update_right_panel()
			_update_hud()
		)
		hb.add_child(cancel_btn)
		pending_vbox.add_child(hb)

# ═══════════════════════════════════
# PHASE C – 결산
# ═══════════════════════════════════
func _go_settle():
	G["refundAmt"] = 0
	for o in G["pendingOrders"]:
		if o["type"] == "buy": G["cash"] += o["price"] * o["qty"]; G["refundAmt"] += o["price"] * o["qty"]
	G["pendingOrders"] = []
	G["rentDue"] = (G["rentDue"] as int) - 1
	var rent_paid: bool = (G["rentDue"] as int) <= 0
	if rent_paid: G["rentDue"] = 30
	G["todayExpense"] = FOOD + (RENT if rent_paid else 0)
	G["cash"] = (G["cash"] as int) - (G["todayExpense"] as int)
	if G["cash"] < 0: _toast("현금이 부족합니다! 긴급 상황!", "err")

	var eval_pnl: int = 0
	for k in G["portfolio"]:
		eval_pnl += (prices[k] - (G["portfolio"][k]["avgPrice"] as int)) * (G["portfolio"][k].get("qty", 0) as int)
	var total: int  = _get_total_asset()
	var pct: float  = _get_goal_pct()

	var real_pnl: int = G["realPnl"] as int
	sc_real_lbl.text   = ("%s%s원" % ["+" if real_pnl>=0 else "", fmt(real_pnl)])
	sc_real_lbl.add_theme_color_override("font_color", C_UP if real_pnl>=0 else C_DOWN)
	sc_unreal_lbl.text = ("%s%s원" % ["+" if eval_pnl>=0 else "", fmt(eval_pnl)])
	sc_unreal_lbl.add_theme_color_override("font_color", C_UP if eval_pnl>=0 else C_DOWN)
	var refund: int = G["refundAmt"] as int
	sc_refund_lbl.text = ("%s원 환불" % fmt(refund)) if refund > 0 else "없음"
	sc_cnt_lbl.text    = "%d회" % (G["tradeCount"] as int)
	rent_row_ctrl.visible = rent_paid
	sc_exp_lbl.text    = "-%s원" % fmt(G["todayExpense"] as int)
	stc_val_lbl.text   = fmt(total) + "원"
	var chg: int = total - 10000000
	stc_chg_lbl.text   = ("%s%s원 (%s%.2f%%)" % ["+" if chg>=0 else "", fmt(chg), "+" if chg>=0 else "", float(chg)/10000000.0*100.0])
	stc_chg_lbl.add_theme_color_override("font_color", C_UP if chg>=0 else C_DOWN)
	gpb_pct_lbl.text   = "%.1f%%" % pct
	gpb_bar.value      = pct

	for c in s_holdings_vbox.get_children(): c.queue_free()
	var held := []
	for k in G["portfolio"]:
		if G["portfolio"][k].get("qty", 0) > 0: held.append(k)
	if held.is_empty():
		s_holdings_vbox.add_child(_lbl("보유 종목 없음", C_TEXT3, 11))
	else:
		for k in held:
			var p: Dictionary = G["portfolio"][k]
			var pnl: int = (prices[k] - (p["avgPrice"] as int)) * (p["qty"] as int)
			var hb = HBoxContainer.new()
			var kl = _lbl("%s %d주" % [STOCKS[k]["name"] as String, p["qty"] as int], C_TEXT2, 11)
			kl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hb.add_child(kl)
			var vl = _lbl("%s%s원" % ["+" if pnl>=0 else "", fmt(pnl)], C_UP if pnl>=0 else C_DOWN, 11)
			hb.add_child(vl)
			s_holdings_vbox.add_child(hb)

	G["workDone"] = false; G["workIncome"] = 0
	wo_cv_btn.disabled = false; wo_tutor_btn.disabled = false; wo_rest_btn.disabled = false
	settle_act_ctrl.visible = false
	_update_hud()
	show_screen("settle")

func _do_work(type: String, pay: int):
	if G["workDone"]: return
	G["workDone"] = true; G["workIncome"] = pay
	if pay > 0: G["cash"] += pay; _toast("알바 수입 +%s원" % fmt(pay), "ok")
	else: _toast("오늘은 쉬기로 했습니다", "warn")
	wo_cv_btn.disabled = true; wo_tutor_btn.disabled = true; wo_rest_btn.disabled = true
	settle_act_ctrl.visible = true
	_update_hud()

# ═══════════════════════════════════
# PHASE D – 일간
# ═══════════════════════════════════
func _go_night():
	var total: int    = _get_total_asset()
	var pct: String   = "%.1f%%" % _get_goal_pct()
	var day_chg: int  = total - (G["startCash"] as int)
	n_day_lbl.text   = "Day %d" % G["day"]
	n_total_lbl.text = fmt(total) + "원"
	n_pnl_lbl.text   = ("%s%s원" % ["+" if day_chg>=0 else "", fmt(day_chg)])
	n_pnl_lbl.add_theme_color_override("font_color", C_UP if day_chg>=0 else C_DOWN)
	n_work_lbl.text  = "+%s원" % fmt(G["workIncome"] as int) if (G["workIncome"] as int) > 0 else "없음"
	n_exp_lbl.text   = "-%s원" % fmt(G["todayExpense"] as int)
	n_goal_lbl.text  = pct
	var msgs := ["오늘도 수고했어요 💪","내일엔 더 잘 될 거예요 📈","포기하지 마세요! 내 집은 반드시! 🏠","오늘의 경험이 내일의 수익을 만들어요 ✨","시장은 항상 기회를 줍니다 🎯"]
	night_msg_lbl.text = msgs[randi() % msgs.size()]
	if total >= GOAL:
		_toast("🎉 목표 달성! Day %d 내집 마련 성공!" % G["day"], "ok")
	show_screen("night")

func _go_morning():
	G["day"] += 1
	G["startCash"] = _get_total_asset() as int
	for i in STOCKS.size(): biases[i] = 0.0
	_init_morning()
	show_screen("morning")

# ═══════════════════════════════════
# 유틸
# ═══════════════════════════════════
func _get_total_asset() -> int:
	var t: int = G["cash"] as int
	for k in G["portfolio"]:
		t += prices[k] * (G["portfolio"][k].get("qty", 0) as int)
	return t

func _get_goal_pct() -> float:
	return minf(100.0, float(_get_total_asset()) / GOAL * 100.0)

func fmt(n: int) -> String:
	var s := str(abs(n))
	var result := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	if n < 0: result = "-" + result
	return result

func _toast(msg: String, _type: String = "ok"):
	toast_lbl.text = msg
	toast_panel.visible = true
	toast_tmr.stop(); toast_tmr.start()
