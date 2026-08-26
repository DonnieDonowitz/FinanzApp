import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: AppViewModel
    @Binding var showTransactions: Bool
    // Two separate booleans/sheets with a hardcoded `initialType` each — rather than one shared
    // sheet fed a mutable `addType` — so there's no shared state for SwiftUI to (incorrectly)
    // reuse between "open for expense" and "open for income" presentations.
    @State private var showAddExpenseSheet = false
    @State private var showAddIncomeSheet = false
    @State private var showBudgetEdit = false
    @State private var editingTransaction: Transaction?
    @State private var selectedDay: Int?

    init(showTransactions: Binding<Bool> = .constant(false)) {
        self._showTransactions = showTransactions
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                header
                BalanceCard(income: vm.monthIncome, expense: vm.monthExpense, balance: vm.monthBalance)
                    .padding(.horizontal, 18)

                budgetCard
                    .padding(.horizontal, 18)

                levelCard
                    .padding(.horizontal, 18)

                QuickAddBar(onIncome: { showAddIncomeSheet = true },
                            onExpense: { showAddExpenseSheet = true })
                    .padding(.horizontal, 18)

                if !vm.monthTransactions.isEmpty {
                    dailyChartCard
                        .padding(.horizontal, 18)
                    insightCards
                }

                if !vm.topCategories.isEmpty {
                    SectionHeader(title: L.topCategories, actionLabel: L.month, action: {})
                    topCategoriesList
                }

                if !vm.recentTransactions.isEmpty {
                    SectionHeader(title: L.recentTransactions, actionLabel: L.seeAll) {
                        showTransactions = true
                    }
                    recentTransactionsList
                }

                Spacer(minLength: 110)
            }
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showAddExpenseSheet) {
            AddTransactionView(initialType: "expense").environmentObject(vm)
        }
        .sheet(isPresented: $showAddIncomeSheet) {
            AddTransactionView(initialType: "income").environmentObject(vm)
        }
        .sheet(item: $editingTransaction) { tx in
            AddTransactionView(editTransaction: tx).environmentObject(vm)
        }
        .sheet(isPresented: $showBudgetEdit) {
            BudgetEditSheet().environmentObject(vm)
        }
        .onChange(of: vm.pendingQuickAddType) { _, pending in
            guard let pending else { return }
            if pending == "income" { showAddIncomeSheet = true } else { showAddExpenseSheet = true }
            vm.pendingQuickAddType = nil
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .tracking(0.3)
                Text(L.overview)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(AppColors.text)
                    .tracking(-0.2)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 14)
        .padding(.bottom, 4)
    }

    // MARK: - Budget card

    private var budgetCard: some View {
        Button { showBudgetEdit = true } label: {
            GlassView(intensity: .strong, radius: 26) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(L.monthlyBudget.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.textTertiary)
                            .tracking(0.4)
                        Spacer()
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(AppColors.textTertiary)
                    }

                    if vm.isBudgetConfigured {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(formatCurrency(vm.monthExpense))
                                .font(.system(size: 26, weight: .bold, design: .monospaced))
                                .foregroundStyle(AppColors.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Text("/ \(formatCurrency(vm.monthlyBudget))")
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundStyle(AppColors.textTertiary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(AppColors.text.opacity(0.10))
                                    .frame(height: 10)
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(vm.isOverBudget ? AppColors.expense : AppColors.income)
                                    .frame(width: geo.size.width * min(vm.monthExpense / max(vm.monthlyBudget, 1), 1), height: 10)
                            }
                        }
                        .frame(height: 10)

                        Text(vm.isOverBudget
                             ? L.overBudgetBy(formatCurrency(-vm.monthBudgetRemaining))
                             : L.remainingBudget(formatCurrency(vm.monthBudgetRemaining)))
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundStyle(vm.isOverBudget ? AppColors.expense : AppColors.income)
                    } else {
                        Text(L.setBudgetPrompt)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(18)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Level card

    private var levelCard: some View {
        GlassView(radius: 26) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.18))
                        .frame(width: 52, height: 52)
                    Text("\(vm.currentLevel)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.primary)
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(L.levelLabel(vm.currentLevel))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(AppColors.text)
                        Spacer()
                        Text(L.xpTotal(Int(vm.totalXP)))
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(AppColors.textTertiary)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(AppColors.text.opacity(0.10))
                                .frame(height: 7)
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(AppColors.primary)
                                .frame(width: geo.size.width * vm.levelProgress, height: 7)
                        }
                    }
                    .frame(height: 7)
                }
            }
            .padding(16)
        }
    }

    // MARK: - Daily bar chart with drill-down

    private var dailyChartCard: some View {
        GlassView(radius: 26) {
            VStack(alignment: .leading, spacing: 10) {
                Text(L.dailySpendingTrend.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
                    .tracking(0.4)

                DailyBarChart(entries: vm.dailyExpenses(for: Date.currentMonth), selectedDay: $selectedDay)
                    .padding(.top, 4)

                if let day = selectedDay {
                    let dayTx = vm.transactionsForDay(dayDateString(day))
                    Divider().background(AppColors.divider).padding(.vertical, 2)
                    Text(L.dayTransactions(day))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.textSecondary)

                    if dayTx.isEmpty {
                        Text(L.noTransactionsThisDay)
                            .font(.system(size: 12.5))
                            .foregroundStyle(AppColors.textTertiary)
                            .padding(.vertical, 6)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(dayTx) { tx in
                                SwipeToDeleteRow(onDelete: { vm.deleteTransaction(tx.id) }, onTap: { editingTransaction = tx }) {
                                    TransactionRow(transaction: tx)
                                }
                                if tx.id != dayTx.last?.id {
                                    Divider().background(AppColors.divider)
                                }
                            }
                        }
                    }
                }
            }
            .padding(18)
        }
    }

    private func dayDateString(_ day: Int) -> String {
        "\(Date.currentMonth)-\(String(format: "%02d", day))"
    }

    // MARK: - Existing sections (unchanged)

    private var insightCards: some View {
        HStack(spacing: 12) {
            GlassView(radius: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L.dailyAverage)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(AppColors.textTertiary)
                        .tracking(0.3)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(formatCurrency(vm.dailyAverageExpense))
                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                        .foregroundStyle(AppColors.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
            }

            GlassView(radius: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L.expenseRatio)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(AppColors.textTertiary)
                        .tracking(0.3)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text("\(String(format: "%.2f", vm.expenseRatio * 100))%")
                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                        .foregroundStyle(vm.expenseRatio > 0.8 ? AppColors.expense : AppColors.income)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
            }
        }
        .padding(.horizontal, 18)
    }

    private var topCategoriesList: some View {
        GlassView(radius: 28) {
            VStack(spacing: 0) {
                ForEach(vm.topCategories) { cat in
                    let category = vm.categoryById(cat.id)
                    let color = category?.displayColor ?? AppColors.textTertiary
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(color.opacity(0.22))
                                .frame(width: 34, height: 34)
                            CategoryIconView(icon: resolvedIcon(for: category), size: 14)
                                .foregroundStyle(color)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L.categoryName(cat.name))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AppColors.text)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                                        .fill(AppColors.text.opacity(0.12))
                                        .frame(height: 5)
                                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                                        .fill(color)
                                        .frame(width: geo.size.width * min(CGFloat(cat.percentage) / 100, 1), height: 5)
                                }
                            }
                            .frame(height: 5)
                        }
                        Spacer(minLength: 8)
                        Text("\(formatCurrency(cat.amount))")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(AppColors.text)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    if cat.id != vm.topCategories.last?.id {
                        Divider().background(AppColors.divider).padding(.leading, 60)
                    }
                }
            }
            .padding(.vertical, 6)
        }
        .padding(.horizontal, 18)
    }

    private var recentTransactionsList: some View {
        GlassView(radius: 28) {
            VStack(spacing: 0) {
                ForEach(vm.recentTransactions) { tx in
                    SwipeToDeleteRow(onDelete: { vm.deleteTransaction(tx.id) }, onTap: { editingTransaction = tx }) {
                        TransactionRow(transaction: tx)
                    }
                    if tx.id != vm.recentTransactions.last?.id {
                        Divider().background(AppColors.divider)
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
        }
        .padding(.horizontal, 18)
    }

    private func greeting() -> String {
        let h = Calendar.current.component(.hour, from: Date())
        return L.greeting(hour: h)
    }
}

struct SectionHeader: View {
    let title: String
    let actionLabel: String
    let action: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(AppColors.text)
                .tracking(-0.2)
            Spacer()
            Button(action: action) {
                Text(actionLabel)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
    }
}
