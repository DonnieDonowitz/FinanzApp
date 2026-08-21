import SwiftUI

struct AddRecurringView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss

    @State private var type = "expense"
    @State private var amount = ""
    @State private var description = ""
    @State private var selectedCategory: Category?
    @State private var frequency = "monthly"
    @State private var dueDate = Date()
    @State private var showCategoryPicker = false
    @State private var isSaving = false

    private let frequencies = ["monthly", "weekly", "yearly"]

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundGradient()

                ScrollView {
                    VStack(spacing: 16) {
                        // Amount
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L.amount)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(AppColors.textTertiary)
                                .tracking(0.5)

                            GlassView(intensity: .strong, radius: 22) {
                                HStack(spacing: 4) {
                                    Text(AppSettingsStore.currentCurrencySymbol)
                                        .font(.system(size: 26, weight: .light))
                                        .foregroundStyle(AppColors.textTertiary)
                                    TextField("0", text: $amount)
                                        .keyboardType(.decimalPad)
                                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                                        .foregroundStyle(AppColors.text)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 20)
                            }
                        }

                        // Type
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L.type)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(AppColors.textTertiary)
                                .tracking(0.5)

                            HStack(spacing: 8) {
                                TypeChip(L.expense, icon: "arrow.up", active: type == "expense", tint: AppColors.expense) {
                                    type = "expense"; selectedCategory = nil
                                }
                                TypeChip(L.income, icon: "arrow.down", active: type == "income", tint: AppColors.income) {
                                    type = "income"; selectedCategory = nil
                                }
                            }
                        }

                        // Description
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L.description)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(AppColors.textTertiary)
                                .tracking(0.5)
                            GlassView(intensity: .strong, radius: 18) {
                                TextField(L.recurringDescPlaceholder, text: $description)
                                    .font(.system(size: 16))
                                    .foregroundStyle(AppColors.text)
                                    .padding(16)
                            }
                        }

                        // Category
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L.categoryLabel)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(AppColors.textTertiary)
                                .tracking(0.5)
                            Button { showCategoryPicker = true } label: {
                                GlassView(intensity: .strong, radius: 18) {
                                    HStack {
                                        if let cat = selectedCategory {
                                            ZStack {
                                                Circle().fill(cat.displayColor.opacity(0.22)).frame(width: 30, height: 30)
                                                CategoryIconView(icon: resolvedIcon(for: cat), size: 13)
                                                    .foregroundStyle(cat.displayColor)
                                            }
                                            Text(L.categoryName(cat.name)).font(.system(size: 16)).foregroundStyle(AppColors.text)
                                        } else {
                                            Text(L.selectCategory).font(.system(size: 16)).foregroundStyle(AppColors.textTertiary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.textTertiary)
                                    }
                                    .padding(16)
                                }
                            }
                        }

                        // Frequency
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L.frequency)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(AppColors.textTertiary)
                                .tracking(0.5)
                            HStack(spacing: 8) {
                                ForEach(frequencies, id: \.self) { f in
                                    Button { frequency = f } label: {
                                        Text(frequencyLabel(f))
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(frequency == f ? .black : AppColors.textSecondary)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(frequency == f ? Color.white.opacity(0.92) : AppColors.glass)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }

                        // Due date
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L.nextPaymentDate)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(AppColors.textTertiary)
                                .tracking(0.5)
                            GlassView(intensity: .strong, radius: 18) {
                                DatePicker("", selection: $dueDate, displayedComponents: .date)
                                    .labelsHidden().tint(AppColors.primary).padding(8)
                            }
                        }

                        // Submit
                        Button {
                            guard !isSaving,
                                  let amt = Double(amount.replacingOccurrences(of: ",", with: ".")),
                                  amt > 0,
                                  let cat = selectedCategory else { return }
                            isSaving = true
                            let f = DateFormatter()
                            f.dateFormat = "yyyy-MM-dd"
                            f.locale = Locale(identifier: "en_US_POSIX")
                            vm.addRecurring(type: type, amount: amt, description: description, categoryId: cat.id, categoryName: cat.name, frequency: frequency, nextDueDate: f.string(from: dueDate))
                            dismiss()
                        } label: {
                            Text(L.save)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(canSubmit ? AppColors.primary : AppColors.textTertiary)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .disabled(!canSubmit || isSaving)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle(L.newRecurring)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L.cancel) { dismiss() }.foregroundStyle(AppColors.textSecondary)
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPicker(selectedCategory: $selectedCategory, type: type)
                    .environmentObject(vm)
            }
        }
    }

    private var canSubmit: Bool {
        !amount.isEmpty && !description.isEmpty && selectedCategory != nil
    }
}
