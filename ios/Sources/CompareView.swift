import SwiftUI

struct CompareView: View {
    @EnvironmentObject var s: AppState

    var body: some View {
        Screen(title: KE("두 가지 길", "Two paths")) {
            Text(s.t("65세가 되면 크게 두 길 중 하나를 고릅니다. 둘 다 동시에 가질 수는 없습니다.",
                     "At 65 you choose one of two main paths. You cannot have both at once."))
                .font(.title3)

            path(title: KE("길 1 · 오리지널 메디케어 + 서플먼트(메디갭) + Part D", "Path 1 · Original Medicare + Supplement (Medigap) + Part D"),
                 icon: "map", tint: Theme.accent, points: [
                    KE("메디케어를 받는 미국 내 어느 의사·병원이든 갈 수 있습니다. 네트워크 제한이 없습니다.", "Any doctor or hospital in the U.S. that takes Medicare. No network."),
                    KE("보통 사전승인(prior authorization)이 적습니다.", "Usually fewer prior-authorization hurdles."),
                    KE("서플먼트가 A·B의 20% 본인부담 등 \"구멍\"을 메워줍니다. 예: Plan G는 Part B 디덕티블만 빼고 대부분을 냅니다. Plan F는 2020년 이전에 메디케어 자격이 있던 분만 가입할 수 있습니다.", "The supplement fills A and B's gaps, like the 20% coinsurance. Plan G covers nearly all of it except the Part B deductible. Plan F is only for people eligible before 2020."),
                    KE("서플먼트는 약을 보장하지 않습니다. Part D를 따로 들어야 합니다.", "Supplements don't cover drugs. You need a separate Part D plan."),
                    KE("월 보험료가 높은 편이지만, 큰 병이 난 해에도 비용이 예측 가능합니다.", "Higher monthly premiums, but costs stay predictable even in a bad health year."),
                 ], fit: KE("맞는 분: 약이나 진료가 많은 분, 여러 전문의를 보는 분, 텍사스 밖(예: 자녀 집)에 자주 머무는 분.", "Good fit: heavy medical use, many specialists, frequent time outside Texas."))

            path(title: KE("길 2 · 메디케어 어드밴티지(Part C)", "Path 2 · Medicare Advantage (Part C)"),
                 icon: "building.2", tint: Theme.warn, points: [
                    KE("민간 보험사 플랜 하나로 A·B·대부분 D까지. 치과·안경·보청기 혜택이 붙기도 합니다.", "One private plan for A, B and usually D. Some add dental, vision or hearing extras."),
                    KE("보험료가 낮거나 $0인 경우가 많습니다. 그래도 Part B 보험료는 계속 냅니다.", "Premiums are often low or $0. You still pay the Part B premium."),
                    KE("네트워크가 있습니다. HMO는 대개 네트워크 밖 진료를 보장하지 않습니다.", "Networks apply. HMOs usually don't cover out-of-network care."),
                    KE("사전승인이 필요한 경우가 많습니다.", "Prior authorization is common."),
                    KE("연간 본인부담 상한이 있습니다. 2027년 최대 $9,850(네트워크 안).", "Yearly out-of-pocket cap: up to $9,850 in-network in 2027."),
                 ], fit: KE("맞는 분: 비교적 건강하고, 다니는 의사가 플랜 네트워크 안에 있으며, 월 보험료를 낮추고 싶은 분.", "Good fit: fairly healthy, your doctors are in the network, you want low monthly costs."))

            SectionTitle(text: s.t("한눈에 비교", "Side by side"))
            VStack(spacing: 0) {
                HStack {
                    Text("").frame(width: 92, alignment: .leading)
                    Text(s.t("오리지널 + 서플먼트", "Original + Supplement")).frame(maxWidth: .infinity, alignment: .leading)
                    Text(s.t("어드밴티지", "Advantage")).frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.subheadline.bold()).padding(12).background(Theme.accentSoft)
                ForEach(rows, id: \.0.en) { r in
                    HStack(alignment: .top) {
                        Text(s.t(r.0)).font(.subheadline.bold()).frame(width: 92, alignment: .leading)
                        Text(s.t(r.1)).frame(maxWidth: .infinity, alignment: .leading)
                        Text(s.t(r.2)).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.subheadline).padding(12)
                    Divider()
                }
            }
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Card(tint: Theme.alert) {
                Label(s.t("가장 중요한 경고: 서플먼트 가입 시기", "Most important warning: when to buy a supplement"), systemImage: "exclamationmark.triangle.fill")
                    .font(.headline).foregroundStyle(Theme.alert)
                Text(s.t("65세 이상이면서 Part B가 시작된 달부터 6개월이 서플먼트 \"개방 가입 기간\"입니다. 이 기간에는 건강 상태 때문에 거절당하거나 더 비싸게 낼 수 없습니다. 이 기간이 지나면 보험사가 건강 질문을 하고 거절하거나 보험료를 올릴 수 있습니다. 그래서 \"일단 어드밴티지로 갔다가 나중에 서플먼트로 바꾸자\"가 생각처럼 쉽지 않을 수 있습니다. 바꾸기 전에 꼭 텍사스 무료 상담(HICAP)에 확인하세요.",
                         "Your Medigap Open Enrollment Period is the 6 months starting the month you are 65 or older and enrolled in Part B. During it, companies can't refuse you or charge more for health problems. After it, they can generally ask health questions and refuse or charge more. So \"start with Advantage and switch to a supplement later\" may not work. Check with Texas HICAP (free) before you switch."))
            }
        }
    }

    let rows: [(KE, KE, KE)] = [
        (KE("의사 선택", "Doctors"), KE("메디케어 받는 곳 어디든", "Anyone who takes Medicare"), KE("네트워크 안", "In the network")),
        (KE("월 보험료", "Monthly premium"), KE("높은 편", "Higher"), KE("낮거나 $0", "Low or $0")),
        (KE("아플 때 최악의 비용", "Worst-case year"), KE("낮고 예측 가능", "Low and predictable"), KE("상한까지(최대 $9,850)", "Up to the cap ($9,850 max)")),
        (KE("약 보장", "Drugs"), KE("Part D 따로 가입", "Separate Part D"), KE("대부분 포함", "Usually included")),
        (KE("사전승인", "Prior authorization"), KE("적음", "Less"), KE("많음", "More")),
        (KE("나중에 바꾸기", "Switching later"), KE("아래 경고 참고", "See the warning below"), KE("아래 경고 참고", "See the warning below")),
    ]

    func path(title: KE, icon: String, tint: Color, points: [KE], fit: KE) -> some View {
        Card {
            Label(s.t(title), systemImage: icon).font(.display(.title3)).foregroundStyle(tint)
            ForEach(points, id: \.en) { Bullet(text: s.t($0), tint: tint) }
            Text(s.t(fit)).font(.subheadline.bold())
                .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
        }
    }
}
