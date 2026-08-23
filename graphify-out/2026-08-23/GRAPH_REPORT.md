# Graph Report - FinanzApp  (2026-08-23)

## Corpus Check
- 38 files · ~39,606 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 846 nodes · 1830 edges · 52 communities (42 shown, 10 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 170 edges (avg confidence: 0.83)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `fc44cfa5`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- L
- .getTimeline
- DatabaseManager
- HomeView
- AppColors
- CategoryEntity
- Widgets.swift
- StatisticsView
- QuickActionsEntry
- GapDonutChart
- TabItem
- View
- Gamification
- CategoryIconView
- Int
- Theme.swift
- SettingsView
- AppViewModel
- Int
- ConfirmDialog
- StatsWidgetView
- AddTransactionView
- String
- BackupFrequency
- MainTabView
- GlassView
- Date
- SwipeToDeleteRow
- .dailyChartCard
- StatsEntry
- .budgetCard
- AGENTS.md
- SectionCard
- SwiftUI
- TransactionRow
- AppLanguage
- NotificationManager
- .performAutoBackupIfNeeded
- SharedData.swift
- .dismiss
- FinanzApp.swift
- AppDelegate
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

## Communities (52 total, 10 thin omitted)

### Community 0 - "L"
Cohesion: 0.03
Nodes (143): L, .active, .add, .addCategory, .addCustomThreshold, .advancedStatistics, .all, .amount (+135 more)

### Community 1 - ".getTimeline"
Cohesion: 0.35
Nodes (5): Double, Int, String, WidgetData, .sharedDBPath

### Community 2 - "DatabaseManager"
Cohesion: 0.08
Nodes (23): Codable, Identifiable, DatabaseManager, .dbPath, Any, Bool, Int, Int64 (+15 more)

### Community 3 - "HomeView"
Cohesion: 0.09
Nodes (23): BalanceCard, .amountDec, .amountInt, .body, FlowChip, .body, .flowAmount, Color (+15 more)

### Community 4 - "AppColors"
Cohesion: 0.06
Nodes (34): AppColors, .accent, .balanceGradient, .balanceHighlight, .bg, .divider, .expense, .expenseLight (+26 more)

### Community 5 - "CategoryEntity"
Cohesion: 0.09
Nodes (23): AppEntity, AppIntent, AppIntents, AppShortcut, AppShortcutsProvider, DisplayRepresentation, EntityQuery, IntentResult (+15 more)

### Community 6 - "Widgets.swift"
Cohesion: 0.23
Nodes (13): FinanzAppWidgetBundle, .body, QuickActionsWidgetView, .t, QuickAddWidget, .body, StatsWidget, .body (+5 more)

### Community 7 - "StatisticsView"
Cohesion: 0.10
Nodes (22): CaseIterable, DateFormatter, StatisticsView, .body, .currentHalf, .currentYear, .header, .monthDetail (+14 more)

### Community 8 - "QuickActionsEntry"
Cohesion: 0.27
Nodes (8): Context, QuickActionsEntry, QuickActionsProvider, StatsProvider, Void, Timeline, TimelineEntry, TimelineProvider

### Community 9 - "GapDonutChart"
Cohesion: 0.13
Nodes (21): CGPoint, ChartLegend, .body, DailyBarChart, .barSpacing, .body, .maxValue, GapDonutChart (+13 more)

### Community 10 - "TabItem"
Cohesion: 0.25
Nodes (7): Namespace, Any, Bool, String, TabItem, .body, UIApplication

### Community 11 - "View"
Cohesion: 0.18
Nodes (18): View, CategoryFormSheet, CategoryManagerView, .body, CategoryRow, InfoRow, .body, SectionLabel (+10 more)

### Community 12 - "Gamification"
Cohesion: 0.16
Nodes (9): Foundation, Gamification, LevelInfo, Double, Int, Scheduling, Bool, String (+1 more)

### Community 13 - "CategoryIconView"
Cohesion: 0.15
Nodes (19): Font, .categoryName, BackgroundGradient, categoryIcon(), CategoryIconView, resolvedIcon(), CGFloat, AddRecurringView (+11 more)

### Community 14 - "Int"
Cohesion: 0.22
Nodes (3): Int, Int, .levelCard

### Community 15 - "Theme.swift"
Cohesion: 0.19
Nodes (14): AppTinting, .body, Color, ColorScheme, .tinting, DarkTints, formatDate(), frequencyLabel() (+6 more)

### Community 16 - "SettingsView"
Cohesion: 0.19
Nodes (14): ImporterKind, autoBackupFolder, restoreBackup, SettingsView, .appearanceSection, .autoBackupSection, .body, .expenseAlertSection (+6 more)

### Community 17 - "AppViewModel"
Cohesion: 0.12
Nodes (14): AppViewModel, .autoBackupsDirectory, .categories, .currentLevel, .isBudgetConfigured, .isOverBudget, .levelProgress, .monthBalance (+6 more)

### Community 19 - "ConfirmDialog"
Cohesion: 0.43
Nodes (5): ConfirmDialog, .body, Bool, String, Void

### Community 20 - "StatsWidgetView"
Cohesion: 0.18
Nodes (12): QuickActionButton, .body, .body, StatsWidgetView, .body, .monthName, .progressBar, .statusColor (+4 more)

### Community 21 - "AddTransactionView"
Cohesion: 0.33
Nodes (8): AddTransactionView, .canSubmit, Bool, Color, String, Void, TypeChip, .body

### Community 22 - "String"
Cohesion: 0.14
Nodes (13): FileDocument, FileWrapper, FormField, .body, Content, String, TextFileDocument, .readableContentTypes (+5 more)

### Community 23 - "BackupFrequency"
Cohesion: 0.18
Nodes (9): Combine, BackupFrequency, daily, .label, .minimumDays, monthly, weekly, TopCategory (+1 more)

### Community 24 - "MainTabView"
Cohesion: 0.32
Nodes (7): LinearGradient, MainTabView, .tabBar, Int, .body, .body, .body

### Community 25 - "GlassView"
Cohesion: 0.17
Nodes (13): GlassIntensity, regular, strong, GlassView, .bg, .border, .highlight, .insetOpacity (+5 more)

### Community 26 - "Date"
Cohesion: 0.29
Nodes (6): Date, .currentMonth, .currentString, .fullIT, .shortIT, .yearMonth

### Community 27 - "SwipeToDeleteRow"
Cohesion: 0.05
Nodes (44): .body, .monthsShort, Bool, CGFloat, Content, String, Void, SwipeToDeleteRow (+36 more)

### Community 29 - "StatsEntry"
Cohesion: 0.29
Nodes (7): StatsEntry, .isOverBudget, .progress, .remaining, Bool, Double, Int

### Community 32 - "SectionCard"
Cohesion: 0.47
Nodes (4): SectionCard, .body, Content, String

### Community 33 - "SwiftUI"
Cohesion: 0.18
Nodes (6): AppLogo, .body, BudgetEditSheet, .parsedAmount, Double, SwiftUI

### Community 34 - "TransactionRow"
Cohesion: 0.15
Nodes (14): formatCurrency(), formatDateShort(), Double, Color, String, TransactionRow, .category, .categoryColor (+6 more)

### Community 35 - "AppLanguage"
Cohesion: 0.12
Nodes (18): Hashable, AppLanguage, de, en, es, fr, .id, it (+10 more)

### Community 36 - "NotificationManager"
Cohesion: 0.33
Nodes (4): NotificationManager, Bool, Void, UNAuthorizationStatus

### Community 38 - "SharedData.swift"
Cohesion: 0.29
Nodes (5): .mediumBody, .smallBody, Color, widgetCurrency(), SQLite3

### Community 39 - ".dismiss"
Cohesion: 0.40
Nodes (4): LevelUpOverlay, .body, Int, Void

### Community 45 - "FinanzApp.swift"
Cohesion: 0.22
Nodes (8): App, ContentView, .body, FinanzApp, .body, Notification.Name, Scene, UserNotifications

### Community 76 - "AppDelegate"
Cohesion: 0.20
Nodes (9): AppDelegate, Void, NSObject, UIApplicationDelegate, UNNotification, UNNotificationPresentationOptions, UNNotificationResponse, UNUserNotificationCenter (+1 more)

### Community 82 - "EmptyState"
Cohesion: 0.50
Nodes (3): EmptyState, .body, String

### Community 83 - "App Group group.com.finanzapp.app"
Cohesion: 1.00
Nodes (3): App Group group.com.finanzapp.app, FinanzApp (iOS App Target), FinanzAppWidget (WidgetKit App Extension)

### Community 91 - "String"
Cohesion: 0.17
Nodes (4): Double, .summaryCard, Color, String

## Knowledge Gaps
- **146 isolated node(s):** `.dbPath`, `AppIntents`, `.parameterSummary`, `.isIncome`, `.displayColor` (+141 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppViewModel` connect `AppViewModel` to `DatabaseManager`, `HomeView`, `StatisticsView`, `View`, `Gamification`, `CategoryIconView`, `Int`, `SettingsView`, `Int`, `AddTransactionView`, `BackupFrequency`, `MainTabView`, `GlassView`, `SwipeToDeleteRow`, `.dailyChartCard`, `SwiftUI`, `TransactionRow`, `AppLanguage`, `.performAutoBackupIfNeeded`, `.processRecurringIfNeeded`, `FinanzApp.swift`, `String`?**
  _High betweenness centrality (0.240) - this node is a cross-community bridge._
- **Why does `L` connect `L` to `AppLanguage`, `CategoryEntity`, `String`, `View`, `CategoryIconView`, `Int`, `SwipeToDeleteRow`, `.dailyChartCard`, `.budgetCard`?**
  _High betweenness centrality (0.226) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `HomeView`, `Widgets.swift`, `StatisticsView`, `GapDonutChart`, `TabItem`, `CategoryIconView`, `SettingsView`, `ConfirmDialog`, `StatsWidgetView`, `AddTransactionView`, `String`, `MainTabView`, `GlassView`, `SwipeToDeleteRow`, `SectionCard`, `SwiftUI`, `TransactionRow`, `.dismiss`, `FinanzApp.swift`, `EmptyState`, `String`?**
  _High betweenness centrality (0.220) - this node is a cross-community bridge._
- **What connects `.dbPath`, `AppIntents`, `.parameterSummary` to the rest of the system?**
  _146 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `L` be split into smaller, more focused modules?**
  _Cohesion score 0.027583527583527584 - nodes in this community are weakly interconnected._
- **Should `DatabaseManager` be split into smaller, more focused modules?**
  _Cohesion score 0.08346134152585766 - nodes in this community are weakly interconnected._
- **Should `HomeView` be split into smaller, more focused modules?**
  _Cohesion score 0.09195402298850575 - nodes in this community are weakly interconnected._