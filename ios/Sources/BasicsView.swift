import SwiftUI

/// Official amounts used across the app. 2026 and 2027 Part A/B/D figures are CMS-announced
/// (2027 Parts A & B released Nov 17, 2026; Federal Register CMS-8094-N; Part D figures July 28, 2026).
enum Figures {
    struct Year {
        let b: Double, bded: Double, a30: Double, a0: Double, aded: Double, dbase: Double
        let hdg: Double, dded: Double, dcap: Double, moop: Double, magiYear: Int
        let bTotals: [Double]          // Part B total monthly premium by IRMAA tier 0...5
        let dIrmaa: [Double]           // Part D monthly adjustment by tier 0...5
        let single: [Double], joint: [Double]   // tier upper bounds (tiers 1-4 inclusive, tier 5 starts at last)
        let sepLow: Double, sepHigh: Double     // married filing separately
    }
    static let y2026 = Year(b: 202.90, bded: 283, a30: 311, a0: 565, aded: 1736, dbase: 38.99,
                            hdg: 2950, dded: 615, dcap: 2100, moop: 9250, magiYear: 2024,
                            bTotals: [202.90, 284.10, 405.80, 527.50, 649.20, 689.90],
                            dIrmaa: [0, 14.50, 37.50, 60.40, 83.30, 91.00],
                            single: [109_000, 137_000, 171_000, 205_000, 500_000],
                            joint: [218_000, 274_000, 342_000, 410_000, 750_000],
                            sepLow: 109_000, sepHigh: 391_000)
    static let y2027 = Year(b: 209.40, bded: 292, a30: 328, a0: 597, aded: 1776, dbase: 41.33,
                            hdg: 3050, dded: 700, dcap: 2400, moop: 9850, magiYear: 2025,
                            bTotals: [209.40, 293.10, 418.80, 544.40, 670.00, 711.80],
                            dIrmaa: [0, 15.40, 39.70, 64.00, 88.30, 96.40],
                            single: [112_000, 141_000, 177_000, 212_000, 500_000],
                            joint: [224_000, 282_000, 354_000, 424_000, 750_000],
                            sepLow: 112_000, sepHigh: 388_000)
    static let checked = KE("2026년 11월 26일", "November 26, 2026")
}

struct BasicsView: View {
    @EnvironmentObject var s: AppState

