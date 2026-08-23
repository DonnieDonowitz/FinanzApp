# Graph Report - FinanzApp  (2026-08-23)

## Corpus Check
- 34 files · ~36,106 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 739 nodes · 1567 edges · 31 communities (25 shown, 6 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 134 edges (avg confidence: 0.83)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `0bc40fd4`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- L
- Widgets.swift
- DatabaseManager
- HomeView
- AppColors
- AddTransactionView
- SwiftUI
- BalanceCard
- BarChartView
- StatisticsView
- Theme.swift
- SettingsView
- AppViewModel
- GlassView
- SwipeToDeleteRow
- View
- AppLanguage
- FinanzApp.swift
- TabItem
- ConfirmDialog
- AppDelegate
- SectionCard
- EmptyState
- App Group group.com.finanzapp.app
- CLAUDE.md AGENTS.md Include Directive
- .expenseAlertBody
- build-ipa.sh
- FinanzApp iOS App Identity
- FinanzApp iOS App Icon
- FinanzApp Dark App Icon

## God Nodes (most connected - your core abstractions)
1. `L` - 138 edges
2. `AppViewModel` - 84 edges
3. `AppColors` - 49 edges
4. `DatabaseManager` - 44 edges
5. `GlassView` - 41 edges
6. `Transaction` - 29 edges
7. `Category` - 27 edges
8. `SettingsView` - 25 edges
9. `RecurringTransaction` - 18 edges
10. `AppLanguage` - 18 edges

## Surprising Connections (you probably didn't know these)
- `.timeAgo` --calls--> `formatDateShort()`  [INFERRED]
  Native_iOS/FinanzApp/Views/Components/TransactionRow.swift → Native_iOS/FinanzApp/Theme/Theme.swift
- `.category` --references--> `AppViewModel`  [INFERRED]
  Native_iOS/FinanzApp/Views/StatisticsView.swift → Native_iOS/FinanzApp/ViewModels/AppViewModel.swift
- `.body` --calls--> `GlassView`  [INFERRED]
  Native_iOS/FinanzApp/Views/Components/BalanceCard.swift → Native_iOS/FinanzApp/Views/Components/GlassView.swift
- `.body` --calls--> `GlassView`  [INFERRED]
  Native_iOS/FinanzApp/Views/Components/EmptyState.swift → Native_iOS/FinanzApp/Views/Components/GlassView.swift
- `.body` --calls--> `GlassView`  [INFERRED]
  Native_iOS/FinanzApp/Views/Components/SectionCard.swift → Native_iOS/FinanzApp/Views/Components/GlassView.swift

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **FinanzApp / FinanzAppWidget App Group Data Sharing** — native_ios_project_finanzapp, native_ios_project_finanzappwidget, native_ios_project_app_group [EXTRACTED 1.00]

## Communities (31 total, 6 thin omitted)

### Community 0 - "L"
Cohesion: 0.03
Nodes (129): L, .active, .add, .addCategory, .addCustomThreshold, .all, .amount, .annualAnalysis (+121 more)

### Community 1 - "Widgets.swift"
Cohesion: 0.07
Nodes (44): Context, FinanzAppWidgetBundle, .body, QuickActionButton, .body, QuickActionsEntry, QuickActionsProvider, QuickActionsWidgetView (+36 more)

### Community 2 - "DatabaseManager"
Cohesion: 0.11
Nodes (8): DatabaseManager, .dbPath, Any, Bool, Int, Int64, String, OpaquePointer

### Community 3 - "HomeView"
Cohesion: 0.23
Nodes (9): HomeView, .body, .header, SectionHeader, .body, Binding, Bool, String (+1 more)

### Community 4 - "AppColors"
Cohesion: 0.06
Nodes (33): AppColors, .accent, .balanceGradient, .balanceHighlight, .bg, .divider, .expense, .expenseLight (+25 more)

### Community 5 - "AddTransactionView"
Cohesion: 0.31
Nodes (8): AddTransactionView, .canSubmit, Bool, Color, String, Void, TypeChip, .body

### Community 6 - "SwiftUI"
Cohesion: 0.18
Nodes (6): AppLogo, .body, QuickAddBar, .body, Void, SwiftUI

### Community 7 - "BalanceCard"
Cohesion: 0.24
Nodes (10): BalanceCard, .amountDec, .amountInt, .body, FlowChip, .body, .flowAmount, Color (+2 more)

### Community 9 - "BarChartView"
Cohesion: 0.13
Nodes (21): Angle, BarData, CGRect, BarChartView, .body, .maxValue, BarData, ChartLegend (+13 more)

### Community 10 - "StatisticsView"
Cohesion: 0.14
Nodes (21): CaseIterable, DateFormatter, BarData, CategoryBreakdownRow, .category, .color, RatioPoint, StatisticsView (+13 more)

### Community 13 - "Theme.swift"
Cohesion: 0.08
Nodes (42): Font, .categoryName, AppTinting, BackgroundGradient, .body, categoryIcon(), CategoryIconView, .body (+34 more)

### Community 16 - "SettingsView"
Cohesion: 0.06
Nodes (41): FileDocument, FileWrapper, NotificationManager, Bool, Void, Int, FormField, .body (+33 more)

### Community 17 - "AppViewModel"
Cohesion: 0.05
Nodes (48): Codable, Combine, Identifiable, Category, .displayColor, .isIncome, Date, .currentMonth (+40 more)

### Community 25 - "GlassView"
Cohesion: 0.16
Nodes (14): GlassIntensity, regular, strong, GlassView, .bg, .body, .border, .highlight (+6 more)

### Community 27 - "SwipeToDeleteRow"
Cohesion: 0.06
Nodes (37): .monthsShort, AnnualSummaryView, .months, .totalBalance, Double, Int, String, Bool (+29 more)

### Community 28 - "View"
Cohesion: 0.11
Nodes (23): ChartView, .body, View, BrandToggle, .body, RecurringRow, .category, .categoryName (+15 more)

### Community 35 - "AppLanguage"
Cohesion: 0.07
Nodes (25): Foundation, Hashable, Scheduling, Bool, String, Notification.Name, AppLanguage, de (+17 more)

### Community 45 - "FinanzApp.swift"
Cohesion: 0.22
Nodes (10): App, ContentView, .body, FinanzApp, .body, MainTabView, .body, .tabBar (+2 more)

### Community 66 - "TabItem"
Cohesion: 0.29
Nodes (6): Any, Bool, String, TabItem, .body, UIApplication

### Community 71 - "ConfirmDialog"
Cohesion: 0.53
Nodes (5): ConfirmDialog, .body, Bool, String, Void

### Community 76 - "AppDelegate"
Cohesion: 0.20
Nodes (9): AppDelegate, Void, NSObject, UIApplicationDelegate, UNNotification, UNNotificationPresentationOptions, UNNotificationResponse, UNUserNotificationCenter (+1 more)

### Community 77 - "SectionCard"
Cohesion: 0.60
Nodes (4): SectionCard, .body, Content, String

### Community 82 - "EmptyState"
Cohesion: 0.50
Nodes (3): EmptyState, .body, String

### Community 83 - "App Group group.com.finanzapp.app"
Cohesion: 1.00
Nodes (3): App Group group.com.finanzapp.app, FinanzApp (iOS App Target), FinanzAppWidget (WidgetKit App Extension)

## Knowledge Gaps
- **128 isolated node(s):** `.dbPath`, `.isIncome`, `.displayColor`, `.isExpense`, `.isExpense` (+123 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `View` connect `View` to `Widgets.swift`, `TabItem`, `HomeView`, `AddTransactionView`, `SwiftUI`, `BalanceCard`, `ConfirmDialog`, `BarChartView`, `StatisticsView`, `Theme.swift`, `FinanzApp.swift`, `SectionCard`, `SettingsView`, `AppViewModel`, `EmptyState`, `GlassView`, `SwipeToDeleteRow`?**
  _High betweenness centrality (0.248) - this node is a cross-community bridge._
- **Why does `AppViewModel` connect `AppViewModel` to `DatabaseManager`, `AppLanguage`, `HomeView`, `AddTransactionView`, `StatisticsView`, `Theme.swift`, `FinanzApp.swift`, `SettingsView`, `GlassView`, `SwipeToDeleteRow`, `View`?**
  _High betweenness centrality (0.243) - this node is a cross-community bridge._
- **Why does `L` connect `L` to `AppLanguage`, `.expenseAlertBody`, `StatisticsView`, `Theme.swift`, `AppViewModel`, `SwipeToDeleteRow`?**
  _High betweenness centrality (0.233) - this node is a cross-community bridge._
- **What connects `.dbPath`, `.isIncome`, `.displayColor` to the rest of the system?**
  _128 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `L` be split into smaller, more focused modules?**
  _Cohesion score 0.030530709600477043 - nodes in this community are weakly interconnected._
- **Should `Widgets.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.06545879602571596 - nodes in this community are weakly interconnected._
- **Should `DatabaseManager` be split into smaller, more focused modules?**
  _Cohesion score 0.11054421768707483 - nodes in this community are weakly interconnected._