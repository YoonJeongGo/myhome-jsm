extends Node

signal news_generated(news_data: Dictionary)
signal news_applied(news_data: Dictionary, is_correct: bool)

const STOCK_NEWS_DATA: Dictionary = {
	"005930": {
		"name": "삼성전자",
		"positive": ["AI 반도체 수요 증가", "메모리 업황 개선 기대", "실적 반등 전망"],
		"negative": ["반도체 업황 둔화 우려", "재고 부담 확대", "수요 회복 지연 가능성"]
	},
	"000660": {
		"name": "SK하이닉스",
		"positive": ["HBM 수요 확대", "AI 서버 투자 증가", "고부가 메모리 강세"],
		"negative": ["반도체 가격 조정 우려", "공급 확대 부담", "실적 변동성 확대 가능성"]
	},
	"005380": {
		"name": "현대차",
		"positive": ["전기차 판매 성장", "수출 호조", "신차 흥행 기대"],
		"negative": ["원자재 가격 상승", "환율 부담 우려", "글로벌 수요 둔화 가능성"]
	},
	"105560": {
		"name": "KB금융",
		"positive": ["금리 수혜 기대", "배당 매력 부각", "실적 안정성 강화"],
		"negative": ["대손충당금 부담", "부동산 리스크 우려", "금융 규제 강화 가능성"]
	},
	"055550": {
		"name": "신한지주",
		"positive": ["실적 개선 기대", "주주환원 확대 기대", "금융주 강세"],
		"negative": ["연체율 상승 우려", "충당금 확대 부담", "시장 불확실성 확대"]
	},
	"086790": {
		"name": "하나금융지주",
		"positive": ["배당 기대감 확대", "이자이익 개선", "실적 방어력 부각"],
		"negative": ["건전성 우려 부각", "대출 부실 리스크", "시장 변동성 확대"]
	},
	"000270": {
		"name": "기아",
		"positive": ["SUV 판매 호조", "전기차 성장 기대", "수익성 개선"],
		"negative": ["글로벌 수요 둔화 우려", "원가 부담 증가", "경쟁 심화 가능성"]
	},
	"068270": {
		"name": "셀트리온",
		"positive": ["바이오시밀러 성장 기대", "해외 판매 확대", "실적 개선 전망"],
		"negative": ["규제 리스크 부각", "경쟁 심화 우려", "수익성 둔화 가능성"]
	},
	"035420": {
		"name": "NAVER",
		"positive": ["광고 매출 회복 기대", "AI 서비스 확대", "플랫폼 성장성 부각"],
		"negative": ["경쟁 심화 우려", "규제 부담 확대", "광고 경기 둔화 가능성"]
	},
	"005490": {
		"name": "POSCO홀딩스",
		"positive": ["철강 업황 회복 기대", "2차전지 소재 성장", "글로벌 수요 확대"],
		"negative": ["원자재 가격 부담", "중국 경기 둔화 우려", "철강 수요 약세 가능성"]
	},
	"086520": {
		"name": "에코프로",
		"positive": ["2차전지 투자심리 회복", "양극재 수요 확대", "성장 기대감 부각"],
		"negative": ["밸류에이션 부담", "수급 변동성 확대", "2차전지 조정 우려"]
	},
	"247540": {
		"name": "에코프로비엠",
		"positive": ["양극재 출하 확대", "전기차 시장 성장", "실적 반등 기대"],
		"negative": ["전방 수요 둔화 우려", "원가 부담 증가", "재고 조정 가능성"]
	},
	"196170": {
		"name": "알테오젠",
		"positive": ["기술수출 기대감 확대", "신약 가치 재평가", "바이오 투자심리 개선"],
		"negative": ["임상 불확실성 부각", "고평가 우려", "변동성 확대 가능성"]
	},
	"028300": {
		"name": "HLB",
		"positive": ["신약 기대감 확대", "임상 결과 기대", "바이오 모멘텀 강화"],
		"negative": ["허가 지연 우려", "임상 리스크 부각", "투자심리 위축 가능성"]
	},
	"277810": {
		"name": "레인보우로보틱스",
		"positive": ["로봇 산업 성장 기대", "대기업 협력 기대", "기술력 부각"],
		"negative": ["고평가 부담", "실적 불확실성", "테마 과열 우려"]
	},
	"267260": {
		"name": "HD현대일렉트릭",
		"positive": ["전력기기 수요 확대", "수출 호조", "전력 인프라 투자 증가"],
		"negative": ["원가 부담 증가", "수주 둔화 우려", "경기 민감도 부각"]
	},
	"034020": {
		"name": "두산에너빌리티",
		"positive": ["원전 수주 기대", "친환경 에너지 투자 확대", "실적 개선 전망"],
		"negative": ["수주 지연 우려", "정책 불확실성", "프로젝트 리스크 부각"]
	},
	"012450": {
		"name": "한화에어로스페이스",
		"positive": ["방산 수출 확대", "실적 성장 기대", "수주 모멘텀 강화"],
		"negative": ["원가 상승 부담", "정책 변수 확대", "단기 과열 우려"]
	},
	"079550": {
		"name": "LIG넥스원",
		"positive": ["방산 수주 확대", "해외 매출 성장 기대", "국방 예산 확대 수혜"],
		"negative": ["수주 공백 우려", "정책 변수 확대", "차익실현 매물 가능성"]
	},
	"042660": {
		"name": "한화오션",
		"positive": ["조선 업황 회복", "고부가 선박 수주 확대", "실적 턴어라운드 기대"],
		"negative": ["원가 부담 확대", "업황 변동성 우려", "수익성 회복 지연 가능성"]
	}
}

