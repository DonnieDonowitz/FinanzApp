import SwiftUI

// MARK: - Color Scheme (matches brand kit exactly)

extension ColorScheme {
    var tinting: AppTinting.Type { self == .light ? LightTints.self : DarkTints.self }
}

protocol AppTinting {
    static var bg: Color { get }
    static var glass: Color { get }
    static var glassStrong: Color { get }
    static var glassBorder: Color { get }
    static var glassBorderStrong: Color { get }
    static var text: Color { get }
    static var textSecondary: Color { get }
    static var textTertiary: Color { get }
    static var primary: Color { get }
    static var income: Color { get }
    static var incomeLight: Color { get }
    static var expense: Color { get }
    static var expenseLight: Color { get }
    static var divider: Color { get }
    static var overlay: Color { get }
    static var tabBar: Color { get }
    static var tabBarBorder: Color { get }
    static var tabActive: Color { get }
    static var tabInactive: Color { get }
    static var shadow: Color { get }
}

// MARK: - Dark — minimal: near-black surface, one accent, flat cards (no material/blur)

enum DarkTints: AppTinting {
    static let bg = Color(hex: "#0A0A0C")
    static let glass = Color(hex: "#18181C")
    static let glassStrong = Color(hex: "#212126")
    static let glassBorder = Color.white.opacity(0.10)
    static let glassBorderStrong = Color.white.opacity(0.16)
    static let text = Color(hex: "#F5F5F7")
    static let textSecondary = Color.white.opacity(0.62)
    static let textTertiary = Color.white.opacity(0.40)
    static let primary = Color(hex: "#5B7CFF")
    static let income = Color(hex: "#34D399")
    static let incomeLight = Color(hex: "#34D399")
    static let expense = Color(hex: "#F87171")
    static let expenseLight = Color(hex: "#F87171")
    static let divider = Color.white.opacity(0.08)
    static let overlay = Color.black.opacity(0.55)
    static let tabBar = Color(hex: "#18181C")
    static let tabBarBorder = Color.white.opacity(0.10)
    static let tabActive = Color(hex: "#F5F5F7")
    static let tabInactive = Color.white.opacity(0.42)
    static let shadow = Color.black.opacity(0.35)
}

// MARK: - Light — minimal: white surface, same accent, flat cards (no material/blur)

enum LightTints: AppTinting {
    static let bg = Color(hex: "#FFFFFF")
    static let glass = Color(hex: "#F4F4F6")
    static let glassStrong = Color(hex: "#EBEBEF")
    static let glassBorder = Color.black.opacity(0.08)
    static let glassBorderStrong = Color.black.opacity(0.12)
    static let text = Color(hex: "#0B0B0F")
    static let textSecondary = Color.black.opacity(0.60)
    static let textTertiary = Color.black.opacity(0.38)
    static let primary = Color(hex: "#3D5AFE")
    static let income = Color(hex: "#16A34A")
    static let incomeLight = Color(hex: "#16A34A")
    static let expense = Color(hex: "#DC2626")
    static let expenseLight = Color(hex: "#DC2626")
    static let divider = Color.black.opacity(0.08)
    static let overlay = Color.black.opacity(0.30)
    static let tabBar = Color(hex: "#F7F7F9")
    static let tabBarBorder = Color.black.opacity(0.08)
    static let tabActive = Color(hex: "#0B0B0F")
    static let tabInactive = Color.black.opacity(0.40)
    static let shadow = Color.black.opacity(0.10)
}

// MARK: - AppColors (access via environment)

struct AppColors {
    static var T: AppTinting.Type {
        UserDefaults.standard.string(forKey: "themeMode") == "light" ? LightTints.self : DarkTints.self
    }
    static var bg: Color { T.bg }
    static var glass: Color { T.glass }
    static var glassStrong: Color { T.glassStrong }
    static var glassBorder: Color { T.glassBorder }
    static var glassBorderStrong: Color { T.glassBorderStrong }
    static var text: Color { T.text }
    static var textSecondary: Color { T.textSecondary }
    static var textTertiary: Color { T.textTertiary }
    static var primary: Color { T.primary }
    static var income: Color { T.income }
    static var incomeLight: Color { T.incomeLight }
    static var expense: Color { T.expense }
    static var expenseLight: Color { T.expenseLight }
    static var divider: Color { T.divider }
    static var overlay: Color { T.overlay }
    static var tabBar: Color { T.tabBar }
    static var tabBarBorder: Color { T.tabBarBorder }
    static var tabActive: Color { T.tabActive }
    static var tabInactive: Color { T.tabInactive }
    static var shadow: Color { T.shadow }
}

// MARK: - Color hex init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Background (flat, minimal — no gradient blobs or blur)

struct BackgroundGradient: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        AppColors.bg.ignoresSafeArea()
    }
}

// MARK: - Utilities

func getCurrentMonth() -> String {
    let f = DateFormatter(); f.dateFormat = "yyyy-MM"; f.locale = Locale(identifier: "en_US_POSIX")
    return f.string(from: Date())
}
func getCurrentDate() -> String {
    let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
    return f.string(from: Date())
}
func formatDateShort(_ dateStr: String) -> String {
    let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
    guard let d = f.date(from: dateStr) else { return dateStr }
    let f2 = DateFormatter(); f2.dateFormat = "dd MMM"; f2.locale = Locale(identifier: AppSettingsStore.currentLanguage.localeIdentifier)
    return f2.string(from: d)
}
func formatDate(_ dateStr: String) -> String {
    let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
    guard let d = f.date(from: dateStr) else { return dateStr }
    let f2 = DateFormatter(); f2.dateFormat = "dd MMMM yyyy"; f2.locale = Locale(identifier: AppSettingsStore.currentLanguage.localeIdentifier)
    return f2.string(from: d)
}
func formatCurrency(_ amount: Double) -> String {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = AppSettingsStore.currencyCode
    f.locale = Locale(identifier: AppSettingsStore.currentLanguage.localeIdentifier)
    return f.string(from: NSNumber(value: amount)) ?? "\(AppSettingsStore.currentCurrencySymbol)0"
}
func frequencyLabel(_ frequency: String) -> String {
    switch frequency {
    case "daily": return L.daily
    case "weekly": return L.weekly
    case "monthly": return L.monthly
    case "yearly": return L.yearly
    default: return frequency
    }
}

