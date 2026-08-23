import WidgetKit
import SwiftUI
import SQLite3

// MARK: - Shared Data Access for Widget

struct WidgetData {
    static let appGroupID = "group.com.finanzapp.app"

    static var sharedDBPath: String? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("finanzapp.db").path
    }

    static func currentMonthTotals() -> (income: Double, expense: Double, balance: Double) {
        guard let path = sharedDBPath else { return (0, 0, 0) }
        var db: OpaquePointer?
        guard sqlite3_open(path, &db) == SQLITE_OK else { return (0, 0, 0) }
        defer { sqlite3_close(db) }

        let month = currentMonthString()
        let sql = "SELECT type, SUM(amount) FROM transactions WHERE date LIKE ? GROUP BY type"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return (0, 0, 0) }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (month + "%").withCString { $0 }, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))

        var income = 0.0, expense = 0.0
        while sqlite3_step(stmt) == SQLITE_ROW {
            let type = String(cString: sqlite3_column_text(stmt, 0))
            let sum = sqlite3_column_double(stmt, 1)
            if type == "income" { income = sum } else { expense = sum }
        }
        return (income, expense, income - expense)
    }

    static func monthlyBudget() -> Double {
        guard let path = sharedDBPath else { return 0 }
        var db: OpaquePointer?
        guard sqlite3_open(path, &db) == SQLITE_OK else { return 0 }
        defer { sqlite3_close(db) }

        let sql = "SELECT value FROM app_settings WHERE key = 'monthly_budget'"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return 0 }
        defer { sqlite3_finalize(stmt) }

        guard sqlite3_step(stmt) == SQLITE_ROW, let cStr = sqlite3_column_text(stmt, 0) else { return 0 }
        return Double(String(cString: cStr)) ?? 0
    }

    static func transactionCount() -> Int {
        guard let path = sharedDBPath else { return 0 }
        var db: OpaquePointer?
        guard sqlite3_open(path, &db) == SQLITE_OK else { return 0 }
        defer { sqlite3_close(db) }

        let sql = "SELECT COUNT(*) FROM transactions WHERE date LIKE ?"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return 0 }
        defer { sqlite3_finalize(stmt) }

        let month = currentMonthString()
        sqlite3_bind_text(stmt, 1, (month + "%").withCString { $0 }, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))

        if sqlite3_step(stmt) == SQLITE_ROW { return Int(sqlite3_column_int(stmt, 0)) }
        return 0
    }

    static func topExpenseCategories() -> [(name: String, color: String, icon: String, amount: Double)] {
        guard let path = sharedDBPath else { return [] }
        var db: OpaquePointer?
        guard sqlite3_open(path, &db) == SQLITE_OK else { return [] }
        defer { sqlite3_close(db) }

        let month = currentMonthString()
        let sql = """
        SELECT c.name, c.color, c.icon, SUM(t.amount) as total
        FROM transactions t LEFT JOIN categories c ON t.category_id = c.id
        WHERE t.type = 'expense' AND t.date LIKE ?
        GROUP BY t.category_id ORDER BY total DESC LIMIT 3
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (month + "%").withCString { $0 }, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))

        var results: [(String, String, String, Double)] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            let name = String(cString: sqlite3_column_text(stmt, 0))
            let color = String(cString: sqlite3_column_text(stmt, 1))
            let icon = String(cString: sqlite3_column_text(stmt, 2))
            let amount = sqlite3_column_double(stmt, 3)
            results.append((name, color, resolvedWidgetIcon(name: name, storedIcon: icon), amount))
        }
        return results
    }

    /// A custom icon the user picked (typically an emoji) takes priority; built-in categories
    /// fall back to a small curated emoji map so the widget still looks right without SF Symbols.
    private static func resolvedWidgetIcon(name: String, storedIcon: String) -> String {
        if !storedIcon.isEmpty, storedIcon != "tag" { return storedIcon }
        return widgetCategoryEmoji[name] ?? "🏷️"
    }

    private static let widgetCategoryEmoji: [String: String] = [
        "Alimentari": "🛒", "Trasporti": "⛽", "Abitazione": "🏠", "Salute": "⚕️",
        "Intrattenimento": "🎬", "Abbigliamento": "👕", "Educazione": "📚", "Ristoranti": "🍽️",
        "Bollette": "⚡️", "Altro": "📦", "Stipendio": "💼", "Freelance": "💻", "Investimenti": "📈",
    ]

    private static func currentMonthString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: Date())
    }
}

// MARK: - Shared settings (App Group container, written by the main app)

private let sharedSettingsDefaults = UserDefaults(suiteName: WidgetData.appGroupID) ?? .standard

/// The widget runs in its own process and can't see the app's `@AppStorage`/`UserDefaults.standard`
/// theme toggle, only the App Group suite the app mirrors it into — so the widget follows the
/// app's own light/dark preference instead of the system-wide appearance.
var sharedIsDarkMode: Bool {
    sharedSettingsDefaults.string(forKey: "themeMode") != "light"
}

private let widgetLocaleIdentifiers = ["it": "it_IT", "en": "en_US", "de": "de_DE", "fr": "fr_FR", "es": "es_ES"]

private var widgetLocale: Locale {
    let code = sharedSettingsDefaults.string(forKey: "languageCode") ?? "en"
    return Locale(identifier: widgetLocaleIdentifiers[code] ?? "en_US")
}

// MARK: - Currency Formatter

func widgetCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = sharedSettingsDefaults.string(forKey: "currencyCode") ?? "EUR"
    formatter.locale = widgetLocale
    return formatter.string(from: NSNumber(value: amount)) ?? "€0,00"
}

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
