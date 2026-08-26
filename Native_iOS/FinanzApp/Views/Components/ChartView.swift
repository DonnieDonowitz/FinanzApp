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

    /// The stroke width actually used to draw the ring. A round cap's outward bulge scales with
    /// this, so clearing it between every pair of N slices eventually demands more gap than the
    /// ring has room for — the previous fix handled that by shrinking the gap itself below the
    /// safe minimum, which let many-category charts overlap again. Drawing a thinner ring once
    /// there are enough categories (the same way a bar chart thins its bars when there are many)
    /// keeps the required gap small instead, so the gap itself is never compromised.
    private var effectiveLineWidth: CGFloat {
        let n = data.count
        guard n > 4 else { return lineWidth }
        let circumference = Double.pi * diameter
        guard circumference > 0 else { return lineWidth }
        // Keeps every gap's total reserve within ~40% of the ring, however many categories
        // there are, so slices always keep the majority of the ring to show actual value.
        let maxTotalGapFraction = 0.4
        let maxLineWidth = (maxTotalGapFraction * circumference) / (2.0 * Double(n))
        return min(lineWidth, max(8, CGFloat(maxLineWidth)))
    }

    /// A round `lineCap` bulges outward by `effectiveLineWidth / 2` past each trim endpoint, so
    /// a gap smaller than roughly one `effectiveLineWidth` of arc length lets adjacent slices'
    /// caps visually touch or overlap even though their trimmed ranges don't.
    private var capClearance: Double {
        let circumference = Double.pi * diameter
        guard circumference > 0 else { return gapFraction }
        return (Double(effectiveLineWidth) * 2) / circumference
    }

    /// (start, end) unit-circle ranges for every slice, laid out so gaps read as a deliberate,
    /// uniform rhythm instead of shrinking or vanishing depending on how the data happens to
    /// split:
    /// - `gapPerSlice` is the same fixed width between every adjacent pair, wide enough to clear
    ///   the round cap's bulge (see `capClearance`) — this is a hard geometric floor and is
    ///   never squeezed down to make room, unlike the previous version of this layout;
    /// - every non-zero slice keeps at least `minSliceWidth` of visible arc — tiny categories
    ///   read as a short, clearly visible pill rather than disappearing — with the remaining
    ///   ring space then distributed to the other slices in proportion to their value.
    ///   `minSliceWidth` (not the gap) is what shrinks first if there isn't enough room.
    private var layout: [(start: Double, end: Double)] {
        guard total > 0, !data.isEmpty else { return [] }
        let n = data.count
        let gapPerSlice = max(gapFraction, capClearance)
        // Only reached at an extreme category count effectiveLineWidth's own cap doesn't fully
        // cover; still fall back to shrinking the gap rather than producing negative widths.
        let totalGap = Double(n) * gapPerSlice
        let safeGapPerSlice = totalGap > 0.9 ? 0.9 / Double(n) : gapPerSlice

        let available = max(0, 1 - Double(n) * safeGapPerSlice)
        var minSliceWidth = safeGapPerSlice * 1.5
        let totalMin = Double(n) * minSliceWidth
        if totalMin > available * 0.7 {
            minSliceWidth = available > 0 ? (available * 0.7) / Double(n) : 0
        }

        var widths = [Double](repeating: 0, count: n)
        var pinned = Set<Int>()
        var remainingValue = data.reduce(0) { $0 + $1.value }
        var remainingAvailable = available

        var changed = true
        while changed {
            changed = false
            for i in 0..<n where !pinned.contains(i) {
                let share = remainingValue > 0 ? (data[i].value / remainingValue) * remainingAvailable : 0
                if share < minSliceWidth {
                    widths[i] = min(minSliceWidth, remainingAvailable)
                    remainingAvailable -= widths[i]
                    remainingValue -= data[i].value
                    pinned.insert(i)
                    changed = true
                    break
                }
            }
        }
        for i in 0..<n where !pinned.contains(i) {
            widths[i] = remainingValue > 0 ? (data[i].value / remainingValue) * remainingAvailable : 0
        }

        var ranges: [(start: Double, end: Double)] = []
        ranges.reserveCapacity(n)
        var position = 0.0
        for i in 0..<n {
            let start = position + safeGapPerSlice / 2
            let end = start + widths[i]
            ranges.append((start, end))
            position = end + safeGapPerSlice / 2
        }
        return ranges
    }

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
                            style: StrokeStyle(lineWidth: isSelected ? effectiveLineWidth + 5 : effectiveLineWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: selectedId)
            } else {
                Circle()
                    .stroke(AppColors.textTertiary.opacity(0.15), style: StrokeStyle(lineWidth: effectiveLineWidth, lineCap: .round))
            }
        }
    }

    private func range(for index: Int) -> (Double, Double) {
        guard index >= 0, index < layout.count else { return (0, 0) }
        return layout[index]
    }

    private func hitSlice(at unitPoint: Double) -> GapDonutSlice? {
        let ranges = layout
        for (idx, item) in data.enumerated() {
            guard idx < ranges.count else { continue }
            let (start, end) = ranges[idx]
            if unitPoint >= start - capClearance && unitPoint <= end + capClearance { return item }
        }
        return nil
    }

    private func handleTouch(_ point: CGPoint) {
        guard interactive, total > 0 else { return }
        let center = CGPoint(x: diameter / 2, y: diameter / 2)
        let dx = point.x - center.x
        let dy = point.y - center.y
        let radius = sqrt(dx * dx + dy * dy)
        guard radius > diameter / 2 - effectiveLineWidth * 1.6, radius < diameter / 2 + effectiveLineWidth * 0.6 else { return }
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
                    .fill(AppColors.expense.opacity(isSelected ? 1 : 0.45))
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
