import SwiftUI

struct FitView: View {
    @EnvironmentObject var s: AppState
    @State private var step = 0

    var body: some View {
        Screen(title: KE("나에게 맞는 선택", "Find my fit")) {
            Text(s.t("세 단계입니다. ① 질문 8개에 답하면 어느 쪽이 맞을지 방향을 알려드리고, ② 받은 견적을 넣으면 1년에 실제로 얼마가 나가는지 비교하고, ③ 소득·근로 기간·벌금·사는 주까지 넣어 본인이 실제로 내는 금액을 계산합니다.",
                     "Three steps. (1) Answer 8 questions to see which direction fits you. (2) Enter the quotes you got to compare yearly costs. (3) Add your income, work history, penalties and state to see what you personally pay."))
            Picker("", selection: $step) {
                Text(s.t("① 설문", "1 Questions")).tag(0)
                Text(s.t("② 1년 비용", "2 Yearly cost")).tag(1)
                Text(s.t("③ 내 금액", "3 My cost")).tag(2)
            }
            .pickerStyle(.segmented)
            switch step {
            case 0: QuizView()
            case 1: CalculatorView()
            default: MyCostView()
            }
        }
    }
}

// MARK: Step 1 — questionnaire

struct Question {
    let id: String
    let q: KE
    let options: [(String, KE)]
}

struct QuizView: View {
    @EnvironmentObject var s: AppState
    @State private var a: [String: String] = ["win": "y", "vis": "s", "chr": "n", "trv": "n", "doc": "y", "bud": "m", "rx": "m", "inc": "n"]
    @State private var shown = false