    var body: some View {
        Screen(title: KE("메디케어 기본", "Medicare basics")) {
            Text(s.t("메디케어는 65세 이상(또는 특정 장애)인 분들을 위한 연방 건강보험입니다. 네 부분(Part)으로 나뉘어 있고, 이것만 알면 나머지는 쉬워집니다.",
                     "Medicare is federal health insurance for people 65 and older (and some people with disabilities). It has four parts. Once you know them, the rest gets easier."))
                .font(.title3)

            ForEach(parts, id: \.0) { p in
                HStack(alignment: .top, spacing: 14) {
                    Text(p.0).font(.system(size: 40, weight: .bold, design: .serif)).foregroundStyle(Theme.accent).frame(width: 40)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(s.t(p.1)).font(.headline)
                        Text(s.t(p.2))
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
            }

            SectionTitle(text: s.t("꼭 알아야 할 용어 4개", "Four words you must know"))
            Card {
                ForEach(terms, id: \.0) { t in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(s.ko ? t.0 : t.1).font(.headline)
                            if s.ko { Text(t.1).font(.subheadline).foregroundStyle(Theme.muted) }
                        }
                        Text(s.t(t.2))
                    }
                    if t.0 != terms.last?.0 { Divider() }
                }
            }
            Card(tint: Theme.warn) {
                Text(s.t("에이전트가 흔히 흐리는 부분", "What sales pitches blur")).font(.headline).foregroundStyle(Theme.warn)
                Text(s.t("\"보험료 $0\" 플랜은 대신 디덕티블이나 본인부담이 높은 경우가 많습니다. 보험료만 보지 말고 1년 총비용 = 보험료×12 + 예상 본인부담으로 비교하세요.",
                         "\"$0 premium\" plans often have higher deductibles or copays. Compare the yearly total = premium × 12 + expected out-of-pocket, not the premium alone."))
            }

            SectionTitle(text: s.t("버킷 두 개로 이해하기", "Think of two buckets"))
            Text(s.t("내가 병원비·약값으로 내는 돈은 버킷에 물을 붓는 것과 같습니다. 버킷은 두 종류가 있고, 다 찼을 때 일어나는 일이 다릅니다.",
                     "Every dollar you pay for care is water poured into a bucket. There are two kinds, and what happens when each is full is different."))
            HStack(alignment: .top, spacing: 12) {
                bucket(title: KE("버킷 1 · 디덕티블", "Bucket 1 · Deductible"),
                       full: KE("다 차면 내 몫이 줄어듭니다. 0이 되지는 않습니다.", "When full, your share drops. It does not go to zero."),
                       lines: [KE("Part B: $292(2027)가 차면 그 뒤 20%씩", "Part B: after $292 (2027), you pay 20%"),
                               KE("Part D 약: $700(2027)이 차면 그 뒤 약 25%씩", "Part D drugs: after $700 (2027), about 25%")],
                       fill: 0.55, tint: Theme.warn)
                bucket(title: KE("버킷 2 · 연간 본인부담 상한", "Bucket 2 · Out-of-pocket maximum"),
                       full: KE("다 차면 그 해 나머지는 $0입니다.", "When full, you pay $0 for the rest of the year."),
                       lines: [KE("Part D 약값: $2,400 (2027)", "Part D drugs: $2,400 (2027)"),
                               KE("어드밴티지: 최대 $9,850 (2027, 네트워크 안)", "Advantage: up to $9,850 (2027, in-network)")],
                       fill: 1.0, tint: Theme.ok)
            }
            Card(tint: Theme.alert) {
                Text(s.t("오리지널 메디케어 A·B만 있으면 이 버킷이 없습니다. 20%가 끝없이 나갈 수 있어서 서플먼트를 듭니다.",
                         "Original Medicare A and B alone has no such bucket. The 20% can go on without limit, which is why people buy a supplement."))
            }
            Card {
                Text(s.t("하이디덕티블 Plan G는 버킷이 하나", "High-Deductible Plan G has one bucket")).font(.headline)
                Text(s.t("$3,050(2027, 2026년은 $2,950)이 차면 그 뒤로는 Plan G가 다 내줍니다. 이 플랜에서는 디덕티블 버킷이 곧 \"이 이상은 안 내도 되는\" 버킷입니다. 1월 1일에 다시 비워집니다.",
                         "Once $3,050 is filled (2027; $2,950 in 2026), Plan G pays the rest. On this plan the deductible bucket is the \"no more after this\" bucket. It empties again on January 1."))
            }

            SectionTitle(text: s.t("디덕티블은 어떻게 내나요?", "How do you actually pay a deductible?"))
            Text(s.t("디덕티블은 한꺼번에 미리 내는 돈이 아닙니다. 따로 청구서가 오지도 않습니다. 병원에 갈 때마다 진료비를 내다 보면 1년 동안 쌓여서 채워지는 \"문턱\"입니다. 문턱을 넘으면 그때부터 내 몫이 확 줄어듭니다.",
                     "A deductible is not paid up front in one lump, and no separate bill comes for it. It is a threshold you fill up over the year as you pay for visits. Once you pass it, your share drops."))
            DeductibleExample()
            ForEach(kinds, id: \.0.en) { k in
                Card {
                    Text(s.t(k.0)).font(.headline)
                    Text(s.t(k.1))
                }
            }

            SectionTitle(text: s.t("2026년과 2027년 주요 금액", "Key amounts, 2026 and 2027"))
            AmountsTable()
            Text(s.t("모두 CMS 공식 발표 금액입니다(2027 Part A·B는 2026년 11월 17일 발표). 상한 금액은 최대치이며 플랜마다 더 낮을 수 있습니다. 확인일: ", "All amounts are official CMS figures (2027 Parts A and B announced Nov 17, 2026). Limits are maximums; many plans set lower ones. Checked: ") + s.t(Figures.checked))
                .font(.footnote).foregroundStyle(Theme.muted)
        }
    }

    let parts: [(String, KE, KE)] = [
        ("A", KE("병원 입원", "Hospital"), KE("입원, 전문요양시설, 호스피스. 10년(40분기) 일하며 세금을 냈다면 대부분 월 보험료가 없습니다.", "Inpatient stays, skilled nursing, hospice. Most people who worked 10 years (40 quarters) pay no monthly premium.")),
        ("B", KE("의사·외래", "Doctors & outpatient"), KE("진료, 검사, 외래 치료, 예방접종. 매달 보험료를 냅니다(보통 소셜연금에서 자동 차감).", "Doctor visits, tests, outpatient care, preventive care. You pay a monthly premium, usually taken from your Social Security check.")),
        ("C", KE("메디케어 어드밴티지", "Medicare Advantage"), KE("민간 보험사가 A·B(대부분 D까지)를 묶어서 파는 플랜. \"C\"는 따로 드는 보험이 아니라 A·B를 대신 받는 방식입니다.", "Private plans that bundle A and B (usually D too). It replaces how you get A and B rather than adding to them.")),
        ("D", KE("처방약", "Prescription drugs"), KE("약값 보험. 민간 보험사가 팔고, 플랜마다 보장하는 약(포뮬러리)과 약국이 다릅니다.", "Drug coverage, sold by private companies. Each plan has its own drug list (formulary) and pharmacies.")),
    ]

    let terms: [(String, String, KE)] = [
        ("보험료", "Premium", KE("매달 내는 돈. 병원에 안 가도 냅니다.", "What you pay every month, even if you never see a doctor.")),
        ("디덕티블 (본인 먼저 내는 금액)", "Deductible", KE("보험이 본격적으로 내주기 전에, 1년 동안 내가 먼저 다 내야 하는 금액.", "What you pay yourself each year before the plan starts paying its share.")),
        ("본인부담 (코페이·코인슈런스)", "Copay / Coinsurance", KE("디덕티블을 채운 뒤에도 내는 몫. 코페이는 정액(예: $20), 코인슈런스는 비율(예: 20%).", "Your share after the deductible. A copay is a flat amount ($20); coinsurance is a percent (20%).")),
        ("연간 본인부담 상한", "Out-of-pocket maximum", KE("1년에 내가 낼 수 있는 최대 금액. 여기까지 내면 그 해 나머지는 보험이 냅니다. 오리지널 메디케어(A·B)에는 이 상한이 없습니다.", "The most you pay in a year; after that the plan pays. Original Medicare (A and B) has no such cap.")),
    ]

    let kinds: [(KE, KE)] = [
        (KE("Part A (입원)", "Part A (hospital)"), KE("입원할 때만 해당됩니다. 1년 단위가 아니라 \"입원 기간\"마다 $1,776(2027; 2026년은 $1,736). 퇴원 후 60일이 지나 다시 입원하면 새로 시작합니다.", "Only when you are admitted. It applies per benefit period, not per year: $1,776 in 2027 ($1,736 in 2026). If you go 60 days out of the hospital and are admitted again, a new one starts.")),
        (KE("Part D (약)", "Part D (drugs)"), KE("약국에서 약값 전액을 내다가 문턱(2027년 최대 $700)을 넘으면 약값의 25% 정도만 냅니다. 1년에 $2,400을 내면 그 해 나머지 약값은 $0입니다. 대부분의 제네릭 약과 인슐린은 문턱과 상관없이 처음부터 싸게 받습니다. 디덕티블이 $0인 플랜도 많습니다.", "At the pharmacy you pay full price until you pass the deductible (up to $700 in 2027), then about 25%. Once you have paid $2,400 in a year, covered drugs cost $0 for the rest of it. Most generics and insulin skip the deductible. Many plans have a $0 deductible.")),
        (KE("어드밴티지 플랜", "Medicare Advantage"), KE("디덕티블 대신 \"진료 한 번 $20, 전문의 $45\"처럼 정해진 금액(코페이)인 경우가 많습니다. 플랜 안내서(Summary of Benefits)에서 확인하세요.", "Often flat copays instead, like $20 per visit or $45 for a specialist. Check the plan's Summary of Benefits.")),
        (KE("서플먼트 Plan G", "Medigap Plan G"), KE("Part B 디덕티블($292, 2027)만 내가 채우고, 그 뒤 20%는 서플먼트가 냅니다. 그래서 1년 의료비 본인부담이 거의 그 금액에서 끝납니다.", "You cover only the Part B deductible ($292 in 2027); the supplement pays the 20% after that, so your yearly medical cost mostly stops there.")),
    ]

    func bucket(title: KE, full: KE, lines: [KE], fill: CGFloat, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 10).stroke(Theme.ink, lineWidth: 2).frame(height: 90)
                RoundedRectangle(cornerRadius: 8).fill(tint.opacity(0.55)).frame(height: 86 * fill).padding(2)
                Text(s.t("다 차면", "Full")).font(.caption.bold()).padding(.bottom, 6)
            }
            .frame(width: 70)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
            Text(s.t(title)).font(.headline)
            Text(s.t(full)).font(.subheadline.bold()).foregroundStyle(tint)
            ForEach(lines, id: \.en) { Text(s.t($0)).font(.footnote) }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
    }
}

