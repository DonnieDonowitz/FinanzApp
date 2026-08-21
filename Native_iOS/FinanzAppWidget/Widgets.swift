import WidgetKit
import SwiftUI
import SQLite3

// MARK: - Widget theme (mirrors Theme.swift brand kit colors)

struct WidgetTint {
    let bgTop: Color, bgBottom: Color
    let text: Color, textSecondary: Color, textTertiary: Color
    let income: Color, expense: Color, accent: Color
    let track: Color

    static let dark = WidgetTint(
        bgTop: Color(hex: "#0D0F1A"), bgBottom: Color(hex: "#0A0C14"),
        text: .white, textSecondary: Color.white.opacity(0.68), textTertiary: Color.white.opacity(0.45),
        income: Color(hex: "#2FE8B0"), expense: Color(hex: "#FF7A7A"), accent: Color(hex: "#7B6FE8"),
        track: Color.white.opacity(0.12)
    )
    static let light = WidgetTint(
        bgTop: Color(hex: "#F5F6FA"), bgBottom: Color(hex: "#E8EAF2"),
        text: Color(hex: "#0B1120"), textSecondary: Color(hex: "#0B1120").opacity(0.68), textTertiary: Color(hex: "#0B1120").opacity(0.45),
        income: Color(hex: "#0AA57C"), expense: Color(hex: "#E14545"), accent: Color(hex: "#5E52D6"),
        track: Color.black.opacity(0.08)
    )

    static func current(_ scheme: ColorScheme) -> WidgetTint { scheme == .dark ? .dark : .light }
}

struct WidgetBackground: View {
    var body: some View {
        let t = WidgetTint.current(sharedIsDarkMode ? .dark : .light)
        LinearGradient(colors: [t.bgTop, t.bgBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

private let widgetMonths = ["Gennaio","Febbraio","Marzo","Aprile","Maggio","Giugno","Luglio","Agosto","Settembre","Ottobre","Novembre","Dicembre"]

// MARK: - Stats Widget (4x2 — all the essentials at a glance)

struct StatsWidget: Widget {
    let kind = "StatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatsProvider()) { entry in
            StatsWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    WidgetBackground()
                }
        }
        .configurationDisplayName("Statistiche")
        .description("Saldo, entrate, uscite e categoria principale del mese")
        .supportedFamilies([.systemMedium])
    }
}

struct StatsProvider: TimelineProvider {
    func placeholder(in context: Context) -> StatsEntry {
        StatsEntry(date: Date(), income: 2500, expense: 1800, balance: 700, txCount: 24, topCat: ("Alimentari", "#E53935", "🛒", 450))
    }

    func getSnapshot(in context: Context, completion: @escaping (StatsEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StatsEntry>) -> Void) {
        let totals = WidgetData.currentMonthTotals()
        let txCount = WidgetData.transactionCount()
        let topCat = WidgetData.topExpenseCategories().first

        let entry = StatsEntry(date: Date(), income: totals.income, expense: totals.expense, balance: totals.balance, txCount: txCount, topCat: topCat)

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct StatsEntry: TimelineEntry {
    let date: Date
    let income: Double
    let expense: Double
    let balance: Double
    let txCount: Int
    let topCat: (name: String, color: String, icon: String, amount: Double)?
}

struct StatsWidgetView: View {
    let entry: StatsEntry
    private var t: WidgetTint { .current(sharedIsDarkMode ? .dark : .light) }

    private var monthName: String {
        widgetMonths[Calendar.current.component(.month, from: entry.date) - 1]
    }

    private var incomeShare: CGFloat {
        let total = entry.income + entry.expense
        guard total > 0 else { return 0.5 }
        return CGFloat(entry.income / total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("Saldo · \(monthName)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(t.textSecondary)
                Spacer()
                Text("\(entry.txCount) movimenti")
                    .font(.system(size: 10))
                    .foregroundStyle(t.textTertiary)
            }

            Text(widgetCurrency(entry.balance))
                .font(.system(size: 26, weight: .bold, design: .monospaced))
                .foregroundStyle(entry.balance >= 0 ? t.income : t.expense)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            GeometryReader { geo in
                HStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(t.income)
                        .frame(width: max(6, geo.size.width * incomeShare))
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(t.expense)
                }
                .frame(height: 6)
            }
            .frame(height: 6)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Entrate").font(.system(size: 9, weight: .semibold)).foregroundStyle(t.textTertiary)
                    Text(widgetCurrency(entry.income))
                        .font(.system(size: 12.5, weight: .bold, design: .monospaced))
                        .foregroundStyle(t.income)
                        .lineLimit(1).minimumScaleFactor(0.7)
                }
                Spacer(minLength: 8)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Uscite").font(.system(size: 9, weight: .semibold)).foregroundStyle(t.textTertiary)
                    Text(widgetCurrency(entry.expense))
                        .font(.system(size: 12.5, weight: .bold, design: .monospaced))
                        .foregroundStyle(t.expense)
                        .lineLimit(1).minimumScaleFactor(0.7)
                }
                Spacer(minLength: 8)
                if let cat = entry.topCat {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("Top categoria").font(.system(size: 9, weight: .semibold)).foregroundStyle(t.textTertiary)
                        HStack(spacing: 4) {
                            Text(cat.icon).font(.system(size: 10))
                            Text(cat.name)
                                .font(.system(size: 11.5, weight: .semibold))
                                .foregroundStyle(t.text)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(14)
    }
}

// MARK: - Quick Actions Widget (4x1-style — one tap to add income or expense)

struct QuickAddWidget: Widget {
    let kind = "QuickAddWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickActionsProvider()) { entry in
            QuickActionsWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    WidgetBackground()
                }
        }
        .configurationDisplayName("Aggiungi Rapido")
        .description("Aggiungi in un tocco una nuova entrata o uscita")
        .supportedFamilies([.systemMedium])
    }
}

struct QuickActionsProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickActionsEntry { QuickActionsEntry(date: Date()) }
    func getSnapshot(in context: Context, completion: @escaping (QuickActionsEntry) -> Void) {
        completion(QuickActionsEntry(date: Date()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickActionsEntry>) -> Void) {
        completion(Timeline(entries: [QuickActionsEntry(date: Date())], policy: .never))
    }
}

struct QuickActionsEntry: TimelineEntry {
    let date: Date
}

struct QuickActionsWidgetView: View {
    let entry: QuickActionsEntry
    private var t: WidgetTint { .current(sharedIsDarkMode ? .dark : .light) }

    var body: some View {
        HStack(spacing: 10) {
            Link(destination: URL(string: "finanzapp://add?type=expense")!) {
                QuickActionButton(label: "Nuova Uscita", icon: "arrow.up", color: t.expense)
            }
            Link(destination: URL(string: "finanzapp://add?type=income")!) {
                QuickActionButton(label: "Nuova Entrata", icon: "arrow.down", color: t.income)
            }
        }
        .padding(12)
    }
}

private struct QuickActionButton: View {
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(color.opacity(0.18)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 15, weight: .bold)).foregroundStyle(color)
            }
            Text(label)
                .font(.system(size: 12.5, weight: .bold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(color.opacity(0.25), lineWidth: 1))
    }
}

// MARK: - Widget Bundle

@main
struct FinanzAppWidgetBundle: WidgetBundle {
    var body: some Widget {
        StatsWidget()
        QuickAddWidget()
    }
}