    let qs: [Question] = [
        Question(id: "win", q: KE("Part B가 시작된 지 6개월이 안 됐나요? (서플먼트 개방 가입 기간)", "Did your Part B start less than 6 months ago? (Medigap open enrollment)"), options: [("y", KE("예", "Yes")), ("n", KE("아니요", "No")), ("u", KE("잘 모름", "Not sure"))]),
        Question(id: "vis", q: KE("1년에 병원(의사) 몇 번 가세요?", "How many doctor visits a year?"), options: [("f", KE("0–4번", "0–4")), ("s", KE("5–12번", "5–12")), ("m", KE("13번 이상", "13+"))]),
        Question(id: "chr", q: KE("지병(당뇨, 심장, 암 등)이 있거나 수술 계획이 있나요?", "Do you have a chronic condition (diabetes, heart, cancer) or a planned surgery?"), options: [("y", KE("예", "Yes")), ("n", KE("아니요", "No"))]),
        Question(id: "trv", q: KE("1년에 몇 달씩 텍사스 밖(자녀 집, 다른 주)에 머무시나요?", "Do you spend months outside Texas each year?"), options: [("y", KE("예", "Yes")), ("n", KE("아니요", "No"))]),
        Question(id: "doc", q: KE("지금 다니는 의사를 꼭 계속 보고 싶으신가요?", "Must you keep your current doctors?"), options: [("y", KE("예", "Yes")), ("n", KE("상관없음", "Not important"))]),
        Question(id: "bud", q: KE("매달 보험료로 낼 수 있는 여유는?", "How much can you spend on monthly premiums?"), options: [("l", KE("최소로", "As little as possible")), ("m", KE("보통", "Moderate")), ("h", KE("넉넉함", "Comfortable"))]),
        Question(id: "rx", q: KE("한 달 약값은 어느 정도인가요?", "Monthly drug costs?"), options: [("l", KE("$100 미만", "Under $100")), ("m", KE("$100–500", "$100–500")), ("h", KE("$500 이상", "Over $500"))]),
        Question(id: "inc", q: KE("한 달 소득이 1인 약 $2,000, 부부 약 $2,700 이하인가요?", "Is monthly income under about $2,000 (single) or $2,700 (couple)?"), options: [("y", KE("예", "Yes")), ("n", KE("아니요", "No")), ("u", KE("잘 모름", "Not sure"))]),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(qs.enumerated()), id: \.offset) { i, q in
                Card {
                    Text("\(i + 1). " + s.t(q.q)).font(.headline)
                    HStack(spacing: 8) {
                        ForEach(q.options, id: \.0) { o in
                            let on = a[q.id] == o.0
                            Button {
                                a[q.id] = o.0
                            } label: {
                                Text(s.t(o.1)).font(.subheadline.bold())
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .background(on ? Theme.accent : Theme.paper, in: RoundedRectangle(cornerRadius: 10))
                                    .foregroundStyle(on ? Color.white : Theme.ink)
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(on ? .isSelected : [])
                        }
                    }
                }
            }
            Button { withAnimation { shown = true } } label: {
                Text(s.t("결과 보기", "See result")).font(.headline).frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent).tint(Theme.accent)
            if shown { result }
        }
    }

    @ViewBuilder var result: some View {
        let r = score()
        Card(tint: Theme.accent) {
            if a["inc"] != "n" {
                Card(tint: Theme.warn) {
                    Text(s.t("먼저 확인하세요", "Check this first")).font(.headline)
                    Text(s.t("소득이 기준 근처라면 엑스트라 헬프·MSP·메디케이드로 보험료와 약값이 크게 줄 수 있습니다. 이게 플랜 선택보다 먼저입니다. \"지원\" 탭에서 점검해 보세요.",
                             "If your income is near the limits, Extra Help, MSP or Medicaid can cut premiums and drug costs a lot. Check this before choosing a plan, in the \"Help paying\" tab."))
                }
            }
            Text(r.head).font(.display(.title3))
            HStack {
                Text(s.t("어드밴티지", "Advantage")).font(.caption.bold())
                ProgressView(value: r.pct).tint(Theme.accent)
                Text(s.t("서플먼트", "Supplement")).font(.caption.bold())
            }
            if let sub = r.sub { Text(s.t("서플먼트 중에서는: ", "Among supplements: ") + sub).font(.subheadline.bold()) }
            ForEach(r.why, id: \.self) { Bullet(text: $0) }
            ForEach(r.warn, id: \.self) { Bullet(text: $0, icon: "exclamationmark.triangle.fill", tint: Theme.alert) }
            Text(s.t("이 결과는 방향을 잡기 위한 참고이며, 특정 보험사 추천이 아닙니다. 결정 전 텍사스 HICAP(1-800-252-9240) 무료 상담을 받으세요.",
                     "This is a starting direction, not a recommendation of any company. Talk to Texas HICAP (1-800-252-9240, free) before deciding."))
                .font(.footnote).foregroundStyle(Theme.muted)
        }
    }

    func score() -> (head: String, pct: Double, sub: String?, why: [String], warn: [String]) {
        var sup = 0, ma = 0
        var why: [String] = [], warn: [String] = []
        func r(_ k: String, _ e: String) { why.append(s.t(k, e)) }
        switch a["vis"] {
        case "m": sup += 2; r("병원에 자주 가시면 진료마다 내는 돈이 적은 서플먼트가 유리합니다.", "Frequent visits favor a supplement, where each visit costs little.")
        case "s": sup += 1
        default: ma += 1; r("병원에 거의 안 가시면 보험료가 낮은 쪽이 1년 총액이 적을 수 있습니다.", "With few visits, low-premium options can cost less over the year.")
        }
        if a["chr"] == "y" { sup += 2; r("지병이나 수술 계획이 있으면 \"많이 아픈 해\" 비용이 예측 가능한 서플먼트가 안전합니다.", "With a condition or planned surgery, a supplement keeps a bad year predictable.") }
        if a["trv"] == "y" { sup += 2; r("텍사스 밖에 오래 계시면 네트워크 제한이 없는 오리지널+서플먼트가 편합니다.", "Long stays outside Texas favor Original Medicare + supplement, which has no network.") }
        if a["doc"] == "y" { sup += 1; r("다니는 의사를 꼭 유지하려면, 어드밴티지는 그 의사가 네트워크 안에 있는지 반드시 확인해야 합니다.", "To keep your doctors on Advantage, confirm each one is in the network.") }
        if a["bud"] == "l" { ma += 2; r("보험료 부담을 최소로 하려면 어드밴티지나 하이디덕 G가 후보입니다.", "To keep premiums low, look at Advantage or High-Deductible G.") }
        else if a["bud"] == "h" { sup += 1 }
        switch a["win"] {
        case "n": ma += 1; warn.append(s.t("서플먼트 개방 가입 기간이 지났다면 건강 심사로 거절되거나 비싸질 수 있습니다. 가입 전에 승인되는지 먼저 확인하세요.", "Your Medigap open enrollment has passed, so you may be refused or charged more. Get approved before dropping any coverage."))
        case "y": warn.append(s.t("지금이 서플먼트를 건강 심사 없이 들 수 있는 기간입니다. 서플먼트를 고려한다면 이 기간을 놓치지 마세요.", "You are in the window to buy a supplement with no health questions. If you are considering one, don't let it pass."))
        default: warn.append(s.t("Part B 시작일은 메디케어 카드에 적혀 있습니다. 6개월이 안 됐다면 서플먼트를 심사 없이 들 수 있습니다.", "Your Part B start date is on your Medicare card. Within 6 months, you can buy a supplement with no health questions."))
        }
        if a["rx"] == "h" { warn.append(s.t("약값이 많으면 어느 쪽이든 Part D 상한 $2,400(2027)이 적용됩니다. 내 약이 플랜 목록에 있는지 Medicare.gov 플랜 비교기로 꼭 확인하세요.", "With high drug costs, every path has the $2,400 Part D cap (2027). Check that your drugs are on the plan's list with the Medicare.gov Plan Finder.")) }
        let total = max(sup + ma, 1)
        let dir = sup > ma + 1 ? "sup" : (ma > sup + 1 ? "ma" : "mid")
        var sub: String? = nil
        if dir != "ma" {
            let k = (a["vis"] == "m" || a["chr"] == "y") ? "G" : (a["vis"] == "f" && a["bud"] != "h") ? "HDG" : "N"
            sub = k == "G" ? s.t("Plan G (진료가 많거나 지병이 있으면 가장 마음 편함)", "Plan G (most predictable with frequent care or a condition)")
                : k == "N" ? s.t("Plan N (G보다 싸고, 진료 1회 최대 $20 부담)", "Plan N (cheaper than G; up to $20 per visit)")
                : s.t("하이디덕 G (보험료 최저, 아픈 해엔 최대 $3,050)", "High-Deductible G (lowest premium; up to $3,050 in a bad year)")
        }
        let head = dir == "sup" ? s.t("오리지널 메디케어 + 서플먼트 쪽으로 기웁니다", "You lean toward Original Medicare + Supplement")
            : dir == "ma" ? s.t("메디케어 어드밴티지 쪽으로 기웁니다", "You lean toward Medicare Advantage")
            : s.t("두 쪽이 비슷합니다. ② 1년 비용으로 숫자를 비교해 보세요", "Both paths are close. Compare numbers in Step 2.")
        return (head, Double(sup) / Double(total), sub, why, warn)
    }
}

