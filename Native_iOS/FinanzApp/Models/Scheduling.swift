import Foundation

enum Scheduling {
    static func getNextDueDate(currentDueDate: String, frequency: String) -> String {
        guard var date = Date(yyyyMMDD: currentDueDate) else { return currentDueDate }
        switch frequency {
        case "daily":  date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
        case "weekly": date = Calendar.current.date(byAdding: .day, value: 7, to: date) ?? date
        case "monthly": date = Calendar.current.date(byAdding: .month, value: 1, to: date) ?? date
        case "yearly": date = Calendar.current.date(byAdding: .year, value: 1, to: date) ?? date
        default: break
        }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: date)
    }

    static func isDue(_ nextDueDate: String) -> Bool {
        return nextDueDate <= Date.currentString
    }

    static func frequencyLabel(_ frequency: String) -> String {
        switch frequency {
        case "daily": return "Giornaliero"
        case "weekly": return "Settimanale"
        case "monthly": return "Mensile"
        case "yearly": return "Annuale"
        default: return frequency
        }
    }
}