const TV_TEMPLATES: Array[String] = [
	"%s, %s 전망",
	"%s, %s 기대감 확산",
	"%s 관련 %s 보도"
]

const INTERNET_TEMPLATES: Array[String] = [
	"%s, %s 영향으로 주목",
	"%s, 시장에서 %s 분석 제기",
	"%s, %s 이슈 부각"
]

const YOUTUBE_TEMPLATES: Array[String] = [
	"%s 이거 진짜 간다? %s",
	"%s 폭등각? %s",
	"%s 내부 재료 떴나? %s"
]

var today_news: Dictionary = {}

func _ready() -> void:
	randomize()

	pass  # main.gd에서 직접 처리

func _generate_today_news() -> void:
	var stock_ids: Array = STOCK_NEWS_DATA.keys()
	if stock_ids.is_empty():
		print("[경고] NewsManager: 뉴스 데이터가 비어 있습니다.")
		return

	var stock_id: String = str(stock_ids[randi() % stock_ids.size()])
	var direction: String = "positive"

	if randf() >= 0.5:
		direction = "negative"

	var stock_data: Dictionary = STOCK_NEWS_DATA[stock_id]
	var keyword_list: Array = stock_data[direction]

	if keyword_list.is_empty():
		print("[경고] NewsManager: 키워드 목록이 비어 있습니다. stock_id=", stock_id)
		return

	var keyword: String = str(keyword_list[randi() % keyword_list.size()])

	today_news = {
		"stock_id": stock_id,
		"stock_name": stock_data["name"],
		"direction": direction,
		"keyword": keyword,
		"tv_text": _make_text("tv", stock_data["name"], keyword),
		"internet_text": _make_text("internet", stock_data["name"], keyword),
		"youtube_text": _make_text("youtube", stock_data["name"], keyword)
	}

	news_generated.emit(today_news)

func _make_text(media_type: String, stock_name: String, keyword: String) -> String:
	var templates: Array[String] = []

	match media_type:
		"tv":
			templates = TV_TEMPLATES
		"internet":
			templates = INTERNET_TEMPLATES
		"youtube":
			templates = YOUTUBE_TEMPLATES
		_:
			templates = INTERNET_TEMPLATES

	var template: String = str(templates[randi() % templates.size()])
	return template % [stock_name, keyword]

func get_today_news() -> Dictionary:
	return today_news

func apply_selected_media(media_type: String) -> void:
	if today_news.is_empty():
		print("[경고] NewsManager: today_news가 비어 있어 적용할 수 없습니다.")
		return

	var accuracy: float = _get_accuracy(media_type)
	var is_correct: bool = randf() < accuracy

	var stock_id: String = str(today_news["stock_id"])
	var direction: String = str(today_news["direction"])

	var trend_value: float = 0.0

	if is_correct:
		if direction == "positive":
			trend_value = 0.01
		else:
			trend_value = -0.01
	else:
		if direction == "positive":
			trend_value = -0.01
		else:
			trend_value = 0.01

	if has_node("/root/MarketManager"):
		MarketManager.apply_trend(stock_id, trend_value)
	else:
		print("[경고] NewsManager: MarketManager Autoload를 찾을 수 없습니다.")
		return

	news_applied.emit(today_news, is_correct)

func _get_accuracy(media_type: String) -> float:
	match media_type:
		"tv":
			return 0.80
		"internet":
			return 0.70
		"youtube":
			return 0.35
		_:
			return 0.50
