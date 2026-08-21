import SwiftUI

struct AnnualSummaryView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())

    private var months: [(name: String, income: Double, expense: Double)] {
        (1...12).map { m in
            let prefix = "\(selectedYear)-\(String(format: "%02d", m))"
            let txs = vm.transactions.filter { $0.date.hasPrefix(prefix) }
            return (
                name: L.monthsShort[m - 1],
                income: txs.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount },
                expense: txs.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
            )
        }
    }

    private var totalBalance: Double {
        months.reduce(0) { $0 + $1.income - $1.expense }
    }

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundGradient()

                ScrollView {
                    VStack(spacing: 12) {
                        // Year selector
                        HStack(spacing: 12) {
                            Button {
                                withAnimation { selectedYear -= 1 }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(AppColors.primary)
                            }
                            Text("\(selectedYear)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(AppColors.text)
                            Button {
                                withAnimation { selectedYear += 1 }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(AppColors.primary)
                            }
                        }
                        .padding(.top, 8)

                        // Total balance
                        GlassView(intensity: .strong, radius: 22) {
                            VStack(spacing: 4) {
                                Text("\(L.annualBalance) \(selectedYear)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(AppColors.textTertiary)
                                    .tracking(0.5)
                                Text(formatCurrency(totalBalance))
                                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                                    .foregroundStyle(totalBalance >= 0 ? AppColors.income : AppColors.expense)
                                    .tracking(-0.3)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .padding(18)
                        }
                        .padding(.horizontal, 16)

                        // Monthly table
                        GlassView(radius: 28) {
                            VStack(spacing: 0) {
                                // Header
                                HStack {
                                    Text(L.month)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.textTertiary)
                                        .tracking(0.5)
                                    Spacer()
                                    Text(L.incomes)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.textTertiary)
                                        .tracking(0.5)
                                    Spacer()
                                    Text(L.expenses)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.textTertiary)
                                        .tracking(0.5)
                                    Spacer()
                                    Text(L.balance)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.textTertiary)
                                        .tracking(0.5)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)

                                Divider().background(AppColors.divider)

                                ForEach(Array(months.enumerated()), id: \.offset) { idx, m in
                                    HStack {
                                        Text(m.name)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(AppColors.text)
                                        Spacer()
                                        Text(formatCurrency(m.income))
                                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                                            .foregroundStyle(AppColors.incomeLight)
                                        Spacer()
                                        Text(formatCurrency(m.expense))
                                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                                            .foregroundStyle(AppColors.expenseLight)
                                        Spacer()
                                        let bal = m.income - m.expense
                                        Text(formatCurrency(bal))
                                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                                            .foregroundStyle(bal >= 0 ? AppColors.income : AppColors.expense)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)

                                    if idx < months.count - 1 {
                                        Divider().background(AppColors.divider).padding(.horizontal, 16)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle(L.annualSummary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L.close) { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
            }
        }
    }
}
