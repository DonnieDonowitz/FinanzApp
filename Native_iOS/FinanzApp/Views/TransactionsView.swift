import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedMonth: String = getCurrentMonth()
    @State private var selectedType: String = "all"
    @State private var showAddSheet = false
    @State private var showStats = false
    @State private var editingTransaction: Transaction?

    private var months: [String] {
        let m = Set(vm.transactions.map { String($0.date.prefix(7)) })
        return m.sorted().reversed()
    }

    private var filtered: [Transaction] {
        vm.transactions.filter {
            (selectedMonth.isEmpty || $0.date.hasPrefix(selectedMonth)) &&
            (selectedType == "all" || $0.type == selectedType)
        }.sorted { $0.date > $1.date }
    }

    private var selectedMonthLabel: String {
        guard selectedMonth.count == 7, let idx = Int(selectedMonth.suffix(2)) else { return L.month }
        return monthLabel(idx: idx, m: selectedMonth)
    }

    private func monthLabel(idx: Int, m: String) -> String {
        let year = String(m.prefix(4))
        let currentYear = String(getCurrentMonth().prefix(4))
        let name = L.monthsShort[idx - 1]
        return year == currentYear ? name : "\(name) \(year)"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack {
                    Text(L.movements)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppColors.text)
                        .tracking(-0.2)
                    Spacer()
                    Button { showStats = true } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.textSecondary)
                            Text(L.statistics)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(AppColors.glass).clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24).padding(.top, 12)

                // Month dropdown selector
                HStack {
                    Menu {
                        ForEach(months, id: \.self) { m in
                            let idx = Int(m.suffix(2)) ?? 1
                            Button {
                                withAnimation { selectedMonth = m }
                            } label: {
                                if selectedMonth == m {
                                    Label(monthLabel(idx: idx, m: m), systemImage: "checkmark")
                                } else {
                                    Text(monthLabel(idx: idx, m: m))
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(selectedMonthLabel)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.text)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(AppColors.glass)
                        .clipShape(Capsule())
                    }
                    Spacer()
                }
                .padding(.horizontal, 18)

                // Filter chips
                HStack(spacing: 8) {
                    FilterChip(L.all, active: selectedType == "all") { selectedType = "all" }
                    FilterChip(L.incomes, active: selectedType == "income") { selectedType = "income" }
                    FilterChip(L.expenses, active: selectedType == "expense") { selectedType = "expense" }
                    Spacer()
                }
                .padding(.horizontal, 18)

                // List
                if filtered.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "list.bullet").font(.system(size: 26)).foregroundStyle(AppColors.textTertiary)
                        Text(L.noMovements).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    GlassView(radius: 28) {
                        VStack(spacing: 0) {
                            ForEach(filtered) { tx in
                                SwipeToDeleteRow(onDelete: { vm.deleteTransaction(tx.id) }, onTap: { editingTransaction = tx }) {
                                    TransactionRow(transaction: tx)
                                }
                                if tx.id != filtered.last?.id {
                                    Divider().background(AppColors.divider)
                                }
                            }
                        }
                        .padding(.vertical, 6).padding(.horizontal, 8)
                    }
                    .padding(.horizontal, 18)
                }

                Spacer(minLength: 110)
            }
        }
        .scrollIndicators(.hidden)
        .overlay(alignment: .bottomTrailing) { FAB { showAddSheet = true } }
        .sheet(isPresented: $showAddSheet) { AddTransactionView().environmentObject(vm) }
        .sheet(isPresented: $showStats) { StatisticsView().environmentObject(vm) }
        .sheet(item: $editingTransaction) { tx in
            AddTransactionView(editTransaction: tx).environmentObject(vm)
        }
    }
}

struct FilterChip: View {
    let label: String; let active: Bool; let action: () -> Void
    init(_ label: String, active: Bool, action: @escaping () -> Void) {
        self.label = label; self.active = active; self.action = action
    }
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(active ? .black : AppColors.textSecondary)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(active ? Color.white.opacity(0.92) : AppColors.glass)
                .clipShape(Capsule())
        }
    }
}

struct FAB: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    ZStack {
                        Rectangle().fill(.ultraThinMaterial).saturation(1.6)
                        LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white.opacity(0.6), lineWidth: 1))
                .shadow(color: .black.opacity(0.3), radius: 24, x: 0, y: 10)
        }
        .padding(.trailing, 22).padding(.bottom, 98)
    }
}