import SwiftUI

struct HelpPayView: View {
    @EnvironmentObject var s: AppState
    @State private var married = false
    @State private var monthly = 1800.0
    @State private var savings = 9000.0

    var body: some View {
        Screen(title: KE("약값·보험료 지원", "Help paying")) {
            Text(s.t("약값이 한 달에 수백~천 불씩 나가는 분은 이 페이지를 먼저 보세요. 소득이 적으면 정부가 상당 부분을 내줍니다.",
                     "If your drugs cost hundreds of dollars a month, start here. With limited income, government programs can pay much of it."))
                .font(.title3)
            SectionTitle(text: s.t("세 가지 지원 프로그램", "Three programs"))
            program("1", KE("엑스트라 헬프", "Extra Help"), "Part D Low-Income Subsidy",
                    KE("Part D 보험료·디덕티블·약값을 줄여줍니다. 2027년에는 대상자가 약값을 제네릭 최대 $5.80, 브랜드 약 최대 $14.40만 냅니다. 소셜시큐리티(ssa.gov)에서 신청하며 무료입니다.",
                       "Lowers Part D premiums, deductibles and drug costs. In 2027, people with Extra Help pay at most $5.80 per generic and $14.40 per brand-name drug. Apply free through Social Security (ssa.gov)."))
            program("2", KE("메디케어 저축 프로그램", "Medicare Savings Programs"), "MSP",
                    KE("주정부 프로그램으로 Part B 보험료(경우에 따라 디덕티블·본인부담까지)를 내줍니다. MSP 자격이 되면 엑스트라 헬프도 자동으로 받습니다. 텍사스는 HHSC(YourTexasBenefits.com)에서 신청합니다.",
                       "State programs that pay the Part B premium, and for some people deductibles and coinsurance too. If you qualify, you also get Extra Help automatically. In Texas, apply through HHSC (YourTexasBenefits.com)."))
            program("3", KE("메디케이드 (메디케어와 동시 수혜 = \"듀얼\")", "Medicaid (\"dual eligible\")"), "Medicaid",
                    KE("소득·재산이 더 낮으면 메디케어와 메디케이드를 둘 다 받을 수 있고, 본인부담이 거의 없어집니다.",
                       "With lower income and assets, you can have both Medicare and Medicaid, and most out-of-pocket costs go away."))
            Card {
                Text(s.t("오바마케어(ACA)는요?", "What about Obamacare (ACA)?")).font(.headline)
                Text(s.t("메디케어가 있는 분은 일반적으로 ACA 마켓플레이스 플랜을 쓸 수 없습니다. 메디케어 가입자가 비용을 줄이는 길은 위의 세 가지입니다.",
                         "People with Medicare generally can't use ACA Marketplace plans. For Medicare enrollees, the three programs above are the way to lower costs."))
            }

            SectionTitle(text: s.t("엑스트라 헬프 자가 점검", "Extra Help self-check"))
            Text(s.t("2026년 기준(연소득: 1인 $23,940 · 부부 $32,460 / 재산: 1인 $18,090 · 부부 $36,100). 집, 차 1대, 장례비 일부는 재산에 포함되지 않습니다.",
                     "2026 limits (yearly income: $23,940 single, $32,460 married; resources: $18,090 single, $36,100 married). Your home, one car and some burial funds don't count."))
                .font(.subheadline)
            Card {
                Picker("", selection: $married) {
                    Text(s.t("혼자", "Single")).tag(false)
                    Text(s.t("부부", "Married")).tag(true)
                }
                .pickerStyle(.segmented)
                NumberField(label: s.t("월 소득 합계 ($) — 소셜연금, 연금, 근로소득 등", "Total monthly income ($) — Social Security, pension, wages"), value: $monthly)
                NumberField(label: s.t("예금·투자 합계 ($) — 집·차 제외", "Savings and investments ($) — not your home or car"), value: $savings)
            }
            ehResult
            Text(s.t("예시 값이 들어 있습니다. 본인 숫자로 바꿔 보세요. 이 점검은 참고용이며, 최종 판단은 소셜시큐리티가 합니다. 기준에 조금 넘어도 일부 소득은 빼고 계산하므로 신청해 보는 것이 좋습니다.",
                     "Example values are filled in; replace them with yours. This is only a guide; Social Security decides. If you are slightly over, apply anyway, since some income isn't counted."))
                .font(.footnote).foregroundStyle(Theme.muted)
            PhoneButton(label: KE("소셜시큐리티 (엑스트라 헬프 신청)", "Social Security (apply for Extra Help)"), number: "1-800-772-1213")
            PhoneButton(label: KE("텍사스 HICAP (MSP·무료 상담)", "Texas HICAP (MSP, free counseling)"), number: "1-800-252-9240")
        }
    }