let IT_MONTHS_SHORT = ["Gen","Feb","Mar","Apr","Mag","Giu","Lug","Ago","Set","Ott","Nov","Dic"]
let IT_MONTHS_FULL = ["Gennaio","Febbraio","Marzo","Aprile","Maggio","Giugno","Luglio","Agosto","Settembre","Ottobre","Novembre","Dicembre"]

// MARK: - Category icon mapping (SF Symbols, minimal liquid-glass style)

let CATEGORY_ICONS: [String: String] = [
    "Alimentari": "cart.fill", "Spesa": "cart.fill",
    "Trasporti": "fuelpump.fill", "Carburante": "fuelpump.fill",
    "Abitazione": "house.fill", "Casa": "house.fill",
    "Salute": "cross.case.fill", "Medicina": "cross.case.fill",
    "Intrattenimento": "film.fill", "Svago": "film.fill",
    "Abbigliamento": "tshirt.fill",
    "Educazione": "book.fill", "Scuola": "book.fill",
    "Ristoranti": "fork.knife", "Cena fuori": "fork.knife",
    "Bollette": "bolt.fill", "Energia": "bolt.fill",
    "Stipendio": "briefcase.fill", "Lavoro": "briefcase.fill",
    "Freelance": "laptopcomputer",
    "Investimenti": "chart.line.uptrend.xyaxis", "Investimento": "chart.line.uptrend.xyaxis",
    "Altro": "shippingbox.fill",
    "Affitto": "house.fill",
    "Palestra": "dumbbell.fill", "Sport": "dumbbell.fill",
    "Netflix": "film.fill",
    "Spotify Family": "music.note", "Musica": "music.note",
    "iCloud+ 200GB": "icloud.fill", "Cloud": "icloud.fill",
    "Il Post — abbonamento": "newspaper.fill",
    "Q8 Distributore": "fuelpump.fill",
]

func categoryIcon(_ name: String) -> String {
    CATEGORY_ICONS[name] ?? "tag.fill"
}

/// Curated SF Symbol choices offered when creating/editing a category, in the same
/// filled "liquid glass" style as the built-in category icons.
let CATEGORY_ICON_CHOICES: [String] = [
    "tag.fill", "cart.fill", "basket.fill", "fork.knife", "cup.and.saucer.fill",
    "takeoutbag.and.cup.and.straw.fill", "wineglass.fill",
    "house.fill", "building.2.fill", "key.fill", "bed.double.fill", "sofa.fill",
    "fuelpump.fill", "car.fill", "bus.fill", "tram.fill", "airplane", "bicycle",
    "figure.walk", "parkingsign", "fanblades.fill",
    "cross.case.fill", "pills.fill", "heart.fill", "figure.run", "dumbbell.fill",
    "stethoscope", "bandage.fill",
    "film.fill", "gamecontroller.fill", "popcorn.fill", "music.note", "ticket.fill",
    "sparkles.tv.fill", "theatermasks.fill",
    "tshirt.fill", "bag.fill", "shoe.fill", "eyeglasses",
    "book.fill", "graduationcap.fill", "pencil", "paintbrush.fill",
    "bolt.fill", "flame.fill", "drop.fill", "wifi", "tv.fill", "washer.fill",
    "briefcase.fill", "laptopcomputer", "desktopcomputer", "printer.fill",
    "chart.line.uptrend.xyaxis", "banknote.fill", "creditcard.fill", "dollarsign.circle.fill",
    "building.columns.fill", "safari.fill", "gift.fill", "pawprint.fill",
    "leaf.fill", "globe.europe.africa.fill", "phone.fill", "envelope.fill",
    "camera.fill", "photo.fill", "guitars.fill", "sportscourt.fill",
    "baby.carriage.fill", "shield.fill", "umbrella.fill", "wrench.and.screwdriver.fill",
    "hammer.fill", "scissors", "person.2.fill", "cloud.fill", "star.fill",
    "shippingbox.fill", "checklist", "calendar", "clock.fill",
]

/// Resolves the icon to display for a category: a user-picked custom icon (typically an
/// emoji typed via the keyboard) takes priority over the built-in SF Symbol name mapping.
func resolvedIcon(for category: Category?) -> String {
    guard let category else { return "tag.fill" }
    if !category.icon.isEmpty, category.icon != "tag" { return category.icon }
    return categoryIcon(category.name)
}

/// SF Symbol names are plain ASCII (letters, digits, dots); anything else (emoji, etc.)
/// is treated as a literal custom icon typed by the user.
func isSFSymbolName(_ value: String) -> Bool {
    !value.isEmpty && value.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == ".") }
}

/// Renders a category icon that may be either an SF Symbol or a custom emoji/character.
struct CategoryIconView: View {
    let icon: String
    var size: CGFloat = 16
    var weight: Font.Weight = .medium

    var body: some View {
        if isSFSymbolName(icon) {
            Image(systemName: icon).font(.system(size: size, weight: weight))
        } else {
            Text(icon).font(.system(size: size * 1.2))
        }
    }
}
