# Graph Report - FinanzApp  (2026-08-23)

## Corpus Check
- 38 files · ~39,079 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 842 nodes · 1823 edges · 45 communities (37 shown, 8 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 170 edges (avg confidence: 0.83)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `f8840e8d`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- L
- .getTimeline
- DatabaseManager
- HomeView
- AppColors
- CategoryEntity
- SwiftUI
- BalanceCard
- StatisticsView
- GapDonutChart
- BackupFrequency
- View
- Gamification
- Theme.swift
- .addTransaction
- .body
- SettingsView
- AppViewModel
- Widgets.swift
- QuickActionsEntry
- TransactionRow
- StatsWidgetView
- TextFileDocument
- CategoryIconView
- Date
- GlassView
- StatsEntry
- AddTransactionView
- RecurringRow
- NotificationManager.swift
- .budgetCard
- AGENTS.md
- AppLanguage
- FinanzApp.swift
- AppDelegate
- SectionCard
- EmptyState
- App Group group.com.finanzapp.app
- CLAUDE.md AGENTS.md Include Directive
- String
- build-ipa.sh
- FinanzApp iOS App Identity
- FinanzApp iOS App Icon
- FinanzApp Dark App Icon

## God Nodes (most connected - your core abstractions)
1. `L` - 162 edges
2. `AppViewModel` - 96 edges
3. `AppColors` - 51 edges
4. `GlassView` - 48 edges
5. `DatabaseManager` - 44 edges
6. `StatisticsView` - 35 edges
7. `Transaction` - 34 edges
8. `SettingsView` - 27 edges
9. `Category` - 26 edges
10. `HomeView` - 19 edges

## Surprising Connections (you probably didn't know these)
- `.body` --calls--> `GlassView`  [INFERRED]
  Native_iOS/FinanzApp/Views/Components/BalanceCard.swift → Native_iOS/FinanzApp/Views/Components/GlassView.swift
- `.body` --calls--> `GlassView`  [INFERRED]
  Native_iOS/FinanzApp/Views/Components/EmptyState.swift → Native_iOS/FinanzApp/Views/Components/GlassView.swift
- `.body` --calls--> `GlassView`  [INFERRED]
  Native_iOS/FinanzApp/Views/Components/SectionCard.swift → Native_iOS/FinanzApp/Views/Components/GlassView.swift
- `.body` --calls--> `BackgroundGradient`  [INFERRED]
  Native_iOS/FinanzApp/App/FinanzApp.swift → Native_iOS/FinanzApp/Theme/Theme.swift
- `.body` --calls--> `LevelUpOverlay`  [INFERRED]
  Native_iOS/FinanzApp/App/FinanzApp.swift → Native_iOS/FinanzApp/Views/Components/LevelUpOverlay.swift

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **FinanzApp / FinanzAppWidget App Group Data Sharing** — native_ios_project_finanzapp, native_ios_project_finanzappwidget, native_ios_project_app_group [EXTRACTED 1.00]

## Communities (45 total, 8 thin omitted)

### Community 0 - "L"
Cohesion: 0.03
Nodes (143): L, .active, .add, .addCategory, .addCustomThreshold, .advancedStatistics, .all, .amount (+135 more)

### Community 1 - ".getTimeline"
Cohesion: 0.19
Nodes (10): .mediumBody, .smallBody, Color, Double, Int, String, widgetCurrency(), WidgetData (+2 more)

### Community 2 - "DatabaseManager"
Cohesion: 0.07
Nodes (24): Codable, Identifiable, DatabaseManager, .dbPath, Any, Bool, Int, Int64 (+16 more)

### Community 3 - "HomeView"
Cohesion: 0.08
Nodes (24): QuickAddBar, .body, Void, Bool, CGFloat, Content, String, Void (+16 more)

### Community 4 - "AppColors"
Cohesion: 0.05
Nodes (46): LinearGradient, .tabBar, String, TabItem, .body, AppColors, .accent, .balanceGradient (+38 more)

### Community 5 - "CategoryEntity"
Cohesion: 0.10
Nodes (23): AppEntity, AppIntent, AppIntents, AppShortcut, AppShortcutsProvider, DisplayRepresentation, EntityQuery, IntentResult (+15 more)

### Community 6 - "SwiftUI"
Cohesion: 0.13
Nodes (9): AddRecurringView, .canSubmit, Bool, AppLogo, .body, BudgetEditSheet, .parsedAmount, Double (+1 more)

### Community 7 - "BalanceCard"
Cohesion: 0.24
Nodes (10): BalanceCard, .amountDec, .amountInt, .body, FlowChip, .body, .flowAmount, Color (+2 more)

### Community 8 - "StatisticsView"
Cohesion: 0.13
Nodes (16): DateFormatter, StatisticsView, .body, .currentHalf, .currentYear, .header, .monthDetail, .monthStepper (+8 more)

### Community 9 - "GapDonutChart"
Cohesion: 0.14
Nodes (19): CGPoint, ChartLegend, .body, DailyBarChart, .barSpacing, .body, .maxValue, GapDonutChart (+11 more)

### Community 10 - "BackupFrequency"
Cohesion: 0.14
Nodes (12): CaseIterable, BackupFrequency, daily, .label, .minimumDays, monthly, weekly, StatsPeriod (+4 more)

### Community 11 - "View"
Cohesion: 0.16
Nodes (21): View, CategoryFormSheet, CategoryManagerView, .body, CategoryRow, FormField, .body, InfoRow (+13 more)

### Community 12 - "Gamification"
Cohesion: 0.17
Nodes (8): Foundation, Gamification, LevelInfo, Double, Int, Scheduling, Bool, String

### Community 13 - "Theme.swift"
Cohesion: 0.20
Nodes (14): AppTinting, categoryIcon(), Color, ColorScheme, .tinting, DarkTints, formatDate(), formatDateShort() (+6 more)

### Community 14 - ".addTransaction"
Cohesion: 0.12
Nodes (8): Combine, Int, .categories, .monthlyBudget, .transactions, Int64, TopCategory, WidgetKit

### Community 15 - ".body"
Cohesion: 0.18
Nodes (14): .categoryName, BackgroundGradient, .body, .body, .body, CategoryPicker, .body, .filteredCategories (+6 more)

### Community 16 - "SettingsView"
Cohesion: 0.13
Nodes (18): NotificationManager, Bool, Void, ImporterKind, autoBackupFolder, restoreBackup, SettingsView, .appearanceSection (+10 more)

### Community 17 - "AppViewModel"
Cohesion: 0.12
Nodes (14): AppViewModel, .autoBackupsDirectory, .currentLevel, .isBudgetConfigured, .isOverBudget, .levelProgress, .monthBalance, .monthBudgetRemaining (+6 more)

### Community 18 - "Widgets.swift"
Cohesion: 0.23
Nodes (13): FinanzAppWidgetBundle, .body, QuickActionsWidgetView, .t, QuickAddWidget, .body, StatsWidget, .body (+5 more)

### Community 19 - "QuickActionsEntry"
Cohesion: 0.27
Nodes (8): Context, QuickActionsEntry, QuickActionsProvider, StatsProvider, Void, Timeline, TimelineEntry, TimelineProvider

### Community 20 - "TransactionRow"
Cohesion: 0.17
Nodes (12): formatCurrency(), Double, Color, String, TransactionRow, .category, .categoryColor, .categoryName (+4 more)

### Community 21 - "StatsWidgetView"
Cohesion: 0.18
Nodes (12): QuickActionButton, .body, .body, StatsWidgetView, .body, .monthName, .progressBar, .statusColor (+4 more)

### Community 22 - "TextFileDocument"
Cohesion: 0.17
Nodes (10): FileDocument, FileWrapper, .backupSection, TextFileDocument, .readableContentTypes, .writableContentTypes, UTType, .finanzBackup (+2 more)

### Community 23 - "CategoryIconView"
Cohesion: 0.29
Nodes (7): Font, CategoryIconView, .body, isSFSymbolName(), Bool, CGFloat, .body

### Community 24 - "Date"
Cohesion: 0.29
Nodes (6): Date, .currentMonth, .currentString, .fullIT, .shortIT, .yearMonth

### Community 25 - "GlassView"
Cohesion: 0.17
Nodes (13): GlassIntensity, regular, strong, GlassView, .bg, .border, .highlight, .insetOpacity (+5 more)

### Community 26 - "StatsEntry"
Cohesion: 0.29
Nodes (7): StatsEntry, .isOverBudget, .progress, .remaining, Bool, Double, Int

### Community 27 - "AddTransactionView"
Cohesion: 0.11
Nodes (23): .monthsShort, getCurrentMonth(), AddTransactionView, .canSubmit, Bool, Color, String, Void (+15 more)

### Community 28 - "RecurringRow"
Cohesion: 0.11
Nodes (20): BrandToggle, .body, RecurringRow, .category, .categoryName, .color, RecurringView, .activeRecurring (+12 more)

### Community 35 - "AppLanguage"
Cohesion: 0.12
Nodes (18): Hashable, AppLanguage, de, en, es, fr, .id, it (+10 more)

### Community 45 - "FinanzApp.swift"
Cohesion: 0.24
Nodes (9): App, ContentView, .body, FinanzApp, .body, MainTabView, .body, Int (+1 more)

### Community 76 - "AppDelegate"
Cohesion: 0.14
Nodes (12): AppDelegate, Any, Bool, Void, NSObject, UIApplication, UIApplicationDelegate, UNNotification (+4 more)

### Community 77 - "SectionCard"
Cohesion: 0.47
Nodes (4): SectionCard, .body, Content, String

### Community 82 - "EmptyState"
Cohesion: 0.50
Nodes (3): EmptyState, .body, String

### Community 83 - "App Group group.com.finanzapp.app"
Cohesion: 1.00
Nodes (3): App Group group.com.finanzapp.app, FinanzApp (iOS App Target), FinanzAppWidget (WidgetKit App Extension)

### Community 91 - "String"
Cohesion: 0.16
Nodes (6): Int, Double, .levelCard, .summaryCard, Color, String

## Knowledge Gaps
- **145 isolated node(s):** `.dbPath`, `AppIntents`, `.parameterSummary`, `.isIncome`, `.displayColor` (+140 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppViewModel` connect `AppViewModel` to `DatabaseManager`, `AppLanguage`, `HomeView`, `SwiftUI`, `AddTransactionView`, `StatisticsView`, `BackupFrequency`, `View`, `Gamification`, `FinanzApp.swift`, `.addTransaction`, `.body`, `SettingsView`, `Theme.swift`, `TransactionRow`, `GlassView`, `String`, `RecurringRow`?**
  _High betweenness centrality (0.241) - this node is a cross-community bridge._
- **Why does `L` connect `L` to `AppLanguage`, `HomeView`, `CategoryEntity`, `String`, `View`, `.body`, `AddTransactionView`, `.budgetCard`?**
  _High betweenness centrality (0.227) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `HomeView`, `AppColors`, `SwiftUI`, `BalanceCard`, `StatisticsView`, `GapDonutChart`, `.body`, `SettingsView`, `Widgets.swift`, `TransactionRow`, `StatsWidgetView`, `CategoryIconView`, `GlassView`, `AddTransactionView`, `RecurringRow`, `FinanzApp.swift`, `SectionCard`, `EmptyState`, `String`?**
  _High betweenness centrality (0.218) - this node is a cross-community bridge._
- **What connects `.dbPath`, `AppIntents`, `.parameterSummary` to the rest of the system?**
  _145 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `L` be split into smaller, more focused modules?**
  _Cohesion score 0.027583527583527584 - nodes in this community are weakly interconnected._
- **Should `DatabaseManager` be split into smaller, more focused modules?**
  _Cohesion score 0.07267884322678843 - nodes in this community are weakly interconnected._
- **Should `HomeView` be split into smaller, more focused modules?**
  _Cohesion score 0.08095238095238096 - nodes in this community are weakly interconnected._