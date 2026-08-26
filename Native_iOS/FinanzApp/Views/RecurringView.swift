import SwiftUI

struct RecurringView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showAdd = false

    private var activeRecurring: [RecurringTransaction] {
        vm.recurringTransactions.filter(\.active).sorted { $0.nextDueDate < $1.nextDueDate }
    }

    private var monthlyTotal: Double {
        activeRecurring.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
    }

    private var nextDueDays: Int {
        guard let first = activeRecurring.first else { return 0 }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
        guard let d = f.date(from: first.nextDueDate) else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: d).day ?? 0
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L.recurringSubtitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColors.textSecondary)
                            .tracking(0.3)
                        Text(L.recurring)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(AppColors.text)
                            .tracking(-0.2)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)

                // Summary bar (unified, brand kit style)
                GlassView(radius: 28) {
                    HStack(spacing: 0) {
                        SummaryStat(label: L.totalPerMonth, value: formatCurrency(monthlyTotal))
                        SummaryDivider()
                        SummaryStat(label: L.active, value: "\(activeRecurring.count)")
                        SummaryDivider()
                        SummaryStat(label: L.next, value: nextDueDays > 0 ? "\(nextDueDays)g" : L.today)
                    }
                    .padding(.vertical, 16)
                }
                .padding(.horizontal, 18)

                // Recurring list
                if activeRecurring.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath").font(.system(size: 26)).foregroundStyle(AppColors.textTertiary)
                        Text(L.noRecurring).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    SectionHeader(title: L.upcoming, actionLabel: L.calendar, action: {})

                    GlassView(radius: 28) {
                        VStack(spacing: 0) {
                            ForEach(activeRecurring) { rec in
                                SwipeToDeleteRow(
                                    swipeLabel: L.deleteRecurringSwipeLabel,
                                    confirmTitle: L.deleteRecurringConfirmTitle,
                                    confirmMessage: L.deleteRecurringConfirmMessage,
                                    onDelete: { vm.deleteRecurring(rec.id) }
                                ) {
                                    RecurringRow(recurring: rec)
                                }
                                if rec.id != activeRecurring.last?.id {
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
        .overlay(alignment: .bottomTrailing) {
            FAB { showAdd = true }
        }
        .sheet(isPresented: $showAdd) {
            AddRecurringView().environmentObject(vm)
        }
    }
}

struct SummaryStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(AppColors.text)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.system(size: 9.5, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
                .tracking(0.2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SummaryDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppColors.divider)
            .frame(width: 1, height: 34)
    }
}

struct RecurringRow: View {
    let recurring: RecurringTransaction
    @EnvironmentObject var vm: AppViewModel

    private var category: Category? {
        vm.categoryById(recurring.categoryId)
    }

    private var categoryName: String {
        category?.name ?? ""
    }

    private var color: Color {
        category?.displayColor ?? AppColors.textTertiary
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(color.opacity(0.22))
                    .frame(width: 42, height: 42)
                CategoryIconView(icon: resolvedIcon(for: category), size: 17)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(recurring.description)
                    .font(.system(size: 14.5, weight: .semibold))
                    .foregroundStyle(AppColors.text)
                Text("\(frequencyLabel(recurring.frequency)) · \(formatDateShort(recurring.nextDueDate))")
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("\(recurring.isExpense ? "−" : "+")\(formatCurrency(recurring.amount))")
                    .font(.system(size: 14.5, weight: .bold, design: .monospaced))
                    .foregroundStyle(recurring.isExpense ? AppColors.text : AppColors.incomeLight)

                BrandToggle(isOn: Binding(
                    get: { recurring.active },
                    set: { newValue in
                        var r = recurring
                        r.active = newValue
                        vm.updateRecurring(r)
                    }
                ))
            }
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 14)
    }
}

struct BrandToggle: View {
    @Binding var isOn: Bool
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(isOn ? AppColors.income : AppColors.glassStrong)
                .frame(width: 38, height: 22)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isOn ? Color.clear : AppColors.glassBorderStrong, lineWidth: 1)
                )
            Circle()
                .fill(Color.white)
                .frame(width: 16, height: 16)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                .offset(x: isOn ? 18 : 2)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isOn.toggle()
            }
        }
    }
}