    var ehResult: some View {
        let lim = married ? (inc: 32460.0, res: 36100.0) : (inc: 23940.0, res: 18090.0)
        let yearly = monthly * 12
        let ok = yearly <= lim.inc && savings <= lim.res
        return Card(tint: ok ? Theme.ok : Theme.warn) {
            Text(ok ? s.t("자격이 될 가능성이 높습니다. 신청해 보세요.", "You likely qualify. Apply.")
                    : s.t("기준을 넘을 수 있지만, 그래도 신청해 볼 만합니다.", "You may be over the limit, but applying is still worth it."))
                .font(.headline).foregroundStyle(ok ? Theme.ok : Theme.warn)
            Text(s.t("연소득 \(money(yearly)) / 기준 \(money(lim.inc)) · 재산 \(money(savings)) / 기준 \(money(lim.res))",
                     "Yearly income \(money(yearly)) / limit \(money(lim.inc)) · Resources \(money(savings)) / limit \(money(lim.res))"))
                .font(.subheadline.monospacedDigit())
        }
    }

    func program(_ n: String, _ title: KE, _ sub: String, _ body: KE) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(n).font(.title2.bold()).foregroundStyle(.white).frame(width: 40, height: 40).background(Theme.accent, in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(s.t(title)).font(.headline)
                Text(sub).font(.caption).foregroundStyle(Theme.muted)
                Text(s.t(body))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct ContactsView: View {
    @EnvironmentObject var s: AppState
    @State private var ticks = Set<Int>()

    let signs: [KE] = [
        KE("메디케어라며 먼저 전화해서 메디케어 번호나 소셜 번호를 물었다", "Someone \"from Medicare\" called first and asked for my Medicare or Social Security number"),
        KE("\"새 카드 발급\", \"혜택이 끊긴다\", \"오늘까지 안 하면 손해\"라고 서둘렀다", "They rushed me: \"new card\", \"you'll lose benefits\", \"today only\""),
        KE("공짜 검사키트, 무릎보호대, 유전자 검사를 준다며 번호를 달라고 했다", "They offered free test kits, braces or genetic tests in exchange for my number"),
        KE("선물이나 현금을 주겠다며 플랜 변경을 권했다", "They offered gifts or cash to switch plans"),
        KE("부탁하지 않았는데 보험 판매원이 전화하거나 집에 찾아왔다", "An agent called or came to my door without my asking"),
        KE("\"정부 공식\"이라며 플랜이 하나뿐인 것처럼 말했다", "They said they were \"official government\" and only one plan was right"),
    ]

    var body: some View {
        Screen(title: KE("사기 주의·연락처", "Scams & phones")) {
            SectionTitle(text: s.t("사기 점검", "Scam check"))
            Text(s.t("받은 전화·문자·방문에 해당하는 것을 체크하세요. 하나라도 있으면 끊고, 직접 확인하세요.",
                     "Tick anything that happened in the call, text or visit. If any apply, hang up and check for yourself."))
            Card {
                ForEach(Array(signs.enumerated()), id: \.offset) { i, sign in
                    Button {
                        if ticks.contains(i) { ticks.remove(i) } else { ticks.insert(i) }
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: ticks.contains(i) ? "checkmark.square.fill" : "square")
                                .font(.title2).foregroundStyle(ticks.contains(i) ? Theme.alert : Theme.muted)
                            Text(s.t(sign)).foregroundStyle(Theme.ink).multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            Card(tint: ticks.isEmpty ? Theme.accent : Theme.alert) {
                Text(ticks.isEmpty
                     ? s.t("해당 사항이 없으면 그래도 번호를 주기 전에 직접 1-800-MEDICARE로 확인하세요.", "Nothing ticked. Still, call 1-800-MEDICARE yourself before giving out your number.")
                     : s.t("사기 의심 신호 \(ticks.count)개. 대화를 끊고, 아무 번호도 주지 마세요. SMP 1-877-808-2468에 신고하세요.", "\(ticks.count) warning sign\(ticks.count > 1 ? "s" : ""). Stop talking and give no numbers. Report to SMP at 1-877-808-2468."))
                    .font(.headline)
            }
            Card {
                Text(s.t("기억할 것", "Remember")).font(.headline)
                Bullet(text: s.t("메디케어는 내가 먼저 연락하지 않았는데 전화해서 번호를 묻지 않습니다.", "Medicare won't call out of the blue to ask for your number."))
                Bullet(text: s.t("보험 판매원은 요청받지 않은 전화·방문으로 영업할 수 없습니다(메디케어 마케팅 규정).", "Agents may not market by unsolicited calls or visits (Medicare marketing rules)."))
                Bullet(text: s.t("에이전트는 계약된 보험사 상품만 보여줄 수 있습니다. 중립적인 비교는 Medicare.gov 플랜 비교기나 HICAP에서 받으세요.", "Agents may only show plans from companies they contract with. For neutral comparisons, use the Medicare.gov Plan Finder or HICAP."))
            }

            SectionTitle(text: s.t("가입·변경 시기", "When you can join or change"))
            dateRow(KE("65세 생일 달 앞뒤 7개월", "7 months around your 65th birthday month"),
                    KE("첫 가입 기간. 생일 달 3개월 전부터 3개월 후까지. 늦으면 평생 벌금(Part B·D)이 붙을 수 있습니다.", "Initial Enrollment: 3 months before your birthday month through 3 months after. Joining late can bring lifelong Part B or D penalties."))
            dateRow(KE("10/15 – 12/7", "10/15 – 12/7"),
                    KE("연례 가입 기간. 어드밴티지·Part D 변경, 오리지널로 복귀. 1월 1일부터 적용.", "Open Enrollment. Change Advantage or Part D plans, or go back to Original Medicare. Changes start Jan 1."))
            dateRow(KE("1/1 – 3/31", "1/1 – 3/31"),
                    KE("어드밴티지 가입자 변경 기간. 다른 어드밴티지로 한 번 바꾸거나 오리지널(+Part D)로 돌아갈 수 있습니다.", "Advantage Open Enrollment: people in an Advantage plan can switch once to another Advantage plan or to Original Medicare (+ Part D)."))
            dateRow(KE("9월 말 우편", "Late September mail"),
                    KE("\"연간 변경 안내(ANOC)\" 편지. 내 플랜이 내년에 무엇이 바뀌는지 적혀 있습니다.", "\"Annual Notice of Change\" letter: what changes in your plan next year."))

            SectionTitle(text: s.t("가입은 전화로 할 수 있습니다", "You can enroll by phone"))
            Card {
                Text("Part A · B").font(.headline)
                Text(s.t("소셜시큐리티 1-800-772-1213 또는 ssa.gov. 소셜연금을 이미 받고 있으면 65세에 자동 가입되는 경우가 많습니다.", "Social Security, 1-800-772-1213 or ssa.gov. If you already get Social Security, you are often enrolled automatically at 65."))
                Divider()
                Text(s.t("어드밴티지 · Part D", "Advantage · Part D")).font(.headline)
                Text(s.t("1-800-MEDICARE(1-800-633-4227). 상담원이 플랜 비교와 등록까지 도와줍니다. 또는 Medicare.gov 플랜 비교기에서 직접 등록.", "1-800-MEDICARE (1-800-633-4227). The representative can compare plans and enroll you. Or enroll yourself in the Medicare.gov Plan Finder."))
                Divider()
                Text(s.t("서플먼트", "Supplement")).font(.headline)
                Text(s.t("원하는 보험사에 직접 전화합니다. 같은 Plan(예: G)이면 보장 내용은 회사가 달라도 똑같고, 보험료만 다릅니다.", "Call the insurance company directly. A given letter plan (like G) has the same benefits at every company; only the price differs."))
                Divider()
                Text(s.t("고르기 전에", "Before choosing")).font(.headline)
                Text(s.t("텍사스 HICAP 1-800-252-9240에서 무료로 중립 상담을 받으세요. 아무 상품도 팔지 않습니다.", "Get free, neutral advice from Texas HICAP, 1-800-252-9240. They sell nothing."))
            }

            SectionTitle(text: s.t("무료 공식 연락처", "Free official phone numbers"))
            Text(s.t("한국어 통역이 필요하면 연결된 뒤 \"Korean\"이라고 말하세요.", "If you need a Korean interpreter, say \"Korean\" when connected.")).font(.subheadline.bold())
            Card {
                PhoneButton(label: KE("메디케어", "Medicare"), number: "1-800-633-4227")
                Divider()
                PhoneButton(label: KE("텍사스 HICAP (무료 1:1 상담)", "Texas HICAP (free counseling)"), number: "1-800-252-9240")
                Divider()
                PhoneButton(label: KE("소셜시큐리티 (가입·엑스트라 헬프)", "Social Security (enroll, Extra Help)"), number: "1-800-772-1213")
                Divider()
                PhoneButton(label: KE("시니어 메디케어 패트롤 (사기 신고)", "Senior Medicare Patrol (fraud)"), number: "1-877-808-2468")
            }
            Link(s.t("Medicare.gov 플랜 비교기 열기", "Open the Medicare.gov Plan Finder"), destination: URL(string: "https://www.medicare.gov/plan-compare/")!).font(.headline)

            SectionTitle(text: s.t("설정", "Settings"))
            Card {
                Toggle(s.t("큰 글씨", "Large text"), isOn: $s.largeText)
                Button(s.t("처음 안내문 다시 보기", "Read the notice again")) { s.acceptedNotice = false }
            }
            Text(s.t("이 앱은 교육용 안내이며 보험 판매나 개인 법률·재정 자문이 아닙니다. 어떤 보험사와도 관계가 없고, 정부 기관 앱이 아닙니다. 개인정보를 수집하지 않으며 입력한 숫자는 이 기기에서만 계산됩니다. 출처: Medicare.gov, CMS(2026·2027 Part A·B·D 발표, 2027 요율 발표·MOOP 기준), 텍사스 HHSC. 마지막 확인: ",
                     "Educational guide only; not insurance sales or personal legal or financial advice. Not affiliated with any insurer or government agency. No personal data is collected; numbers you enter are calculated only on this device. Sources: Medicare.gov, CMS (2026 and 2027 Part A, B and D announcements, CY2027 Rate Announcement, MOOP standards), Texas HHSC. Last checked: ") + s.t(Figures.checked))
                .font(.footnote).foregroundStyle(Theme.muted)
            Link(s.t("개인정보 처리방침", "Privacy policy"), destination: URL(string: "https://choij1104.github.io/medicare-guide/privacy.html")!).font(.footnote)
            Text("© 2026 HAKOYA LLC").font(.footnote).foregroundStyle(Theme.muted)
        }
    }

    func dateRow(_ when: KE, _ what: KE) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "calendar").font(.title2).foregroundStyle(Theme.accent)
            VStack(alignment: .leading, spacing: 4) {
                Text(s.t(when)).font(.headline)
                Text(s.t(what))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
    }
}
