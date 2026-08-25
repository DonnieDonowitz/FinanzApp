import Foundation

/// Level/XP are never persisted — they're always recomputed from `transactions` and the
/// current `monthly_budget` setting, so editing/deleting transactions, importing a CSV, or
/// restoring an old `.finanz` backup just makes the level recompute itself with no migration
/// step needed.
enum Gamification {
    static let maxLevel = 100

    /// Once the per-level XP requirement (Fibonacci-scaled) would exceed this, it stays flat
    /// instead of continuing to grow — otherwise a pure Fibonacci curve would make level 100
    /// require billions of XP, an unreachable number for a real household budget.
    private static let incrementCap = 8000

    /// 1-indexed Fibonacci: fib(1) = fib(2) = 1, fib(3) = 2, fib(4) = 3, fib(5) = 5, fib(6) = 8, ...
    private static func fib(_ n: Int) -> Int {
        guard n > 0 else { return 0 }
        var a = 0, b = 1
        for _ in 0..<n { (a, b) = (b, a + b) }
        return a
    }

    /// XP required to go from `level` to `level + 1`.
    static func increment(forLevel level: Int) -> Int {
        min(fib(level) * 1000, incrementCap)
    }

    /// Total XP needed, starting fresh at level 1 with 0 XP, to reach `level`.
    static func cumulativeXP(toReachLevel level: Int) -> Double {
        guard level > 1 else { return 0 }
        var total = 0
        for l in 1..<level { total += increment(forLevel: l) }
        return Double(total)
    }

    struct LevelInfo {
        let level: Int
        let xpIntoLevel: Double
        /// XP needed to reach the next level; `nil` once `level == maxLevel`.
        let xpForNextLevel: Double?
        /// 0...1 progress toward the next level; pinned to 1.0 at `maxLevel`.
        let progress: Double
    }

    static func levelInfo(forXP xp: Double) -> LevelInfo {
        let clamped = max(0, xp)
        var level = 1
        while level < maxLevel && cumulativeXP(toReachLevel: level + 1) <= clamped {
            level += 1
        }
        let currentThreshold = cumulativeXP(toReachLevel: level)
        let xpIntoLevel = clamped - currentThreshold
        guard level < maxLevel else {
            return LevelInfo(level: level, xpIntoLevel: xpIntoLevel, xpForNextLevel: nil, progress: 1.0)
        }
        let xpForNext = Double(increment(forLevel: level))
        let progress = xpForNext > 0 ? min(1.0, xpIntoLevel / xpForNext) : 1.0
        return LevelInfo(level: level, xpIntoLevel: xpIntoLevel, xpForNextLevel: xpForNext, progress: progress)
    }

    /// XP earned/lost for a single month, combining two components. Returns 0 if no budget is
    /// configured yet.
    /// - Spending discipline: +5 XP per euro spent under budget, -1 XP per euro spent over.
    /// - Earnings bonus: +1 XP per euro of income beyond the budget (e.g. earn 1000, budget
    ///   500 → 500 euro "avanzano" → +500 XP), but only when the month's actual balance
    ///   (income - spent) is still positive — earning a lot doesn't earn a bonus if it was
    ///   all spent (or overspent) anyway.
    static func monthXP(income: Double, spent: Double, budget: Double) -> Double {
        guard budget > 0 else { return 0 }
        let spendXP = spent <= budget ? (budget - spent) * 5 : -(spent - budget)
        let balance = income - spent
        let earningsBonusXP = (income > budget && balance > 0) ? income - budget : 0
        return spendXP + earningsBonusXP
    }

    /// Lifetime total XP across every calendar month that has at least one transaction,
    /// evaluated against the current budget. Clamped to a minimum of 0.
    static func totalXP(transactions: [Transaction], budget: Double) -> Double {
        guard budget > 0 else { return 0 }
        var months = Set<String>()
        var expenseByMonth: [String: Double] = [:]
        var incomeByMonth: [String: Double] = [:]
        for t in transactions {
            guard t.date.count >= 7 else { continue }
            let month = String(t.date.prefix(7))
            months.insert(month)
            if t.type == "expense" {
                expenseByMonth[month, default: 0] += t.amount
            } else {
                incomeByMonth[month, default: 0] += t.amount
            }
        }
        let sum = months.reduce(0.0) { acc, month in
            acc + monthXP(income: incomeByMonth[month] ?? 0, spent: expenseByMonth[month] ?? 0, budget: budget)
        }
        return max(0, sum)
    }
}