// MARK: Step 2 — yearly cost calculator (2027)

struct CalculatorView: View {
    @EnvironmentObject var s: AppState
    @State private var g = 180.0, n = 130.0, hd = 55.0, d = 40.0, m = 0.0, mc = 20.0, moop = 5900.0, v = 8.0

    var body: some View {
        let y = Figures.y2027
        let visit = 150.0, badB = 30000.0
        let visits = v.rounded()
        let light = visits * visit
        let origLight = min(light, y.bded) + 0.2 * max(light - y.bded, 0)
        let origBad = y.aded + y.bded + 0.2 * (badB - y.bded)
        let cap = min(moop, y.moop)
        let rows: [(String, Double, Double)] = [
            ("Plan G + Part D", (g + d) * 12 + min(light, y.bded), (g + d) * 12 + y.bded),
            ("Plan N + Part D", (n + d) * 12 + min(light, y.bded) + visits * 20, (n + d) * 12 + y.bded + visits * 20),
            (s.t("하이디덕 G + Part D", "High-Ded. G + Part D"), (hd + d) * 12 + min(origLight, y.hdg), (hd + d) * 12 + min(origBad, y.hdg)),
            (s.t("어드밴티지 (약 포함)", "Advantage (drugs incl.)"), m * 12 + min(visits * mc, cap), m * 12 + cap),
        ]
        let minL = rows.map(\.1).min() ?? 0, minB = rows.map(\.2).min() ?? 0

        VStack(alignment: .leading, spacing: 14) {
            Text(s.t("예시 숫자가 들어 있습니다. 보험사·HICAP·Medicare.gov에서 받은 본인 견적으로 바꾸세요. Part B 보험료(2027년 월 $209.40)는 어느 쪽이든 똑같이 내므로 계산에서 뺐습니다.",
                     "Example numbers are filled in. Replace them with your own quotes from insurers, HICAP or Medicare.gov. The Part B premium ($209.40/month in 2027) is the same on every path, so it is left out."))
                .font(.subheadline)
            Card {
                NumberField(label: s.t("Plan G 월 보험료 ($)", "Plan G monthly premium ($)"), value: $g)
                NumberField(label: s.t("Plan N 월 보험료 ($)", "Plan N monthly premium ($)"), value: $n)
                NumberField(label: s.t("하이디덕 G 월 보험료 ($)", "High-Deductible G monthly premium ($)"), value: $hd)
                NumberField(label: s.t("Part D 월 보험료 ($) — 서플먼트 쪽만", "Part D monthly premium ($) — supplement paths only"), value: $d)
                NumberField(label: s.t("어드밴티지 월 보험료 ($)", "Advantage monthly premium ($)"), value: $m)
                NumberField(label: s.t("어드밴티지 진료 1회 코페이 ($)", "Advantage copay per visit ($)"), value: $mc)
                NumberField(label: s.t("어드밴티지 연간 상한 ($, 네트워크 안)", "Advantage yearly out-of-pocket max ($, in-network)"), value: $moop)
                Stepper(value: $v, in: 0...60) {
                    Text(s.t("1년 예상 진료 횟수", "Doctor visits per year") + ": \(Int(visits))").font(.subheadline)
                }
            }
            VStack(spacing: 0) {
                HStack {
                    Text(s.t("선택", "Option")).frame(maxWidth: .infinity, alignment: .leading)
                    Text(s.t("가벼운 해", "Light year")).frame(width: 90, alignment: .trailing)
                    Text(s.t("많이 아픈 해", "Bad year")).frame(width: 90, alignment: .trailing)
                }
                .font(.subheadline.bold()).padding(12).background(Theme.accentSoft)
                ForEach(rows, id: \.0) { r in
                    HStack {
                        Text(r.0).font(.subheadline).frame(maxWidth: .infinity, alignment: .leading)
                        cell(r.1, best: r.1 == minL)
                        cell(r.2, best: r.2 == minB)
                    }
                    .padding(12)
                    Divider()
                }
            }
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            Text(s.t("초록색이 그 상황에서 가장 적게 나가는 선택입니다. Plan G와 하이디덕 G의 1년 보험료 차이는 \(money((g - hd) * 12))입니다. 이 차이가 약 $2,750보다 크면, 많이 아픈 해에도 하이디덕 G가 손해가 아닙니다.",
                     "Green is the lowest cost in that scenario. The yearly premium gap between Plan G and High-Deductible G is \(money((g - hd) * 12)). If it is more than about $2,750, High-Deductible G costs no more even in a bad year."))
                .font(.subheadline)
            Text(s.t("계산 가정: 진료 1회당 메디케어 인정 금액 약 $150. \"많이 아픈 해\"는 입원 1회(Part A 디덕티블 $1,776, 2027) + 외래·검사 $30,000으로 가정. Plan N은 진료 1회 최대 $20 코페이로 계산했고, 초과청구(excess charge)는 포함하지 않았습니다. 어드밴티지 \"많이 아픈 해\"는 연간 상한까지 낸다고 가정. 약값 본인부담(최대 $2,400)은 어느 쪽이든 비슷하게 상한이 있어 제외했습니다. 실제 금액은 플랜마다 다릅니다.",
                     "Assumptions: about $150 Medicare-approved per visit. \"Bad year\" = one hospital stay (Part A deductible $1,776, 2027) plus $30,000 of outpatient care and tests. Plan N uses up to $20 per visit and excludes excess charges. Advantage \"bad year\" assumes you reach the plan's cap. Drug out-of-pocket costs (capped at $2,400) are left out since every path has that cap. Real costs vary by plan."))
                .font(.footnote).foregroundStyle(Theme.muted)
        }
    }

