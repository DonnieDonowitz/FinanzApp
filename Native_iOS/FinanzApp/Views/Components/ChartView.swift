import SwiftUI

struct ChartView: View {
    var body: some View {
        Text("ChartView placeholder - use PieChart or BarChart directly")
            .font(.caption).foregroundStyle(AppColors.textTertiary)
    }
}

// MARK: - Donut Pie Chart

struct DonutChart: View {
    let data: [(label: String, value: Double, color: Color)]
    let centerText: String
    let centerSubtext: String

    @State private var animated = false
    @State private var selectedIndex: Int? = nil

    private var total: Double { data.map(\.value).reduce(0, +) }

    var body: some View {
        ZStack {
            if total > 0 {
                ForEach(Array(data.enumerated()), id: \.offset) { idx, item in
                    PieSlice(
                        startAngle: angle(for: idx),
                        endAngle: angle(for: idx + 1),
                        isSelected: selectedIndex == idx
                    )
                    .fill(item.color)
                    .scaleEffect(selectedIndex == idx ? 1.03 : 1.0)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedIndex = selectedIndex == idx ? nil : idx
                        }
                    }
                }
                .opacity(animated ? 1 : 0)
                .scaleEffect(animated ? 1 : 0.8)

                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 90, height: 90)
                    .overlay(
                        VStack(spacing: 2) {
                            Text(centerText)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundStyle(AppColors.text)
                            Text(centerSubtext)
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(AppColors.textTertiary)
                        }
                    )
            } else {
                Text("Nessun dato")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .frame(height: 190)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                animated = true
            }
        }
    }

    private func angle(for index: Int) -> Angle {
        if total == 0 { return .zero }
        let sum = data.prefix(index).map(\.value).reduce(0, +)
        return .degrees(sum / total * 360 - 90)
    }
}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let isSelected: Bool

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let inset = isSelected ? -4.0 : 0.0

        var path = Path()
        path.move(to: center)
        path.addArc(center: center, radius: radius + CGFloat(inset), startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Legend

struct ChartLegend: View {
    let data: [(label: String, value: Double, color: Color)]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                HStack(spacing: 6) {
                    Circle()
                        .fill(item.color)
                        .frame(width: 8, height: 8)
                    Text(item.label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

// MARK: - Stacked Bar Chart

struct BarChartView: View {
    let bars: [BarData]
    let incomeLabel: String
    let expenseLabel: String

    @State private var hoveredBar: Int? = nil

    struct BarData: Identifiable {
        let id = UUID()
        let label: String
        let income: Double
        let expense: Double
        let month: String
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(Array(bars.enumerated()), id: \.element.id) { idx, bar in
                    VStack(spacing: 4) {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(AppColors.textTertiary.opacity(0.15))
                                .frame(height: 96)

                            VStack(spacing: 2) {
                                if bar.income > 0 {
                                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                                        .fill(LinearGradient(colors: [Color(hex: "#5CFFCB"), Color(hex: "#17C899")], startPoint: .top, endPoint: .bottom))
                                        .frame(height: max(8, barHeight(bar.income)))
                                }
                                if bar.expense > 0 {
                                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                                        .fill(LinearGradient(colors: [Color(hex: "#FF9B9B"), Color(hex: "#FF5C5C")], startPoint: .top, endPoint: .bottom))
                                        .frame(height: max(8, barHeight(bar.expense)))
                                }
                            }
                            .frame(height: 96, alignment: .bottom)
                        }
                        .onTapGesture {
                            withAnimation { hoveredBar = hoveredBar == idx ? nil : idx }
                        }

                        Text(bar.label)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(hoveredBar == idx ? AppColors.text : AppColors.textTertiary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color(hex: "#1FD8A4")).frame(width: 9, height: 9)
                    Text(incomeLabel).font(.system(size: 11, weight: .semibold)).foregroundStyle(AppColors.textSecondary)
                }
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color(hex: "#FF6B6B")).frame(width: 9, height: 9)
                    Text(expenseLabel).font(.system(size: 11, weight: .semibold)).foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }

    private var maxValue: Double {
        max(bars.map { max($0.income, $0.expense) }.max() ?? 1, 1)
    }

    private func barHeight(_ value: Double) -> CGFloat {
        CGFloat(value / maxValue) * 84
    }
}