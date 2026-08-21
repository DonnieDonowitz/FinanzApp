import SwiftUI

enum StatsPeriod: String, CaseIterable {
    case week, month, year

    var label: String {
        switch self {
        case .week: return L.week
        case .month: return L.month
        case .year: return L.year
        }
    }
}

struct StatisticsView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var period: StatsPeriod = .month
    @State private var stats = StatsSnapshot()

    private static let ymdFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private func ymd(_ date: Date) -> String { Self.ymdFormatter.string(from: date) }

    private var analysisTitle: String {
        switch period {
        case .week: return L.weeklyAnalysis
        case .month: return L.monthlyAnalysis
        case .year: return L.annualAnalysis
        }
    }

    private struct RatioPoint { let label: String; let ratio: Double }
    private struct BarData { let label: String; let incomeH: CGFloat; let expenseH: CGFloat }

    private struct StatsSnapshot {
        var dateRangeLabel: String = ""
        var balance: Double = 0
        var balanceDeltaPercent: Double? = nil
        var categoryBreakdown: [(name: String, amount: Double, pct: Double)] = []
        var ratioTrend: [RatioPoint] = []
        var barData: [BarData] = []
        var currentPeriodRatio: Double = 0
        var previousBucketRatio: Double = 0
        var ratioDeltaPoints: Double = 0
        var currentBucketIndex: Int? = nil
    }

    /// Computes every derived statistic for the selected period in a single pass over
    /// `vm.transactions`. Previously each stat below was its own computed property, several of
    /// which were read multiple times per body evaluation (e.g. `ratioTrend` from up to 5 call
    /// sites); each read re-filtered the *entire* transaction list from scratch, and the bucketed
    /// charts re-filtered it once per bucket on top of that. With a real-sized transaction
    /// history that added up to hundreds of full-array scans (plus fresh `DateFormatter`
    /// instances) per render, which is what froze this screen. Now it's one pass, cached in
    /// `stats`, only redone when the period changes or the view appears.
    private func computeStats() -> StatsSnapshot {
        let cal = Calendar.current
        let now = Date()

        let rangeStart: String, rangeEnd: String, rangeLabel: String
        let prevStart: String, prevEnd: String
        var bucketLabels: [String] = []
        var weekDayIndex: [String: Int] = [:]

        switch period {
        case .week:
            let interval = cal.dateInterval(of: .weekOfYear, for: now)
            let start = interval?.start ?? now
            let end = interval.map { cal.date(byAdding: .day, value: -1, to: $0.end) ?? $0.end } ?? now
            rangeStart = ymd(start); rangeEnd = ymd(end)
            rangeLabel = "\(formatDateShort(rangeStart)) – \(formatDateShort(rangeEnd))"

            let prevBase = cal.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            let prevInterval = cal.dateInterval(of: .weekOfYear, for: prevBase)
            let pStart = prevInterval?.start ?? prevBase
            let pEnd = prevInterval.map { cal.date(byAdding: .day, value: -1, to: $0.end) ?? $0.end } ?? prevBase
            prevStart = ymd(pStart); prevEnd = ymd(pEnd)

            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            dayFormatter.locale = Locale(identifier: AppSettingsStore.currentLanguage.localeIdentifier)
            for i in 0..<7 {
                guard let day = cal.date(byAdding: .day, value: i, to: start) else { continue }
                weekDayIndex[ymd(day)] = i
                bucketLabels.append(dayFormatter.string(from: day))
            }

        case .month:
            let y = cal.component(.year, from: now)
            let m = cal.component(.month, from: now)
            let mm = String(format: "%02d", m)
            let lastDay = cal.range(of: .day, in: .month, for: now)?.count ?? 30
            rangeStart = "\(y)-\(mm)-01"
            rangeEnd = "\(y)-\(mm)-\(String(format: "%02d", lastDay))"
            rangeLabel = L.monthsShort[m - 1]

            let prevBase = cal.date(byAdding: .month, value: -1, to: now) ?? now
            let py = cal.component(.year, from: prevBase)
            let pm = cal.component(.month, from: prevBase)
            let pmm = String(format: "%02d", pm)
            let pLastDay = cal.range(of: .day, in: .month, for: prevBase)?.count ?? 30
            prevStart = "\(py)-\(pmm)-01"
            prevEnd = "\(py)-\(pmm)-\(String(format: "%02d", pLastDay))"

            var start = 1
            while start <= lastDay {
                let end = min(start + 6, lastDay)
                bucketLabels.append("\(start)")
                start = end + 1
            }

        case .year:
            let y = cal.component(.year, from: now)
            rangeStart = "\(y)-01-01"; rangeEnd = "\(y)-12-31"; rangeLabel = "\(y)"
            prevStart = "\(y - 1)-01-01"; prevEnd = "\(y - 1)-12-31"
            bucketLabels = L.monthsShort
        }

        let bucketCount = bucketLabels.count
        var bucketIncome = [Double](repeating: 0, count: bucketCount)
        var bucketExpense = [Double](repeating: 0, count: bucketCount)
        var income = 0.0, expense = 0.0
        var prevIncome = 0.0, prevExpense = 0.0
        var categoryTotals: [Int64: Double] = [:]
        var uncategorizedTotal = 0.0

        for tx in vm.transactions {
            let d = tx.date
            if d >= rangeStart && d <= rangeEnd {
                if tx.type == "income" {
                    income += tx.amount
                } else {
                    expense += tx.amount
                    if let cid = tx.categoryId { categoryTotals[cid, default: 0] += tx.amount }
                    else { uncategorizedTotal += tx.amount }
                }
                if bucketCount > 0, let idx = bucketIndex(for: d, period: period, weekDayIndex: weekDayIndex, bucketCount: bucketCount) {
                    if tx.type == "income" { bucketIncome[idx] += tx.amount } else { bucketExpense[idx] += tx.amount }
                }
            } else if d >= prevStart && d <= prevEnd {
                if tx.type == "income" { prevIncome += tx.amount } else { prevExpense += tx.amount }
            }
        }

        let balance = income - expense
        let prevBalance = prevIncome - prevExpense
        let balanceDelta: Double? = prevBalance != 0 ? (balance - prevBalance) / abs(prevBalance) * 100 : nil

        var breakdown: [(name: String, amount: Double, pct: Double)] = categoryTotals.map { id, amount in
            (name: vm.categoryById(id)?.name ?? L.categories, amount: amount, pct: expense > 0 ? amount / expense * 100 : 0)
        }
        if uncategorizedTotal > 0 {
            breakdown.append((name: L.categories, amount: uncategorizedTotal, pct: expense > 0 ? uncategorizedTotal / expense * 100 : 0))
        }
        breakdown.sort { $0.amount > $1.amount }

        let ratioTrend: [RatioPoint] = (0..<bucketCount).map { i in
            let inc = bucketIncome[i], exp = bucketExpense[i]
            let ratio = inc > 0 ? exp / inc : (exp > 0 ? 1 : 0)
            return RatioPoint(label: bucketLabels[i], ratio: ratio)
        }

        let maxTotal = max((0..<bucketCount).map { bucketIncome[$0] + bucketExpense[$0] }.max() ?? 1, 1)
        let capHeight: CGFloat = 80
        let barData: [BarData] = (0..<bucketCount).map { i in
            BarData(label: bucketLabels[i],
                    incomeH: CGFloat(bucketIncome[i] / maxTotal) * capHeight,
                    expenseH: CGFloat(bucketExpense[i] / maxTotal) * capHeight)
        }

        // The headline ratio is the whole selected period's expense/income (mirrors how
        // `balance` above is computed), not just the last bucket's — the last bucket only
        // happens to represent "now" when today is the final day of the period, which made
        // this read as a permanent 0% any other day of the week/month/year.
        let currentRatio = income > 0 ? expense / income : (expense > 0 ? 1 : 0)
        let prevRatio = prevIncome > 0 ? prevExpense / prevIncome : (prevExpense > 0 ? 1 : 0)
        let todayBucket = bucketCount > 0 ? bucketIndex(for: ymd(now), period: period, weekDayIndex: weekDayIndex, bucketCount: bucketCount) : nil

        return StatsSnapshot(
            dateRangeLabel: rangeLabel,
            balance: balance,
            balanceDeltaPercent: balanceDelta,
            categoryBreakdown: breakdown,
            ratioTrend: ratioTrend,
            barData: barData,
            currentPeriodRatio: currentRatio,
            previousBucketRatio: prevRatio,
            ratioDeltaPoints: (currentRatio - prevRatio) * 100,
            currentBucketIndex: todayBucket
        )
    }

    private func bucketIndex(for date: String, period: StatsPeriod, weekDayIndex: [String: Int], bucketCount: Int) -> Int? {
        switch period {
        case .week:
            return weekDayIndex[date]
        case .month:
            guard date.count == 10, let day = Int(date.suffix(2)) else { return nil }
            let idx = (day - 1) / 7
            return min(idx, bucketCount - 1)
        case .year:
            guard date.count == 10, let month = Int(date.dropFirst(5).prefix(2)) else { return nil }
            let idx = month - 1
            return idx >= 0 && idx < bucketCount ? idx : nil
        }
    }

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            BackgroundGradient()
            ScrollView {
            VStack(spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(analysisTitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColors.textSecondary)
                            .tracking(0.3)
                        Text(L.statistics)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(AppColors.text)
                            .tracking(-0.2)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)

                // Segmented control (brand kit pill style)
                HStack(spacing: 4) {
                    ForEach(StatsPeriod.allCases, id: \.self) { p in
                        Text(p.label)
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundStyle(period == p ? Color(hex: "#0B1120") : AppColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(period == p ? Color.white.opacity(0.9) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .onTapGesture { withAnimation { period = p } }
                    }
                }
                .padding(4)
                .background(AppColors.glass)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 18)

                // Chart card (brand kit style)
                GlassView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(L.netSavings) · \(stats.dateRangeLabel.uppercased())")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.textSecondary)

                        Text(formatCurrency(stats.balance))
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundStyle(stats.balance >= 0 ? AppColors.income : AppColors.expense)
                            .tracking(-0.3)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        if let delta = stats.balanceDeltaPercent {
                            Text("\(delta >= 0 ? "▲" : "▼") \(String(format: "%.0f", abs(delta)))% \(L.vsPreviousPeriod)")
                                .font(.system(size: 12.5, weight: .bold))
                                .foregroundStyle(delta >= 0 ? AppColors.incomeLight : AppColors.expenseLight)
                        }

                        // Stacked bar chart
                        HStack(alignment: .bottom, spacing: 10) {
                            ForEach(Array(stats.barData.enumerated()), id: \.offset) { _, b in
                                VStack(spacing: 8) {
                                    VStack(spacing: 3) {
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(LinearGradient(colors: [Color(hex: "#5CFFCB"), Color(hex: "#17C899")],
                                                                 startPoint: .top, endPoint: .bottom))
                                            .frame(height: b.incomeH)
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(LinearGradient(colors: [Color(hex: "#FF9B9B"), Color(hex: "#FF5C5C")],
                                                                 startPoint: .top, endPoint: .bottom))
                                            .frame(height: b.expenseH)
                                    }
                                    .frame(height: 96, alignment: .bottom)

                                    Text(b.label)
                                        .font(.system(size: 10.5, weight: .bold))
                                        .foregroundStyle(AppColors.textTertiary)
                                }
                            }
                        }
                        .padding(.top, 10)

                        HStack(spacing: 16) {
                            HStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .fill(Color(hex: "#1FD8A4")).frame(width: 9, height: 9)
                                Text(L.incomes).font(.system(size: 11.5, weight: .semibold)).foregroundStyle(AppColors.textSecondary)
                            }
                            HStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .fill(Color(hex: "#FF6B6B")).frame(width: 9, height: 9)
                                Text(L.expenses).font(.system(size: 11.5, weight: .semibold)).foregroundStyle(AppColors.textSecondary)
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 14, trailing: 20))
                }
                .padding(.horizontal, 18)

                // Expense ratio trend card
                expenseRatioTrendCard
                    .padding(.horizontal, 18)

                // Category breakdown
                if !stats.categoryBreakdown.isEmpty {
                    SectionHeader(title: L.expensesByCategory, actionLabel: stats.dateRangeLabel, action: {})

                    GlassView(radius: 28) {
                        VStack(spacing: 0) {
                            ForEach(Array(stats.categoryBreakdown.enumerated()), id: \.offset) { idx, cat in
                                CategoryBreakdownRow(cat: cat)
                                if idx != stats.categoryBreakdown.count - 1 {
                                    Divider().background(AppColors.divider)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                    }
                    .padding(.horizontal, 18)
                }

                Spacer(minLength: 110)
            }
        }
        .scrollIndicators(.hidden)
        }
        .overlay(alignment: .topTrailing) {
            Button(L.close) { dismiss() }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.text)
                .padding(.horizontal, 16)
                .padding(.top, 14)
        }
        .task(id: period) {
            stats = computeStats()
        }
    }

    private func ratioColor(_ ratio: Double) -> Color {
        if ratio >= 1.0 { return AppColors.expense }
        if ratio >= 0.75 { return AppColors.gold }
        return AppColors.income
    }

    private var expenseRatioTrendCard: some View {
        GlassView {
            VStack(alignment: .leading, spacing: 8) {
                Text(L.expenseRatioTrend.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(String(format: "%.2f", stats.currentPeriodRatio * 100))%")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundStyle(ratioColor(stats.currentPeriodRatio))
                        .tracking(-0.3)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    if stats.previousBucketRatio > 0 || stats.currentPeriodRatio > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: stats.ratioDeltaPoints > 0 ? "arrow.up.right" : (stats.ratioDeltaPoints < 0 ? "arrow.down.right" : "minus"))
                                .font(.system(size: 10, weight: .bold))
                            Text("\(String(format: "%.0f", abs(stats.ratioDeltaPoints)))%")
                                .font(.system(size: 12.5, weight: .bold))
                        }
                        .foregroundStyle(stats.ratioDeltaPoints > 0 ? AppColors.expense : AppColors.income)
                    }
                }

                Text(L.vsPreviousPeriod)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)

                // Trend chart: bars colored by threshold, with reference lines at 50/75/100%
                GeometryReader { geo in
                    let chartHeight: CGFloat = 92
                    let maxRatio = max(stats.ratioTrend.map(\.ratio).max() ?? 1, 1.05)
                    ZStack(alignment: .bottomLeading) {
                        ForEach([0.5, 0.75, 1.0], id: \.self) { threshold in
                            let y = chartHeight - CGFloat(threshold / maxRatio) * chartHeight
                            Path { p in
                                p.move(to: CGPoint(x: 0, y: y))
                                p.addLine(to: CGPoint(x: geo.size.width, y: y))
                            }
                            .stroke(AppColors.text.opacity(0.12), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                        }

                        HStack(alignment: .bottom, spacing: 10) {
                            ForEach(Array(stats.ratioTrend.enumerated()), id: \.offset) { idx, point in
                                VStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .fill(ratioColor(point.ratio).opacity(idx == (stats.currentBucketIndex ?? stats.ratioTrend.count - 1) ? 1 : 0.55))
                                        .frame(height: max(4, CGFloat(point.ratio / maxRatio) * chartHeight))
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: chartHeight, alignment: .bottom)
                    }
                }
                .frame(height: 92)
                .padding(.top, 6)

                HStack(spacing: 0) {
                    ForEach(Array(stats.ratioTrend.enumerated()), id: \.offset) { _, point in
                        Text(point.label)
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundStyle(AppColors.textTertiary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 16, trailing: 20))
        }
    }
}

struct CategoryBreakdownRow: View {
    let cat: (name: String, amount: Double, pct: Double)
    @EnvironmentObject var vm: AppViewModel

    private var category: Category? {
        vm.categories.first(where: { $0.name == cat.name })
    }

    private var color: Color {
        category?.displayColor ?? AppColors.textTertiary
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.22))
                    .frame(width: 38, height: 38)
                CategoryIconView(icon: resolvedIcon(for: category), size: 15)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(L.categoryName(cat.name))
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundStyle(AppColors.text)
                    Spacer()
                    Text("\(formatCurrency(cat.amount)) · \(String(format: "%.0f", cat.pct))%")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(AppColors.textTertiary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(AppColors.text.opacity(0.12))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(color)
                            .frame(width: geo.size.width * min(CGFloat(cat.pct) / 100, 1), height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 14)
    }
}