    func cell(_ x: Double, best: Bool) -> some View {
        Text(money(x))
            .font(.subheadline.monospacedDigit().weight(best ? .heavy : .regular))
            .foregroundStyle(best ? Theme.ok : Theme.ink)
            .padding(.horizontal, 6).padding(.vertical, 3)
            .background(best ? Theme.ok.opacity(0.15) : .clear, in: RoundedRectangle(cornerRadius: 6))
            .frame(width: 90, alignment: .trailing)
    }
}

// MARK: Step 3 — my own cost

enum StateData {
    /// KFF analysis of NAIC data via Mark Farrah Associates, 2025: average monthly premium among current
    /// policyholders (all ages) — [all plans, Plan G, Plan N].
    static let medigap: [String: [Double]] = ["AK": [222, 176, 170], "AL": [218, 191, 143], "AR": [230, 183, 151], "AZ": [249, 197, 173], "CA": [261, 196, 204], "CO": [237, 198, 166], "CT": [255, 242, 191], "DC": [232, 165, 165], "DE": [227, 168, 182], "FL": [262, 222, 202], "GA": [227, 178, 160], "HI": [214, 169, 142], "IA": [250, 181, 160], "ID": [234, 211, 169], "IL": [260, 205, 171], "IN": [236, 186, 183], "KS": [239, 187, 149], "KY": [235, 180, 174], "LA": [228, 182, 163], "MA": [237, 197, 141], "MD": [260, 208, 190], "ME": [250, 230, 189], "MI": [235, 180, 184], "MN": [283, 206, 191], "MO": [241, 204, 176], "MS": [231, 179, 151], "MT": [227, 186, 165], "NC": [223, 193, 155], "ND": [272, 195, 141], "NE": [254, 203, 159], "NH": [222, 180, 194], "NJ": [258, 210, 191], "NM": [217, 164, 160], "NV": [253, 199, 191], "NY": [306, 257, 269], "OH": [229, 183, 190], "OK": [223, 175, 168], "OR": [238, 214, 174], "PA": [236, 190, 158], "RI": [239, 181, 176], "SC": [220, 165, 152], "SD": [242, 188, 150], "TN": [220, 171, 149], "TX": [238, 191, 165], "UT": [240, 192, 170], "VA": [220, 165, 154], "VT": [223, 179, 182], "WA": [243, 220, 186], "WI": [256, 152, 185], "WV": [249, 189, 178], "WY": [236, 187, 165]]
    static let rating: [String: String] = ["AR": "c", "CT": "c", "ID": "c", "MA": "c", "ME": "c", "MN": "c", "NY": "c", "VT": "c", "WA": "c", "FL": "i", "AZ": "ic", "GA": "ic", "MO": "ic"]
    static let waiver: Set<String> = ["MA", "MN", "WI"]
}

