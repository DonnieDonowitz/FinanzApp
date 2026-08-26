# Graph Report - FinanzApp  (2026-08-26)

## Corpus Check
- 38 files · ~27,669 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 819 nodes · 1778 edges · 43 communities (36 shown, 7 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 159 edges (avg confidence: 0.83)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `f978bc88`
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
- StatsPeriod
- SectionLabel
- Gamification
- SettingsView.swift
- String
- Theme.swift
- SettingsView
- AppViewModel
- Scheduling
- ConfirmDialog
- StatsWidgetView
- RecurringRow
- TextFileDocument
- GlassView
- AddTransactionView
- StatsEntry
- .budgetCard
- AGENTS.md
- SectionCard
- SwiftUI
- AppLanguage
- FlowChip
- Foundation
- MainTabView
- EmptyState
- App Group group.com.finanzapp.app
- CLAUDE.md AGENTS.md Include Directive
- View
- build-ipa.sh
- FinanzApp iOS App Identity
- FinanzApp iOS App Icon
- FinanzApp Dark App Icon

## God Nodes (most connected - your core abstractions)
1. `L` - 162 edges
2. `AppViewModel` - 90 edges
3. `DatabaseManager` - 44 edges
4. `AppColors` - 44 edges
5. `GlassView` - 44 edges
6. `StatisticsView` - 35 edges
7. `Transaction` - 34 edges
8. `Category` - 26 edges
9. `SettingsView` - 25 edges
10. `RecurringTransaction` - 18 edges

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

## Communities (43 total, 7 thin omitted)

### Community 0 - "L"
Cohesion: 0.03
Nodes (143): L, .active, .add, .addCategory, .advancedStatistics, .all, .amount, .annualAnalysis (+135 more)

### Community 1 - ".getTimeline"
Cohesion: 0.35
Nodes (5): Double, Int, String, WidgetData, .sharedDBPath

### Community 2 - "DatabaseManager"
Cohesion: 0.11
Nodes (8): DatabaseManager, .dbPath, Any, Bool, Int, Int64, String, OpaquePointer

### Community 3 - "HomeView"
Cohesion: 0.09
Nodes (24): QuickAddBar, .body, Void, Bool, CGFloat, Content, String, Void (+16 more)

### Community 4 - "AppColors"
Cohesion: 0.09
Nodes (23): AppColors, .bg, .divider, .expense, .expenseLight, .glass, .glassBorder, .glassBorderStrong (+15 more)

### Community 5 - "CategoryEntity"
Cohesion: 0.10
Nodes (23): AppEntity, AppIntent, AppIntents, AppShortcut, AppShortcutsProvider, DisplayRepresentation, EntityQuery, IntentResult (+15 more)

### Community 6 - "Widgets.swift"
Cohesion: 0.24
Nodes (11): FinanzAppWidgetBundle, .body, QuickAddWidget, .body, StatsWidget, .body, WidgetBackground, .body (+3 more)

### Community 7 - "StatisticsView"
Cohesion: 0.14
Nodes (16): DateFormatter, StatisticsView, .body, .currentHalf, .currentYear, .header, .monthDetail, .monthStepper (+8 more)

### Community 8 - "QuickActionsEntry"
Cohesion: 0.27
Nodes (8): Context, QuickActionsEntry, QuickActionsProvider, StatsProvider, Void, Timeline, TimelineEntry, TimelineProvider

### Community 9 - "GapDonutChart"
Cohesion: 0.13
Nodes (22): CGPoint, ChartLegend, .body, DailyBarChart, .barSpacing, .body, .maxValue, GapDonutChart (+14 more)

### Community 10 - "StatsPeriod"
Cohesion: 0.29
Nodes (6): CaseIterable, StatsPeriod, .label, month, semester, year

### Community 11 - "SectionLabel"
Cohesion: 0.17
Nodes (14): FormField, .body, InfoRow, .body, SectionLabel, .body, SettingsRow, .body (+6 more)

### Community 12 - "Gamification"
Cohesion: 0.15
Nodes (10): Gamification, LevelInfo, Double, Int, NotificationManager, Bool, Int, Void (+2 more)

### Community 13 - "SettingsView.swift"
Cohesion: 0.24
Nodes (8): CategoryFormSheet, CategoryManagerView, .body, CategoryRow, .body, Void, UIKit, UniformTypeIdentifiers

### Community 14 - "String"
Cohesion: 0.28
Nodes (5): Int, .levelCard, .budgetSection, .summaryCard, String

### Community 15 - "Theme.swift"
Cohesion: 0.07
Nodes (41): Font, .categoryName, AppTinting, BackgroundGradient, .body, categoryIcon(), CategoryIconView, .body (+33 more)

### Community 16 - "SettingsView"
Cohesion: 0.19
Nodes (14): ImporterKind, autoBackupFolder, restoreBackup, SettingsView, .appearanceSection, .autoBackupSection, .body, .expenseAlertSection (+6 more)

### Community 17 - "AppViewModel"
Cohesion: 0.06
Nodes (35): Codable, Identifiable, Category, .displayColor, .isIncome, RecurringTransaction, .isExpense, Bool (+27 more)

### Community 18 - "Scheduling"
Cohesion: 0.47
Nodes (3): Scheduling, Bool, String

### Community 19 - "ConfirmDialog"
Cohesion: 0.53
Nodes (5): ConfirmDialog, .body, Bool, String, Void

### Community 20 - "StatsWidgetView"
Cohesion: 0.15
Nodes (17): QuickActionButton, .body, QuickActionsWidgetView, .body, .t, StatsWidgetView, .body, .mediumBody (+9 more)

### Community 21 - "RecurringRow"
Cohesion: 0.09
Nodes (23): AddRecurringView, .canSubmit, Bool, BrandToggle, .body, RecurringRow, .category, .categoryName (+15 more)

### Community 22 - "TextFileDocument"
Cohesion: 0.18
Nodes (9): FileDocument, FileWrapper, TextFileDocument, .readableContentTypes, .writableContentTypes, UTType, .finanzBackup, ReadConfiguration (+1 more)

### Community 25 - "GlassView"
Cohesion: 0.23
Nodes (10): GlassIntensity, regular, strong, GlassView, .bg, .body, .border, CGFloat (+2 more)

### Community 27 - "AddTransactionView"
Cohesion: 0.11
Nodes (23): .monthsShort, getCurrentMonth(), AddTransactionView, .canSubmit, Bool, Color, String, Void (+15 more)

### Community 29 - "StatsEntry"
Cohesion: 0.15
Nodes (13): Date, .currentMonth, .currentString, .fullIT, .shortIT, .yearMonth, StatsEntry, .isOverBudget (+5 more)

### Community 32 - "SectionCard"
Cohesion: 0.60
Nodes (4): SectionCard, .body, Content, String

### Community 33 - "SwiftUI"
Cohesion: 0.14
Nodes (9): BudgetEditSheet, .body, .parsedAmount, Double, LevelUpOverlay, .body, Int, Void (+1 more)

### Community 35 - "AppLanguage"
Cohesion: 0.12
Nodes (18): Hashable, AppLanguage, de, en, es, fr, .id, it (+10 more)

### Community 37 - "FlowChip"
Cohesion: 0.24
Nodes (9): BalanceCard, .body, FlowChip, .body, .flowAmount, Bool, Color, Double (+1 more)

### Community 38 - "Foundation"
Cohesion: 0.18
Nodes (5): Combine, Foundation, Color, SQLite3, WidgetKit

### Community 45 - "MainTabView"
Cohesion: 0.07
Nodes (28): App, Namespace, AppDelegate, ContentView, .body, FinanzApp, .body, MainTabView (+20 more)

### Community 82 - "EmptyState"
Cohesion: 0.50
Nodes (3): EmptyState, .body, String

### Community 83 - "App Group group.com.finanzapp.app"
Cohesion: 1.00
Nodes (3): App Group group.com.finanzapp.app, FinanzApp (iOS App Target), FinanzAppWidget (WidgetKit App Extension)

### Community 91 - "View"
Cohesion: 0.33
Nodes (5): AppLogo, .body, View, Color, Double

## Knowledge Gaps
- **127 isolated node(s):** `.dbPath`, `AppIntents`, `.parameterSummary`, `.isIncome`, `.displayColor` (+122 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `L` connect `L` to `AppLanguage`, `HomeView`, `CategoryEntity`, `SettingsView.swift`, `String`, `Theme.swift`, `AddTransactionView`, `.budgetCard`?**
  _High betweenness centrality (0.259) - this node is a cross-community bridge._
- **Why does `AppViewModel` connect `AppViewModel` to `SwiftUI`, `AppLanguage`, `HomeView`, `Foundation`, `StatisticsView`, `Gamification`, `MainTabView`, `SettingsView.swift`, `Theme.swift`, `SettingsView`, `RecurringRow`, `GlassView`, `AddTransactionView`?**
  _High betweenness centrality (0.244) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `SectionCard`, `SwiftUI`, `HomeView`, `FlowChip`, `Widgets.swift`, `StatisticsView`, `GapDonutChart`, `SectionLabel`, `MainTabView`, `SettingsView.swift`, `Theme.swift`, `SettingsView`, `EmptyState`, `ConfirmDialog`, `StatsWidgetView`, `RecurringRow`, `GlassView`, `AddTransactionView`?**
  _High betweenness centrality (0.239) - this node is a cross-community bridge._
- **What connects `.dbPath`, `AppIntents`, `.parameterSummary` to the rest of the system?**
  _127 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `L` be split into smaller, more focused modules?**
  _Cohesion score 0.027583527583527584 - nodes in this community are weakly interconnected._
- **Should `DatabaseManager` be split into smaller, more focused modules?**
  _Cohesion score 0.11436170212765957 - nodes in this community are weakly interconnected._
- **Should `HomeView` be split into smaller, more focused modules?**
  _Cohesion score 0.08870967741935484 - nodes in this community are weakly interconnected._