/// Interactive version of the Part B deductible example: drag the year's bills and watch the threshold fill.
struct DeductibleExample: View {
    @EnvironmentObject var s: AppState
    @State private var bills: Double = 450

    var body: some View {
        let ded = Figures.y2027.bded
        let toward = min(bills, ded)
        let you = toward + 0.2 * max(bills - ded, 0)
        Card {
            Text(s.t("Part B 예시 (2027 디덕티블 $292)", "Part B example (2027 deductible $292)")).font(.headline)
            Text(s.t("올해 진료비 합계", "Bills so far this year") + ": " + money(bills)).font(.subheadline)
            Slider(value: $bills, in: 0...2000, step: 10).tint(Theme.accent)
            ProgressView(value: toward, total: ded) {
                Text(s.t("문턱(디덕티블)", "Threshold (deductible)") + " " + money(toward) + " / " + money(ded)).font(.footnote)
            }
            .tint(Theme.warn)
            HStack {
                Text(s.t("내가 낸 돈", "You paid")).font(.headline)
                Spacer()
                Text(money(you, cents: true)).font(.title2.bold().monospacedDigit()).foregroundStyle(Theme.accent)
            }
            Text(s.t("진료비는 메디케어가 인정하는 금액 기준입니다. 문턱까지는 전액, 그 뒤로는 20%를 냅니다. 다음 해 1월 1일에 문턱이 다시 $0부터 시작합니다. 숫자는 이해를 돕기 위한 예시입니다.",
                     "Bills are Medicare-approved amounts. You pay in full up to the threshold, then 20%. The threshold starts over at $0 each January 1. Numbers are an illustration."))
                .font(.footnote).foregroundStyle(Theme.muted)
        }
    }
}

