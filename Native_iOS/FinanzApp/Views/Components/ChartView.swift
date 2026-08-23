import SwiftUI

// MARK: - Gap Donut Chart

/// One slice of a `GapDonutChart`. `id` should be stable per category (or a sentinel like -1
/// for "uncategorized") so selection survives re-renders.
struct GapDonutSlice: Identifiable {
    let id: Int64
    let label: String
    let value: Double
    let color: Color
}

/// An empty-centered ring chart with a small angular gap and rounded caps between slices.
/// Tap or drag a finger across a slice to select it (drag lets the user "sweep" across
/// segments instead of only tapping one at a time); the selection drives a highlight (a
/// brighter, thicker stroke) and is meant to be read by the caller to show a drill-down list.
struct GapDonutChart: View {
    let data: [GapDonutSlice]
    var diameter: CGFloat = 190
    var lineWidth: CGFloat = 26
    var gapFraction: Double = 0.014
    @Binding var selectedId: Int64?
    var interactive: Bool = true

    private var total: Double { max(data.map(\.value).reduce(0, +), 0) }

    var body: some View {
        Group {
            // The drag gesture is only attached when `interactive`, so a non-interactive
            // preview donut (e.g. inside a month list row's own `Button`) never competes with
            // an ancestor view's own tap handling.
            if interactive {
                ring.gesture(DragGesture(minimumDistance: 0).onChanged { value in handleTouch(value.location) })
            } else {
                ring
            }
        }
        .frame(width: diameter, height: diameter)
        .contentShape(Circle())
    }

    private var ring: some View {
        ZStack {
            if total > 0 {
                ForEach(Array(data.enumerated()), id: \.element.id) { idx, item in
                    let (start, end) = range(for: idx)
                    let isSelected = selectedId == item.id
                    Circle()
                        .trim(from: start, to: end)
                        .stroke(
                            item.color.opacity(selectedId == nil || isSelected ? 1 : 0.32),
                            style: StrokeStyle(lineWidth: isSelected ? lineWidth + 5 : lineWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: selectedId)
            } else {
                Circle()
                    .stroke(AppColors.textTertiary.opacity(0.15), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            }
        }
    }

    private func range(for index: Int) -> (Double, Double) {
        guard total > 0 else { return (0, 0) }
        let before = data.prefix(index).map(\.value).reduce(0, +)
        let rawStart = before / total
        let rawEnd = (before + data[index].value) / total
        let gap = gapFraction / 2
        let start = rawStart + gap
        let end = max(start, rawEnd - gap)
        return (start, end)
    }

    private func hitSlice(at unitPoint: Double) -> GapDonutSlice? {
        for (idx, item) in data.enumerated() {
            let (start, end) = range(for: idx)
            if unitPoint >= start - gapFraction && unitPoint <= end + gapFraction { return item }
        }
        return nil
    }

    private func handleTouch(_ point: CGPoint) {
        guard interactive, total > 0 else { return }
        let center = CGPoint(x: diameter / 2, y: diameter / 2)
        let dx = point.x - center.x
        let dy = point.y - center.y
        let radius = sqrt(dx * dx + dy * dy)
        guard radius > diameter / 2 - lineWidth * 1.6, radius < diameter / 2 + lineWidth * 0.6 else { return }
        var degrees = atan2(dy, dx) * 180 / .pi + 90
        if degrees < 0 { degrees += 360 }
        if let hit = hitSlice(at: degrees / 360), hit.id != selectedId {
            selectedId = hit.id
        }
    }
}

// MARK: - Daily Bar Chart

/// One bar per day of a month on the dashboard. Tapping a bar highlights it (brighter fill)
/// and toggles `selectedDay`, which the caller uses to reveal that day's transactions below.
struct DailyBarChart: View {
    let entries: [(day: Int, amount: Double)]
    @Binding var selectedDay: Int?
    var height: CGFloat = 120

    private var maxValue: Double { max(entries.map(\.amount).max() ?? 1, 1) }
    private var barSpacing: CGFloat { entries.count > 20 ? 2 : 4 }

    var body: some View {
        HStack(alignment: .bottom, spacing: barSpacing) {
            ForEach(entries, id: \.day) { entry in
                let isSelected = selectedDay == entry.day
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(barFill(isSelected: isSelected))
                    .frame(height: max(3, CGFloat(entry.amount / maxValue) * height))
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedDay = isSelected ? nil : entry.day
                        }
                    }
            }
        }
        .frame(height: height, alignment: .bottom)
    }

    private func barFill(isSelected: Bool) -> LinearGradient {
        isSelected
            ? LinearGradient(colors: [Color(hex: "#FF9B9B"), Color(hex: "#FF3B3B")], startPoint: .top, endPoint: .bottom)
            : LinearGradient(colors: [Color(hex: "#FF9B9B").opacity(0.55), Color(hex: "#FF5C5C").opacity(0.55)], startPoint: .top, endPoint: .bottom)
    }
}

// MARK: - Legend

struct ChartLegend: View {
    let data: [GapDonutSlice]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(data) { item in
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
