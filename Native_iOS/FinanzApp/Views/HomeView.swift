import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: AppViewModel
    @Binding var showTransactions: Bool
    // Two separate booleans/sheets with a hardcoded `initialType` each — rather than one shared
    // sheet fed a mutable `addType` — so there's no shared state for SwiftUI to (incorrectly)
    // reuse between "open for expense" and "open for income" presentations.
    @State private var showAddExpenseSheet = false
    @State private var showAddIncomeSheet = false
    @State private var editingTransaction: Transaction?

    init(showTransactions: Binding<Bool> = .constant(false)) {
        self._showTransactions = showTransactions
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                header
                BalanceCard(income: vm.monthIncome, expense: vm.monthExpense, balance: vm.monthBalance, monthName: currentMonthName())
                    .padding(.horizontal, 18)

                QuickAddBar(onIncome: { showAddIncomeSheet = true },
                            onExpense: { showAddExpenseSheet = true })
                    .padding(.horizontal, 18)

                if !vm.monthTransactions.isEmpty {
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

    private func currentMonthName() -> String {
        let m = Calendar.current.component(.month, from: Date()) - 1
        return IT_MONTHS_FULL[m]
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