struct MyCostView: View {
    @EnvironmentObject var s: AppState
    @State private var year = 2027
    @State private var st = "TX"
    @State private var fs = "s"
    @State private var income = 50000.0
    @State private var wq = 40
    @State private var aLate = false
    @State private var bLate = 0.0
    @State private var dLate = 0.0
    @State private var msp = "none"
    @State private var eh = false
    @State private var plan = "G"
    @State private var mgQuote: Double? = nil
    @State private var pd = 40.0
    @State private var maPrem = 0.0

    var body: some View {
        let y = year == 2026 ? Figures.y2026 : Figures.y2027
        VStack(alignment: .leading, spacing: 14) {
            Text(s.t("CMS·Medicare.gov 공식 규칙으로 본인이 실제로 내는 월·연 금액을 계산합니다. 소득별 할증(IRMAA), Part A 보험료, 늦은 가입 벌금, 지원 프로그램을 반영하고, 서플먼트는 본인 견적(없으면 주 평균 참고치)을 씁니다.",
                     "Uses official CMS and Medicare.gov rules to compute what you personally pay each month and year: income surcharge (IRMAA), Part A premium, late penalties and help programs. The supplement uses your quote, or your state's average if you have none yet."))
                .font(.subheadline)
            Card {
                ChoiceRow(label: s.t("기준 연도", "Year"), selection: $year, options: [(2026, "2026"), (2027, "2027")])
                ChoiceRow(label: s.t("사는 주", "State you live in"), selection: $st, options: StateData.medigap.keys.sorted().map { ($0, $0) })
                ChoiceRow(label: s.t("세금 보고 형태", "Tax filing status"), selection: $fs, options: [("s", s.t("혼자", "Single")), ("j", s.t("부부 공동", "Married filing jointly")), ("m", s.t("부부 별도", "Married filing separately"))])
                NumberField(label: s.t("수정 조정 총소득(MAGI, $) — \(String(y.magiYear))년 세금보고", "Modified adjusted gross income (MAGI, $) — your \(String(y.magiYear)) tax return"), value: $income)
                ChoiceRow(label: s.t("본인 또는 배우자 근로 기간(메디케어 세금 낸 분기)", "Work credits (you or spouse, Medicare-taxed quarters)"), selection: $wq, options: [(40, s.t("40분기(10년) 이상", "40+")), (30, "30–39"), (0, s.t("30분기 미만", "Under 30"))])
                if wq < 40 {
                    Toggle(s.t("Part A를 돈 내고 사는데 늦게 가입했나요?", "Buying Part A and enrolled late?"), isOn: $aLate).font(.subheadline)
                }
                NumberField(label: s.t("Part B 늦게 가입한 기간 (개월, 특별가입기간 제외)", "Months Part B was delayed (outside a Special Enrollment Period)"), value: $bLate)
                NumberField(label: s.t("약 보험(크레디터블) 없이 지낸 기간 (개월)", "Months without creditable drug coverage"), value: $dLate)
                ChoiceRow(label: s.t("메디케어 저축 프로그램(MSP)", "Medicare Savings Program (MSP)"), selection: $msp, options: [("none", s.t("없음", "None")), ("qmb", "QMB"), ("slmb", "SLMB · QI")])
                Toggle(s.t("엑스트라 헬프(Part D 지원) 받음", "I have Extra Help (Part D)"), isOn: $eh).font(.subheadline)
                ChoiceRow(label: s.t("서플먼트 플랜", "Supplement plan"), selection: $plan, options: [("G", "Plan G"), ("N", "Plan N"), ("H", s.t("하이디덕 G", "High-Deductible G"))])
                NumberField(label: s.t("서플먼트 월 보험료 견적 ($) — 0이면 주 평균", "Supplement monthly quote ($) — 0 = state average"), value: Binding(get: { mgQuote ?? 0 }, set: { mgQuote = $0 > 0 ? $0 : nil }))
                NumberField(label: s.t("Part D 플랜 월 보험료 ($)", "Part D plan monthly premium ($)"), value: $pd)
                NumberField(label: s.t("어드밴티지 플랜 월 보험료 ($)", "Advantage plan monthly premium ($)"), value: $maPrem)
                Link(s.t("▶ Medicare.gov에서 내 ZIP 서플먼트 견적 보기", "▶ Get supplement prices for your ZIP on Medicare.gov"), destination: URL(string: "https://www.medicare.gov/medigap-supplemental-insurance-plans/")!).font(.subheadline.bold())
                Link(s.t("▶ Medicare.gov에서 Part D·어드밴티지 보험료 보기", "▶ Compare Part D and Advantage premiums on Medicare.gov"), destination: URL(string: "https://www.medicare.gov/plan-compare/")!).font(.subheadline.bold())
            }
            result(y)
        }
    }

