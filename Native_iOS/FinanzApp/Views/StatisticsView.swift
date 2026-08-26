import SwiftUI

enum StatsPeriod: String, CaseIterable {
    case month, semester, year

    var label: String {
        switch self {
        case .month: return L.month
        case .semester: return L.semester
        case .year: return L.year
        }
    }
}

struct StatisticsView: View {
    @EnvironmentObject var vm: AppViewModel

    @State private var period: StatsPeriod = .month
    @State private var selectedMonth: String = Date.currentMonth
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedHalf: Int = Calendar.current.component(.month, from: Date()) <= 6 ? 1 : 2
    @State private var selectedSliceId: Int64?

    private static let ymdFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    var body: some View {
        ZStack {
            BackgroundGradient()
            ScrollView {
                VStack(spacing: 12) {
                    header
                    periodSelector

                    switch period {
                    case .month:
                        monthDetail
                    case .semester:
                        monthList(months: monthsInHalf(year: selectedYear, half: selectedHalf), stepper: semesterStepper, title: semesterLabel)
                    case .year:
                        monthList(months: monthsInYear(selectedYear), stepper: yearStepper, title: "\(selectedYear)")
                    }

                    Spacer(minLength: 110)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onChange(of: period) { _, _ in selectedSliceId = nil }
        .onChange(of: selectedMonth) { _, _ in selectedSliceId = nil }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(L.advancedStatistics)
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
    }

    private var periodSelector: some View {
        HStack(spacing: 4) {
            ForEach(StatsPeriod.allCases, id: \.self) { p in
                Text(p.label)
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(period == p ? .white : AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(period == p ? AppColors.primary : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .onTapGesture { withAnimation { period = p } }
            }
        }
        .padding(4)
        .background(AppColors.glass)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 18)
    }

    // MARK: - Month detail (interactive donut + drill-down)

    private var monthDetail: some View {
        VStack(spacing: 12) {
            monthStepper
                .padding(.horizontal, 18)

            summaryCard
                .padding(.horizontal, 18)

            let breakdown = categoryBreakdown(for: selectedMonth)
            if !breakdown.isEmpty {
                GlassView {
                    VStack(spacing: 14) {
                        GapDonutChart(data: breakdown, selectedId: $selectedSliceId)

                        VStack(spacing: 0) {
                            ForEach(breakdown) { slice in
                                categoryRow(slice)
                                if slice.id != breakdown.last?.id {
                                    Divider().background(AppColors.divider)
                                }
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 20, leading: 16, bottom: 16, trailing: 16))
                }
                .padding(.horizontal, 18)

                if let selected = selectedSliceId {
                    drilldownList(for: selected, month: selectedMonth)
                        .padding(.horizontal, 18)
                }
            } else {
                GlassView {
                    Text(L.noExpensesThisMonth)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(30)
                }
                .padding(.horizontal, 18)
            }
        }
    }

    private var monthStepper: some View {
        HStack(spacing: 12) {
            Button { selectedMonth = shiftMonth(selectedMonth, by: -1) } label: {
                Image(systemName: "chevron.left").foregroundStyle(AppColors.primary)
            }
            Text(monthLabel(selectedMonth).capitalized)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(AppColors.text)
            Button { selectedMonth = shiftMonth(selectedMonth, by: 1) } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(selectedMonth < Date.currentMonth ? AppColors.primary : AppColors.textTertiary)
            }
            .disabled(selectedMonth >= Date.currentMonth)
        }
        .frame(maxWidth: .infinity)
    }

    private var summaryCard: some View {
        let income = vm.incomeForMonth(selectedMonth)
        let expense = vm.expenseForMonth(selectedMonth)
        let xp = Gamification.monthXP(income: income, spent: expense, budget: vm.monthlyBudget)

        return GlassView {
            VStack(spacing: 10) {
                summaryRow(income: income, expense: expense)
                if vm.isBudgetConfigured {
                    Divider().background(AppColors.divider)
                    HStack {
                        Text(xp >= 0 ? L.xpEarnedThisMonth(Int(xp)) : L.xpLostThisMonth(Int(-xp)))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(xp >= 0 ? AppColors.income : AppColors.expense)
                        Spacer()
                    }
                }
            }
            .padding(18)
        }
    }

    /// The income/expenses/balance three-column row shared by the month summary and the
    /// semester/year period summary — same layout, just fed a different income/expense pair.
    private func summaryRow(income: Double, expense: Double) -> some View {
        let balance = income - expense
        return HStack {
            statColumn(L.incomes, formatCurrency(income), AppColors.incomeLight)
            statColumn(L.expenses, formatCurrency(expense), AppColors.expenseLight)
            statColumn(L.balance, formatCurrency(balance), balance >= 0 ? AppColors.income : AppColors.expense)
        }
    }

    private func statColumn(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 9.5, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
                .tracking(0.3)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func categoryRow(_ slice: GapDonutSlice) -> some View {
        let isSelected = selectedSliceId == slice.id
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedSliceId = isSelected ? nil : slice.id
            }
        } label: {
            HStack(spacing: 10) {
                Circle().fill(slice.color).frame(width: 10, height: 10)
                Text(L.categoryName(slice.label))
                    .font(.system(size: 13, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(AppColors.text)
                Spacer()
                Text(formatCurrency(slice.value))
                    .font(.system(size: 12.5, weight: .bold, design: .monospaced))
                    .foregroundStyle(isSelected ? slice.color : AppColors.textTertiary)
            }
            .padding(.vertical, 9)
        }
        .buttonStyle(.plain)
    }

    private func drilldownList(for sliceId: Int64, month: String) -> some View {
        let items = transactions(for: sliceId, month: month)
        return GlassView(radius: 24) {
            VStack(spacing: 0) {
                ForEach(items) { tx in
                    TransactionRow(transaction: tx)
                        .padding(.horizontal, 8)
                    if tx.id != items.last?.id {
                        Divider().background(AppColors.divider)
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
        }
    }

    // MARK: - Semester / Year (month list with mini pie previews)

    private var semesterLabel: String {
        "\(selectedHalf == 1 ? L.firstHalf : L.secondHalf) \(selectedYear)"
    }

    private var semesterStepper: (prev: () -> Void, next: () -> Void, canNext: Bool) {
        (
            prev: { let (y, h) = shiftHalf(year: selectedYear, half: selectedHalf, by: -1); selectedYear = y; selectedHalf = h },
            next: { let (y, h) = shiftHalf(year: selectedYear, half: selectedHalf, by: 1); selectedYear = y; selectedHalf = h },
            canNext: selectedYear < currentYear || (selectedYear == currentYear && selectedHalf < currentHalf)
        )
    }

    private var yearStepper: (prev: () -> Void, next: () -> Void, canNext: Bool) {
        (
            prev: { selectedYear -= 1 },
            next: { selectedYear += 1 },
            canNext: selectedYear < currentYear
        )
    }

    private func monthList(months: [String], stepper: (prev: () -> Void, next: () -> Void, canNext: Bool), title: String) -> some View {
        let income = months.reduce(0.0) { $0 + vm.incomeForMonth($1) }
        let expense = months.reduce(0.0) { $0 + vm.expenseForMonth($1) }

        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: stepper.prev) {
                    Image(systemName: "chevron.left").foregroundStyle(AppColors.primary)
                }
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(AppColors.text)
                Button(action: stepper.next) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(stepper.canNext ? AppColors.primary : AppColors.textTertiary)
                }
                .disabled(!stepper.canNext)
            }
            .padding(.horizontal, 18)

            GlassView {
                summaryRow(income: income, expense: expense)
                    .padding(18)
            }
            .padding(.horizontal, 18)

            VStack(spacing: 10) {
                ForEach(months, id: \.self) { month in
                    monthPreviewRow(month)
                }
            }
            .padding(.horizontal, 18)
        }
    }

    private func monthPreviewRow(_ month: String) -> some View {
        let breakdown = categoryBreakdown(for: month)
        let total = breakdown.map(\.value).reduce(0, +)
        return Button {
            selectedMonth = month
            withAnimation { period = .month }
        } label: {
            GlassView(radius: 22) {
                HStack(spacing: 14) {
                    GapDonutChart(data: breakdown, diameter: 46, lineWidth: 9, gapFraction: 0.03, selectedId: .constant(nil), interactive: false)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(monthLabel(month).capitalized)
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundStyle(AppColors.text)
                        Text(total > 0 ? formatCurrency(total) : L.noExpensesThisMonth)
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(AppColors.textTertiary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.textTertiary)
                }
                .padding(14)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Data helpers

    private func categoryBreakdown(for month: String) -> [GapDonutSlice] {
        var totals: [Int64: Double] = [:]
        var uncategorized: Double = 0
        for tx in vm.transactionsForMonth(month) where tx.type == "expense" {
            if let cid = tx.categoryId { totals[cid, default: 0] += tx.amount }
            else { uncategorized += tx.amount }
        }
        var slices: [GapDonutSlice] = totals.compactMap { id, amount in
            guard let cat = vm.categoryById(id) else { return nil }
            return GapDonutSlice(id: id, label: cat.name, value: amount, color: cat.displayColor)
        }
        if uncategorized > 0 {
            slices.append(GapDonutSlice(id: -1, label: L.categories, value: uncategorized, color: AppColors.textTertiary))
        }
        return slices.sorted { $0.value > $1.value }
    }

    private func transactions(for sliceId: Int64, month: String) -> [Transaction] {
        vm.transactionsForMonth(month).filter { tx in
            guard tx.type == "expense" else { return false }
            return sliceId == -1 ? tx.categoryId == nil : tx.categoryId == sliceId
        }
    }

    private func monthsInHalf(year: Int, half: Int) -> [String] {
        let startMonth = half == 1 ? 1 : 7
        return (startMonth..<startMonth + 6).map { m in "\(year)-\(String(format: "%02d", m))" }
    }

    private func monthsInYear(_ year: Int) -> [String] {
        (1...12).map { m in "\(year)-\(String(format: "%02d", m))" }
    }

    private func shiftHalf(year: Int, half: Int, by delta: Int) -> (Int, Int) {
        var h = half + delta
        var y = year
        while h < 1 { h += 2; y -= 1 }
        while h > 2 { h -= 2; y += 1 }
        return (y, h)
    }

    private func shiftMonth(_ month: String, by delta: Int) -> String {
        guard let date = Self.ymdFormatter.date(from: month),
              let shifted = Calendar.current.date(byAdding: .month, value: delta, to: date) else { return month }
        return Self.ymdFormatter.string(from: shifted)
    }

    private func monthLabel(_ month: String) -> String {
        guard let date = Self.ymdFormatter.date(from: month) else { return month }
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        f.locale = Locale(identifier: AppSettingsStore.currentLanguage.localeIdentifier)
        return f.string(from: date)
    }

    private var currentYear: Int { Calendar.current.component(.year, from: Date()) }
    private var currentHalf: Int { Calendar.current.component(.month, from: Date()) <= 6 ? 1 : 2 }
}
