import SwiftUI

/// One piece of text in Korean and English.
struct KE: Hashable {
    let ko: String
    let en: String
    init(_ ko: String, _ en: String) { self.ko = ko; self.en = en }
}

enum Lang: String { case ko, en }

@MainActor
final class AppState: ObservableObject {
    @Published var lang: Lang { didSet { UserDefaults.standard.set(lang.rawValue, forKey: "lang") } }
    @Published var largeText: Bool { didSet { UserDefaults.standard.set(largeText, forKey: "largeText") } }
    @Published var acceptedNotice: Bool { didSet { UserDefaults.standard.set(acceptedNotice, forKey: "acceptedNotice") } }
    @Published var tab: Int = 0

    init() {
        let d = UserDefaults.standard
        if let s = d.string(forKey: "lang"), let l = Lang(rawValue: s) {
            lang = l
        } else {
            lang = (Locale.preferredLanguages.first ?? "").hasPrefix("ko") ? .ko : .en
        }
        largeText = d.object(forKey: "largeText") == nil ? true : d.bool(forKey: "largeText")
        acceptedNotice = d.bool(forKey: "acceptedNotice")
    }

    func t(_ k: KE) -> String { lang == .ko ? k.ko : k.en }
    func t(_ ko: String, _ en: String) -> String { lang == .ko ? ko : en }
    var ko: Bool { lang == .ko }
}

enum Theme {
    static let paper = Color("Paper")
    static let card = Color("Card")
    static let ink = Color("Ink")
    static let muted = Color("Muted")
    static let accent = Color("Pine")
    static let accentSoft = Color("PineSoft")
    static let warn = Color("Warn")
    static let alert = Color("Alert")
    static let ok = Color("Ok")
}

extension Font {
    static func display(_ style: Font.TextStyle) -> Font { .system(style, design: .serif).weight(.bold) }
}

func money(_ x: Double, cents: Bool = false) -> String {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = "USD"
    f.locale = Locale(identifier: "en_US")
    f.maximumFractionDigits = cents ? 2 : 0
    f.minimumFractionDigits = cents ? 2 : 0
    return f.string(from: NSNumber(value: cents ? x : x.rounded())) ?? "$\(x)"
}

// MARK: shared building blocks

struct Card<Content: View>: View {
    var tint: Color? = nil
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(tint?.opacity(0.10) ?? Theme.card, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(tint ?? Theme.muted.opacity(0.25), lineWidth: tint == nil ? 1 : 1.5))
    }
}

struct SectionTitle: View {
    let text: String
    var body: some View {
        Text(text).font(.display(.title2)).foregroundStyle(Theme.ink).padding(.top, 6)
    }
}

struct Bullet: View {
    let text: String
    var icon: String = "circle.fill"
    var tint: Color = Theme.accent
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: icon).font(icon == "circle.fill" ? .system(size: 7) : .body).foregroundStyle(tint)
            Text(text).fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct PhoneButton: View {
    @EnvironmentObject var s: AppState
    let label: KE
    let number: String
    var body: some View {
        HStack(spacing: 12) {
            Link(destination: URL(string: "tel:" + number.filter(\.isNumber))!) {
                HStack(spacing: 12) {
                    Image(systemName: "phone.fill").font(.title3).foregroundStyle(.white)
                        .frame(width: 44, height: 44).background(Theme.accent, in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(s.t(label)).font(.headline).foregroundStyle(Theme.ink)
                        Text(number).font(.title3.monospacedDigit().bold()).foregroundStyle(Theme.accent)
                    }
                }
            }
            Spacer()
            Button {
                UIPasteboard.general.string = number
            } label: {
                Image(systemName: "doc.on.doc").font(.title3)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(s.t("번호 복사", "Copy number"))
        }
    }
}

struct LangToggle: View {
    @EnvironmentObject var s: AppState
    var body: some View {
        Picker("", selection: $s.lang) {
            Text("한국어").tag(Lang.ko)
            Text("English").tag(Lang.en)
        }
        .pickerStyle(.segmented)
        .frame(width: 170)
    }
}

/// Screen scaffold: paper background, big serif title, language switch.
struct Screen<Content: View>: View {
    @EnvironmentObject var s: AppState
    let title: KE
    @ViewBuilder var content: Content
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) { content }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 32)
            }
            .background(Theme.paper.ignoresSafeArea())
            .navigationTitle(s.t(title))
            .toolbar { ToolbarItem(placement: .topBarTrailing) { LangToggle() } }
        }
    }
}

struct NumberField: View {
    let label: String
    @Binding var value: Double
    var body: some View {
        HStack {
            Text(label).font(.subheadline).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            TextField("0", value: $value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.body.monospacedDigit().bold())
                .frame(width: 110)
                .padding(8)
                .background(Theme.paper, in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct ChoiceRow<T: Hashable>: View {
    let label: String
    @Binding var selection: T
    let options: [(T, String)]
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.subheadline.bold())
            Picker(label, selection: $selection) {
                ForEach(options, id: \.0) { Text($0.1).tag($0.0) }
            }
            .pickerStyle(.menu)
            .tint(Theme.accent)
        }
    }
}
