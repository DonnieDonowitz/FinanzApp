import Foundation
import SwiftUI

struct Category: Identifiable, Codable {
    var id: Int64 = 0
    var name: String
    var icon: String
    var color: String
    var type: String
    var isDefault: Bool

    var isIncome: Bool { type == "income" }

    var displayColor: Color { Color(hex: color) }

    static let empty = Category(name: "", icon: "tag", color: "#6200EE", type: "expense", isDefault: false)
}

struct Transaction: Identifiable, Codable {
    var id: Int64 = 0
    var amount: Double
    var description: String
    var categoryId: Int64?
    var date: String
    var type: String
    var recurringId: Int64?

    var isExpense: Bool { type == "expense" }

    static let empty = Transaction(amount: 0, description: "", categoryId: nil, date: Date.currentString, type: "expense", recurringId: nil)
}

struct RecurringTransaction: Identifiable, Codable {
    var id: Int64 = 0
    var amount: Double
    var description: String
    var categoryId: Int64?
    var type: String
    var frequency: String
    var startDate: String
    var endDate: String?
    var nextDueDate: String
    var active: Bool

    var isExpense: Bool { type == "expense" }

    static let empty = RecurringTransaction(amount: 0, description: "", categoryId: nil, type: "expense", frequency: "monthly", startDate: Date.currentString, endDate: nil, nextDueDate: Date.currentString, active: true)
}

extension Date {
    static var currentString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: Date())
    }

    static var currentMonth: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: Date())
    }

    var shortIT: String {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        f.locale = Locale(identifier: "it_IT")
        return f.string(from: self)
    }

    var fullIT: String {
        let f = DateFormatter()
        f.dateFormat = "d MMMM yyyy"
        f.locale = Locale(identifier: "it_IT")
        return f.string(from: self)
    }

    var yearMonth: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: self)
    }

    init?(yyyyMMDD: String) {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        guard let d = f.date(from: yyyyMMDD) else { return nil }
        self = d
    }
}
