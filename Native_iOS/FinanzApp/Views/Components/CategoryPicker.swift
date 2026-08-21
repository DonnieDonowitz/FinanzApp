import SwiftUI

struct CategoryPicker: View {
    @Binding var selectedCategory: Category?
    let type: String
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss

    var filteredCategories: [Category] {
        vm.categories.filter { $0.type == type }
    }

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundGradient()

                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(filteredCategories) { cat in
                            Button {
                                selectedCategory = cat
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(cat.displayColor.opacity(0.22))
                                            .frame(width: 34, height: 34)
                                        CategoryIconView(icon: resolvedIcon(for: cat), size: 15)
                                            .foregroundStyle(cat.displayColor)
                                    }
                                    Text(L.categoryName(cat.name))
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(AppColors.text)
                                    Spacer()
                                    if selectedCategory?.id == cat.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(AppColors.primary)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            }
                        }
                    }
                }
            }
            .navigationTitle(L.categories)
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
