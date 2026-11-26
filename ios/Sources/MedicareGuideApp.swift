import SwiftUI

@main
struct MedicareGuideApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(state)
                .dynamicTypeSize(state.largeText ? .xLarge : .large)
                .tint(Theme.accent)
                .onAppear {
                    // Launch argument used only by the CI screenshot step (-tab N).
                    let d = UserDefaults.standard
                    if d.object(forKey: "tab") != nil { state.tab = d.integer(forKey: "tab") }
                }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var s: AppState

    var body: some View {
        TabView(selection: $s.tab) {
            BasicsView()
                .tabItem { Label(s.t("기본", "Basics"), systemImage: "book.closed") }.tag(0)
            CompareView()
                .tabItem { Label(s.t("비교", "Compare"), systemImage: "arrow.left.arrow.right") }.tag(1)
            FitView()
                .tabItem { Label(s.t("내게 맞는", "My fit"), systemImage: "person.crop.circle.badge.questionmark") }.tag(2)
            HelpPayView()
                .tabItem { Label(s.t("지원", "Help paying"), systemImage: "hands.and.sparkles") }.tag(3)
            ContactsView()
                .tabItem { Label(s.t("사기·연락처", "Scams & phones"), systemImage: "phone.badge.checkmark") }.tag(4)
        }
        .fullScreenCover(isPresented: Binding(get: { !s.acceptedNotice }, set: { _ in })) {
            NoticeView().environmentObject(s)
        }
    }
}

struct NoticeView: View {
    @EnvironmentObject var s: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack { Spacer(); LangToggle() }
                Text(s.t("메디케어 길라잡이", "Medicare Guide")).font(.system(size: 38, weight: .bold, design: .serif)).foregroundStyle(Theme.accent)
                Text(s.t("에이전트 없이 혼자서도 이해하는 메디케어", "Understand Medicare on your own, without a sales agent")).font(.title3)
                Card {
                    Bullet(text: s.t("이 앱은 교육용 안내입니다. 보험을 팔지 않고, 어떤 보험사와도 관계가 없습니다.", "This is an educational guide. It sells no insurance and is not affiliated with any insurer."))
                    Bullet(text: s.t("정부 기관(메디케어, CMS, 소셜시큐리티)의 앱이 아닙니다. 공식 결정은 그 기관들이 합니다.", "It is not an app of Medicare, CMS or Social Security. Official decisions come from those agencies."))
                    Bullet(text: s.t("개인 법률·재정 자문이 아닙니다. 결정 전 텍사스 HICAP(1-800-252-9240) 무료 상담을 받으세요.", "It is not personal legal or financial advice. Talk to Texas HICAP (1-800-252-9240, free) before deciding."))
                    Bullet(text: s.t("이름, 번호, 소득 등 아무 정보도 저장하거나 보내지 않습니다.", "It stores or sends no names, numbers or income."))
                }
                Button {
                    s.acceptedNotice = true
                } label: {
                    Text(s.t("이해했습니다. 시작하기", "I understand. Start")).font(.title3.bold()).frame(maxWidth: .infinity, minHeight: 56)
                }
                .buttonStyle(.borderedProminent).tint(Theme.accent)
            }
            .padding(22)
        }
        .background(Theme.paper.ignoresSafeArea())
        .dynamicTypeSize(s.largeText ? .xLarge : .large)
    }
}