    func tier(_ y: Figures.Year) -> Int {
        if fs == "m" { return income <= y.sepLow ? 0 : (income < y.sepHigh ? 4 : 5) }
        let b = fs == "j" ? y.joint : y.single
        if income <= b[0] { return 0 }
        if income <= b[1] { return 1 }
        if income <= b[2] { return 2 }
        if income <= b[3] { return 3 }
        return income < b[4] ? 4 : 5
    }

    func r10(_ x: Double) -> Double { (x * 10).rounded() / 10 }

    @ViewBuilder
    func result(_ y: Figures.Year) -> some View {
        let ko = s.ko
        let aBase = wq >= 40 ? 0 : (wq >= 30 ? y.a30 : y.a0)
        let aPrem = msp == "qmb" ? 0 : (aBase > 0 && aLate ? r10(aBase * 1.1) : aBase)
        let t = tier(y)
        let bIrmaa = y.bTotals[t]
        let blm = floor(bLate), dlm = floor(dLate)
        let bPen = floor(blm / 12) * 0.10 * y.b
        let bPrem = msp != "none" ? 0 : r10(bIrmaa + bPen)
        let dirm = eh ? 0 : y.dIrmaa[t]
        let dPen = eh ? 0 : r10(y.dbase * dlm / 100)
        let avg = StateData.medigap[st] ?? [0, 0, 0]
        let mgSrc: String = mgQuote != nil ? "q" : ((plan == "G" && avg[1] > 0) || (plan == "N" && avg[2] > 0)) ? "a" : "x"
        let mgUsed: Double = mgQuote ?? (mgSrc == "a" ? (plan == "G" ? avg[1] : avg[2]) : 0)
        let mgLine = mgSrc == "q" ? s.t("내 견적", "Your quote") : mgSrc == "a" ? s.t("\(st) 주 평균 참고치 (실제 견적 아님)", "\(st) state average (not a quote)") : s.t("견적 필요 — 주 평균 자료 없음", "Quote needed — no state average")
        let supM = aPrem + bPrem + mgUsed + pd + dirm + dPen
        let maM = aPrem + bPrem + maPrem + dirm + dPen
        let planName = plan == "G" ? "Plan G" : plan == "N" ? "Plan N" : s.t("하이디덕 G", "High-Deductible G")
        let supMax = msp == "qmb" ? 0 : (plan == "H" ? y.hdg : y.bded)
        let maMax = msp == "qmb" ? 0 : y.moop
        let rows: [(String, Double?, Double?)] = [
            (s.t("Part A 보험료", "Part A premium"), aPrem, aPrem),
            (s.t("Part B 보험료 (할증·벌금 포함)", "Part B premium (incl. surcharge, penalty)"), bPrem, bPrem),
            ("\(planName) — \(mgLine)", mgUsed, nil),
            (s.t("Part D 플랜 보험료", "Part D plan premium"), pd, nil),
            (s.t("어드밴티지 플랜 보험료", "Advantage plan premium"), nil, maPrem),
            (s.t("Part D 소득 할증", "Part D income surcharge"), dirm, dirm),
            (s.t("Part D 늦은 가입 벌금", "Part D late penalty"), dPen, dPen),
        ]
        Card(tint: Theme.accent) {
            Text(ko ? "\(String(year))년 내 월 보험료" : "My monthly premiums, \(String(year))").font(.display(.title3))
            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 8) {
                GridRow {
                    Text(s.t("항목", "Item")).bold()
                    Text(s.t("오리지널+서플먼트", "Original+Supp.")).bold().gridColumnAlignment(.trailing)
                    Text(s.t("어드밴티지", "Advantage")).bold().gridColumnAlignment(.trailing)
                }
                ForEach(rows, id: \.0) { r in
                    GridRow {
                        Text(r.0)
                        Text(r.1.map { money($0, cents: true) } ?? "—").monospacedDigit()
                        Text(r.2.map { money($0, cents: true) } ?? "—").monospacedDigit()
                    }
                }
                Divider().gridCellColumns(3)
                GridRow {
                    Text(s.t("월 합계", "Monthly total")).bold()
                    Text(money(supM, cents: true)).bold().monospacedDigit()
                    Text(money(maM, cents: true)).bold().monospacedDigit()
                }
                GridRow {
                    Text(s.t("1년 보험료 합계", "Yearly premiums")).bold()
                    Text(money(supM * 12)).bold().foregroundStyle(supM <= maM ? Theme.ok : Theme.ink)
                    Text(money(maM * 12)).bold().foregroundStyle(maM < supM ? Theme.ok : Theme.ink)
                }
                GridRow {
                    Text(s.t("아픈 해 의료비 본인부담 최대 (약값 제외)", "Most you pay for medical care in a bad year (excl. drugs)"))
                    Text(money(supMax) + (plan == "N" ? s.t(" + 코페이", " + copays") : ""))
                    Text((msp == "qmb" ? "" : s.t("최대 ", "up to ")) + money(maMax))
                }
                GridRow {
                    Text(s.t("약값 본인부담 상한 (Part D)", "Drug out-of-pocket cap (Part D)"))
                    Text(money(y.dcap))
                    Text(money(y.dcap))
                }
                GridRow {
                    Text(s.t("최악의 해 총액 (보험료 + 의료비 + 약값 상한)", "Worst-case year (premiums + medical + drug cap)")).bold()
                    Text(money(supM * 12 + supMax + y.dcap)).bold()
                    Text(money(maM * 12 + maMax + y.dcap)).bold()
                }
            }
            .font(.footnote)

            ForEach(notes(y: y, t: t, bIrmaa: bIrmaa, bPen: bPen, blm: blm, dPen: dPen, dlm: dlm, aBase: aBase, aPrem: aPrem, mgSrc: mgSrc), id: \.self) {
                Bullet(text: $0)
            }
            if mgSrc == "x" {
                Bullet(text: s.t("\(planName)는 \(st) 주 평균 자료가 없어 서플먼트 보험료를 $0으로 두었습니다. 견적을 입력하세요.", "No \(st) state average for \(planName), so the supplement premium is $0 here. Enter a quote."), icon: "exclamationmark.triangle.fill", tint: Theme.alert)
            }
            if StateData.waiver.contains(st) {
                Bullet(text: s.t("\(st) 주는 서플먼트가 연방 표준(A–N)과 다른 자체 플랜 체계를 씁니다. 플랜 이름이 다를 수 있습니다.", "\(st) uses its own supplement plan system, not the federal A–N letters. Plan names may differ."), icon: "exclamationmark.triangle.fill", tint: Theme.alert)
            }
            Text(s.t("어드밴티지 쪽은 약 보장이 포함된 플랜(MA-PD) 기준이며, 소득 할증·늦은 가입 벌금은 어드밴티지 약 보장에도 똑같이 붙습니다. 보험료가 가장 낮은 쪽이 꼭 맞는 선택은 아닙니다. 결정 전 텍사스 HICAP(1-800-252-9240) 무료 상담을 받으세요.",
                     "The Advantage column assumes a plan with drug coverage (MA-PD); income surcharges and late penalties apply there too. The lowest premium is not always the right choice. Talk to Texas HICAP (1-800-252-9240, free) before deciding."))
                .font(.footnote).foregroundStyle(Theme.muted)
            Text(s.t("출처: CMS 2026·2027 Part A·B 보험료·디덕티블 및 IRMAA 표(2027년분 2026년 11월 17일 발표), CMS 2027 Part D 기준 보험료($41.33)·하이디덕 G $3,050·어드밴티지 상한 $9,850, Medicare.gov 늦은 가입 벌금 안내, 주별 서플먼트 평균: KFF의 NAIC 자료 분석(2025, 현재 가입자 전 연령 평균). 실제 보험료 고지서는 사회보장국(SSA)이 보냅니다.",
                     "Sources: CMS 2026 and 2027 Part A and B premiums, deductibles and IRMAA tables (2027 released Nov 17, 2026); CMS 2027 Part D base premium ($41.33), High-Deductible G $3,050 and Advantage cap $9,850; Medicare.gov late-penalty rules; state supplement averages: KFF analysis of NAIC data (2025, current policyholders of all ages). Your actual premium notice comes from Social Security."))
                .font(.caption).foregroundStyle(Theme.muted)
        }
    }

    func notes(y: Figures.Year, t: Int, bIrmaa: Double, bPen: Double, blm: Double, dPen: Double, dlm: Double, aBase: Double, aPrem: Double, mgSrc: String) -> [String] {
        var n: [String] = []
        let f = { (x: Double) in money(x, cents: true) }
        if msp != "none" {
            n.append(s.t("MSP가 Part B 보험료를 대신 내므로 $0으로 계산했습니다.", "MSP pays your Part B premium, so it is $0 here."))
        } else if t > 0 {
            n.append(s.t("소득이 할증 \(t)구간입니다. Part B 보험료가 표준 \(f(y.b)) 대신 \(f(bIrmaa))입니다. \(String(y.magiYear))년 세금보고 소득 기준이며, 은퇴·배우자 사망 등 소득이 줄었다면 SSA-44 양식으로 재심을 요청할 수 있습니다.",
                         "Your income is in surcharge tier \(t). Your Part B premium is \(f(bIrmaa)) instead of the standard \(f(y.b)). It is based on your \(String(y.magiYear)) tax return; if your income dropped (retirement, death of a spouse), you can ask SSA to redo it with form SSA-44."))
        } else {
            n.append(s.t("소득 할증 없음. Part B 표준 보험료 \(f(y.b))입니다 (\(String(y.magiYear))년 세금보고 소득 기준).", "No income surcharge. Standard Part B premium \(f(y.b)) (based on your \(String(y.magiYear)) tax return)."))
        }
        if bPen > 0 && msp == "none" {
            n.append(s.t("Part B 늦은 가입 벌금: \(Int(blm / 12))년 × 10% = 월 \(f(bPen)). 평생 붙습니다.", "Part B late penalty: \(Int(blm / 12)) full year(s) × 10% = \(f(bPen))/month, for as long as you have Part B."))
        }
        if blm > 0 && blm < 12 && msp == "none" {
            n.append(s.t("12개월을 채우지 않은 기간에는 Part B 벌금이 붙지 않습니다.", "No Part B penalty for less than a full 12 months."))
        }
        if dPen > 0 {
            n.append(s.t("Part D 늦은 가입 벌금: 기준 보험료 \(f(y.dbase)) × \(Int(dlm))% = 월 \(f(dPen)). Part D가 있는 동안 계속 붙습니다. 63일 미만 공백은 벌금이 없습니다.", "Part D late penalty: base premium \(f(y.dbase)) × \(Int(dlm))% = \(f(dPen))/month, for as long as you have Part D. Gaps under 63 days carry no penalty."))
        }
        if eh {
            n.append(s.t("엑스트라 헬프가 있으면 Part D 늦은 가입 벌금이 없고, 기준 금액 이하 플랜을 고르면 Part D 보험료가 $0일 수 있습니다. Part D 보험료 칸에 실제 금액을 넣으세요.", "With Extra Help there is no Part D late penalty, and a plan at or below the benchmark can cost $0. Enter your actual Part D premium."))
        }
        if aBase > 0 && msp == "qmb" {
            n.append(s.t("근로 기간이 40분기 미만이지만 QMB가 Part A 보험료(\(f(aBase)))를 내줍니다.", "You have under 40 work quarters, but QMB pays your Part A premium (\(f(aBase)))."))
        } else if aBase > 0 {
            n.append(s.t("근로 기간이 40분기 미만이라 Part A를 사야 합니다: 월 \(f(aPrem))\(aLate ? " (늦은 가입 10% 포함, 늦은 기간의 2배 동안)." : ".") 배우자의 근로 기록으로 무료가 될 수 있으니 SSA(1-800-772-1213)에 확인하세요.",
                         "With under 40 work quarters you buy Part A: \(f(aPrem))/month\(aLate ? " (incl. 10% late penalty, lasting twice the years you were late)." : ".") You may qualify free through a spouse's work record; check with SSA (1-800-772-1213)."))
        }
        if msp == "qmb" {
            n.append(s.t("QMB는 Part A·B 보험료와 디덕티블·본인부담까지 내줍니다. 그래서 서플먼트가 보통 필요 없습니다. 병원은 QMB 가입자에게 본인부담을 청구할 수 없습니다.", "QMB pays Part A and B premiums, deductibles and coinsurance, so a supplement is usually not needed. Providers may not bill QMB members for Medicare cost-sharing."))
        }
        if mgSrc == "a" {
            n.append(s.t("\(st) 주 서플먼트 평균은 현재 가입자 전 연령 평균입니다(KFF 2025). 65세 신규 가입자는 보통 이보다 싸고, 나이·성별·흡연·ZIP에 따라 크게 다릅니다. Medicare.gov에서 본인 견적을 받아 칸에 넣으세요.", "The \(st) supplement average covers current policyholders of all ages (KFF, 2025). New 65-year-olds often pay less, and prices vary a lot by age, sex, tobacco use and ZIP. Get your own quote on Medicare.gov and enter it."))
        }
        switch StateData.rating[st] {
        case "c": n.append(s.t("\(st) 주는 서플먼트 보험료를 나이와 관계없이 같게 매기는 방식(커뮤니티 레이팅)입니다.", "\(st) requires community rating: the same premium regardless of age."))
        case "i": n.append(s.t("\(st) 주는 가입 당시 나이로 보험료를 정하는 방식(이슈 에이지)입니다.", "\(st) requires issue-age rating: based on your age when you buy."))
        case "ic": n.append(s.t("\(st) 주는 가입 나이 기준 또는 커뮤니티 레이팅만 허용합니다.", "\(st) allows issue-age or community rating only."))
        default: n.append(s.t("\(st) 주는 나이가 들수록 보험료가 오르는 방식(어테인드 에이지)도 허용됩니다. 견적을 받을 때 어떤 방식인지 꼭 물어보세요.", "\(st) allows attained-age rating, where premiums rise as you age. Ask which method a quote uses."))
        }
        return n
    }
}