struct AmountsTable: View {
    @EnvironmentObject var s: AppState
    var rows: [(KE, String, String)] {
        let a = Figures.y2026, b = Figures.y2027
        return [
            (KE("Part B 월 보험료(표준)", "Part B monthly premium (standard)"), money(a.b, cents: true), money(b.b, cents: true)),
            (KE("Part B 연간 디덕티블", "Part B yearly deductible"), money(a.bded), money(b.bded)),
            (KE("Part A 입원 디덕티블(입원 기간마다)", "Part A hospital deductible (per benefit period)"), money(a.aded), money(b.aded)),
            (KE("Part D 최대 디덕티블", "Part D maximum deductible"), money(a.dded), money(b.dded)),
            (KE("Part D 연간 약값 본인부담 상한", "Part D yearly drug cost cap"), money(a.dcap), money(b.dcap)),
            (KE("어드밴티지 본인부담 상한(네트워크 안)", "Advantage out-of-pocket limit (in-network)"), money(a.moop), money(b.moop)),
            (KE("하이디덕 Plan G 디덕티블", "High-Deductible Plan G deductible"), money(a.hdg), money(b.hdg)),
        ]
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(s.t("항목", "Item")).frame(maxWidth: .infinity, alignment: .leading)
                Text("2026").frame(width: 82, alignment: .trailing)
                Text("2027").frame(width: 82, alignment: .trailing)
            }
            .font(.subheadline.bold()).padding(12).background(Theme.accentSoft)
            ForEach(rows, id: \.0.en) { r in
                HStack(alignment: .top) {
                    Text(s.t(r.0)).font(.subheadline).frame(maxWidth: .infinity, alignment: .leading)
                    Text(r.1).frame(width: 82, alignment: .trailing)
                    Text(r.2).bold().frame(width: 82, alignment: .trailing)
                }
                .font(.subheadline.monospacedDigit())
                .padding(12)
                Divider()
            }
        }
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
